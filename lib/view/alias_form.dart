import 'package:flutter/widgets.dart';
import 'package:hux/hux.dart';

class AliasForm extends StatelessWidget {
  const AliasForm({
    super.key,
    required this.nameHint,
    required this.commandHint,
    required this.nameController,
    required this.commandController,
    required this.onAddAlias,
  });

  final String nameHint;
  final String commandHint;
  final TextEditingController nameController;
  final TextEditingController commandController;
  final VoidCallback onAddAlias;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: HuxTextField(
            controller: nameController,
            label: 'Alias name',
            hint: nameHint,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: HuxTextField(
            controller: commandController,
            label: 'Command',
            hint: commandHint,
            onSubmitted: (_) => onAddAlias(),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 22),
          child: SizedBox(
            height: 46,
            child: HuxButton(
              key: Key('add_alias_button'),
              onPressed: onAddAlias,
              child: Text('Add'),
            ),
          ),
        ),
      ],
    );
  }
}
