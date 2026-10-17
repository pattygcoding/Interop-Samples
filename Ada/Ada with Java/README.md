# Ada with Java

Ada builds the numbers into the Java helper's argument list and reads the average
it prints back from standard output.

| | |
|---|---|
| **Host language** | Ada |
| **Guest language** | Java |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.adb`, `AverageCalculator.java` |

## Prerequisites

- **GNAT**, the Ada frontend of GCC. On Linux: `apt install gnat`. On Windows,
  MSYS2 provides `mingw-w64-x86_64-gcc-ada`, and `msys64\mingw64\bin` must be on
  your `PATH`.
- A **JDK** 11 or newer, providing `javac` and `java`

## Build & run

```bash
javac AverageCalculator.java
gnatmake main.adb -o main

./main                 # uses the built-in default data set
./main 1 2 3 4
./main -5 5 10
```

On Windows the Ada program is `main.exe`. The class file must sit in the working
directory, because the helper is launched as `java AverageCalculator` with the
default classpath.

You can also exercise the Java side on its own:

```bash
java AverageCalculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./main
The average of 5 value(s) is: 30.00

$ ./main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Ada runs the helper with `GNAT.Expect.Get_Command_Output`, which starts a process,
hands it a command line and returns everything it wrote to standard output
together with the exit status. The argument list is one longer than the number
count, because the class name comes first:

```ada
declare
   Arguments : Argument_List (1 .. Count + 1);
begin
   Arguments (1) := new String'("AverageCalculator");
   ...
end;
```

The array bound is computed at run time, which is why the declaration sits in a
nested block after the numbers have been collected.

Numbers are rendered with `Float'Image` (minus its leading space), producing
values like `1.00000000000000E+01`; Java's `Double.parseDouble` reads that form
without complaint. The result is parsed with `Float'Value` after trimming
whitespace — using the sample's own `Trimmed` helper, because
`Ada.Strings.Fixed.Trim` only removes spaces, not the newline Java writes.

`AverageCalculator.java` parses each argument with `Double.parseDouble` and prints
through `System.out.printf(Locale.ROOT, "%.2f%n", ...)`, so the decimal separator
does not depend on the machine's default locale.
