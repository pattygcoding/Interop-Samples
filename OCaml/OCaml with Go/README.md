# OCaml with Go

OCaml writes the numbers to a temporary file, runs a compiled Go program, and
reads the average back from the file the helper writes.

| | |
|---|---|
| **Host language** | OCaml |
| **Guest language** | Go |
| **Bridge** | Child process + temporary files |
| **Files** | `main.ml`, `average_calculator.go` |

## Prerequisites

- **OCaml** 4.08 or newer (the interpreter, `ocaml`)
- **Go** 1.18 or newer (`go`)

## Build & run

```bash
go build -o average_calculator average_calculator.go
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

`main.ml` uses only the OCaml standard library. It writes the numbers to a file,
invokes the helper with `Sys.command`, and reads the answer back:

```ocaml
match Sys.command command with
| 0 -> (* read and parse the output file *)
| status -> failwith (Printf.sprintf "the Go helper exited with status %d" status)
```

Both temporary files are removed by the `Fun.protect ~finally` handler, so the
sample cleans up even when the helper fails.

Running the interpreter rather than a compiled binary keeps the sample free of
linking requirements — on Windows, native compilation would additionally need
`flexlink` from the `flexdll` package.

`average_calculator.go` splits the input with `strings.Fields`, parses each token
with `strconv.ParseFloat`, writes `%.2f` to the output file, and reports any
problem on stderr with exit status 1.
