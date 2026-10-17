# Go with Prolog

Go passes the numbers as command-line arguments to a SWI-Prolog program and reads
the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Go |
| **Guest language** | SWI-Prolog |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.go`, `average_calculator.pl` |

## Prerequisites

- **Go** 1.21 or newer
- **SWI-Prolog** (`swipl`) on your `PATH`

## Build & run

```bash
go build -o average main.go          # Windows: go build -o average.exe main.go

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

Go writes the name you give it verbatim, so on Windows the `-o` value needs the
`.exe` suffix explicitly; run the program as `.\average.exe` there.

You can also exercise the Prolog side on its own:

```bash
swipl -q -f average_calculator.pl -g main -- 10 20 30     # -> 20.00
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
arguments := []string{"-q", "-f", "average_calculator.pl", "-g", "main", "--"}
...
command := exec.Command("swipl", arguments...)
command.Stderr = os.Stderr
output, err := command.Output()
```

`-q` silences the banner, `-f` loads the program without the usual initialisation
file, and `-g main` runs the entry predicate. The `--` separator stops SWI-Prolog
from treating a negative number such as `-5` as one of its own options.

Wiring the child's stderr straight to Go's own `os.Stderr` keeps the helper's
diagnostics visible while `Output()` captures only the number.

`average_calculator.pl` parses its arguments with `atom_number/2`, computes
`sum_list / length` and prints the result with `format('~2f')`. Its `main`
predicate halts explicitly on both the success and the failure path — without
that, `swipl` would drop into its interactive top level and wait for input.
