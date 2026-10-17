import 'dart:io';

/// Interop sample: Dart driving a compiled Haskell program.
///
/// Dart passes the numbers as command-line arguments to the Haskell helper and
/// reads the average it prints back from stdout.
///
/// See README.md for build and run instructions.
Future<void> main(List<String> args) async {
  final scriptDirectory = File.fromUri(Platform.script).parent.path;
  final executable =
      '$scriptDirectory/${Platform.isWindows ? 'average_calculator.exe' : 'average_calculator'}';

  final numbers = args.isEmpty ? <double>[10, 20, 30, 40, 50] : _parseNumbers(args);

  if (numbers.isEmpty) {
    stderr.writeln('error: no numbers to average');
    exitCode = 1;
    return;
  }

  final result = await Process.run(
    executable,
    numbers.map((value) => value.toString()).toList(),
  );

  if (result.exitCode != 0) {
    final detail = (result.stderr as String).trim();
    stderr.writeln(
      'error: ${detail.isEmpty ? 'the Haskell helper exited with code ${result.exitCode}' : detail}',
    );
    exitCode = 1;
    return;
  }

  final average = double.tryParse((result.stdout as String).trim());

  if (average == null) {
    stderr.writeln('error: unexpected output from the Haskell helper: ${result.stdout}');
    exitCode = 1;
    return;
  }

  stdout.writeln('The average of ${numbers.length} value(s) is: ${average.toStringAsFixed(2)}');
}

/// Convert command-line tokens to doubles, skipping anything invalid.
List<double> _parseNumbers(List<String> tokens) {
  final numbers = <double>[];

  for (final token in tokens) {
    final value = double.tryParse(token);

    if (value == null) {
      stderr.writeln("warning: skipping non-numeric argument '$token'");
    } else {
      numbers.add(value);
    }
  }

  return numbers;
}
