# Ada with Kotlin

Ada feeds the numbers to a compiled Kotlin program on standard input and reads
the average back from its standard output.

| | |
|---|---|
| **Host language** | Ada |
| **Guest language** | Kotlin |
| **Bridge** | Child process + stdin/stdout |
| **Files** | `main.adb`, `AverageCalculator.kt` |

## Prerequisites

- **GNAT**, the Ada frontend of GCC. On Linux: `apt install gnat`. On Windows,
  MSYS2 provides `mingw-w64-x86_64-gcc-ada`, and `msys64\mingw64\bin` must be on
  your `PATH`.
- **JDK 11+** (`java`)
- The **Kotlin compiler** (`kotlinc`)

## Build & run

```bash
kotlinc AverageCalculator.kt -include-runtime -d AverageCalculator.jar
gnatmake main.adb -o main

./main                 # uses the built-in default data set
./main 1 2 3 4
./main -5 5 10
```

On Windows the Ada program is `main.exe`.

You can also exercise the Kotlin side on its own:

```bash
echo "10 20 30" | java -jar AverageCalculator.jar     # -> 20.00
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
output together with its exit status:

```ada
Output :=
  To_Unbounded_String
    (Get_Command_Output
       (Command   => "java",
        Arguments => Jar_Arguments,
        Input     => To_String (Payload),
        Status    => Status'Access));
```

The numbers are rendered with `Float'Image` (minus its leading space) so Kotlin's
parser can read them, and the result is parsed with `Float'Value` after trimming
whitespace — note that `Ada.Strings.Fixed.Trim` only removes spaces, not the
newline the helper writes.

`GNAT.Expect` ships with GNAT, so nothing beyond a standard Ada installation is
required.
