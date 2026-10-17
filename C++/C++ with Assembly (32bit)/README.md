# C++ with Assembly (32-bit)

Computes the arithmetic mean of an integer array in **hand-written x86 assembly**
(cdecl, 32-bit) and calls it from C++ through an `extern "C"` declaration.

| | |
|---|---|
| **Host language** | C++ |
| **Guest language** | x86-32 assembly (NASM) |
| **Bridge** | Native linking + cdecl calling convention |
| **Files** | `main.cpp`, `calculate_average.asm` |

## Prerequisites

- [NASM](https://www.nasm.us/) 2.14 or newer
- A 32-bit-capable C++ toolchain:
  - **Linux:** `g++` plus the 32-bit runtime (`gcc-multilib` / `libc6-dev-i386`)
  - **Windows:** a 32-bit MinGW-w64 toolchain (e.g. MSYS2 `mingw-w64-i686-gcc`)

## Build & run

### Linux

```bash
nasm -f elf32 calculate_average.asm -o calculate_average.o
g++ -m32 -O2 -Wall -Wextra main.cpp calculate_average.o -o average

./average
./average 2 4 6 8 10
```

### Windows (32-bit MinGW-w64)

```powershell
nasm -f win32 calculate_average.asm -o calculate_average.obj
g++ -m32 -O2 -Wall -Wextra main.cpp calculate_average.obj -o average.exe

.\average.exe
.\average.exe 2 4 6 8 10
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 2 4 6 8 10
The average of 5 value(s) is: 6.00
```

Numbers are read from the command line; with no arguments a default set of
`10 20 30 40 50` is used. Invalid arguments are reported and skipped.

## How it works

C++ name-mangles functions, so the declaration is wrapped in `extern "C"` to
match the plain symbol name emitted by NASM:

```cpp
extern "C" double calculate_average(const int *numbers, int count);
```

`main.cpp` collects the command line into a `std::vector<int>` and passes
`numbers.data()` together with the size. The assembly reads `[ebp + 8]`
(pointer) and `[ebp + 12]` (count) under cdecl, accumulates the sum on the x87
FPU, and returns the mean in `ST(0)`.

The same source assembles for Linux (`-f elf32`) and Windows (`-f win32`); the
externally visible symbol name is selected with a NASM conditional. `count <= 0`
returns `0.0` instead of dividing by zero.
