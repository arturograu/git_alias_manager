import 'dart:io';

import 'package:git_alias_manager/models/alias.dart';

class GitConfigService {
  Future<void> addAlias(String name, String command) async {
    await Process.run('git', ['config', '--global', 'alias.$name', command]);
  }

  Future<List<GitAlias>> getAliases() async {
    final result = await Process.run('git', [
      'config',
      '--global',
      '--get-regexp',
      '^alias\\.',
    ]);
    if (result.exitCode != 0) return [];

    final lines = result.stdout.toString().split('\n');
    return lines.where((line) => line.trim().isNotEmpty).map((line) {
      final parts = line.trim().split(RegExp(r'\s+'));
      final name = parts[0].replaceFirst('alias.', '');
      final command = parts.sublist(1).join(' ');
      return GitAlias(name: name, command: command);
    }).toList();
  }

  Future<void> deleteAlias(String name) async {
    await Process.run('git', ['config', '--global', '--unset', 'alias.$name']);
  }
}
