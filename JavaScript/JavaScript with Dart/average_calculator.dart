import 'dart:convert';
import 'dart:io';

/// Interop sample: reads a JSON array of numbers from standard input and writes
/// the arithmetic mean to standard output.
///
/// Invoked by `main.js`; see README.md for build and run instructions.
void main() {
  final input = stdin.readLineSync();

  if (input == null || input.trim().isEmpty) {
    stderr.writeln('error: expected a JSON array of numbers on stdin');
    exitCode = 1;
    return;
  }

  try {
    final decoded = jsonDecode(input);

    if (decoded is! List) {
      stderr.writeln('error: input must be a JSON array');
      exitCode = 1;
      return;
    }

    final numbers = decoded.map((value) => (value as num).toDouble()).toList();

    if (numbers.isEmpty) {
      stderr.writeln('error: the array is empty');
      exitCode = 1;
      return;
    }

    final sum = numbers.fold<double>(0.0, (total, value) => total + value);
    final average = sum / numbers.length;

    stdout.writeln(average);
  } on FormatException catch (error) {
    stderr.writeln('error: invalid JSON: ${error.message}');
    exitCode = 1;
  }
}

