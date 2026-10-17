# JavaScript with Perl

Node.js passes the numbers as command-line arguments to a Perl script and reads
the average it prints back from stdout.

| | |
|---|---|
| **Host language** | JavaScript (Node.js) |
| **Guest language** | Perl |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.js`, `average_calculator.pl` |

## Prerequisites

- **Node.js** 18 or newer
- **Perl** 5.16 or newer (`perl`) on your `PATH` — preinstalled on Linux and macOS

## Build & run

There is nothing to compile:

```bash
node main.js                 # uses the built-in default data set
node main.js 1 2 3 4
node main.js -5 5 10
```

You can also exercise the Perl side on its own:

```bash
perl average_calculator.pl 10 20 30     # -> 20.00
```

## Expected output

```text
$ node main.js
The average of 5 value(s) is: 30.00

$ node main.js 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.js` spawns the helper with an argument vector and drains both pipes before
checking the exit code, which avoids the classic pipe-buffer deadlock:

```js
const child = spawn('perl', [SCRIPT, ...numbers.map(String)], { stdio: ['ignore', 'pipe', 'pipe'] });
```

Arguments are vetted in JavaScript first, so `NaN` never reaches the script.

`average_calculator.pl` checks each argument's shape with a regular expression
before adding it:

```perl
if ($token !~ /\A-?(?:\d+(?:\.\d*)?|\.\d+)\z/) { ... }
```

That check matters. Perl's automatic string-to-number conversion is very
forgiving: `12abc` would silently become `12` and `hello` would become `0`, so
without it a bad argument would quietly skew the average instead of failing. The
result is printed with `printf "%.2f"`.
