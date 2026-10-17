# Lua with Swift

Lua passes the numbers as command-line arguments to a compiled Swift program and
reads the average it prints back through a pipe.

| | |
|---|---|
| **Host language** | Lua |
| **Guest language** | Swift |
| **Bridge** | Child process + `io.popen` pipe |
| **Files** | `main.lua`, `average_calculator.swift` |

## Prerequisites

- **Lua** 5.1 or newer (`lua`)
- **Swift** 5.5 or newer (`swiftc`). On Windows this needs the Visual Studio build
  tools, which the Swift toolchain uses as its linker.

## Build & run

```bash
swiftc average_calculator.swift -o average_calculator
lua main.lua                 # uses the built-in default data set
lua main.lua 1 2 3 4
lua main.lua -5 5 10
```

On Windows the helper is `average_calculator.exe`; `main.lua` detects the platform
and uses the right name (including the `./` prefix Unix needs).

You can also exercise the Swift side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ lua main.lua
The average of 5 value(s) is: 30.00

$ lua main.lua 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.lua` assembles the command line and opens a pipe to the Swift process:

```lua
local pipe = io.popen("average_calculator 10 20 30", "r")
local output = pipe:read("*a")
local ok = pipe:close()
```

`pipe:close()` reports whether the helper exited cleanly, and the result is
converted with `tonumber` so malformed output is reported rather than used.

`average_calculator.swift` parses its arguments with `Double(_:)` and prints the
mean using `String(format:locale:)` with the `en_US_POSIX` locale, so the decimal
separator is a dot on every machine. The script deliberately avoids post-5.1 Lua
features so it runs on the widest range of interpreters.
