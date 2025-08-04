import 'package:flutter/material.dart';
import 'package:git_alias_manager/sources/alias_source.dart';
import 'package:git_alias_manager/sources/git_alias_source.dart';
import 'package:git_alias_manager/sources/shell_alias_source.dart';
import 'package:git_alias_manager/view/alias_form.dart';
import 'package:git_alias_manager/view/alias_list.dart';
import 'package:git_alias_manager/view/alias_type_selector.dart';

class AliasListScreen extends StatefulWidget {
  const AliasListScreen({
    super.key,
    required this.shellAliasSource,
    required this.gitAliasSource,
  });

  final ShellAliasSource shellAliasSource;
  final GitAliasSource gitAliasSource;

  @override
  State<AliasListScreen> createState() => _AliasListScreenState();
}

class _AliasListScreenState extends State<AliasListScreen> {
  final _nameController = TextEditingController();
  final _commandController = TextEditingController();

  bool _isLoading = false;
  List<Alias> _aliases = [];
  AliasType _selectedType = AliasType.shell;
  AliasSource get _currentSource =>
      _selectedType.isShell ? widget.shellAliasSource : widget.gitAliasSource;

  Future<void> _loadAliases() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final aliases = await _currentSource.getAliases();
      setState(() {
        _aliases = aliases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load aliases: $e')));
    }
  }

  Future<void> _addAlias() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final command = _commandController.text.trim();

    if (name.isEmpty || command.isEmpty) return;

    final alias = Alias(name: name, command: command);

    try {
      setState(() {
        _isLoading = true;
      });
      await _currentSource.addAlias(alias);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save alias: $e')));
    }

    setState(() {
      _aliases.add(Alias(name: name, command: command));
      _nameController.clear();
      _commandController.clear();
    });
  }

  Future<void> _deleteAlias(String name) async {
    await _currentSource.deleteAlias(name);
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AliasTypeSelector(
              selectedType: _selectedType,
              onChanged: (type) async {
                setState(() {
                  _selectedType = type;
                });
                await _loadAliases();
              },
            ),
            const SizedBox(height: 20),
            AliasForm(
              nameHint: 'e.g. ${_selectedType.isShell ? 'll' : 'lg'}',
              commandHint:
                  'e.g. ${_selectedType.isShell ? 'ls -alF' : 'log --oneline'}',
              nameController: _nameController,
              commandController: _commandController,
              onAddAlias: _addAlias,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AliasList(
                      aliases: _aliases,
                      selectedType: _selectedType,
                      onDeleteAlias: _deleteAlias,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
