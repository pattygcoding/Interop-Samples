# C++ with Lua

C++ passes the numbers as command-line arguments to a Lua script and reads the
average back through a pipe.

| | |
|---|---|
| **Host language** | C++ |
| **Guest language** | Lua |
| **Bridge** | Child process + `popen` pipe |
| **Files** | `main.cpp`, `average_calculator.lua` |

## Prerequisites

- A C++17 compiler (`g++`, `clang++`, or MSVC)
- **Lua** 5.1 or newer (`lua`) on your `PATH`

## Build & run

```bash
g++ -O2 -std=c++17 -Wall -Wextra main.cpp -o average

./average                 # uses the built-in default data set
./average 1 2 3 4
./average -5 5 10
```

On Windows the compiler writes `average.exe`, so run `.\average.exe` instead.

Run the program from this directory: it looks for `average_calculator.lua` in the
working directory.

You can also exercise the Lua side on its own:

```bash
lua average_calculator.lua 10 20 30     # -> 20.00
```

## Expected output

```text
$ ./average
The average of 5 value(s) is: 30.00

$ ./average 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.cpp` collects the command line into a `std::vector<int>` and runs the script
through `popen`:

```cpp
std::string command = "lua average_calculator.lua";

for (int number : numbers) {
    command += " " + std::to_string(number);
}

FILE *pipe = popen(command.c_str(), "r");
```

`pclose` returns the child's exit status, so a script that fails is reported
rather than silently producing a bogus average.

`average_calculator.lua` walks the global `arg` table, converts each entry with
`tonumber`, and prints the mean via `("%.2f"):format(...)`. Non-numeric arguments
are reported on stderr with `os.exit(1)`. The script deliberately avoids
post-5.1 features so it runs on the widest range of interpreters.
