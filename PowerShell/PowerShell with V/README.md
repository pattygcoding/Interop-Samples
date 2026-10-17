# PowerShell with V

PowerShell passes the numbers as command-line arguments to a compiled V program
and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | PowerShell |
| **Guest language** | V |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.ps1`, `average_calculator.v` |

## Prerequisites

- **PowerShell** 7+ (`pwsh`) or the Windows-only `powershell`
- **V** 0.4 or newer, plus a C backend:
  - **Windows:** V ships TinyCC, so `v -cc tcc` works out of the box
  - **Linux / macOS:** the default `cc` (gcc or clang) is used

## Build & run

```bash
v -cc tcc -o average_calculator average_calculator.v

pwsh -NoProfile -File main.ps1                 # uses the built-in default data set
pwsh -NoProfile -File main.ps1 1 2 3 4
pwsh -NoProfile -File main.ps1 -5 5 10
```

On Windows the helper is `average_calculator.exe`; `main.ps1` detects the platform
and looks for the right name.

You can also exercise the V side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ pwsh -NoProfile -File main.ps1
The average of 5 value(s) is: 30.00

$ pwsh -NoProfile -File main.ps1 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.ps1` takes its input through a
`[Parameter(ValueFromRemainingArguments = $true)]` parameter, so every trailing
argument is collected into one array, and runs the helper with the call operator:

```powershell
$arguments = $values | ForEach-Object { $_.ToString($invariant) }
$output = & $executable $arguments
```

Both sides use `CultureInfo.InvariantCulture` — PowerShell when parsing the
arguments and formatting the call, and V when printing — so the decimal separator
never depends on the host locale.

`average_calculator.v` pre-validates each token with `is_number`, because V's
`str.f64()` quietly yields `0.0` for unparsable input — without the check, `oops`
would silently become a zero. The mean is printed with V's `${value:.2f}`
interpolation.
