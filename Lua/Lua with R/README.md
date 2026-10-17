# Lua with R

Lua passes the numbers as command-line arguments to an R script and reads the
average back through a pipe.

| | |
|---|---|
| **Host language** | Lua |
| **Guest language** | R |
| **Bridge** | Child process + `io.popen` pipe |
| **Files** | `main.lua`, `average_calculator.R` |

## Prerequisites

- **Lua** 5.1 or newer (`lua`)
- **R** with `Rscript` on your `PATH`

## Build & run

There is nothing to compile:

```bash
lua main.lua                 # uses the built-in default data set
lua main.lua 1 2 3 4
lua main.lua -5 5 10
```

Run it from this directory: it looks for `average_calculator.R` in the working
directory.

You can also exercise the R side on its own:

```bash
Rscript average_calculator.R 10 20 30     # -> 20.00
```

## Expected output

```text
$ lua main.lua
The average of 5 value(s) is: 30.00

$ lua main.lua 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.lua` assembles the command line and opens a pipe to the R process:

```lua
local pipe = io.popen("Rscript average_calculator.R 10 20 30", "r")
local output = pipe:read("*a")
local ok = pipe:close()
```

`pipe:close()` reports whether R exited cleanly, and the output is converted with
`tonumber` so a malformed result is reported rather than used.

`average_calculator.R` reads `commandArgs(trailingOnly = TRUE)`, converts the
values with `as.numeric`, and prints `mean(numbers)` formatted with `sprintf`.
Diagnostics go to stderr via `message` and failures exit with status 1.

The script deliberately avoids post-5.1 Lua features (no `goto`, `unpack` rather
than `table.unpack`) so it runs on the widest range of interpreters.
