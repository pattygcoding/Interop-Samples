# F# with SCSS

The SCSS module **computes the average itself**. F# configures it with the numbers
under test, compiles it with Dart Sass, and reads the result back out of the
generated CSS.

| | |
|---|---|
| **Host language** | F# |
| **Guest language** | SCSS (Dart Sass) |
| **Bridge** | Child process + a generated CSS custom property |
| **Files** | `main.fsx`, `average_calculator.scss` |

## Prerequisites

- The **.NET SDK** 8.0 or newer, which includes `dotnet fsi`
- **Dart Sass** (`sass`) on your `PATH`

## Build & run

There is nothing to compile — the sample is an F# script:

```bash
dotnet fsi main.fsx                 # uses the built-in default data set
dotnet fsi main.fsx 1 2 3 4
dotnet fsi main.fsx -5 5 10
```

You can also compile the module by hand:

```bash
echo '@use "average_calculator" with ($numbers: (10, 20, 30));' > entry.scss
sass --load-path . entry.scss out.css && cat out.css
```

## Expected output

```text
$ dotnet fsi main.fsx
The average of 5 value(s) is: 30.00

$ dotnet fsi main.fsx 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`average_calculator.scss` is a real Sass module: it takes `$numbers` as a
configurable variable, sums the list with `@each`, divides by `list.length`, and
emits the answer as a CSS custom property:

```scss
:root {
  --average: #{average($numbers)};
}
```

`main.fsx` writes a one-line entry file into a temporary directory —
`@use "average_calculator" with ($numbers: (10, 20, 30));` — compiles it, and
extracts `--average` from the CSS with a regular expression. The scratch directory
is removed in a `finally` block, so it is cleaned up even when compilation fails.

On Windows the command is run as `cmd /c sass ...`, because `sass` installs as a
`.cmd` shim and `Process.Start` with `UseShellExecute = false` cannot start a
batch file directly:

```fsharp
let sassInvocation (arguments: string list) =
    if OperatingSystem.IsWindows() then
        "cmd", [ "/c"; "sass" ] @ arguments
    else
        "sass", arguments
```
