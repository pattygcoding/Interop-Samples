# Groovy with Shell

Groovy passes the numbers as command-line arguments to a POSIX shell script and
reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Groovy |
| **Guest language** | Shell (POSIX `sh`) |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.groovy`, `average_calculator.sh` |

## Prerequisites

- **Groovy** 4 or newer with a JDK
- A POSIX shell. On Linux and macOS that is `/bin/sh`; on Windows use **Git Bash**
  or **MSYS2**.

## Build & run

There is nothing to compile:

```bash
groovy main.groovy                 # uses the built-in default data set
groovy main.groovy 1 2 3 4
groovy main.groovy -5 5 10
```

You can also exercise the shell side on its own:

```bash
sh average_calculator.sh 10 20 30     # -> 20.00
```

## Expected output

```text
$ groovy main.groovy
The average of 5 value(s) is: 30.00

$ groovy main.groovy 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.groovy` runs the helper through `ProcessBuilder` with an argument vector and
drains both streams, so the script's own diagnostics survive:

```groovy
def command = [interpreter, 'average_calculator.sh'] + numbers.collect { it.toString() }
def process = new ProcessBuilder(command).start()
...
process.consumeProcessOutput(output, errors)
```

Finding the interpreter takes some care. On Windows a bare `bash` is hijacked by
`System32\bash.exe` — the WSL relay, which fails when no distribution is
installed — because `CreateProcess` searches `System32` before `PATH`. `shell()`
therefore probes each candidate with `bash -c "exit 0"` and keeps the first one
that actually runs. `SHELL_INTERPRETER` overrides the search entirely.

`average_calculator.sh` rejects anything that is not a number, then pipes the
values into `awk`, since POSIX `sh` has no floating-point arithmetic of its own.
