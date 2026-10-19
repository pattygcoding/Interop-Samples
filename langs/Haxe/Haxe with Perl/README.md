# Haxe with Perl

Haxe — compiled to Neko bytecode — passes the numbers as command-line arguments
to a Perl script and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Haxe (Neko target) |
| **Guest language** | Perl |
| **Bridge** | Child process + argv/stdout |
| **Files** | `Main.hx`, `average_calculator.pl` |

## Prerequisites

- **Haxe** 4.0 or newer, plus **Neko** (`neko`) — both ship in the standard Haxe
  distribution
- **Perl** 5.10 or newer

## Build & run

```bash
haxe -cp . -main Main -neko main.n
neko main.n                 # uses the built-in default data set
neko main.n 1 2 3 4
neko main.n -5 5 10
```

You can also exercise the Perl side on its own:

```bash
perl average_calculator.pl 10 20 30     # -> 20.00
```

## Expected output

```text
$ neko main.n
The average of 5 value(s) is: 30.00

$ neko main.n 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`Main.hx` is compiled to **Neko bytecode** rather than JavaScript or C, because
the Neko target has a real `sys.io.Process`:

```haxe
var process = new sys.io.Process("perl", arguments);
var output = process.stdout.readAll().toString();
var exitCode = process.exitCode();
```

Both streams are drained before `exitCode()` is consulted, which avoids the
classic pipe-buffer deadlock, and the result is validated with `Std.parseFloat`
before it is used.

`average_calculator.pl` vets every argument with
`Scalar::Util::looks_like_number` and prints the mean via `printf "%.2f"`. The
Haxe side re-implements two-decimal formatting in `toFixed`, because Haxe has no
printf-style format for floats.
