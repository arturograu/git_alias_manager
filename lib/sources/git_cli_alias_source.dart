import 'dart:io';

import 'package:git_alias_manager/models/alias.dart';
import 'package:git_alias_manager/sources/git_alias_source.dart';

class GitCliAliasSource implements GitAliasSource {
  @override
  Future<void> addAlias(String name, String command) async {
    final result = await Process.run('git', [
      'config',
      '--global',
      'alias.$name',
      command,
    ]);

    if (result.exitCode != 0) {
      throw Exception('Failed to add alias: ${result.stderr}');
    }
  }

  @override
  Future<List<GitAlias>> getAliases() async {
    final result = await Process.run('git', [
      'config',
      '--global',
      '--get-regexp',
      '^alias\\.',
    ]);

    if (result.exitCode != 0) {
      throw Exception('Failed to get aliases: ${result.stderr}');
    }

    final lines = result.stdout.toString().split('\n');
    return lines.where((line) => line.trim().isNotEmpty).map((line) {
      final parts = line.trim().split(RegExp(r'\s+'));
      final name = parts[0].replaceFirst('alias.', '');
      final command = parts.sublist(1).join(' ');
      return GitAlias(name: name, command: command);
    }).toList();
  }

  @override
  Future<void> deleteAlias(String name) async {
    final result = await Process.run('git', [
      'config',
      '--global',
      '--unset',
      'alias.$name',
    ]);
    if (result.exitCode != 0) {
      throw Exception('Failed to delete alias: ${result.stderr}');
    }
  }
}
