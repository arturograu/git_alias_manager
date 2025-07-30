import 'package:flutter/material.dart';
import 'package:git_alias_manager/models/alias.dart';
import 'package:git_alias_manager/services/git_config_service.dart';
import 'package:hux/hux.dart';

class AliasListScreen extends StatefulWidget {
  const AliasListScreen({super.key});

  @override
  State<AliasListScreen> createState() => _AliasListScreenState();
}

class _AliasListScreenState extends State<AliasListScreen> {
  final _gitService = GitConfigService();
  final _nameController = TextEditingController();
  final _commandController = TextEditingController();
  List<GitAlias> _aliases = [];

  Future<void> _loadAliases() async {
    try {
      final aliases = await _gitService.getAliases();
      setState(() => _aliases = aliases);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load aliases: $e')));
      }
    }
  }

  Future<void> _addAlias() async {
    final name = _nameController.text.trim();
    final command = _commandController.text.trim();

    if (name.isEmpty || command.isEmpty) return;

    try {
      await _gitService.addAlias(name, command);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save alias: $e')));
      }
    }

    setState(() {
      _aliases.add(GitAlias(name: name, command: command));
      _nameController.clear();
      _commandController.clear();
    });
  }

  Future<void> _deleteAlias(String name) async {
    await _gitService.deleteAlias(name);
    setState(() {
      _aliases.removeWhere((alias) => alias.name == name);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAliases();
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
            const SizedBox(height: 8),
            HuxTextField(
              controller: _commandController,
              label: 'Git command',
              hint: 'e.g. log --oneline',
              onSubmitted: (_) => _addAlias(),
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
                      onPressed: () => _deleteAlias(alias.name),
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
