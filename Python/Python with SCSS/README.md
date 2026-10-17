# Python with SCSS

The SCSS module **computes the average itself**. Python configures it with the
numbers under test, compiles it with Dart Sass, and reads the result back out of
the generated CSS.

| | |
|---|---|
| **Host language** | Python 3 |
| **Guest language** | SCSS (Dart Sass) |
| **Bridge** | Child process + a generated CSS custom property |
| **Files** | `main.py`, `average_calculator.scss` |

## Prerequisites

- **Python 3.9+**
- **Dart Sass** (`sass`) on your `PATH`

## Build & run

There is nothing to compile:

```bash
python3 main.py                 # uses the built-in default data set
python3 main.py 1 2 3 4
python3 main.py -5 5 10
```

You can also compile the module by hand:

```bash
echo '@use "average_calculator" with ($numbers: (10, 20, 30));' > /tmp/entry.scss
sass --load-path . /tmp/entry.scss /tmp/out.css && cat /tmp/out.css
```

## Expected output

```text
$ python3 main.py
The average of 5 value(s) is: 30.00

$ python3 main.py 1 2 3 4
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

`main.py` writes a small entry file that configures the module —
`@use "average_calculator" with ($numbers: (10, 20, 30));` — compiles it, and
scans the CSS for `--average` with a regular expression. The temporary directory
is cleaned up by the `with tempfile.TemporaryDirectory(...)` block, even when the
compiler fails.

On Windows the command is run as `cmd /c sass ...`, because `sass` installs as a
`.cmd` shim and `CreateProcess` cannot execute batch files directly:

```python
SASS = ["cmd", "/c", "sass"] if sys.platform == "win32" else ["sass"]
```
