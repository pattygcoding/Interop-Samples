# Perl with Prolog

Perl drives **SWI-Prolog** to compute a factorial, validating the input before
the Prolog program ever runs.

| | |
|---|---|
| **Host language** | Perl |
| **Guest language** | Prolog (SWI-Prolog) |
| **Bridge** | Child process, command-line argument + stdout |
| **Files** | `main.pl`, `factorial.pro` |

## Prerequisites

- **Perl** 5.10 or newer
- **SWI-Prolog** (`swipl`) on your `PATH`

## Build & run

```bash
perl main.pl                 # factorial of 5 (the default)
perl main.pl 10              # factorial of 10
```

You can also run the Prolog program on its own:

```bash
swipl -q -f factorial.pro -g main -- 10
```

## Expected output

```text
$ perl main.pl
The factorial of 5 is: 120

$ perl main.pl 10
The factorial of 10 is: 3628800
```

## How it works

Perl rejects anything that is not a non-negative integer, then runs the Prolog
program with `-g main` and captures stdout:

```perl
my $result = `swipl -q -f "$program" -g main -- $number`;
```

In `factorial.pro` the `main/0` predicate reads `argv`, converts the argument
with `atom_number/2` and delegates to a **tail-recursive, accumulator-based**
`factorial_/3`. The accumulator version keeps memory use constant, and `main`
calls `halt` explicitly — otherwise `swipl` would drop into its interactive top
level and wait for input.
