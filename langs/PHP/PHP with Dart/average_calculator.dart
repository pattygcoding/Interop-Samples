import 'dart:io';

/// Interop sample: prints the arithmetic mean of the numbers given on the
/// command line.
///
/// Invoked by main.php; see README.md for build and run instructions.
void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('error: no numbers supplied');
    exitCode = 1;
    return;
  }

  final numbers = <double>[];

  for (final token in args) {
    final value = double.tryParse(token);

    if (value == null) {
      stderr.writeln("error: '$token' is not a number");
      exitCode = 1;
      return;
    }

    numbers.add(value);
  }

  final sum = numbers.fold<double>(0.0, (total, value) => total + value);

  stdout.writeln((sum / numbers.length).toStringAsFixed(2));
}
