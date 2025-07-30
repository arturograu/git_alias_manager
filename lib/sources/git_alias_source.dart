import 'package:git_alias_manager/models/alias.dart';

abstract class GitAliasSource {
  Future<void> addAlias(String name, String command);
  Future<List<GitAlias>> getAliases();
  Future<void> deleteAlias(String name);
}
