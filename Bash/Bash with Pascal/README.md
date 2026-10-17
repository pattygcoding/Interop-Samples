# Bash with Pascal

Bash passes the numbers as command-line arguments to a compiled Free Pascal
program and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Bash |
| **Guest language** | Pascal (Free Pascal) |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.sh`, `average_calculator.pas` |

## Prerequisites

- **Bash** 4 or newer. On Windows use **Git Bash** or **MSYS2**.
- The **Free Pascal Compiler** (`fpc`)

## Build & run

```bash
fpc average_calculator.pas

bash main.sh                 # uses the built-in default data set
bash main.sh 1 2 3 4
bash main.sh -5 5 10
```

On Windows, run it through Git Bash:

```bash
"C:/Program Files/Git/bin/bash.exe" main.sh
```

You can also exercise the Pascal side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ bash main.sh
The average of 5 value(s) is: 30.00

$ bash main.sh 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.sh` uses **bash arrays** (rather than the POSIX `set --` trick) to collect the
arguments that survive validation, then runs the helper:

```bash
if ! average=$("$executable" "${numbers[@]}"); then
  echo "error: the Pascal helper failed" >&2
  exit 1
fi
```

Testing the command in an `if` keeps `set -e` from aborting the script before the
message can be printed, and the helper's own stderr passes straight through.

`average_calculator.pas` parses each argument with `TryStrToFloat`, sums them and
prints `FormatFloat('0.00', ...)`. It pins
`DefaultFormatSettings.DecimalSeparator` to `.` before parsing so both the input
and the output are independent of the machine's locale.
