# Python with C++

Python spawns a compiled C++ helper as a child process and exchanges data with
it over **stdin/stdout**. The C++ side deliberately avoids any third-party JSON
library, so the only requirement is a C++ compiler.

| | |
|---|---|
| **Host language** | Python 3 |
| **Guest language** | C++17 |
| **Bridge** | Child process + whitespace-separated numbers on stdin/stdout |
| **Files** | `main.py`, `average_calculator.cpp` |

## Prerequisites

- **Python 3.9+**
- A **C++17 compiler** (`g++`, `clang++`, or MSVC)

## Build & run

Compile the helper first (the Python script expects the binary next to it):

**Linux / macOS**

```bash
g++ -O2 -std=c++17 -Wall -Wextra average_calculator.cpp -o average_calculator
python3 main.py
python3 main.py 1 2 3 4
```

**Windows (MinGW-w64)**

```powershell
g++ -O2 -std=c++17 -Wall -Wextra average_calculator.cpp -o average_calculator.exe
python main.py
python main.py 1 2 3 4
```

You can also exercise the C++ side on its own:

```bash
echo "10 20 30" | ./average_calculator
```

## Expected output

```text
$ python3 main.py
The average of 5 value(s) is: 30.00

$ python3 main.py 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.py` writes the numbers as a single space-separated line and reads the
result back:

```python
result = subprocess.run([str(EXECUTABLE)], input=payload,
                        capture_output=True, text=True)
```

`average_calculator.cpp` reads values with `std::cin >>` until EOF, distinguishes
"end of input" from "malformed token", and prints the mean with 17 significant
digits so the value round-trips through `float()` exactly. A non-zero exit code
and a message on `stderr` become a `RuntimeError` on the Python side.

`main.py` also exposes `calculate_average(numbers)` for use as a module.
