# F# with Lisp

F# writes the numbers to an SBCL (Common Lisp) script's standard input and reads
the average back from its standard output.

| | |
|---|---|
| **Host language** | F# |
| **Guest language** | Common Lisp (SBCL) |
| **Bridge** | Child process + stdin/stdout |
| **Files** | `main.fsx`, `average.lisp` |

## Prerequisites

- The **.NET SDK** 6.0 or newer, which provides `dotnet fsi`
- **SBCL** (`sbcl`) on your `PATH`

## Build & run

There is nothing to compile — `dotnet fsi` runs the script directly:

```bash
dotnet fsi main.fsx                 # uses the built-in default data set
dotnet fsi main.fsx 1 2 3 4
dotnet fsi main.fsx -5 5 10
```

`main.fsx` locates `average.lisp` through `__SOURCE_DIRECTORY__`, so the sample
works from any working directory.

You can also exercise the Lisp side on its own:

```bash
echo "10 20 30" | sbcl --script average.lisp     # -> 20.00
```

## Expected output

```text
$ dotnet fsi main.fsx
The average of 5 value(s) is: 30.00

$ dotnet fsi main.fsx 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.fsx` starts `sbcl --script average.lisp` with `ProcessStartInfo`, wires up
redirected standard streams and writes the numbers in:

```fsharp
let startInfo = ProcessStartInfo()
startInfo.FileName <- "sbcl"
startInfo.ArgumentList.Add "--script"
startInfo.RedirectStandardInput <- true
```

Using `ArgumentList` rather than a single command string keeps the arguments
correctly quoted, and closing the standard input tells SBCL that the data is
complete.

`average.lisp` reads values with `read` until end-of-file, rejects anything that
is not a number, and prints the mean with `format`'s `~,2f` directive. Errors are
written to stderr and the script exits with status 1 via `sb-ext:exit`.

Numbers are parsed with `NumberStyles.Float` and `CultureInfo.InvariantCulture`
on the F# side so the decimal separator does not depend on the machine's locale.
