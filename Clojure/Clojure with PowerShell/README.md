# Clojure with PowerShell

Clojure passes the numbers as command-line arguments to a PowerShell script and
reads the average back from its standard output.

| | |
|---|---|
| **Host language** | Clojure |
| **Guest language** | PowerShell |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.clj`, `average_calculator.ps1`, `deps.edn` |

## Prerequisites

- The **Clojure CLI** (`clojure`) with a JDK
- **PowerShell**: `pwsh` (PowerShell 7+, cross-platform) or the Windows-only
  `powershell`. The sample probes for `pwsh` first and falls back automatically.

## Build & run

There is nothing to compile:

```bash
clojure -M main.clj                 # uses the built-in default data set
clojure -M main.clj 1 2 3 4
clojure -M main.clj -5 5 10
```

`main.clj` resolves the helper next to itself via `*file*`, so the sample works
from any working directory.

You can also exercise the PowerShell side on its own:

```powershell
pwsh -NoProfile -File average_calculator.ps1 10 20 30     # -> 20.00
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
(apply shell/sh
       (powershell)
       (concat ["-NoProfile" "-ExecutionPolicy" "Bypass" "-File" script]
               (map str numbers)))
```

`sh` returns a map with `:exit`, `:out` and `:err`, so the Clojure side can
distinguish a clean run from a failure and surface the script's own message.
`powershell` is detected by probing each candidate executable with
`-Command "exit 0"`, which works the same way on Windows, Linux and macOS.

`average_calculator.ps1` takes its input through a
`[Parameter(ValueFromRemainingArguments = $true)]` parameter, so every trailing
argument is collected into one array. Values are parsed and formatted with
`CultureInfo.InvariantCulture` on both sides, which keeps the decimal separator
stable regardless of the host locale.
