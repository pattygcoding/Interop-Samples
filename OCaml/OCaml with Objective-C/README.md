# OCaml with Objective-C

OCaml passes the numbers as command-line arguments to a compiled Objective-C
program and reads the average back from a file the helper's output is redirected
to.

| | |
|---|---|
| **Host language** | OCaml |
| **Guest language** | Objective-C |
| **Bridge** | Child process + shell redirection |
| **Files** | `main.ml`, `average_calculator.m` |

## Prerequisites

- **OCaml** 4.08 or newer (the interpreter, `ocaml`)
- A C compiler with an **Objective-C frontend** and the GNU Objective-C runtime:
  - **Windows (MSYS2):** `mingw-w64-x86_64-gcc-objc` and
    `mingw-w64-x86_64-libobjc`. `msys64\mingw64\bin` must be on `PATH`, both so
    `gcc` is found and so the helper can load `libobjc-4.dll` at run time.
  - **Linux:** `apt install gobjc` (or `gcc-objc`)

## Build & run

```bash
gcc -std=gnu11 -Wno-objc-root-class average_calculator.m -o average_calculator -lobjc

ocaml main.ml                 # uses the built-in default data set
ocaml main.ml 1 2 3 4
ocaml main.ml -5 5 10
```

On Windows the helper is `average_calculator.exe`; `main.ml` checks `Sys.win32`
and looks for the right name.

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

`main.ml` runs the helper through the shell, redirecting its output to a
temporary file, and reads the file back:

```ocaml
let command =
  Printf.sprintf "%s %s > %s" executable
    (String.concat " " (List.map render_number numbers))
    (Filename.quote output)
```

The file is removed by a `Fun.protect ~finally` handler, so the sample cleans up
even when the helper fails.

`average_calculator.m` deliberately avoids Foundation — it declares its own root
class and allocates it with the runtime function `class_createInstance`, so
`libobjc` is the only library it needs. Two build details matter: `-std=gnu11`
because GCC's Objective-C frontend still defaults to C89, and
`-Wno-objc-root-class` to silence the expected warning about a class with no
superclass.
