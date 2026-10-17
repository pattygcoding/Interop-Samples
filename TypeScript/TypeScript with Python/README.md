# TypeScript with Python

TypeScript on Node.js spawns a Python program and exchanges data with it over
**stdin/stdout** using JSON.

| | |
|---|---|
| **Host language** | TypeScript (Node.js) |
| **Guest language** | Python 3 |
| **Bridge** | Child process + JSON on stdin/stdout |
| **Files** | `main.ts`, `average_calculator.py`, `tsconfig.json`, `package.json` |

## Prerequisites

- **Node.js** 18 or newer
- **TypeScript** and the Node type definitions — installed by `npm install`
- **Python 3.9+** on your `PATH`

## Build & run

```bash
npm install
npm run build            # tsc, emits build/main.js
npm start                # node build/main.js
node build/main.js 1 2 3 4
node build/main.js -5 5 10
```

`main.ts` resolves the Python script relative to the compiled output, so the
sample works from any working directory.

If your Python interpreter is not called `python` (on many Unix systems it is
`python3`), set the `PYTHON` environment variable:

```bash
PYTHON=python3 node build/main.js
```

You can also exercise the Python side on its own:

```bash
echo "[10,20,30]" | python average_calculator.py
```

## Expected output

```text
$ npm start
The average of 5 value(s) is: 30.00

$ node build/main.js 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.ts` spawns the helper, pipes a JSON array to its standard input and parses
the single number it writes back:

```ts
const child = spawn(PYTHON, [scriptPath], { stdio: ['pipe', 'pipe', 'pipe'] });
child.stdin.end(JSON.stringify(numbers));
```

The compiled output lives in `build/`, so the Python script — which sits beside
the TypeScript source — is resolved as `path.resolve(__dirname, '..', ...)`.

`average_calculator.py` reads stdin, decodes the array with `json.loads`, and
prints the mean. Non-JSON input, an empty array and non-numeric elements are all
reported on stderr with exit status 1, which the TypeScript side turns into a
rejected promise and a non-zero exit code.
