# Ada with JavaScript

Ada feeds the numbers to a Node.js program on standard input and reads the
average it prints back from standard output.

| | |
|---|---|
| **Host language** | Ada |
| **Guest language** | JavaScript (Node.js) |
| **Bridge** | Child process + stdin/stdout |
| **Files** | `main.adb`, `average_calculator.js` |

## Prerequisites

- **GNAT**, the Ada frontend of GCC. On Linux: `apt install gnat`. On Windows,
  MSYS2 provides `mingw-w64-x86_64-gcc-ada`, and `msys64\mingw64\bin` must be on
  your `PATH`.
- **Node.js** 18 or newer (`node`)

## Build & run

```bash
gnatmake main.adb -o main

./main                 # uses the built-in default data set
./main 1 2 3 4
./main -5 5 10
```

On Windows the Ada program is `main.exe`.

You can also exercise the JavaScript side on its own:

```bash
echo "10 20 30" | node average_calculator.js     # -> 20.00
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
       (Command   => "node",
        Arguments => Node_Arguments,
        Input     => To_String (Payload),
        Status    => Status'Access));
```

The numbers are rendered with `Float'Image` (minus its leading space), which
produces values like `1.00000000000000E+01` — JavaScript's `parseFloat` reads that
form without complaint. The result is parsed with `Float'Value` after trimming
whitespace, using the sample's own `Trimmed` helper because
`Ada.Strings.Fixed.Trim` only removes spaces, not the newline Node writes.

`average_calculator.js` buffers stdin, splits it on whitespace, and prints
`(total / count).toFixed(2)`.
