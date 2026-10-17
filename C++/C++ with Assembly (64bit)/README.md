# C++ with Assembly (64-bit)

Computes the arithmetic mean of an integer array in **hand-written x86-64
assembly** and calls it from C++ through an `extern "C"` declaration. A single
assembly source builds for both the System V AMD64 ABI and the Microsoft x64 ABI.

| | |
|---|---|
| **Host language** | C++ |
| **Guest language** | x86-64 assembly (NASM) |
| **Bridge** | Native linking + platform x64 ABI |
| **Files** | `main.cpp`, `calculate_average.asm` |

## Prerequisites

- [NASM](https://www.nasm.us/) 2.14 or newer
- A 64-bit C++ toolchain:
  - **Linux:** `g++`
  - **Windows:** MinGW-w64 `g++`

## Build & run

### Linux / macOS

```bash
nasm -f elf64 calculate_average.asm -o calculate_average.o
g++ -O2 -Wall -Wextra main.cpp calculate_average.o -o average

./average
./average 2 4 6 8 10
```

### Windows (MinGW-w64)

```powershell
nasm -f win64 calculate_average.asm -o calculate_average.obj
g++ -O2 -Wall -Wextra main.cpp calculate_average.obj -o average.exe

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

The declaration uses C linkage so the symbol name lines up with NASM output:

```cpp
extern "C" double calculate_average(const int *numbers, int count);
```

`main.cpp` parses the command line into a `std::vector<int>` and calls the
routine with `numbers.data()` and the size. The assembly picks the correct
argument and return registers for the target ABI at assembly time:

```asm
%ifidn __OUTPUT_FORMAT__, win64
    %define NUMBERS rcx      ; Windows: rcx = numbers, rdx = count
    %define COUNT   edx
%else
    %define NUMBERS rdi      ; System V: rdi = numbers, rsi = count
    %define COUNT   esi
%endif
```

The sum is accumulated in `xmm0` and divided by the count with `divsd`.
`count <= 0` returns `0.0` instead of dividing by zero.
