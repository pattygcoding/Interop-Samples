# Java with Groovy

Calls a Groovy class from Java. `AverageCalculator.groovy` is compiled to
ordinary JVM bytecode with `groovyc`; Java then links against it like any other
class it did not write.

| | |
|---|---|
| **Host language** | Java |
| **Guest language** | Groovy |
| **Bridge** | Ahead-of-time compilation, shared JVM bytecode |
| **Files** | `Main.java`, `AverageCalculator.groovy` |

## Prerequisites

- **JDK 11+**
- **Groovy** 4 or newer, with the `GROOVY_HOME` environment variable pointing at
  your Groovy installation

## Build & run

**Linux / macOS**

```bash
groovyc AverageCalculator.groovy
javac -cp ".:$GROOVY_HOME/lib/*" Main.java
java  -cp ".:$GROOVY_HOME/lib/*" Main
java  -cp ".:$GROOVY_HOME/lib/*" Main 1 2 3 4
```

**Windows (PowerShell)**

```powershell
groovyc AverageCalculator.groovy
javac -cp ".;$env:GROOVY_HOME\lib\*" Main.java
java  -cp ".;$env:GROOVY_HOME\lib\*" Main
java  -cp ".;$env:GROOVY_HOME\lib\*" Main 1 2 3 4
```

The Groovy runtime must be on the classpath for **both** steps: the generated
`AverageCalculator.class` implements `groovy.lang.GroovyObject`, so `javac`
needs the Groovy API to compile `Main.java`, and `java` needs it at run time.

## Expected output

```text
$ java -cp ".;$env:GROOVY_HOME\lib\*" Main
The average of 5 value(s) is: 30.00

$ java -cp ".;$env:GROOVY_HOME\lib\*" Main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

Groovy is dynamically typed but compiles to real bytecode, so the call from Java
is a normal static method call:

```java
double average = AverageCalculator.calculateAverage(numbers);
```

The Groovy side uses `numbers.sum() as double` for clarity and to avoid Groovy's
`BigDecimal` division semantics, and returns `0.0` for a `null` or empty array.
