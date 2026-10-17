# Scala with Julia

Scala passes the numbers as command-line arguments to a Julia program and reads
the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Scala 3 |
| **Guest language** | Julia |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.scala`, `average_calculator.jl` |

## Prerequisites

- **[Scala CLI](https://scala-cli.virtuslab.org/)** (`scala`), used here as a
  single-command Scala runner. A plain Scala 3 installation works too.
- **Julia** 1.6 or newer (`julia`) on your `PATH`

## Build & run

There is nothing to compile ahead of time — Scala CLI builds and runs the script:

```bash
scala run main.scala                 # uses the built-in default data set
scala run main.scala -- 1 2 3 4
scala run main.scala -- -5 5 10
```

The `--` separates Scala CLI's own options from the program's arguments.

You can also exercise the Julia side on its own:

```bash
julia average_calculator.jl 10 20 30     # -> 20.00
```

## Expected output

```text
$ scala run main.scala
The average of 5 value(s) is: 30.00

$ scala run main.scala -- 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.scala` builds the command with `scala.sys.process` and captures both streams
separately:

```scala
val command = Seq("julia", "average_calculator.jl") ++ numbers.map(render)

val out = new StringBuilder
val err = new StringBuilder
val logger = ProcessLogger(line => out.append(line).append('\n'), line => err.append(line).append('\n'))

val exitCode = command.!(logger)
```

A `ProcessLogger` keeps stdout and stderr apart, so a non-zero exit code can be
reported together with whatever the Julia side wrote. The result is formatted with
`String.format` and `Locale.ROOT`, and `render` drops the trailing `.0` from whole
numbers so the command line looks natural.

`average_calculator.jl` parses each argument with `tryparse(Float64, ...)` and
prints the mean through `@printf("%.2f")`, reporting bad input on stderr with exit
status 1.
