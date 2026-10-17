# Java with Kotlin

Calls a Kotlin `object` from Java. `@JvmStatic` makes Kotlin emit a **static
forwarder**, so the Java side calls it like any plain Java method.

| | |
|---|---|
| **Host language** | Java |
| **Guest language** | Kotlin |
| **Bridge** | Ahead-of-time compilation, shared JVM bytecode |
| **Files** | `Main.java`, `AverageCalculator.kt` |

## Prerequisites

- **JDK 11+**
- The **Kotlin command-line compiler** (`kotlinc`) and launcher (`kotlin`) 1.9 or
  newer, on your `PATH`

## Build & run

**Linux / macOS**

```bash
kotlinc AverageCalculator.kt -d classes
javac -cp classes -d classes Main.java
kotlin -cp classes Main
kotlin -cp classes Main 1 2 3 4
```

**Windows (PowerShell)**

```powershell
kotlinc AverageCalculator.kt -d classes
javac -cp classes -d classes Main.java
kotlin -cp classes Main
kotlin -cp classes Main 1 2 3 4
```

`kotlinc` compiles the Kotlin object and the JVM needs the **Kotlin standard
library** at run time; the `kotlin` launcher adds it automatically. If you would
rather use the plain `java` launcher, add `kotlin-stdlib.jar` to the classpath:

```bash
java -cp "classes:/path/to/kotlin-stdlib.jar" Main
```

## Expected output

```text
$ kotlin -cp classes Main
The average of 5 value(s) is: 30.00

$ kotlin -cp classes Main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

The Kotlin side declares a `package` and a singleton `object`; `@JvmStatic` is
what turns the function into a static method that Java can call without touching
the generated `INSTANCE` field:

```kotlin
package com.example

object AverageCalculator {
    @JvmStatic
    fun calculateAverage(numbers: IntArray): Double =
        if (numbers.isEmpty()) 0.0 else numbers.average()
}
```

Because the Kotlin file lives in package `com.example`, `Main.java` must import
it:

```java
import com.example.AverageCalculator;
```
