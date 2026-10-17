# Ada with SQL

Ada loads the numbers into an in-memory SQLite database and runs the query in
`average_calculator.sql`, so the mean is computed **in SQL**.

| | |
|---|---|
| **Host language** | Ada |
| **Guest language** | SQL (SQLite) |
| **Bridge** | Child process + the `sqlite3` shell over stdin/stdout |
| **Files** | `main.adb`, `average_calculator.sql` |

## Prerequisites

- **GNAT**, the Ada frontend of GCC. On Linux: `apt install gnat`. On Windows,
  MSYS2 provides `mingw-w64-x86_64-gcc-ada`, and `msys64\mingw64\bin` must be on
  your `PATH`.
- The **SQLite command-line shell** (`sqlite3`) on your `PATH`

## Build & run

```bash
gnatmake main.adb -o main

./main                 # uses the built-in default data set
./main 1 2 3 4
./main -5 5 10
```

On Windows the Ada program is `main.exe`.

You can also run the query by hand:

```bash
sqlite3 :memory: "CREATE TABLE numbers(value REAL); INSERT INTO numbers VALUES (10),(20),(30); SELECT AVG(value) FROM numbers;"
```

## Expected output

```text
$ ./main
The average of 5 value(s) is: 30.00

$ ./main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Ada runs the shell with `GNAT.Expect.Get_Command_Output`, which starts a process,
feeds it standard input and returns everything it wrote to standard output
together with the exit status:

```ada
Output :=
  To_Unbounded_String
    (Get_Command_Output
       (Command   => "sqlite3",
        Arguments => Sqlite_Arguments,
        Input     => To_String (Script),
        Status    => Status'Access));
```

`Script` is assembled at run time: a `CREATE TABLE`, one `INSERT` per number, and
then the contents of `average_calculator.sql`, which is read from disk so the
query stays in one place. Passing the whole script on **stdin** avoids the
`sqlite3` quirk that treats an argument starting with `--` as an option — which
the query file's comment header would otherwise trigger.

Note that `Ada.Strings.Fixed.Trim` only removes spaces, not the newline `sqlite3`
writes, so the sample uses its own `Trimmed` helper before `Float'Value`.
