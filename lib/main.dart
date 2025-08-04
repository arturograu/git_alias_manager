import 'package:flutter/material.dart';
import 'package:git_alias_manager/sources/git_alias_source.dart';
import 'package:git_alias_manager/sources/shell_alias_source.dart';
import 'package:git_alias_manager/view/alias_list_screen.dart';
import 'package:hux/hux.dart';

void main() {
  runApp(
    MainApp(
      gitAliasSource: GitAliasSource(),
      shellAliasSource: ShellAliasSource(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.shellAliasSource,
    required this.gitAliasSource,
  });

  final GitAliasSource gitAliasSource;
  final ShellAliasSource shellAliasSource;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alias Manager',
      theme: HuxTheme.lightTheme,
      darkTheme: HuxTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AliasListScreen(
        shellAliasSource: shellAliasSource,
        gitAliasSource: gitAliasSource,
      ),
    );
  }
}
