# Haskell with Assembly (32-bit)

Haskell drives a **hand-written 32-bit x86 assembly** program. Haskell writes
the numbers to a scratch file, the assembly program reads them, adds them up and
writes the total to a second file, and Haskell then prints the average.

| | |
|---|---|
| **Host language** | Haskell |
| **Guest language** | x86-32 assembly (NASM) |
| **Bridge** | Child process + text files |
| **Files** | `main.hs`, `sum_calc.asm` |
| **Platform** | **Linux i386 only** — the assembly issues raw `int 0x80` system calls |

## Prerequisites

- **GHC** 8.10 or newer. The `process`, `directory` and `filepath` libraries used
  here ship with GHC, as does `Text.Printf` from `base`.
- **NASM** 2.14 or newer
- A 32-bit-capable Linux environment (a native system, WSL, or a container —
  e.g. the `i386/debian` image)

## Build & run

```bash
nasm -f elf32 sum_calc.asm -o sum_calc.o
ld -m elf_i386 sum_calc.o -o sum_calc

ghc -O2 -o average main.hs
./average
```

Run `./average` from this directory: it looks for the helper as `./sum_calc`.

You can also exercise the assembly program on its own:

```bash
printf '10 20 30 40 50' > numbers.txt
./sum_calc numbers.txt result.txt
cat result.txt          # -> 150
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00
```

## How it works

1. `main.hs` writes the numbers to `numbers.txt` inside a temporary directory
   (`withScratchDirectory`, which always cleans up afterwards).
2. It runs `./sum_calc numbers.txt result.txt` with
   `readProcessWithExitCode` and fails loudly if the helper exits non-zero.
3. It parses the total from `result.txt` and prints the average.

`sum_calc.asm` is a freestanding Linux i386 program — no libc. It reaches the
kernel through `int 0x80`, reading the whole input file into a buffer, parsing
the integers out of it (spaces, tabs and newlines separate values; a leading `-`
is honoured) and rendering the total back as decimal text before writing it to
the output file. Bad usage or an unreadable file produce a message on stderr and
exit status 1.
