class GitAlias {
  final String name;
  final String command;

  GitAlias({required this.name, required this.command});
}

abstract class GitAliasSource {
  Future<void> addAlias(GitAlias alias);
  Future<List<GitAlias>> getAliases();
  Future<void> deleteAlias(String name);
}
