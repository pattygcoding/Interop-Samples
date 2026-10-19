# Ada with Lisp

Ada feeds the numbers to an SBCL (Common Lisp) script on standard input and reads
the average back from its standard output.

| | |
|---|---|
| **Host language** | Ada |
| **Guest language** | Common Lisp (SBCL) |
| **Bridge** | Child process + stdin/stdout |
| **Files** | `main.adb`, `average_calculator.lisp` |

## Prerequisites

- **GNAT**, the Ada frontend of GCC. On Linux: `apt install gnat`. On Windows,
  MSYS2 provides `mingw-w64-x86_64-gcc-ada`, and `msys64\mingw64\bin` must be on
  your `PATH`.
- **SBCL** (`sbcl`) on your `PATH`

## Build & run

```bash
gnatmake main.adb -o main

./main                 # uses the built-in default data set
./main 1 2 3 4
./main -5 5 10
```

On Windows the Ada program is `main.exe`.

You can also exercise the Lisp side on its own:

```bash
echo "10 20 30" | sbcl --script average_calculator.lisp     # -> 20.00
```

## Expected output

```text
$ ./main
The average of 5 value(s) is: 30.00

$ ./main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Ada runs the helper with `GNAT.Expect.Get_Command_Output`, which starts a
process, feeds it standard input and returns everything it wrote to standard
output together with the exit status:

```ada
Output :=
  To_Unbounded_String
    (Get_Command_Output
       (Command   => "sbcl",
        Arguments => Sbcl_Arguments,
        Input     => To_String (Payload),
        Status    => Status'Access));
```

The numbers are rendered with `Float'Image` (minus its leading space) so the Lisp
reader can parse them, and the result is parsed with `Float'Value` after trimming
whitespace — `Ada.Strings.Fixed.Trim` only removes spaces, not the newline SBCL
writes, so the sample uses its own `Trimmed` helper.

`average_calculator.lisp` reads values with `read` until end-of-file, rejects
anything that is not a number, and prints the mean with `format`'s `~,2f`
directive. Errors go to stderr and the script exits with status 1 via
`sb-ext:exit`.
