# OCaml with SCSS

The SCSS module **computes the average itself**. OCaml configures it with the
numbers under test, compiles it with Dart Sass, and reads the result back out of
the generated CSS.

| | |
|---|---|
| **Host language** | OCaml |
| **Guest language** | SCSS (Dart Sass) |
| **Bridge** | Child process + a generated CSS custom property |
| **Files** | `main.ml`, `average_calculator.scss` |

## Prerequisites

- **OCaml** 4.08 or newer (the interpreter, `ocaml`)
- **Dart Sass** (`sass`) on your `PATH`

## Build & run

There is nothing to compile:

```bash
ocaml main.ml                 # uses the built-in default data set
ocaml main.ml 1 2 3 4
ocaml main.ml -5 5 10
```

### Windows note

MSYS2's OCaml records its standard library under a Unix path
(`/ucrt64/lib/ocaml`), so invoking it from PowerShell needs:

```powershell
$env:OCAMLLIB = 'C:\msys64\ucrt64\lib\ocaml'
```

Running `ocaml main.ml` from the **MSYS2 UCRT64** shell needs no workaround.

## Expected output

```text
$ ocaml main.ml
The average of 5 value(s) is: 30.00

$ ocaml main.ml 1 2 3 4
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

`main.ml` writes a small entry file that configures the module —
`@use "average_calculator" with ($numbers: (10, 20, 30));` — runs `sass` on it,
and scans the compiled CSS for `--average`. Both temporary files are removed by a
`Fun.protect ~finally` handler.

Two details are worth noting. OCaml's `string_of_float` renders `10.0` as `10.`,
which Sass rejects with "Expected digit", so numbers are written with `%.10g`
instead. And the `--load-path` is taken from `dirname Sys.argv.(0)`, falling back
to the working directory when the interpreter does not report a usable path.
