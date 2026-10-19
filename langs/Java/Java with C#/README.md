# Java with C#

Java starts a .NET console app and exchanges data with it over **stdin/stdout**
using JSON — the same protocol the [JavaScript with C#](../../JavaScript/JavaScript%20with%20C%23/README.md)
sample uses.

| | |
|---|---|
| **Host language** | Java |
| **Guest language** | C# (.NET) |
| **Bridge** | Child process + JSON on stdin/stdout |
| **Files** | `Main.java`, `Program.cs`, `AverageCalculator.csproj` |

## Prerequisites

- **JDK 11+** (`javac`, `java`)
- **.NET SDK** 8.0 or newer (`dotnet`)

## Build & run

```bash
javac Main.java
java Main                 # uses the built-in default data set
java Main 1 2 3 4
java Main -5 5 10
```

The .NET project is built automatically the first time it runs. `Main` locates
the C# project from its own class location, so the sample works from any
directory.

You can also exercise the C# side on its own:

```bash
echo "[10,20,30]" | dotnet run --project .
```

## Expected output

```text
$ java Main
The average of 5 value(s) is: 30.00

$ java Main 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`Main.java` writes a JSON array to the child's standard input and reads the
average back:

```java
ProcessBuilder builder = new ProcessBuilder(
        "dotnet", "run", "--project", projectDirectory().toString(), "-v", "quiet");
Process process = builder.start();
```

`projectDirectory()` derives the project path from
`Main.class.getProtectionDomain().getCodeSource().getLocation()`, which is why
the sample does not depend on the current working directory.

`Program.cs` deserializes the array with the built-in `System.Text.Json` (no
NuGet packages required) and prints the mean with `CultureInfo.InvariantCulture`
so the decimal separator does not depend on the machine's locale. Empty or
malformed input produces a message on `stderr` and a non-zero exit code, which
Java turns into an error message and exit status 1.

> Note that `dotnet run` does not accept `--nologo`; passing it would forward the
> flag to the application. `-v quiet` is the supported way to silence the build.
