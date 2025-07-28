import 'package:flutter/material.dart';
import 'package:git_alias_manager/view/alias_list_screen.dart';
import 'package:hux/hux.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git Alias Manager',
      theme: HuxTheme.lightTheme,
      darkTheme: HuxTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AliasListScreen(),
    );
  }
}
