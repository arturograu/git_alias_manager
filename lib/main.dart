import 'package:flutter/material.dart';
import 'package:git_alias_manager/sources/git_alias_source.dart';
import 'package:git_alias_manager/view/alias_list_screen.dart';
import 'package:hux/hux.dart';

void main() {
  final gitAliasSource = GitAliasSource();
  runApp(MainApp(gitAliasSource: gitAliasSource));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.gitAliasSource});

  final GitAliasSource gitAliasSource;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git Alias Manager',
      theme: HuxTheme.lightTheme,
      darkTheme: HuxTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AliasListScreen(gitAliasSource: gitAliasSource),
    );
  }
}
