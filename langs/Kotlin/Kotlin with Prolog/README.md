# Kotlin with Prolog

Kotlin passes the numbers as command-line arguments to a SWI-Prolog program and
reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Kotlin |
| **Guest language** | Prolog (SWI-Prolog) |
| **Bridge** | Child process + argv/stdout |
| **Files** | `Main.kt`, `average_calculator.pl` |

## Prerequisites

- **JDK 11+** (`java`)
- The **Kotlin command-line compiler** (`kotlinc`), 1.9 or newer
- **SWI-Prolog** (`swipl`) on your `PATH`

## Build & run

```bash
kotlinc Main.kt -include-runtime -d Main.jar
java -jar Main.jar                 # uses the built-in default data set
java -jar Main.jar 1 2 3 4
java -jar Main.jar -5 5 10
```

`-include-runtime` bundles the Kotlin standard library into the jar, so the plain
`java` launcher is enough to run it.

You can also exercise the Prolog side on its own:

```bash
swipl -q -f average_calculator.pl -g main -- 10 20 30     # -> 20.00
```

## Expected output

```text
$ java -jar Main.jar
The average of 5 value(s) is: 30.00

$ java -jar Main.jar 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`Main.kt` starts the helper with `ProcessBuilder`, passing each argument
separately so nothing goes through a shell:

```kotlin
val command = mutableListOf("swipl", "-q", "-f", "average_calculator.pl", "-g", "main", "--")
numbers.mapTo(command) { it.toString() }

val process = ProcessBuilder(command).start()
```

Both streams are read before `waitFor()`, and the exit code is checked before the
output is trusted. The result is formatted with `String.format` and `Locale.ROOT`
so the decimal separator does not depend on the host locale.

`average_calculator.pl` parses its arguments with `atom_number/2`, computes
`sum_list / length` and prints the result with `format('~2f')`. Its `main`
predicate halts explicitly on both the success and the failure path — without
that, `swipl` would drop into its interactive top level and wait for input.
