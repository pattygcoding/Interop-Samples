# Swift with Nim

Swift writes the numbers to a compiled Nim program's standard input and reads the
average back from its standard output.

| | |
|---|---|
| **Host language** | Swift |
| **Guest language** | Nim |
| **Bridge** | Child process + stdin/stdout |
| **Files** | `main.swift`, `average_calculator.nim` |

## Prerequisites

- **Swift** 5.5 or newer (`swiftc`). On Windows this needs the Visual Studio
  build tools, which the Swift toolchain uses as its linker.
- **Nim** 1.6 or newer (`nim`) on your `PATH`

## Build & run

```bash
nim c -d:release --hints:off -o:average_calculator average_calculator.nim
swiftc main.swift -o average

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the binaries are `average_calculator.exe` and `average.exe`; `main.swift`
detects the platform and looks for the right helper name.

You can also exercise the Nim side on its own:

```bash
echo "10 20 30" | ./average_calculator
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.swift` runs the helper with Foundation's `Process`, wiring up three pipes:

```swift
let process = Process()
process.executableURL = executableURL
process.standardInput = stdinPipe
process.standardOutput = stdoutPipe
process.standardError = stderrPipe
```

It writes the numbers, closes stdin so the helper sees end-of-input, reads stdout
to completion and then checks `terminationStatus`. Because the executable is
addressed by URL rather than by a shell command line, paths containing spaces are
not a problem.

`average_calculator.nim` reads all of stdin, splits on whitespace, parses each
token with `parseFloat` and prints the mean via `formatFloat(..., ffDecimal, 15)`.
Bad input exits with status 1 after a message on stderr.
