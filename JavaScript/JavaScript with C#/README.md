# JavaScript with C#

Node.js spawns a .NET console program as a child process and exchanges data
with it over **stdin/stdout** using JSON.

| | |
|---|---|
| **Host language** | JavaScript (Node.js) |
| **Guest language** | C# (.NET) |
| **Bridge** | Child process + JSON over stdin/stdout |
| **Files** | `main.js`, `Program.cs`, `AverageCalculator.csproj` |

## Prerequisites

- **Node.js** 18 or newer
- **.NET SDK** 8.0 or newer (`dotnet`)

## Build & run

The .NET project is built automatically the first time it runs.

```bash
node main.js                 # uses the built-in default data set
node main.js 1 2 3 4         # average of the numbers you pass
```

Run it from any directory — `main.js` resolves the C# project relative to its
own location.

You can also exercise the C# side on its own:

```bash
echo "[10,20,30]" | dotnet run --project .
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
const child = spawn('dotnet', ['run', '--project', PROJECT, '-v', 'quiet', '--nologo'], {
  stdio: ['pipe', 'pipe', 'pipe'],
});
child.stdin.end(JSON.stringify(numbers));
```

`Program.cs` deserializes the array with the built-in `System.Text.Json` (no
NuGet packages required) and prints the mean with `CultureInfo.InvariantCulture`
so the decimal separator does not depend on the machine's locale. It returns a
non-zero exit code and a message on `stderr` for empty or malformed input, which
`main.js` surfaces as a rejected `Promise`.

The module also exports `calculateAverage(numbers)` so it can be required from
other scripts.
