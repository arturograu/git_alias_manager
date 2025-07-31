import 'dart:io';

class CommandResult {
  final int exitCode;
  final String stdout;
  final String stderr;

  CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });
}

class SystemCommandRunner {
  Future<CommandResult> run(String executable, List<String> arguments) async {
    final result = await Process.run(executable, arguments);
    return CommandResult(
      exitCode: result.exitCode,
      stdout: result.stdout.toString(),
      stderr: result.stderr.toString(),
    );
  }
}
