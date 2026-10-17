# C with Assembly (32-bit)

Computes the arithmetic mean of an integer array in **hand-written x86 assembly**
(cdecl, 32-bit) and calls it from C.

| | |
|---|---|
| **Host language** | C |
| **Guest language** | x86-32 assembly (NASM) |
| **Bridge** | Native linking + cdecl calling convention |
| **Files** | `main.c`, `calculate_average.asm` |

## Prerequisites

- [NASM](https://www.nasm.us/) 2.14 or newer
- A 32-bit-capable C toolchain:
  - **Linux:** `gcc` plus the 32-bit runtime (`gcc-multilib` / `libc6-dev-i386`)
  - **Windows:** a 32-bit MinGW-w64 toolchain (e.g. MSYS2 `mingw-w64-i686-gcc`)

## Build & run

### Linux

```bash
nasm -f elf32 calculate_average.asm -o calculate_average.o
gcc -m32 -O2 -Wall -Wextra main.c calculate_average.o -o average

./average                 # uses the built-in default data set
./average 1 2 3 4         # average of the numbers you pass
```

### Windows (32-bit MinGW-w64)

```powershell
nasm -f win32 calculate_average.asm -o calculate_average.obj
gcc -m32 -O2 -Wall -Wextra main.c calculate_average.obj -o average.exe

.\average.exe
.\average.exe 1 2 3 4
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50

$ ./average -5 5 10
The average of 3 value(s) is: 3.33
```

Numbers are read from the command line; with no arguments a default set of
`10 20 30 40 50` is used. Non-integer arguments are reported and skipped, and
invoking the program without any usable numbers exits with a non-zero status.

## How it works

`main.c` declares the assembly routine and links against the NASM object file:

```c
extern double calculate_average(const int *numbers, int count);
```

Under the 32-bit **cdecl** convention the arguments arrive on the stack, so the
assembly reads them at `[ebp + 8]` (pointer) and `[ebp + 12]` (count). The sum is
accumulated on the x87 FPU (`fild` / `faddp`) and divided by the count with
`fdivp`; the result is returned in `ST(0)`, which is exactly where the C ABI
expects a `double` return value.

The same source assembles for both Linux (`-f elf32`) and Windows (`-f win32`);
only the externally visible symbol name differs, which the file handles with a
NASM conditional. `count <= 0` returns `0.0` instead of dividing by zero.
