# Shell with VB / VB.NET

A POSIX shell passes the numbers as command-line arguments to a VB.NET console
app and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Shell (POSIX `sh`) |
| **Guest language** | VB.NET |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.sh`, `Program.vb`, `AverageCalculator.vbproj` |

## Prerequisites

- A POSIX shell. On Linux and macOS that is `/bin/sh`; on Windows use **Git Bash**
  or **MSYS2**.
- **.NET SDK** 8.0 or newer (`dotnet`), which includes the VB compiler

## Build & run

The .NET project is built automatically the first time it runs.

```bash
sh main.sh                 # uses the built-in default data set
sh main.sh 1 2 3 4
sh main.sh -5 5 10
```

On Windows, run it through Git Bash:

```bash
"C:/Program Files/Git/bin/bash.exe" main.sh
```

You can also exercise the VB side on its own:

```bash
dotnet run --project . -- 10 20 30     # -> 20.00
```

## Expected output

```text
$ sh main.sh
The average of 5 value(s) is: 30.00

$ sh main.sh 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.sh` filters the arguments with a POSIX `case` pattern — anything containing
a character outside `0-9.+-` is dropped with a warning — and then hands the
survivors to `dotnet`:

```sh
average=$(dotnet run --project "$project_directory" -v quiet -- "$@")
```

The project directory comes from `dirname "$0"`, so the script works no matter
where it is invoked from. Because a POSIX shell has no way to format floats, the
VB.NET side does the `%.2f` formatting itself with
`ToString("0.00", CultureInfo.InvariantCulture)`.
