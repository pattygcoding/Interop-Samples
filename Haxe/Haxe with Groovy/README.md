# Haxe with Groovy

Haxe — compiled to Neko bytecode — passes the numbers as command-line arguments
to a Groovy script and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Haxe (Neko target) |
| **Guest language** | Groovy |
| **Bridge** | Child process + argv/stdout |
| **Files** | `Main.hx`, `average_calculator.groovy` |

## Prerequisites

- **Haxe** 4.0 or newer, plus **Neko** (`neko`) — both ship in the standard Haxe
  distribution
- **Groovy** 4 or newer, with `GROOVY_HOME` set
- A **JDK** (`java`)

## Build & run

```bash
haxe -cp . -main Main -neko main.n
neko main.n                 # uses the built-in default data set
neko main.n 1 2 3 4
neko main.n -5 5 10
```

You can also exercise the Groovy side on its own:

```bash
groovy average_calculator.groovy 10 20 30     # -> 20.00
```

## Expected output

```text
$ neko main.n
The average of 5 value(s) is: 30.00

$ neko main.n 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`Main.hx` is compiled to **Neko bytecode**, which gives it a real
`sys.io.Process`. The helper is started through `java` rather than through the
`groovy` command:

```haxe
var arguments = ["-cp", classpath(), "groovy.ui.GroovyMain", SCRIPT];
var process = new sys.io.Process("java", arguments);
```

That indirection is deliberate. On Windows `groovy` is a `.cmd` shim, and Neko's
`sys.io.Process` cannot spawn batch files — routing through `cmd /c` does not work
either, because the shim keeps the pipe open and the read never returns. Starting
the Groovy interpreter on the JVM directly sidesteps both problems and works
identically on every platform.

Both streams are drained before `exitCode()` is consulted, which avoids the
classic pipe-buffer deadlock, and the result is validated with `Std.parseFloat`
before use.

`average_calculator.groovy` converts each argument with `as Double`, sums the
list and prints `String.format(Locale.ROOT, '%.2f', ...)`.
