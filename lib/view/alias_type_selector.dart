import 'package:flutter/material.dart';

enum AliasType {
  shell,
  git;

  bool get isShell => this == AliasType.shell;
  bool get isGit => this == AliasType.git;
}

class AliasTypeSelector extends StatelessWidget {
  const AliasTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final AliasType selectedType;
  final ValueChanged<AliasType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AliasType>(
      segments: const <ButtonSegment<AliasType>>[
        ButtonSegment<AliasType>(
          value: AliasType.shell,
          label: Text('Shell'),
          icon: Icon(Icons.terminal),
        ),
        ButtonSegment<AliasType>(
          value: AliasType.git,
          label: Text('Git'),
          icon: Icon(Icons.code),
        ),
      ],
      selected: {selectedType},
      onSelectionChanged: (Set<AliasType> newSelection) {
        onChanged(newSelection.first);
      },
    );
  }
}
