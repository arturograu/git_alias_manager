import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_alias_manager/sources/git_alias_source.dart';
import 'package:git_alias_manager/view/alias_list_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockGitAliasSource extends Mock implements GitAliasSource {}

void main() {
  group('AliasListScreen', () {
    late GitAliasSource gitAliasSource;

    setUpAll(() {
      registerFallbackValue(GitAlias(name: '', command: ''));
    });

    setUp(() {
      gitAliasSource = MockGitAliasSource();
      when(() => gitAliasSource.getAliases()).thenAnswer((_) async => []);
    });

    group('renders', () {
      testWidgets('empty state', (tester) async {
        when(() => gitAliasSource.getAliases()).thenAnswer((_) async => []);

        await tester.pumpWidget(
          MaterialApp(home: AliasListScreen(gitAliasSource: gitAliasSource)),
        );

        expect(find.byType(AliasListScreen), findsOneWidget);
        expect(find.text('No aliases found'), findsOneWidget);
      });

      testWidgets('list of aliases', (tester) async {
        when(() => gitAliasSource.getAliases()).thenAnswer(
          (_) async => [
            GitAlias(name: 'alias1', command: 'command1'),
            GitAlias(name: 'alias2', command: 'command2'),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(home: AliasListScreen(gitAliasSource: gitAliasSource)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AliasListScreen), findsOneWidget);
        expect(find.text('alias1'), findsOneWidget);
        expect(find.text('command1'), findsOneWidget);
        expect(find.text('alias2'), findsOneWidget);
        expect(find.text('command2'), findsOneWidget);
      });
    });

    group('calls', () {
      testWidgets('getAliases on init', (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: AliasListScreen(gitAliasSource: gitAliasSource)),
        );

        verify(() => gitAliasSource.getAliases()).called(1);
      });

      testWidgets('addAlias when add button is pressed', (tester) async {
        final newAlias = GitAlias(name: 'newAlias', command: 'newCommand');
        when(
          () => gitAliasSource.addAlias(any(that: isA<GitAlias>())),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(
          MaterialApp(home: AliasListScreen(gitAliasSource: gitAliasSource)),
        );

        await tester.enterText(find.byType(TextField).at(0), newAlias.name);
        await tester.enterText(find.byType(TextField).at(1), newAlias.command);
        await tester.tap(find.byKey(Key('add_alias_button')));
        await tester.pumpAndSettle();

        verify(() => gitAliasSource.addAlias(newAlias)).called(1);
      });

      testWidgets('deleteAlias when delete button is pressed', (tester) async {
        when(() => gitAliasSource.getAliases()).thenAnswer(
          (_) async => [GitAlias(name: 'aliasToDelete', command: 'command')],
        );
        when(() => gitAliasSource.deleteAlias(any())).thenAnswer((_) async {});

        await tester.pumpWidget(
          MaterialApp(home: AliasListScreen(gitAliasSource: gitAliasSource)),
        );
        await tester.pumpAndSettle();

        expect(find.text('aliasToDelete'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        verify(() => gitAliasSource.deleteAlias('aliasToDelete')).called(1);
      });
    });
  });
}
