# Swift with Ruby

Swift passes the numbers as command-line arguments to a Ruby script and reads the
average it prints back from stdout.

| | |
|---|---|
| **Host language** | Swift |
| **Guest language** | Ruby |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.swift`, `average_calculator.rb` |

## Prerequisites

- The **Swift toolchain** (`swiftc`), 5.9 or newer
- **Ruby** 2.7 or newer (`ruby`) on your `PATH`

## Build & run

```bash
swiftc -O main.swift -o average      # Windows: -o average.exe

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

`swiftc` uses the `-o` name verbatim, so on Windows it needs the `.exe` suffix
explicitly; run the program as `.\average.exe` there.

You can also exercise the Ruby side on its own:

```bash
ruby average_calculator.rb 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Swift's `Process` takes an absolute executable URL, so `main.swift` resolves
`ruby` itself rather than relying on the platform to search `PATH`:

```swift
let process = Process()
process.executableURL = ruby.command
process.arguments = ["average_calculator.rb"] + numbers.map { String($0) }
```

Two portability details are easy to get wrong:

- **The environment lookup is case-sensitive.** Windows spells the variable
  `Path`, not `PATH`, and Foundation keeps whatever casing the process was
  started with. `environmentValue` falls back to a case-insensitive match.
- **Batch shims cannot be started directly.** MSYS2 installs `ruby.bat` and
  `ruby.cmd` next to its own tools, and `CreateProcess` refuses to run either, so
  `locate` prefers a real `.exe` and only falls back to a shim — launched through
  `COMSPEC /c` — when nothing else is available.

`average_calculator.rb` converts each argument with `Float`, which raises
`ArgumentError` on anything unparsable, and prints `numbers.sum / numbers.length`
with `format('%.2f', ...)`.
