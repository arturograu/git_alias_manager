import 'package:flutter/material.dart';
import 'package:git_alias_manager/models/alias.dart';
import 'package:hux/hux.dart';

class AliasListScreen extends StatefulWidget {
  const AliasListScreen({super.key});

  @override
  State<AliasListScreen> createState() => _AliasListScreenState();
}

class _AliasListScreenState extends State<AliasListScreen> {
  final _nameController = TextEditingController();
  final _commandController = TextEditingController();
  final List<GitAlias> _aliases = [];

  void _addAlias() {
    final name = _nameController.text.trim();
    final command = _commandController.text.trim();

    if (name.isEmpty || command.isEmpty) return;

    setState(() {
      _aliases.add(GitAlias(name: name, command: command));
      _nameController.clear();
      _commandController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Git Alias Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HuxTextField(
              controller: _nameController,
              label: 'Alias name',
              hint: 'e.g. lg',
            ),
            HuxTextField(
              controller: _commandController,
              label: 'Git command',
              hint: 'e.g. log --oneline',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: HuxButton(onPressed: _addAlias, child: Text('Add')),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _aliases.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final alias = _aliases[index];
                  return ListTile(
                    title: Text(alias.name),
                    subtitle: Text(alias.command),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _aliases.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
