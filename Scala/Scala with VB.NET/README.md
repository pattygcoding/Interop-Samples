# Scala with VB / VB.NET

Scala passes the numbers as command-line arguments to a VB.NET console app and
reads the average back from its standard output.

| | |
|---|---|
| **Host language** | Scala 3 |
| **Guest language** | VB.NET |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.scala`, `Program.vb`, `AverageCalculator.vbproj` |

## Prerequisites

- **[Scala CLI](https://scala-cli.virtuslab.org/)** (`scala`), used here as a
  single-command Scala runner. A plain Scala 3 installation works too.
- **.NET SDK** 8.0 or newer (`dotnet`), which includes the VB compiler

## Build & run

```bash
scala run main.scala                 # uses the built-in default data set
scala run main.scala -- 1 2 3 4
scala run main.scala -- -5 5 10
```

The .NET project is built automatically the first time it runs. Run the sample
from this directory: Scala passes `.` as the project path.

You can also exercise the VB side on its own:

```bash
dotnet run --project . -- 10 20 30     # -> 20
```

## Expected output

```text
$ scala run main.scala
The average of 5 value(s) is: 30.00

$ scala run main.scala -- 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.scala` builds the command with `scala.sys.process`, using `--` to separate
`dotnet`'s own options from the arguments destined for the application:

```scala
val command =
  Seq("dotnet", "run", "--project", ".", "-v", "quiet", "--") ++ numbers.map(render)
val exitCode = command.!(logger)
```

A `ProcessLogger` captures stdout and stderr separately, so a non-zero exit code
can be reported together with whatever the .NET side wrote.

`Program.vb` is a `Module` with `Function Main(args As String()) As Integer`. It
parses each argument with `Double.TryParse` using
`NumberStyles.Float`/`CultureInfo.InvariantCulture` and writes the mean with an
invariant format string, returning 1 for bad input.

> `dotnet run` has no `--nologo` option — passing it forwards the flag to the
> application. `-v quiet` is the supported way to silence the build.
