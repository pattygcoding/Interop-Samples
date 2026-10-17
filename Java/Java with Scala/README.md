# Java with Scala

Calls a Scala object from Java. A top-level Scala `object` emits **static
forwarders**, so the Java side sees a plain static method and needs no Scala
types.

| | |
|---|---|
| **Host language** | Java |
| **Guest language** | Scala 3 |
| **Bridge** | Ahead-of-time compilation, shared JVM bytecode |
| **Files** | `Main.java`, `AverageCalculator.scala` |

## Prerequisites

- **JDK 11+**
- **[Scala CLI](https://scala-cli.virtuslab.org/)** (`scala`) — the easiest way to
  build and run this. A plain Scala 3 distribution (`scalac`) also works for
  Option B below.

## Build & run

### Option A — Scala CLI (one command)

Scala CLI compiles the `.scala` and `.java` sources together and runs `Main`:

```bash
scala run . --main-class Main
scala run . --main-class Main -- 1 2 3 4
```

### Option B — explicit compilation

**Linux / macOS**

```bash
mkdir -p out
scalac AverageCalculator.scala -d out
javac -cp out -d out Main.java
java  -cp "out:$SCALA3_LIB:$SCALA2_LIB" Main
```

**Windows (PowerShell)**

```powershell
New-Item -ItemType Directory -Force out | Out-Null
scalac AverageCalculator.scala -d out
javac -cp out -d out Main.java
java  -cp "out;$SCALA3_LIB;$SCALA2_LIB" Main
```

where `SCALA3_LIB` is `scala3-library_3-<version>.jar` and `SCALA2_LIB` is
`scala-library-2.13.x.jar` (both available on Maven Central). The Scala runtime
jars are only needed at run time.

## Expected output

```text
$ scala run . --main-class Main
The average of 5 value(s) is: 30.00

$ scala run . --main-class Main -- 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

The Scala side is a plain `object`:

```scala
object AverageCalculator:
  def calculateAverage(numbers: Array[Int]): Double =
    if numbers.isEmpty then 0.0 else numbers.sum.toDouble / numbers.length
```

The compiler generates both the singleton (`AverageCalculator$`) and a class
with a static forwarder (`AverageCalculator`), which is why Java can write:

```java
double average = AverageCalculator.calculateAverage(numbers);
```
