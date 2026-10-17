# Elixir with Fortran

Elixir passes the numbers as command-line arguments to a compiled Fortran program
and reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | Elixir |
| **Guest language** | Fortran |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.exs`, `average_calculator.f90` |

## Prerequisites

- **Elixir** 1.12 or newer, with a working Erlang/OTP installation
- **gfortran** (GNU Fortran)

## Build & run

```bash
gfortran -O2 -o average_calculator average_calculator.f90
elixir main.exs                 # uses the built-in default data set
elixir main.exs 1 2 3 4
elixir main.exs -5 5 10
```

On Windows the helper is `average_calculator.exe`; the script detects the platform
and looks for the right name.

You can also exercise the Fortran side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ elixir main.exs
The average of 5 value(s) is: 30.00

$ elixir main.exs 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Elixir runs the helper with `System.cmd`, which returns the output and the exit
status together:

```elixir
case System.cmd(executable, arguments) do
  {output, 0} -> parse_output(output)
  {output, status} -> {:error, failure_message(output, status)}
end
```

Because `System.cmd` only captures **stdout**, the Fortran helper writes its error
messages there too rather than to stderr — otherwise they would be lost. The call
is wrapped in a `try/rescue` so a missing helper produces a readable message
instead of an exception trace.

`average_calculator.f90` reads its arguments with `get_command_argument` and
list-directed `read`, sums them, and prints the mean with the `F0.2` edit
descriptor, which yields exactly two decimals without a fixed field width.
