# Elm with Swift

An Elm program asks a thin Node host to run a compiled Swift helper, receives the
average back through a port, formats the result line and hands it out again. All
of the presentation logic lives in Elm; the host only moves bytes.

| | |
|---|---|
| **Host language** | Elm |
| **Guest language** | Swift |
| **Bridge** | Ports + a Node host, child process + argv/stdout |
| **Files** | `src/Main.elm`, `main.js`, `average_calculator.swift`, `elm.json` |

## Prerequisites

- **Elm** 0.19.2 — applications pin the compiler version exactly, so `elm.json`
  must match what you have installed
- **Node.js** 18 or newer
- **Swift** 5.5 or newer (`swiftc`). On Windows this needs the Visual Studio build
  tools, which the Swift toolchain uses as its linker.

## Build & run

```bash
swiftc average_calculator.swift -o average_calculator
elm make src/Main.elm --optimize --output=elm.js

node main.js                 # uses the built-in default data set
node main.js 1 2 3 4
node main.js -5 5 10
```

On Windows the helper is `average_calculator.exe`; `main.js` detects the platform
and looks for the right name.

You can also exercise the Swift side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
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

`main.js` loads the compiled program, subscribes to `calculate`, spawns the Swift
helper with the numbers as arguments, and pushes the answer back in through
`calculated`. Elm then builds the sentence and sends it out via `report`, which
the host prints. Because the Elm side owns the message and the two-decimal
formatting, the JavaScript stays trivial.

`average_calculator.swift` parses its arguments with `Double(_:)` and prints the
mean using `String(format:locale:)` with the `en_US_POSIX` locale, so the decimal
separator is a dot on every machine.
