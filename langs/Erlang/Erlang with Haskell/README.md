# Erlang with Haskell

An Erlang escript opens a compiled Haskell program as a **port**, passes the
numbers as command-line arguments and reads the average back from its standard
output.

| | |
|---|---|
| **Host language** | Erlang |
| **Guest language** | Haskell |
| **Bridge** | Erlang port (child process) + argv/stdout |
| **Files** | `main.escript`, `main.hs` |

## Prerequisites

- **Erlang/OTP** 24 or newer, providing `escript` and `erl`
- **GHC** 8.10 or newer (`ghc`)

## Build & run

Compile the Haskell helper first:

```bash
ghc -O2 -o average_calculator main.hs
escript main.escript                 # uses the built-in default data set
escript main.escript 1 2 3 4
escript main.escript -5 5 10
```

On Windows the helper is `average_calculator.exe`; the escript detects the
platform and looks for the right name.

Run the escript from this directory: it resolves the helper relative to the
working directory.

You can also exercise the Haskell side on its own:

```bash
./average_calculator 10 20 30     # -> 20.0000000000
```

## Expected output

```text
$ escript main.escript
The average of 5 value(s) is: 30.00

$ escript main.escript 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Erlang talks to external programs through **ports**, which give it both the
child's output and its exit status:

```erlang
Port = open_port(
    {spawn_executable, executable()},
    [binary, exit_status, stderr_to_stdout, {args, [integer_to_list(N) || N <- Numbers]}]
).
```

`{args, ...}` passes the numbers without any shell quoting, `stderr_to_stdout`
folds diagnostics into the same stream, and `exit_status` turns the child's exit
code into a message Erlang can match on. A `receive` loop collects the data and
then reports either `{ok, Average}` or `{error, Reason}`.

`main.hs` parses its arguments with `reads`, prints the mean using
`printf "%.10f"` — a fixed-notation result is easy to parse on the other side —
and writes errors to stderr with exit status 1.

> One OTP subtlety: `string:trim/1` returns a **binary** when given the binary
> that a port delivers, and `string:to_float/1` then returns a binary remainder
> that will never match `""`. The escript normalises the port data with
> `unicode:characters_to_list/1` before parsing.
