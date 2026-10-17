# Julia with SQL

Julia loads the numbers into a temporary SQLite database and runs the query in
`average_calculator.sql`, so the mean is computed **in SQL**.

| | |
|---|---|
| **Host language** | Julia |
| **Guest language** | SQL (SQLite) |
| **Bridge** | Child process + the `sqlite3` shell over stdin/stdout |
| **Files** | `main.jl`, `average_calculator.sql` |

## Prerequisites

- **Julia** 1.6 or newer
- The **SQLite command-line shell** (`sqlite3`) on your `PATH`

## Build & run

```bash
julia main.jl                 # uses the built-in default data set
julia main.jl 1 2 3 4
julia main.jl -5 5 10
```

You can also run the query by hand:

```bash
sqlite3 :memory: "CREATE TABLE numbers(value REAL); INSERT INTO numbers VALUES (10),(20),(30); SELECT AVG(value) FROM numbers;"
```

## Expected output

```text
$ julia main.jl
The average of 5 value(s) is: 30.00

$ julia main.jl 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.jl` creates a temporary database, inserts the numbers, and pipes the
contents of `average_calculator.sql` into the shell:

```julia
function sqlite(db, statement)
    output = IOBuffer()
    run(pipeline(`sqlite3 -batch $db`; stdin = IOBuffer(statement), stdout = output))
    return String(take!(output))
end
```

Feeding the statement on **stdin** rather than as an argument matters: the SQL
file opens with a `--` comment, which `sqlite3` would otherwise try to read as a
command-line option. `run` raises when the shell exits non-zero, and the
temporary database is removed in a `finally` block.

`average_calculator.sql` holds the entire computation:

```sql
SELECT AVG(value) FROM numbers;
```
