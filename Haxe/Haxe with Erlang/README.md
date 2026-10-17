# Haxe with Erlang

Haxe — compiled to Neko bytecode — passes the numbers as command-line arguments to
an Erlang escript and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Haxe (Neko target) |
| **Guest language** | Erlang |
| **Bridge** | Child process + argv/stdout |
| **Files** | `Main.hx`, `average_calculator.escript` |

## Prerequisites

- **Haxe** 4.0 or newer, plus **Neko** (`neko`) — both ship in the standard Haxe
  distribution
- **Erlang/OTP** 24 or newer, providing `escript`

## Build & run

```bash
haxe -cp . -main Main -neko main.n
neko main.n                 # uses the built-in default data set
neko main.n 1 2 3 4
neko main.n -5 5 10
```

You can also exercise the Erlang side on its own:

```bash
escript average_calculator.escript 10 20 30     # -> 20.00
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
`sys.io.Process`:

```haxe
var process = new sys.io.Process("escript", arguments);
var output = process.stdout.readAll().toString();
var exitCode = process.exitCode();
```

Both streams are drained before `exitCode()` is consulted, which avoids the
classic pipe-buffer deadlock, and the result is validated with `Std.parseFloat`
before use. `escript` is a real executable on every platform, so no shim workaround
is needed here — unlike the [Groovy sample](../Haxe%20with%20Groovy/README.md).

`average_calculator.escript` accepts both integer and decimal arguments: it tries
`string:to_float/1` first and falls back to `string:to_integer/1`, since
`10` has no decimal point for the float parser to find. Anything else is reported
on stderr with `halt(1)`.
