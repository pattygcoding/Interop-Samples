# Rust with Lisp

Rust passes the numbers as command-line arguments to an SBCL Lisp script and reads
the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Rust |
| **Guest language** | Lisp (SBCL) |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.rs`, `average_calculator.lisp` |

## Prerequisites

- **rustc** 1.70 or newer (`cargo` also works)
- **SBCL** (`sbcl`) on your `PATH`

## Build & run

```bash
rustc -O main.rs -o average          # Windows: -o average.exe

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

`rustc` uses the `-o` name verbatim, so on Windows it needs the `.exe` suffix
explicitly; run the program as `.\average.exe` there.

You can also exercise the Lisp side on its own:

```bash
sbcl --script average_calculator.lisp 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.rs` starts the Lisp helper with `sbcl --script`, passing the numbers after
the script name:

```rust
let output = Command::new("sbcl")
    .args(["--script", "average_calculator.lisp"])
    .args(&arguments)
    .output()
    .map_err(|error| format!("could not run sbcl: {}", error))?;
```

`--script` suppresses SBCL's banner, leaving stdout containing nothing but the
answer. A non-zero exit is reported together with whatever the script wrote to
stderr, and the printed value is validated with `parse::<f64>()` before use.

`average_calculator.lisp` picks its arguments out of `sb-ext:*posix-argv*` — whose
first entry is the script name itself — and converts each one with
`read-from-string`, rejecting anything that is not a `numberp`. The result is
coerced with `float` before `~,2f` prints it, so a whole-number division such as
`10/3` cannot print as a Lisp ratio.
