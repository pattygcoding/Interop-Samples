# Haxe with SCSS

The SCSS module **computes the average itself**. Haxe — compiled to Neko bytecode
— configures it with the numbers under test, compiles it with Dart Sass, and reads
the result back out of the generated CSS.

| | |
|---|---|
| **Host language** | Haxe (Neko target) |
| **Guest language** | SCSS (Dart Sass) |
| **Bridge** | Child process + a generated CSS custom property |
| **Files** | `Main.hx`, `average_calculator.scss` |

## Prerequisites

- **Haxe** 4.0 or newer, plus **Neko** (`neko`) — both ship in the standard Haxe
  distribution
- **Dart Sass** (`sass`) on your `PATH`

## Build & run

```bash
haxe -cp . -main Main -neko main.n
neko main.n                 # uses the built-in default data set
neko main.n 1 2 3 4
neko main.n -5 5 10
```

You can also compile the module by hand:

```bash
echo '@use "average_calculator" with ($numbers: (10, 20, 30));' > entry.scss
sass --load-path . entry.scss out.css && cat out.css
```

## Expected output

```text
$ neko main.n
The average of 5 value(s) is: 30.00

$ neko main.n 1 2 3 4
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

`Main.hx` writes a one-line entry file into a scratch directory —
`@use "average_calculator" with ($numbers: (10, 20, 30));` — compiles it, and
extracts `--average` from the CSS with a regular expression.

This sample uses `Sys.command` rather than `sys.io.Process`, and the reason is
worth remembering: on Windows `sass` installs as a `.cmd` shim, which
`CreateProcess` cannot start, so Neko's `Process` fails outright. `Sys.command`
runs the line through the platform's command processor instead, which can.

Two Haxe-specific details also show up here. There is no `finally` clause, so the
scratch files are removed by hand after a `try`/`catch`; and a literal `$` inside
an interpolated string is written `$$`, not `\$`.
