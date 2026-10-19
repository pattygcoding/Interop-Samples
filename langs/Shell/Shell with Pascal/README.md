# Shell with Pascal

A POSIX shell passes the numbers as command-line arguments to a compiled Free
Pascal program and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Shell (POSIX `sh`) |
| **Guest language** | Pascal (Free Pascal) |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.sh`, `average_calculator.pas` |

## Prerequisites

- A POSIX shell. On Linux and macOS that is `/bin/sh`; on Windows use **Git Bash**
  or **MSYS2**.
- The **Free Pascal Compiler** (`fpc`)

## Build & run

```bash
fpc average_calculator.pas

sh main.sh                 # uses the built-in default data set
sh main.sh 1 2 3 4
sh main.sh -5 5 10
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
$ sh main.sh
The average of 5 value(s) is: 30.00

$ sh main.sh 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

The script is deliberately **POSIX**, unlike the [Bash with Pascal](../Bash/Bash%20with%20Pascal/README.md)
sample: it has no arrays, so the surviving arguments are rebuilt into a string and
then handed back to the shell with `set --`:

```sh
# shellcheck disable=SC2086
set -- $numbers
count=$#

if ! average=$("$executable" "$@"); then
  echo "error: the Pascal helper failed" >&2
  exit 1
fi
```

The project directory comes from `dirname "$0"`, so the script works no matter
where it is invoked from. Testing the command in an `if` keeps `set -e` from
aborting before the message can be printed, and the helper's own stderr passes
straight through.

`average_calculator.pas` parses each argument with `TryStrToFloat`, sums them and
prints `FormatFloat('0.00', ...)`. It pins
`DefaultFormatSettings.DecimalSeparator` to `.` before parsing so both the input
and the output are independent of the machine's locale.
