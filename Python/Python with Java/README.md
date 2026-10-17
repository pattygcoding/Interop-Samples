# Python with Java

Python spawns a Java helper as a child process and exchanges data with it over
**stdin/stdout**. The Java side uses only the JDK, so no JSON jar is required.

| | |
|---|---|
| **Host language** | Python 3 |
| **Guest language** | Java |
| **Bridge** | Child process + whitespace-separated numbers on stdin/stdout |
| **Files** | `main.py`, `AverageCalculator.java` |

## Prerequisites

- **Python 3.9+**
- **JDK 11+** (`javac`, `java`)

## Build & run

Compile the helper first:

```bash
javac AverageCalculator.java
python3 main.py
python3 main.py 1 2 3 4
```

`main.py` starts the JVM with its own directory on the classpath
(`java -cp <dir> AverageCalculator`), so it works from any working directory.

You can also exercise the Java side on its own:

```bash
echo "10 20 30" | java -cp . AverageCalculator
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
JAVA_COMMAND = ["java", "-cp", str(HERE), "AverageCalculator"]

result = subprocess.run(JAVA_COMMAND, input=payload,
                        capture_output=True, text=True)
```

`AverageCalculator.java` reads stdin line by line, splits on whitespace,
parses each token as a `double` and prints the mean. Invalid tokens and empty
input produce a message on `stderr` and a non-zero exit code, which `main.py`
turns into a `RuntimeError`.

`main.py` also exposes `calculate_average(numbers)` for use as a module.
