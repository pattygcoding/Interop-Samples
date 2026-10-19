# Elm with Scala

An Elm program asks a thin Node host to run a Scala program, receives the average
back through a port, formats the result line and hands it out again. All of the
presentation logic lives in Elm; the host only moves bytes.

| | |
|---|---|
| **Host language** | Elm |
| **Guest language** | Scala 3 |
| **Bridge** | Ports + a Node host, child process + argv/stdout |
| **Files** | `src/Main.elm`, `main.js`, `AverageCalculator.scala`, `elm.json` |

## Prerequisites

- **Elm** 0.19.2 — applications pin the compiler version exactly, so `elm.json`
  must match what you have installed
- **Node.js** 18 or newer
- **[Scala CLI](https://scala-cli.virtuslab.org/)** (`scala`), used as a
  single-command Scala runner

## Build & run

```bash
elm make src/Main.elm --optimize --output=elm.js
node main.js                 # uses the built-in default data set
node main.js 1 2 3 4
node main.js -5 5 10
```

You can also exercise the Scala side on its own:

```bash
scala run AverageCalculator.scala -- 10 20 30     # -> 20.00
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

`main.js` loads the compiled program, subscribes to `calculate`, runs the Scala
helper and pushes the answer back in through `calculated`. Elm then builds the
sentence and sends it out via `report`, which the host prints.

Getting the command right takes two small pieces of care. On Windows `scala` is a
`.cmd` shim, which Node cannot spawn directly, so it is routed through `cmd /c`:

```js
return process.platform === 'win32'
  ? { command: 'cmd', args: ['/c', 'scala', ...args] }
  : { command: 'scala', args };
```

`shell: true` looks like the simpler answer but is not: Node joins the arguments
without quoting them, so the sample path would be split at its space. Going
through `cmd` with an argv array lets Node quote each argument itself.

`AverageCalculator.scala` is a plain `@main` entry point that parses its arguments
with `toDoubleOption` and formats with `String.format(Locale.ROOT, "%.2f", ...)`.
Scala CLI prints its build progress on **stderr**, so stdout holds nothing but the
number.
