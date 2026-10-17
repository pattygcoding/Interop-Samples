# Clojure with Lua

Clojure passes the numbers as command-line arguments to a Lua script and reads the
average it prints back from stdout.

| | |
|---|---|
| **Host language** | Clojure |
| **Guest language** | Lua |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.clj`, `average_calculator.lua`, `deps.edn` |

## Prerequisites

- The **Clojure CLI** (`clojure`) with a JDK
- **Lua** 5.1 or newer (`lua`) on your `PATH`

## Build & run

There is nothing to compile:

```bash
clojure -M main.clj                 # uses the built-in default data set
clojure -M main.clj 1 2 3 4
clojure -M main.clj -5 5 10
```

`main.clj` resolves the helper next to itself via `*file*`, so the sample works
from any working directory.

You can also exercise the Lua side on its own:

```bash
lua average_calculator.lua 10 20 30     # -> 20.00
```

## Expected output

```text
$ clojure -M main.clj
The average of 5 value(s) is: 30.00

$ clojure -M main.clj 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.clj` shells out with `clojure.java.shell/sh`, passing the numbers as
separate arguments so no shell quoting is involved:

```clojure
(let [result (apply shell/sh "lua" script (map str numbers))]
  ...)
```

`sh` returns a map with `:exit`, `:out` and `:err`, so the Clojure side can tell a
clean run from a failure and surface the script's own message. The result is
formatted with `String.format` and `Locale/ROOT` so the decimal separator does not
depend on the host locale.

`average_calculator.lua` walks the global `arg` table, converts each entry with
`tonumber`, and prints the mean via `("%.2f"):format(...)`. Non-numeric arguments
are reported on stderr with `os.exit(1)`.
