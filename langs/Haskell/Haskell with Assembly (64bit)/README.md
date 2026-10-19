# Haskell with Assembly (64-bit)

Haskell drives a **hand-written x86-64 assembly** program. Haskell writes the
numbers to a scratch file, the assembly program reads them, adds them up and
writes the total to a second file, and Haskell then prints the average.

| | |
|---|---|
| **Host language** | Haskell |
| **Guest language** | x86-64 assembly (NASM) |
| **Bridge** | Child process + text files |
| **Files** | `main.hs`, `sum_calc.asm` |
| **Platform** | **Linux x86-64 only** — the assembly issues raw `syscall` instructions |

## Prerequisites

- **GHC** 8.10 or newer. The `process`, `directory` and `filepath` libraries used
  here ship with GHC, as does `Text.Printf` from `base`.
- **NASM** 2.14 or newer
- A Linux x86-64 environment (a native system, WSL, or a container)

## Build & run

```bash
nasm -f elf64 sum_calc.asm -o sum_calc.o
ld sum_calc.o -o sum_calc

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

`sum_calc.asm` is a freestanding Linux program — no libc. It opens and reads the
input file with the `open`/`read`/`close` syscalls, parses the integers from the
raw buffer (spaces, tabs and newlines all act as separators, and a leading `-`
is honoured), renders the total as decimal text and writes it out with the
`open`/`write`/`close` syscalls. Bad usage or an unreadable file produce a
message on stderr and exit status 1.
