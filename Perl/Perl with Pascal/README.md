# Perl with Pascal

Perl writes the numbers to a temporary file, compiles a **Free Pascal** helper
on the fly and runs it to compute the average.

| | |
|---|---|
| **Host language** | Perl |
| **Guest language** | Pascal (Free Pascal) |
| **Bridge** | Child process + temporary text file |
| **Files** | `main.pl`, `average.pas` |

## Prerequisites

- **Perl** 5.10 or newer
- The **Free Pascal Compiler** (`fpc`) on your `PATH`

## Build & run

`main.pl` compiles `average.pas` itself, into a scratch directory, so there is
nothing to build by hand:

```bash
perl main.pl                 # uses the built-in default data set
perl main.pl 1 2 3 4         # average of the numbers you pass
```

You can also compile and run the Pascal helper directly:

```bash
fpc average.pas
./average numbers.txt        # one or more whitespace-separated numbers
```

## Expected output

```text
$ perl main.pl
The average of 5 value(s) is: 30.00

$ perl main.pl 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

1. Perl validates the arguments with `Scalar::Util::looks_like_number` and writes
   them to a temporary file (`File::Temp`).
2. It copies `average.pas` into a scratch directory, runs `fpc`, and checks the
   exit status — build artefacts never touch the repository.
3. It executes the compiled helper, passing the data file path as `argv[1]`, and
   prints the average the helper writes to stdout.

The Pascal side reads numbers with `Read(Input, Value)` until `SeekEof`, which
handles any mix of spaces and line breaks, and pins
`DefaultFormatSettings.DecimalSeparator` to `.` so the output is not affected by
the machine's locale.
