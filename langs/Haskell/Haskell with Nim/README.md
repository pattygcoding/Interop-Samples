# Haskell with Nim

Haskell passes the numbers as command-line arguments to a compiled Nim program and
reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Haskell |
| **Guest language** | Nim |
| **Bridge** | Child process + argv/stdout |
| **Files** | `Main.hs`, `average_calculator.nim` |

## Prerequisites

- **GHC** 9.x, which includes `runghc`
- The **Nim compiler** (`nim`) with a C backend (gcc or clang)

## Build & run

```bash
nim c -d:release average_calculator.nim

runghc Main.hs                 # uses the built-in default data set
runghc Main.hs 1 2 3 4
runghc Main.hs -5 5 10
```

To produce a binary instead: `ghc -O2 -o average Main.hs`.

On Windows, Nim writes `average_calculator.exe`, which is exactly what
`Main.hs` looks for — the executable name gains `.exe` when `System.Info.os` is
`mingw32`.

You can also exercise the Nim side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ runghc Main.hs
The average of 5 value(s) is: 30.00

$ runghc Main.hs 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`Main.hs` runs the helper with `readProcessWithExitCode`, which hands back the
exit code together with both streams:

```haskell
(exitCode, output, errors) <- readProcessWithExitCode executable (map show numbers) ""
```

On success the printed value is parsed with `reads`, which conveniently reports
what it could not consume — the trailing newline is accepted because the
remainder is checked with `all isSpace`. A non-zero exit is turned into the
helper's own message and a matching non-zero exit status.

One Haskell trap is worth noting: `printf` inside a `do` block needs its result
type pinned down. The warning is therefore written with
`hPutStrLn stderr (printf ...)` rather than a bare `printf`, which GHC otherwise
rejects as an ambiguous `PrintfType`.

`average_calculator.nim` converts each argument with `parseFloat`, which raises
`ValueError` on bad input, and prints `formatFloat(total / count, ffDecimal, 2)`
— which always uses a dot, regardless of locale.
