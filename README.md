# Interop Samples

A collection of small, self-contained programs that show **two languages working
together**. Every sample computes something simple — usually the average of a
list of numbers — so that the *interop mechanism* is the interesting part rather
than the arithmetic.

Testing how two languages cooperate fascinates me, so each folder pairs a host
language with a guest language and demonstrates a different bridging technique:
native linking, ahead-of-time compilation to a shared runtime, in-process
embedding, and child processes connected by files, pipes or JSON.

Each sample has its **own README** with prerequisites, the exact build commands,
and the expected output.

## Sample index

| Sample | Host | Guest | Bridge | Platform |
| --- | --- | --- | --- | --- |
| [C with Assembly (32-bit)](C/C%20with%20Assembly%20(32bit)/README.md) | C | x86-32 assembly | Native linking, `cdecl` | Linux, Windows |
| [C with Assembly (64-bit)](C/C%20with%20Assembly%20(64bit)/README.md) | C | x86-64 assembly | Native linking, System V / MS x64 ABI | Linux, Windows |
| [C++ with Assembly (32-bit)](C%2B%2B/C%2B%2B%20with%20Assembly%20(32bit)/README.md) | C++ | x86-32 assembly | Native linking, `extern "C"` | Linux, Windows |
| [C++ with Assembly (64-bit)](C%2B%2B/C%2B%2B%20with%20Assembly%20(64bit)/README.md) | C++ | x86-64 assembly | Native linking, `extern "C"` | Linux, Windows |
| [Haskell with Assembly (32-bit)](Haskell/Haskell%20with%20Assembly%20(32bit)/README.md) | Haskell | x86-32 assembly | Child process + text files | Linux i386 |
| [Haskell with Assembly (64-bit)](Haskell/Haskell%20with%20Assembly%20(64bit)/README.md) | Haskell | x86-64 assembly | Child process + text files | Linux x86-64 |
| [Haskell with Scala](Haskell/Haskell%20with%20Scala/README.md) | Haskell | Scala 3 | Child process + stdin/stdout | Any |
| [Java with Clojure](Java/Java%20with%20Clojure/README.md) | Java | Clojure | In-process JVM API | Any (JVM) |
| [Java with Groovy](Java/Java%20with%20Groovy/README.md) | Java | Groovy | Shared JVM bytecode | Any (JVM) |
| [Java with Kotlin](Java/Java%20with%20Kotlin/README.md) | Java | Kotlin | Shared JVM bytecode | Any (JVM) |
| [Java with Scala](Java/Java%20with%20Scala/README.md) | Java | Scala 3 | Shared JVM bytecode | Any (JVM) |
| [JavaScript with C#](JavaScript/JavaScript%20with%20C%23/README.md) | Node.js | C# (.NET) | Child process + JSON on stdin/stdout | Any |
| [JavaScript with Dart](JavaScript/JavaScript%20with%20Dart/README.md) | Node.js | Dart | Child process + JSON on stdin/stdout | Any |
| [Perl with Pascal](Perl/Perl%20with%20Pascal/README.md) | Perl | Free Pascal | Child process + temporary file | Any |
| [Perl with Prolog](Perl/Perl%20with%20Prolog/README.md) | Perl | SWI-Prolog | Child process + argv/stdout | Any |
| [Python with C++](Python/Python%20with%20C%2B%2B/README.md) | Python | C++17 | Child process + stdin/stdout | Any |
| [Python with Java](Python/Python%20with%20Java/README.md) | Python | Java | Child process + stdin/stdout | Any |
| [Python with Prolog](Python/Python%20with%20Prolog/README.md) | Python | SWI-Prolog | In-process embedding (PySwip) | Any |

## Conventions

The samples deliberately follow a few shared rules so that they are easy to
compare and to trust:

- **One host, one guest.** Each folder contains exactly two program units and
  the build steps needed to join them.
- **A predictable result line.** Host programs print
  `The average of N value(s) is: XX.XX`, so the output of every sample is easy to
  eyeball.
- **Real input handling.** Numbers can be passed on the command line where that
  makes sense; invalid input is reported and skipped rather than crashing, and
  running out of usable input exits with a non-zero status.
- **Empty inputs are handled.** Averages of nothing return `0.0` instead of
  dividing by zero.
- **Paths are resolved, not assumed.** Helpers are located relative to the
  script or executable, so samples run from any working directory.
- **Build artefacts never land in the tree.** Compilers are pointed at scratch
  directories or the results are covered by `.gitignore`.

## Prerequisites

Install only the toolchains for the samples you want to run.

| Tool | Version used | Needed by |
| --- | --- | --- |
| NASM | 2.16 | all *with Assembly* samples |
| GCC / G++ (or MinGW-w64) | 15.2 | C, C++, Python with C++ |
| GHC | 9.8 | all Haskell samples |
| JDK | 21 | all Java samples, Python with Java |
| Clojure CLI | 1.12 | Java with Clojure |
| Groovy | 5.1 | Java with Groovy |
| Kotlin compiler | 2.0 | Java with Kotlin |
| Scala CLI (or Scala 3) | 3.9 | Java with Scala, Haskell with Scala |
| Node.js | 22 | both JavaScript samples |
| .NET SDK | 8.0 | JavaScript with C# |
| Dart SDK | 3.13 | JavaScript with Dart |
| Python | 3.14 | all Python samples |
| PySwip | latest | Python with Prolog |
| SWI-Prolog | 10.0 | Perl with Prolog, Python with Prolog |
| Free Pascal | 3.2 | Perl with Pascal |

### Platform notes

- The **C/C++ with Assembly** samples build on Linux and Windows; the assembly
  adapts to the target object format and calling convention automatically.
- The **Haskell with Assembly** samples are **Linux only**. The assembly helpers
  are freestanding programs that use raw system calls (`syscall` on x86-64,
  `int 0x80` on i386) and therefore do not run on Windows.
- Everything else is portable across Windows, Linux and macOS.

## Repository layout

```text
.
├── C/            C + x86 assembly (32-bit and 64-bit)
├── C++/          C++ + x86 assembly (32-bit and 64-bit)
├── Haskell/      Haskell + assembly, and Haskell + Scala
├── Java/         Java + Clojure, Groovy, Kotlin, Scala
├── JavaScript/   Node.js + C#, and Node.js + Dart
├── Perl/         Perl + Pascal, and Perl + Prolog
└── Python/       Python + C++, Java, and Prolog
```

## Getting started

Pick any folder, open its `README.md`, and follow the build and run steps. For
example:

```bash
cd "C/C with Assembly (64bit)"
nasm -f elf64 calculate_average.asm -o calculate_average.o
gcc -O2 -Wall -Wextra main.c calculate_average.o -o average
./average
```

```text
The average of 5 value(s) is: 30.00
```

## Contributing

New samples are welcome. Keep them small, keep them self-contained, and make
sure the folder contains a `README.md` with prerequisites, build commands and
the expected output, plus any `.gitignore` entries needed for build artefacts.

