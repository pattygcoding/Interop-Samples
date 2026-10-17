# Elm with D

Elm cannot start a process, so a thin Node host runs the compiled D program and
answers the Elm program's `calculate` port request.

| | |
|---|---|
| **Host language** | Elm |
| **Guest language** | D |
| **Bridge** | Ports + Node host, child process |
| **Files** | `main.js`, `src/Main.elm`, `elm.json`, `average_calculator.d` |

## Prerequisites

- The **Elm compiler** 0.19.2 (`elm`)
- **Node.js** 18 or newer
- The **DMD** compiler (`dmd`)

> **Windows runtime note.** DMD builds link against the Visual C++ 2013 runtime
> (`msvcr120.dll`). If the [VC++ 2013 redistributable](https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist)
> is not installed system-wide, add DMD's own `windows\bin64` folder — which
> contains a copy — to your `PATH`. Otherwise the helper exits with `0xC0000135`
> ("the specified module could not be found").

## Build & run

```bash
dmd -O average_calculator.d
elm make src/Main.elm --output=elm.js

node main.js                 # uses the built-in default data set
node main.js 1 2 3 4
node main.js -5 5 10
```

DMD names the output after the source file, so the helper lands as
`average_calculator.exe` on Windows and `average_calculator` elsewhere.

You can also exercise the D side on its own:

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

`src/Main.elm` is a `Platform.worker` that talks to the host through three ports:
`calculate` sends the numbers out, `calculated` receives the average back, and
`report` hands the finished line to the host for printing. All of the presentation
logic — including the two-decimal formatter — lives in Elm:

```elm
update msg model =
    case msg of
        GotAverage average ->
            ( model, report ("The average of " ++ String.fromInt model.count ++ " value(s) is: " ++ format average) )
```

`main.js` only moves bytes. It compiles nothing and formats nothing; it starts the
D helper with an argument vector, validates the exit code and the printed number,
and forwards the value into the port.

One detail is easy to get wrong: the host converts arguments one at a time and
drops the bad ones instead of mapping the raw tokens with `Number()`. `Number("abc")`
is `NaN`, and `String(NaN)` is `"NaN"` — a perfectly valid D `double`, so the
helper would happily average it and print `nan`.

`average_calculator.d` converts each argument with `to!double`, catching
`ConvException` for anything unparsable, and prints `format("%.2f", ...)`.
