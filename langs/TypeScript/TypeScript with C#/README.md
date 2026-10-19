# TypeScript with C#

TypeScript on Node.js runs a .NET console app, passing the numbers as
command-line arguments and reading the average back from stdout.

| | |
|---|---|
| **Host language** | TypeScript (Node.js) |
| **Guest language** | C# (.NET) |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.ts`, `Program.cs`, `AverageCalculator.csproj`, `tsconfig.json`, `package.json` |

## Prerequisites

- **Node.js** 18 or newer
- **TypeScript** and the Node type definitions — installed by `npm install`
- **.NET SDK** 8.0 or newer (`dotnet`)

## Build & run

```bash
npm install
npm run build            # tsc, emits build/main.js
npm start
node build/main.js 1 2 3 4
node build/main.js -5 5 10
```

The .NET project is built automatically the first time it runs, and `main.ts`
resolves it from its own compiled location, so the sample works from any working
directory.

You can also exercise the C# side on its own:

```bash
dotnet run --project . -- 10 20 30     # -> 20.00
```

## Expected output

```text
$ npm start
The average of 5 value(s) is: 30.00

$ node build/main.js 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.ts` spawns the helper and passes the numbers after a `--` separator, which
is how `dotnet run` distinguishes its own options from the application's:

```ts
const child = spawn(
  'dotnet',
  ['run', '--project', projectPath, '-v', 'quiet', '--', ...numbers.map(String)],
  { stdio: ['ignore', 'pipe', 'pipe'] }
);
```

The compiled output lives in `build/`, so the C# project — which sits beside the
TypeScript source — is resolved as `path.resolve(__dirname, '..')`.

`Program.cs` parses each argument with `double.TryParse` using
`NumberStyles.Float`/`CultureInfo.InvariantCulture` and prints the mean with
`ToString("0.00", CultureInfo.InvariantCulture)`, returning 1 for bad input.

> `dotnet run` has no `--nologo` option — passing it forwards the flag to the
> application. `-v quiet` is the supported way to silence the build.
