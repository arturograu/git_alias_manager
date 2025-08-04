import 'dart:io';

import 'package:git_alias_manager/shell/system_command_runner.dart';
import 'package:git_alias_manager/sources/alias_source.dart';

class ShellAliasSource implements AliasSource {
  ShellAliasSource({SystemCommandRunner? commandRunner})
    : _commandRunner = commandRunner ?? SystemCommandRunner(),
      _shell = _detectShell(),
      _rcFile = _detectRcFile();

  final SystemCommandRunner _commandRunner;
  final String _shell;
  final String _rcFile;

  static String _detectShell() {
    final shell = Platform.environment['SHELL'] ?? '';
    if (shell.contains('zsh')) return 'zsh';
    return 'bash';
  }

  static String _detectRcFile() {
    final home = Platform.environment['HOME'] ?? '';
    final shell = Platform.environment['SHELL'] ?? '';
    if (shell.contains('zsh')) return '$home/.zshrc';
    return '$home/.bashrc';
  }

  (String, List<String>) _buildCommand(List<String> subcommand) {
    return (_shell, ['-c', ...subcommand]);
  }

  bool _isInvalidExitCode(int exitCode) => exitCode != 0;

  @override
  Future<void> addAlias(Alias alias) async {}

  @override
  Future<List<Alias>> getAliases() async {
    final (executable, arguments) = _buildCommand(['source $_rcFile && alias']);
    final result = await _commandRunner.run(executable, arguments);

    if (_isInvalidExitCode(result.exitCode)) {
      throw Exception('Failed to get aliases: ${result.stderr}');
    }

    final lines = result.stdout.toString().split('\n');
    return _mapLinesIntoAliases(lines);
  }

  List<Alias> _mapLinesIntoAliases(List<String> lines) {
    return lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
          // Matches: alias <name>='<command>'
          // (\S+) → Captures alias name (no spaces)
          // (.+?) → Captures alias command (lazy match until closing quote)
          // '?    → Optional single quote
          // ^/$   → Match entire line
          final aliasPattern = RegExp(r"alias\s+(\S+)='?(.+?)'?$");

          final match = aliasPattern.firstMatch(line.trim());
          if (match != null) {
            return Alias(name: match.group(1)!, command: match.group(2)!);
          }
          return null;
        })
        .whereType<Alias>()
        .toList();
  }

  @override
  Future<void> deleteAlias(String name) async {
    // Implementation for deleting a Bash alias
  }
}
