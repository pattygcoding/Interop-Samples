# Rust with Shell

Rust passes the numbers as command-line arguments to a POSIX shell script and
reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Rust |
| **Guest language** | Shell (POSIX `sh`) |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.rs`, `average_calculator.sh` |

## Prerequisites

- **rustc** (any recent stable toolchain)
- A POSIX shell. On Linux and macOS that is `/bin/sh`; on Windows use **Git Bash**
  or **MSYS2**, and note the caveat below.

## Build & run

```bash
rustc -O main.rs -o average

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the program is `average.exe`.

You can also exercise the shell side on its own:

```bash
sh average_calculator.sh 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Rust runs the script with `Command`, which gives it stdout, stderr and the exit
status in one call:

```rust
let output = Command::new(interpreter)
    .arg("average_calculator.sh")
    .args(&arguments)
    .output()?;
```

`average_calculator.sh` rejects anything that is not a number, then pipes the
values through `awk`. That is not a stylistic choice: POSIX `sh` has no
floating-point arithmetic, so `awk` — which every POSIX system ships — does the
sum and the `%.2f` formatting.

### The Windows shell trap

Finding an interpreter is more subtle than it looks. On Windows a bare `bash`
resolves to `System32\bash.exe`, the **WSL relay**, which fails with "No such file
or directory" when no distribution is installed. Prepending Git Bash to `PATH`
does not help, because `CreateProcess` searches `System32` *before* `PATH` — a
difference from `where.exe`, which follows `PATH`.

The program therefore probes a short list of candidates (`bash`, `sh`, then the
usual Git Bash and MSYS2 install paths) with `bash -c "exit 0"` and uses the first
one that actually runs. Set `SHELL_INTERPRETER` to skip the search entirely:

```powershell
$env:SHELL_INTERPRETER = 'C:\Program Files\Git\bin\bash.exe'
.\average.exe
```
