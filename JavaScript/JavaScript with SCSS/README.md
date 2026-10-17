# JavaScript with SCSS

The SCSS module **computes the average itself**. Node configures it with the
numbers under test, compiles it with Dart Sass, and reads the result back out of
the generated CSS.

| | |
|---|---|
| **Host language** | JavaScript (Node.js) |
| **Guest language** | SCSS (Dart Sass) |
| **Bridge** | In-process Sass compiler + a generated CSS custom property |
| **Files** | `main.js`, `average_calculator.scss`, `package.json` |

## Prerequisites

- **Node.js** 18 or newer

## Build & run

```bash
npm install
node main.js                 # uses the built-in default data set
node main.js 1 2 3 4
node main.js -5 5 10
```

## Expected output

```text
$ node main.js
The average of 5 value(s) is: 30.00

$ node main.js 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`average_calculator.scss` is a real Sass module. It takes `$numbers` as a
configurable variable, sums the list with `@each` and divides by `list.length`,
then emits the answer as a CSS custom property:

```scss
:root {
  --average: #{average($numbers)};
}
```

`main.js` writes a small entry file that configures the module —
`@use "average_calculator" with ($numbers: (10, 20, 30, 40, 50));` — compiles it
through the Sass JavaScript API and extracts `--average` from the CSS. The
temporary directory is removed in a `finally` block.

Using the JS API instead of the `sass` command-line tool sidesteps a
Windows-specific problem: `sass` installs as a `.cmd` shim, which Node's `spawn`
will not execute directly.
