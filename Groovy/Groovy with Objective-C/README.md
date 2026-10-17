# Groovy with Objective-C

Groovy passes the numbers as command-line arguments to a compiled Objective-C
program and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Groovy |
| **Guest language** | Objective-C |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.groovy`, `average_calculator.m` |

## Prerequisites

- **Groovy** 4 or newer
- A C compiler with an **Objective-C frontend** and the GNU Objective-C runtime:
  - **Windows (MSYS2):** `mingw-w64-x86_64-gcc-objc` and
    `mingw-w64-x86_64-libobjc`. `msys64\mingw64\bin` must be on your `PATH`, both
    so `gcc` is found and so the helper can load `libobjc-4.dll` at run time.
  - **Linux:** `apt install gobjc` (or `gcc-objc`)

## Build & run

```bash
gcc -std=gnu11 -Wno-objc-root-class average_calculator.m -o average_calculator -lobjc

groovy main.groovy                 # uses the built-in default data set
groovy main.groovy 1 2 3 4
groovy main.groovy -5 5 10
```

On Windows the helper is `average_calculator.exe`; `main.groovy` detects the
platform and looks for the right name.

You can also exercise the Objective-C side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ groovy main.groovy
The average of 5 value(s) is: 30.00

$ groovy main.groovy 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`average_calculator.m` deliberately avoids Foundation — it declares its own root
class and allocates it with the runtime function `class_createInstance`, so
`libobjc` is the only library it needs:

```objc
@interface AverageCalculator
{
    Class isa;
}
+ (id)alloc;
- (double)meanOfValues:(const double *)values count:(int)count;
@end
```

`main.groovy` starts the helper with `ProcessBuilder`, passing the command as a
list so no shell is involved, drains both streams with Groovy's
`consumeProcessOutput`, and checks `exitValue()` before parsing the result.

Two build details matter: `-std=gnu11` because GCC's Objective-C frontend still
defaults to C89, which rejects `for (int i = ...)`, and `-Wno-objc-root-class`
to silence the expected warning about declaring a class with no superclass.
