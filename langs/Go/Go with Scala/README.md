# Go with Scala

Go passes the numbers as command-line arguments to a Scala program and reads the
average it prints back from stdout.

| | |
|---|---|
| **Host language** | Go |
| **Guest language** | Scala 3 |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.go`, `AverageCalculator.scala` |

## Prerequisites

- **Go** 1.21 or newer
- **[Scala CLI](https://scala-cli.virtuslab.org/)** (`scala`) with a JDK — it
  compiles and caches the Scala helper on first use

## Build & run

```bash
go build -o average main.go          # Windows: go build -o average.exe main.go

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

Go writes the name you give it verbatim, so on Windows the `-o` value needs the
`.exe` suffix explicitly; run the program as `.\average.exe` there.

You can also exercise the Scala side on its own:

```bash
scala run AverageCalculator.scala -- 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.go` builds the command with `exec.Command` and passes the numbers as a
separate argument list:

```go
arguments := []string{"run", "AverageCalculator.scala", "--"}
...
command := exec.Command("scala", arguments...)
command.Stderr = os.Stderr
output, err := command.Output()
```

The `--` tells Scala CLI where its own options stop and the program's arguments
begin. Wiring the child's stderr straight to Go's own `os.Stderr` keeps warnings
visible while `Output()` captures only the number.

The first run is slow because Scala CLI compiles the helper, and it emits
`Compiling project...` on stderr; later runs use the build cache. Every token is
vetted with `strconv.ParseFloat`, so bad input is reported and skipped rather
than silently becoming a zero.
