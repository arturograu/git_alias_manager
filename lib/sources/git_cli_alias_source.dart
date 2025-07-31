import 'package:git_alias_manager/shell/system_command_runner.dart';
import 'package:git_alias_manager/sources/git_alias_source.dart';

class GitCliAliasSource implements GitAliasSource {
  GitCliAliasSource({SystemCommandRunner? commandRunner})
    : _commandRunner = commandRunner ?? SystemCommandRunner();

  final SystemCommandRunner _commandRunner;

  // Should be bigger bigger than 1 since 0 is a valid exit code and 1 is used
  // for valid but empty content.
  bool _isInvalidExitCode(int exitCode) => exitCode > 1;

  (String, List<String>) _buildCommand(List<String> subcommand) {
    return ('git', ['config', '--global', ...subcommand]);
  }

  @override
  Future<void> addAlias(GitAlias alias) async {
    final (executable, arguments) = _buildCommand([
      'alias.${alias.name}',
      alias.command,
    ]);
    final result = await _commandRunner.run(executable, arguments);

    if (_isInvalidExitCode(result.exitCode)) {
      throw Exception('Failed to add alias: ${result.stderr}');
    }
  }

  @override
  Future<List<GitAlias>> getAliases() async {
    final (executable, arguments) = _buildCommand([
      '--get-regexp',
      '^alias\\.',
    ]);
    final result = await _commandRunner.run(executable, arguments);

    if (_isInvalidExitCode(result.exitCode)) {
      throw Exception('Failed to get aliases: ${result.stderr}');
    }

    final lines = result.stdout.toString().split('\n');
    return lines
        .where((line) => line.trim().isNotEmpty)
        .map(_getGitAliasFromLine)
        .toList();
  }

  GitAlias _getGitAliasFromLine(String line) {
    final parts = line.trim().split(' ').where((p) => p.isNotEmpty).toList();
    final name = parts[0].replaceFirst('alias.', '');
    final command = parts.sublist(1).join(' ');
    return GitAlias(name: name, command: command);
  }

  @override
  Future<void> deleteAlias(String name) async {
    final (executable, arguments) = _buildCommand(['--unset', 'alias.$name']);
    final result = await _commandRunner.run(executable, arguments);

    if (result.exitCode != 0) {
      throw Exception('Failed to delete alias: ${result.stderr}');
    }
  }
}
