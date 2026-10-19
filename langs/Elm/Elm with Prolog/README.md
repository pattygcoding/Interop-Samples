# Elm with Prolog

An Elm program asks a thin Node host to run **SWI-Prolog**, receives the average
back through a port, formats the result line and hands it out again. All of the
presentation logic lives in Elm; the host only moves bytes.

| | |
|---|---|
| **Host language** | Elm |
| **Guest language** | Prolog (SWI-Prolog) |
| **Bridge** | Ports + a Node host, child process + argv/stdout |
| **Files** | `src/Main.elm`, `main.js`, `average.pl`, `elm.json` |

## Prerequisites

- **Elm** 0.19.2 — applications pin the compiler version exactly, so `elm.json`
  must match what you have installed
- **Node.js** 18 or newer
- **SWI-Prolog** (`swipl`) on your `PATH`

## Build & run

```bash
elm make src/Main.elm --optimize --output=elm.js
node main.js                 # uses the built-in default data set
node main.js 1 2 3 4
node main.js -5 5 10
```

You can also exercise the Prolog side on its own:

```bash
swipl -q -f average.pl -g main -- 10 20 30     # -> 30.00
```

## Expected output

```text
$ node main.js
The average of 5 value(s) is: 30.00

$ node main.js 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Elm has no FFI and cannot start processes, so the standard way to reach the
outside world is **ports**:

```elm
port calculate : List Float -> Cmd msg
port calculated : (Float -> msg) -> Sub msg
port report : String -> Cmd msg
```

`main.js` loads the compiled program, subscribes to `calculate`, runs
`swipl -q -f average.pl -g main -- <numbers>`, and pushes the answer back in
through `calculated`. Elm then builds the sentence and sends it out via
`report`, which the host prints. Because the Elm side owns the message and the
two-decimal formatting, the JavaScript stays trivial.

`average.pl` converts its arguments with `atom_number/2`, computes
`sum_list / length` and prints the result with `format('~2f')`. `main` halts
explicitly on both the success and the failure path — without that, `swipl`
would drop into its interactive top level and wait for input.
