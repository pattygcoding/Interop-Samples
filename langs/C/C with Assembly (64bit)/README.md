# C with Assembly (64-bit)

Computes the arithmetic mean of an integer array in **hand-written x86-64
assembly** and calls it from C. A single assembly source builds for both the
System V AMD64 ABI (Linux/macOS) and the Microsoft x64 ABI (Windows).

| | |
|---|---|
| **Host language** | C |
| **Guest language** | x86-64 assembly (NASM) |
| **Bridge** | Native linking + platform x64 ABI |
| **Files** | `main.c`, `calculate_average.asm` |

## Prerequisites

- [NASM](https://www.nasm.us/) 2.14 or newer
- A 64-bit C toolchain:
  - **Linux:** `gcc`
  - **Windows:** MinGW-w64 `gcc`

## Build & run

### Linux / macOS

```bash
nasm -f elf64 calculate_average.asm -o calculate_average.o
gcc -O2 -Wall -Wextra main.c calculate_average.o -o average

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

### Windows (MinGW-w64)

```powershell
nasm -f win64 calculate_average.asm -o calculate_average.obj
gcc -O2 -Wall -Wextra main.c calculate_average.obj -o average.exe

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

`main.c` declares the assembly routine with C linkage:

```c
extern double calculate_average(const int *numbers, int count);
```

The 64-bit ABI passes the first two integer arguments in registers and returns
floating-point values in `xmm0`. Because those registers differ between
platforms, the assembly selects the right ones at assembly time:

```asm
%ifidn __OUTPUT_FORMAT__, win64
    %define NUMBERS rcx      ; Windows: rcx = numbers, rdx = count
    %define COUNT   edx
%else
    %define NUMBERS rdi      ; System V: rdi = numbers, rsi = count
    %define COUNT   esi
%endif
```

The sum is accumulated in `xmm0` with `cvtsi2sd` / `addsd`, then divided by the
count with `divsd`. `count <= 0` returns `0.0` instead of dividing by zero, and
an ELF-only `.note.GNU-stack` section keeps the linker from marking the stack
executable.
