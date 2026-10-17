# Dart with Python

Dart passes the numbers as command-line arguments to a Python program and reads
the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Dart |
| **Guest language** | Python 3 |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.dart`, `average_calculator.py` |

## Prerequisites

- The **Dart SDK** 3.0 or newer (`dart`)
- **Python 3.9+** — as `python3` on Linux and macOS, as `python` on Windows

## Build & run

There is nothing to compile:

```bash
dart run main.dart                 # uses the built-in default data set
dart run main.dart 1 2 3 4
dart run main.dart -5 5 10
```

You can also exercise the Python side on its own:

```bash
python3 average_calculator.py 10 20 30     # -> 20.00
```

## Expected output

```text
$ dart run main.dart
The average of 5 value(s) is: 30.00

$ dart run main.dart 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.dart` uses `Process.run` with an argument vector, so no shell is involved
and the helper's stderr is returned to Dart rather than escaping to the terminal:

```dart
final result = await Process.run(
  interpreter,
  ['average_calculator.py', ...numbers.map((value) => value.toString())],
);
```

The interpreter name is platform-dependent — `python3` on Linux and macOS,
`python` on Windows — and `_parseNumbers` vets every token with
`double.tryParse`, warning about and dropping anything unparsable.

`average_calculator.py` reads `sys.argv`, converts each argument with `float()`,
and prints `sum(...) / len(...)` through an f-string with `:.2f`.
