# Haskell with Scala

Haskell sends the numbers to a Scala helper on **stdin**; the helper prints the
sum on stdout, and Haskell turns it into the average. There are no temporary
files — the process boundary is the only interface.

| | |
|---|---|
| **Host language** | Haskell |
| **Guest language** | Scala 3 |
| **Bridge** | Child process + stdin/stdout |
| **Files** | `main.hs`, `SumCalculator.scala` |

## Prerequisites

- **GHC** 8.10 or newer. The `process` library used here ships with GHC, as does
  `Text.Printf` from `base`.
- **[Scala CLI](https://scala-cli.virtuslab.org/)** (`scala`), used as a
  single-command Scala runner. A plain Scala 3 installation works too, as long
  as `scala SumCalculator.scala` runs the program.

## Build & run

```bash
ghc -O2 -o average main.hs
./average
```

Run `./average` from this directory: it invokes `scala SumCalculator.scala`
relative to the working directory.

You can also exercise the Scala helper on its own:

```bash
echo "10 20 30 40 50" | scala SumCalculator.scala    # -> 150.0
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00
```

## How it works

`main.hs` pipes the numbers into the helper and reads a single number back:

```haskell
(exitCode, stdout, stderr) <-
    readProcessWithExitCode "scala" ["SumCalculator.scala"] payload
```

Scala CLI writes its compilation progress to **stderr**, so `stdout` contains
nothing but the sum — which is what makes this protocol robust. A non-zero exit
code, or output that will not parse, makes the Haskell program fail with a
message on stderr.

`SumCalculator.scala` reads one line from stdin, splits it on whitespace and
prints `numbers.sum`; empty input is reported on stderr with exit status 1.
