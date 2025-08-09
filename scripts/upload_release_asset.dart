import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final env = Platform.environment;

  final repo = _req(env['GITHUB_REPOSITORY'], 'GITHUB_REPOSITORY');
  final token = env['GITHUB_PAT']?.trim().isNotEmpty == true
      ? env['GITHUB_PAT']!
      : _req(env['PERSONAL_ACCESS_TOKEN'], 'PERSONAL_ACCESS_TOKEN');
  final appName = _req(env['APP_NAME'], 'APP_NAME');

  // Zip we expect to upload (created earlier in the workflow)
  final filePath = '$appName.zip';
  final file = File(filePath);
  if (!file.existsSync()) {
    _fail(
      'Zip not found at $filePath. CWD contents:\n${Directory.current.listSync().join('\n')}',
    );
  }

  // Tag name: prefer CM_TAG; fallback to latest tagged version
  var tag = env['CM_TAG'];
  tag = (tag == null || tag.isEmpty) ? await _latestTag() : tag;

  if (tag == null || tag.isEmpty) {
    _fail('No tag specified. Set CM_TAG or ensure a git tag exists.');
  }

  _log('Using tag: $tag');

  final api = 'https://api.github.com/repos/$repo';
  final http = HttpClient();

  // Get or create release
  final releaseId =
      await _getReleaseId(http, api, token, tag) ??
      await _createRelease(http, api, token, tag);

  if (releaseId == null) {
    _fail('Could not resolve or create a release for tag $tag.');
  }
  _log('Release id: $releaseId');

  // If asset with same name exists, delete it to avoid 422
  await _deleteAssetIfExists(
    http,
    api,
    token,
    releaseId,
    file.uri.pathSegments.last,
  );

  // Upload
  await _uploadAsset(http, repo, token, releaseId, file);

  _log('✅ Upload complete.');
  http.close(force: true);
}

String _req(String? v, String name) {
  if (v == null || v.trim().isEmpty) {
    _fail('Missing required env var: $name');
  }
  return v;
}

void _log(String msg) => stdout.writeln(msg);
Never _fail(String msg) {
  stderr.writeln('ERROR: $msg');
  exit(1);
}

Future<String?> _latestTag() async {
  try {
    final res = await Process.run('git', [
      "-c",
      "versionsort.suffix=-",
      "tag",
      "--list",
      "v*",
      "--sort=-v:refname",
    ]);
    if (res.exitCode != 0) return null;
    final line = res.stdout
        .toString()
        .split('\n')
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    return line.isEmpty ? null : line.trim();
  } catch (_) {
    return null;
  }
}

Future<int?> _getReleaseId(
  HttpClient http,
  String api,
  String token,
  String tag,
) async {
  final uri = Uri.parse('$api/releases/tags/$tag');
  final req = await http.getUrl(uri);
  req.headers
    ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
    ..set(HttpHeaders.authorizationHeader, 'token $token');
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  if (res.statusCode == 200) {
    return jsonDecode(body)['id'] as int?;
  }
  if (res.statusCode == 404) return null; // release not found
  _fail('Fetching release failed (${res.statusCode}): $body');
}

Future<int?> _createRelease(
  HttpClient http,
  String api,
  String token,
  String tag,
) async {
  _log('Creating release for $tag…');
  final uri = Uri.parse('$api/releases');
  final req = await http.postUrl(uri);
  req.headers
    ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
    ..set(HttpHeaders.authorizationHeader, 'token $token')
    ..set(HttpHeaders.contentTypeHeader, 'application/json');
  req.write(
    jsonEncode({
      'tag_name': tag,
      'name': tag,
      'draft': false,
      'prerelease': false,
    }),
  );
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  if (res.statusCode == 201) {
    return jsonDecode(body)['id'] as int?;
  }
  _fail('Creating release failed (${res.statusCode}): $body');
}

Future<void> _deleteAssetIfExists(
  HttpClient http,
  String api,
  String token,
  int releaseId,
  String assetName,
) async {
  final listUri = Uri.parse('$api/releases/$releaseId/assets');
  final listReq = await http.getUrl(listUri);
  listReq.headers
    ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
    ..set(HttpHeaders.authorizationHeader, 'token $token');
  final listRes = await listReq.close();
  final listBody = await listRes.transform(utf8.decoder).join();
  if (listRes.statusCode != 200) {
    _fail('Listing assets failed (${listRes.statusCode}): $listBody');
  }
  final assets = (jsonDecode(listBody) as List).cast<Map<String, dynamic>>();
  final existing = assets.firstWhere(
    (a) => a['name'] == assetName,
    orElse: () => {},
  );
  final id = existing['id'];
  if (id != null) {
    _log('Deleting existing asset ($assetName, id: $id)…');
    final delReq = await http.deleteUrl(Uri.parse('$api/releases/assets/$id'));
    delReq.headers.set(HttpHeaders.authorizationHeader, 'token $token');
    final delRes = await delReq.close();
    if (delRes.statusCode != 204) {
      final b = await delRes.transform(utf8.decoder).join();
      _fail('Deleting asset failed (${delRes.statusCode}): $b');
    }
  }
}

Future<void> _uploadAsset(
  HttpClient http,
  String repo,
  String token,
  int releaseId,
  File file,
) async {
  _log('Uploading ${file.path}…');
  final uploadUri = Uri.parse(
    'https://uploads.github.com/repos/$repo/releases/$releaseId/assets?name=${Uri.encodeQueryComponent(file.uri.pathSegments.last)}',
  );
  final req = await http.postUrl(uploadUri);
  req.headers
    ..set(HttpHeaders.authorizationHeader, 'token $token')
    ..set(HttpHeaders.contentTypeHeader, 'application/zip');
  await req.addStream(file.openRead());
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  if (res.statusCode != 201) {
    _fail('Uploading asset failed (${res.statusCode}): $body');
  }
  final url = jsonDecode(body)['browser_download_url'];
  _log('Uploaded: $url');
}
