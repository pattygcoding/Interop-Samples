# JavaScript with Dart

Node.js spawns a Dart program as a child process and exchanges data with it over
**stdin/stdout** using JSON.

| | |
|---|---|
| **Host language** | JavaScript (Node.js) |
| **Guest language** | Dart |
| **Bridge** | Child process + JSON over stdin/stdout |
| **Files** | `main.js`, `average_calculator.dart` |

## Prerequisites

- **Node.js** 18 or newer
- The **Dart SDK** (`dart`) 3.0 or newer, on your `PATH`

## Build & run

```bash
node main.js                 # uses the built-in default data set
node main.js 1 2 3 4         # average of the numbers you pass
```

Run it from any directory — `main.js` resolves the Dart script relative to its
own location.

You can also exercise the Dart side on its own:

```bash
echo "[10,20,30]" | dart average_calculator.dart
```

## Expected output

```text
$ node main.js
The average of 5 value(s) is: 30.00

$ node main.js 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.js` writes `JSON.stringify(numbers)` to the child's stdin and reads the
result from stdout:

```js
const child = spawn('dart', [SCRIPT], { stdio: ['pipe', 'pipe', 'pipe'] });
child.stdin.end(JSON.stringify(numbers));
```

`average_calculator.dart` decodes the JSON with `dart:convert`, folds the values
into a sum, and writes `sum / count` to stdout. Invalid or empty input is
reported on `stderr` with a non-zero exit code, which `main.js` turns into a
rejected `Promise`.

The module also exports `calculateAverage(numbers)` so it can be required from
other scripts.
