# JavaScript with SQL

Node.js loads the numbers into an in-memory SQLite database and runs the query in
`average_calculator.sql`, so the mean is computed **in SQL**.

| | |
|---|---|
| **Host language** | JavaScript (Node.js) |
| **Guest language** | SQL (SQLite) |
| **Bridge** | Child process + the `sqlite3` shell over stdin/stdout |
| **Files** | `main.js`, `average_calculator.sql` |

## Prerequisites

- **Node.js** 18 or newer
- The **SQLite command-line shell** (`sqlite3`) on your `PATH`

## Build & run

There is nothing to compile:

```bash
node main.js                 # uses the built-in default data set
node main.js 1 2 3 4
node main.js -5 5 10
```

You can also run the query by hand:

```bash
sqlite3 :memory: "CREATE TABLE numbers(value REAL); INSERT INTO numbers VALUES (10),(20),(30); SELECT AVG(value) FROM numbers;"
```

## Expected output

```text
$ node main.js
The average of 5 value(s) is: 30.00

$ node main.js 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.js` spawns the shell, writes the whole script to its standard input and
reads the answer back:

```js
const child = spawn('sqlite3', ['-batch', ':memory:'], { stdio: ['pipe', 'pipe', 'pipe'] });
child.stdin.end(statement);
```

The script is built at run time: a `CREATE TABLE`, one `INSERT` per number, and
then the contents of `average_calculator.sql`, which is read from disk so the
query stays in one place. Feeding it on **stdin** avoids a `sqlite3` quirk: an
argument that begins with `--` is read as a command-line option, which the query
file's comment header would otherwise trigger.

`average_calculator.sql` holds the entire computation:

```sql
SELECT AVG(value) FROM numbers;
```
