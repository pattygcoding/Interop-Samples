# V with C++

V passes the numbers as command-line arguments to a compiled C++ program and
reads the average it prints back from stdout.

| | |
|---|---|
| **Host language** | V |
| **Guest language** | C++17 |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.v`, `average_calculator.cpp` |

## Prerequisites

- **V** 0.4 or newer, plus a C backend:
  - **Windows:** V ships TinyCC, so `v -cc tcc` works out of the box
  - **Linux / macOS:** the default `cc` (gcc or clang) is used
- A **C++17 compiler** (`g++` or `clang++`)

## Build & run

```bash
g++ -O2 -std=c++17 -Wall -Wextra average_calculator.cpp -o average_calculator
v -cc tcc -o main main.v          # Linux/macOS: plain `v -o main main.v` also works

./main                 # uses the built-in default data set
./main 1 2 3 4
./main -5 5 10
```

On Windows the binaries are `average_calculator.exe` and `main.exe`; `main.v`
detects the platform and looks for the right helper name.

You can also exercise the C++ side on its own:

```bash
./average_calculator 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./main
The average of 5 value(s) is: 30.00

$ ./main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.v` runs the helper through `os.execute`, which hands back both the exit
code and the captured output:

```v
result := os.execute(arguments.join(' '))

if result.exit_code != 0 {
    detail := result.output.trim_space()
    ...
}
```

`is_number` pre-validates every token because V's `str.f64()` quietly yields
`0.0` for unparsable input — without the check, `oops` would silently become a
zero. The average is printed with V's `${value:.2f}` interpolation.

On Windows, build with `-cc tcc`: the MinGW-w64 linker rejects an intrinsic in
V's runtime, while V's bundled TinyCC links it correctly.
