# Objective-C with Lisp

Objective-C builds the numbers into a command line, runs an SBCL (Common Lisp)
script through a pipe, and reads the average back.

| | |
|---|---|
| **Host language** | Objective-C |
| **Guest language** | Common Lisp (SBCL) |
| **Bridge** | Child process + `popen` pipe |
| **Files** | `main.m`, `average_calculator.lisp` |

## Prerequisites

- A C compiler with an **Objective-C frontend** and the GNU Objective-C runtime:
  - **Windows (MSYS2):** `mingw-w64-x86_64-gcc-objc` and
    `mingw-w64-x86_64-libobjc`. `msys64\mingw64\bin` must be on your `PATH`, both
    so `gcc` is found and so the program can load `libobjc-4.dll` at run time.
  - **Linux:** `apt install gobjc` (or `gcc-objc`)
- **SBCL** (`sbcl`) on your `PATH`

## Build & run

```bash
gcc -std=gnu11 -Wno-objc-root-class main.m -o average -lobjc

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the program is `average.exe`.

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

`main.m` deliberately avoids Foundation. It declares its own root class — a plain
`Class isa` ivar allocated with the runtime function `class_createInstance` — so
`libobjc` is the only library it needs. The class owns the whole interaction with
the helper:

```objc
id calculator = [AverageCalculator alloc];
const double average = [calculator averageForValues:values count:count];
```

Inside, the method builds the command line, runs it with `popen` and reads the
answer. `pclose` returns the helper's exit status, so a failure inside the Lisp
script is reported instead of being mistaken for a result.

Two build details matter: `-std=gnu11` because GCC's Objective-C frontend still
defaults to C89, and `-Wno-objc-root-class` to silence the expected warning about
a class with no superclass.

`average_calculator.lisp` picks its arguments out of `sb-ext:*posix-argv*` — whose
first entry is the script name itself — and converts each one with
`read-from-string`, rejecting anything that is not a `numberp`. The result is
coerced with `float` before `~,2f` prints it.
