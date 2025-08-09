import 'package:alias_manager/sources/alias_source.dart';
import 'package:alias_manager/view/alias_type_selector.dart';
import 'package:flutter/material.dart';

class AliasList extends StatelessWidget {
  const AliasList({
    super.key,
    required this.aliases,
    required this.selectedType,
    required this.onDeleteAlias,
  });

  final List<Alias> aliases;
  final AliasType selectedType;
  final ValueChanged<String> onDeleteAlias;

  @override
  Widget build(BuildContext context) {
    return aliases.isEmpty
        ? Text(
            'No ${selectedType.isShell ? 'shell' : 'git'} aliases found',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        : ListView.separated(
            itemCount: aliases.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final alias = aliases[index];
              return ListTile(
                title: Text(alias.name),
                subtitle: Text(alias.command),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  // TODO: Add provider so we can call the `GitAliasSource` methods
                  // directly without needing to pass it around.
                  // This will also allow us to split the UI in a cleaner way.
                  onPressed: () => onDeleteAlias(alias.name),
                ),
              );
            },
          );
  }
}
