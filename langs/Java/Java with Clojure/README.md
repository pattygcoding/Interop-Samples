# Java with Clojure

Invokes a Clojure function from Java through Clojure's own Java API
(`clojure.java.api.Clojure`), with no `main` in the Clojure side at all.

| | |
|---|---|
| **Host language** | Java |
| **Guest language** | Clojure |
| **Bridge** | In-process JVM API (`clojure.java.api.Clojure`) |
| **Files** | `Main.java`, `average_calculator.clj`, `deps.edn` |

## Prerequisites

- **JDK 11+**
- The **[Clojure CLI](https://clojure.org/guides/install_clojure)** (`clojure`) —
  used here to resolve Clojure and print the classpath

## Build & run

`deps.edn` declares the Clojure dependency and adds this directory to the
classpath so the namespace file is visible as a resource. Because the namespace
is named `average-calculator`, Clojure looks for `average_calculator.clj`.

**Linux / macOS**

```bash
CP=$(clojure -Spath)
javac -cp "$CP" Main.java
java  -cp "$CP" Main
java  -cp "$CP" Main 1 2 3 4
```

**Windows (PowerShell)**

```powershell
$CP = clojure -Spath
javac -cp "$CP" Main.java
java  -cp "$CP" Main
java  -cp "$CP" Main 1 2 3 4
```

> `java Main.java` (single-file source launch, JDK 11+) also works and skips the
> separate `javac` step: `java -cp "$CP" Main.java`.

## Expected output

```text
$ java -cp "$CP" Main
The average of 5 value(s) is: 30.00

$ java -cp "$CP" Main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

The Clojure var is resolved lazily, so the namespace must be **required**
before it can be looked up:

```java
Clojure.var("clojure.core", "require").invoke(Clojure.read("average-calculator"));

IFn calculateAverage = Clojure.var("average-calculator", "calculate-average");
Number result = (Number) calculateAverage.invoke(numbers);
```

`calculate-average` deliberately coerces its result with `(double …)`. Without
that, Clojure would return a `Long` or a `Ratio` and the Java-side cast would
fail on non-integer means. The function accepts a Java `int[]` because Clojure's
`seq` understands Java arrays.
