import 'package:equatable/equatable.dart';

class GitAlias extends Equatable {
  final String name;
  final String command;

  const GitAlias({required this.name, required this.command});

  @override
  List<Object?> get props => [name, command];
}

abstract class GitAliasSource {
  Future<void> addAlias(GitAlias alias);
  Future<List<GitAlias>> getAliases();
  Future<void> deleteAlias(String name);
}
