# Dart with Haskell

Dart passes the numbers as command-line arguments to a compiled Haskell program
and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Dart |
| **Guest language** | Haskell |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.dart`, `average_calculator.hs` |

## Prerequisites

- The **Dart SDK** 3.0 or newer (`dart`)
- **GHC** 8.10 or newer (`ghc`)

## Build & run

Compile the helper first:

```bash
ghc -O2 -o average_calculator average_calculator.hs
dart main.dart                 # uses the built-in default data set
dart main.dart 1 2 3 4
dart main.dart -5 5 10
```

On Windows the helper is `average_calculator.exe`; `main.dart` detects the
platform and looks for the right name. It resolves the helper from
`Platform.script`, so the sample works from any working directory.

You can also exercise the Haskell side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ dart main.dart
The average of 5 value(s) is: 30.00

$ dart main.dart 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.dart` runs the helper with `Process.run`, which collects stdout, stderr and
the exit code in one call:

```dart
final result = await Process.run(executable, numbers.map((value) => value.toString()).toList());
```

The exit code is checked before the output is parsed, so a failing helper is
reported rather than turned into a bogus average.

`average_calculator.hs` parses its arguments with `reads`, prints the mean using
`printf "%.2f"`, and writes errors to stderr with exit status 1.
