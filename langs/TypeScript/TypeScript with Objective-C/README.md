# TypeScript with Objective-C

TypeScript on Node.js passes the numbers as command-line arguments to a compiled
Objective-C program and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | TypeScript (Node.js) |
| **Guest language** | Objective-C |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.ts`, `average_calculator.m`, `tsconfig.json`, `package.json` |

## Prerequisites

- **Node.js** 18 or newer
- **TypeScript** and the Node type definitions — installed by `npm install`
- A C compiler with an **Objective-C frontend** and the GNU Objective-C runtime:
  - **Windows (MSYS2):** `mingw-w64-x86_64-gcc-objc` and
    `mingw-w64-x86_64-libobjc`. `msys64\mingw64\bin` must be on your `PATH`, both
    so `gcc` is found and so the helper can load `libobjc-4.dll` at run time.
  - **Linux:** `apt install gobjc` (or `gcc-objc`)

## Build & run

```bash
gcc -std=gnu11 -Wno-objc-root-class average_calculator.m -o average_calculator -lobjc

npm install
npm run build            # tsc, emits build/main.js
npm start
node build/main.js 1 2 3 4
node build/main.js -5 5 10
```

On Windows the helper is `average_calculator.exe`; `main.ts` detects the platform
and looks for the right name.

You can also exercise the Objective-C side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ npm start
The average of 5 value(s) is: 30.00

$ node build/main.js 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.ts` spawns the helper with an argument vector, so no shell is involved and
paths containing spaces are safe:

```ts
const child = spawn(executable, numbers.map(String), { stdio: ['ignore', 'pipe', 'pipe'] });
```

The compiled output lives in `build/`, so the helper — which sits beside the
TypeScript source — is resolved as `path.resolve(__dirname, '..', ...)`.

Arguments are converted one at a time by `parseNumbers`, which reports anything
unparsable and drops it. Mapping the raw tokens with `Number()` would turn bad
input into `NaN`, and the helper would then average `NaN` as if it were a value.

`average_calculator.m` deliberately avoids Foundation: it declares its own root
class and allocates it with the runtime function `class_createInstance`, so
`libobjc` is the only library it needs. Two build details matter: `-std=gnu11`
because GCC's Objective-C frontend still defaults to C89, and
`-Wno-objc-root-class` to silence the expected warning about a class with no
superclass.
