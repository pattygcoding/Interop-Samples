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
| [Ada with JavaScript](Ada/Ada%20with%20JavaScript/README.md) | Ada | JavaScript (Node.js) | Child process + stdin/stdout | Any |
| [Ada with Kotlin](Ada/Ada%20with%20Kotlin/README.md) | Ada | Kotlin | Child process + stdin/stdout | Any |
| [Ada with Lisp](Ada/Ada%20with%20Lisp/README.md) | Ada | Common Lisp (SBCL) | Child process + stdin/stdout | Any |
| [Ada with SQL](Ada/Ada%20with%20SQL/README.md) | Ada | SQL (SQLite) | Child process + `sqlite3` shell | Any |
| [Bash with Pascal](Bash/Bash%20with%20Pascal/README.md) | Bash | Free Pascal | Child process + argv/stdout | Any |
| [C with Assembly (32-bit)](C/C%20with%20Assembly%20(32bit)/README.md) | C | x86-32 assembly | Native linking, `cdecl` | Linux, Windows |
| [C with Assembly (64-bit)](C/C%20with%20Assembly%20(64bit)/README.md) | C | x86-64 assembly | Native linking, System V / MS x64 ABI | Linux, Windows |
| [C with Elixir](C/C%20with%20Elixir/README.md) | C | Elixir | Child process + `popen` pipe | Any |
| [C with PHP](C/C%20with%20PHP/README.md) | C | PHP | Child process + `popen` pipe | Any |
| [C with Python](C/C%20with%20Python/README.md) | C | Python 3 | Child process + `popen` pipe | Any |
| [C++ with Assembly (32-bit)](C%2B%2B/C%2B%2B%20with%20Assembly%20(32bit)/README.md) | C++ | x86-32 assembly | Native linking, `extern "C"` | Linux, Windows |
| [C++ with Assembly (64-bit)](C%2B%2B/C%2B%2B%20with%20Assembly%20(64bit)/README.md) | C++ | x86-64 assembly | Native linking, `extern "C"` | Linux, Windows |
| [C++ with Lua](C%2B%2B/C%2B%2B%20with%20Lua/README.md) | C++ | Lua | Child process + `popen` pipe | Any |
| [Clojure with Lua](Clojure/Clojure%20with%20Lua/README.md) | Clojure | Lua | Child process + argv/stdout | Any |
| [Clojure with PowerShell](Clojure/Clojure%20with%20PowerShell/README.md) | Clojure | PowerShell | Child process + argv/stdout | Any |
| [Dart with Haskell](Dart/Dart%20with%20Haskell/README.md) | Dart | Haskell | Child process + argv/stdout | Any |
| [Elixir with Fortran](Elixir/Elixir%20with%20Fortran/README.md) | Elixir | Fortran | Child process + argv/stdout | Any |
| [Elm with Prolog](Elm/Elm%20with%20Prolog/README.md) | Elm | SWI-Prolog | Ports + Node host, child process | Any |
| [Elm with Scala](Elm/Elm%20with%20Scala/README.md) | Elm | Scala 3 | Ports + Node host, child process | Any |
| [Elm with Swift](Elm/Elm%20with%20Swift/README.md) | Elm | Swift | Ports + Node host, child process | Any |
| [Erlang with Haskell](Erlang/Erlang%20with%20Haskell/README.md) | Erlang | Haskell | Erlang port + argv/stdout | Any |
| [F# with Lisp](F%23/F%23%20with%20Lisp/README.md) | F# | Common Lisp (SBCL) | Child process + stdin/stdout | Any |
| [Fortran with COBOL](Fortran/Fortran%20with%20COBOL/README.md) | Fortran | COBOL (GnuCOBOL) | Child process + shell redirection | Linux |
| [Groovy with Objective-C](Groovy/Groovy%20with%20Objective-C/README.md) | Groovy | Objective-C | Child process + argv/stdout | Any |
| [Haskell with Assembly (32-bit)](Haskell/Haskell%20with%20Assembly%20(32bit)/README.md) | Haskell | x86-32 assembly | Child process + text files | Linux i386 |
| [Haskell with Assembly (64-bit)](Haskell/Haskell%20with%20Assembly%20(64bit)/README.md) | Haskell | x86-64 assembly | Child process + text files | Linux x86-64 |
| [Haskell with Scala](Haskell/Haskell%20with%20Scala/README.md) | Haskell | Scala 3 | Child process + stdin/stdout | Any |
| [Haxe with Erlang](Haxe/Haxe%20with%20Erlang/README.md) | Haxe (Neko) | Erlang | Child process + argv/stdout | Any |
| [Haxe with Groovy](Haxe/Haxe%20with%20Groovy/README.md) | Haxe (Neko) | Groovy | Child process + argv/stdout | Any |
| [Haxe with Perl](Haxe/Haxe%20with%20Perl/README.md) | Haxe (Neko) | Perl | Child process + argv/stdout | Any |
| [Java with C#](Java/Java%20with%20C%23/README.md) | Java | C# (.NET) | Child process + JSON on stdin/stdout | Any |
| [Java with Clojure](Java/Java%20with%20Clojure/README.md) | Java | Clojure | In-process JVM API | Any (JVM) |
| [Java with Groovy](Java/Java%20with%20Groovy/README.md) | Java | Groovy | Shared JVM bytecode | Any (JVM) |
| [Java with Kotlin](Java/Java%20with%20Kotlin/README.md) | Java | Kotlin | Shared JVM bytecode | Any (JVM) |
| [Java with Scala](Java/Java%20with%20Scala/README.md) | Java | Scala 3 | Shared JVM bytecode | Any (JVM) |
| [JavaScript with C#](JavaScript/JavaScript%20with%20C%23/README.md) | Node.js | C# (.NET) | Child process + JSON on stdin/stdout | Any |
| [JavaScript with Dart](JavaScript/JavaScript%20with%20Dart/README.md) | Node.js | Dart | Child process + JSON on stdin/stdout | Any |
| [JavaScript with SCSS](JavaScript/JavaScript%20with%20SCSS/README.md) | Node.js | SCSS (Dart Sass) | In-process Sass compiler | Any |
| [JavaScript with SQL](JavaScript/JavaScript%20with%20SQL/README.md) | Node.js | SQL (SQLite) | Child process + `sqlite3` shell | Any |
| [Julia with SQL](Julia/Julia%20with%20SQL/README.md) | Julia | SQL (SQLite) | Child process + `sqlite3` shell | Any |
| [Kotlin with Prolog](Kotlin/Kotlin%20with%20Prolog/README.md) | Kotlin | SWI-Prolog | Child process + argv/stdout | Any |
| [Lua with R](Lua/Lua%20with%20R/README.md) | Lua | R | Child process + `io.popen` pipe | Any |
| [Lua with Swift](Lua/Lua%20with%20Swift/README.md) | Lua | Swift | Child process + `io.popen` pipe | Any |
| [Nim with R](Nim/Nim%20with%20R/README.md) | Nim | R | Child process + argv/stdout | Any |
| [OCaml with Go](OCaml/OCaml%20with%20Go/README.md) | OCaml | Go | Child process + temporary files | Any |
| [OCaml with Objective-C](OCaml/OCaml%20with%20Objective-C/README.md) | OCaml | Objective-C | Child process + shell redirection | Any |
| [OCaml with SCSS](OCaml/OCaml%20with%20SCSS/README.md) | OCaml | SCSS (Dart Sass) | Child process + generated CSS | Any |
| [Perl with Pascal](Perl/Perl%20with%20Pascal/README.md) | Perl | Free Pascal | Child process + temporary file | Any |
| [Perl with Prolog](Perl/Perl%20with%20Prolog/README.md) | Perl | SWI-Prolog | Child process + argv/stdout | Any |
| [PHP with Dart](PHP/PHP%20with%20Dart/README.md) | PHP | Dart | Child process + argv/stdout | Any |
| [PowerShell with V](PowerShell/PowerShell%20with%20V/README.md) | PowerShell | V | Child process + argv/stdout | Any |
| [Python with C++](Python/Python%20with%20C%2B%2B/README.md) | Python | C++17 | Child process + stdin/stdout | Any |
| [Python with Java](Python/Python%20with%20Java/README.md) | Python | Java | Child process + stdin/stdout | Any |
| [Python with Prolog](Python/Python%20with%20Prolog/README.md) | Python | SWI-Prolog | In-process embedding (PySwip) | Any |
| [Python with SCSS](Python/Python%20with%20SCSS/README.md) | Python | SCSS (Dart Sass) | Child process + generated CSS | Any |
| [R with PHP](R/R%20with%20PHP/README.md) | R | PHP | Child process + argv/stdout | Any |
| [Ruby with Rust](Ruby/Ruby%20with%20Rust/README.md) | Ruby | Rust | Child process + stdin/stdout | Any |
| [Rust with Shell](Rust/Rust%20with%20Shell/README.md) | Rust | Shell (POSIX `sh`) | Child process + argv/stdout | Any |
| [Scala with Julia](Scala/Scala%20with%20Julia/README.md) | Scala 3 | Julia | Child process + argv/stdout | Any |
| [Scala with VB / VB.NET](Scala/Scala%20with%20VB.NET/README.md) | Scala 3 | VB.NET | Child process + argv/stdout | Any |
| [Shell with Pascal](Shell/Shell%20with%20Pascal/README.md) | Shell | Free Pascal | Child process + argv/stdout | Any |
| [Shell with VB.NET](Shell/Shell%20with%20VB.NET/README.md) | Shell | VB.NET | Child process + argv/stdout | Any |
| [Swift with Nim](Swift/Swift%20with%20Nim/README.md) | Swift | Nim | Child process + stdin/stdout | Any |
| [TypeScript with C#](TypeScript/TypeScript%20with%20C%23/README.md) | TypeScript (Node.js) | C# (.NET) | Child process + argv/stdout | Any |
| [TypeScript with Objective-C](TypeScript/TypeScript%20with%20Objective-C/README.md) | TypeScript (Node.js) | Objective-C | Child process + argv/stdout | Any |
| [TypeScript with Python](TypeScript/TypeScript%20with%20Python/README.md) | TypeScript (Node.js) | Python 3 | Child process + JSON on stdin/stdout | Any |
| [V with C++](V/V%20with%20C%2B%2B/README.md) | V | C++17 | Child process + argv/stdout | Any |
| [V with R](V/V%20with%20R/README.md) | V | R | Child process + argv/stdout | Any |

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
| GCC / G++ (or MinGW-w64) | 15.2 | C, C++, C with Elixir, C with PHP, C with Python, C++ with Lua, Nim with R, Python with C++, V with C++ |
| GNAT (`gcc-ada`) | 16.2 | Ada with JavaScript, Ada with Kotlin, Ada with Lisp, Ada with SQL |
| GHC | 9.8 | all Haskell samples, Dart with Haskell |
| JDK | 21 | all Java samples, Python with Java, Ada with Kotlin, Haxe with Groovy, Kotlin with Prolog |
| Clojure CLI | 1.12 | Clojure with Lua, Clojure with PowerShell, Java with Clojure |
| Groovy | 5.1 | Groovy with Objective-C, Haxe with Groovy, Java with Groovy |
| Kotlin compiler | 2.0 | Ada with Kotlin, Java with Kotlin, Kotlin with Prolog |
| Scala CLI (or Scala 3) | 3.9 | Elm with Scala, Haskell with Scala, Java with Scala, Scala with Julia, Scala with VB / VB.NET |
| Node.js | 22 | all JavaScript samples, Ada with JavaScript, TypeScript with C#, TypeScript with Objective-C, TypeScript with Python |
| TypeScript | 5.7 | TypeScript with C#, TypeScript with Objective-C, TypeScript with Python |
| Dart Sass | 1.105 | JavaScript with SCSS, OCaml with SCSS, Python with SCSS |
| .NET SDK | 8.0 | Java with C#, JavaScript with C#, F# with Lisp, Scala with VB / VB.NET, Shell with VB.NET, TypeScript with C# |
| Dart SDK | 3.13 | Dart with Haskell, JavaScript with Dart, PHP with Dart |
| Elm | 0.19.2 | Elm with Prolog, Elm with Scala, Elm with Swift |
| Python | 3.14 | all Python samples, C with Python, Python with SCSS, TypeScript with Python |
| PySwip | latest | Python with Prolog |
| SWI-Prolog | 10.0 | Elm with Prolog, Kotlin with Prolog, Perl with Prolog, Python with Prolog |
| Free Pascal | 3.2 | Bash with Pascal, Perl with Pascal, Shell with Pascal |
| Elixir | 1.20 | C with Elixir |
| R | 4.6 | Lua with R, Nim with R, R with PHP, V with R |
| Lua | 5.1 | Clojure with Lua, C++ with Lua, Lua with R, Lua with Swift |
| Ruby | 3.4 | Ruby with Rust |
| Rust (`rustc`) | 1.98 | Ruby with Rust, Rust with Shell |
| SBCL | 2.6 | Ada with Lisp, F# with Lisp |
| Erlang/OTP | 29 | Erlang with Haskell, Haxe with Erlang |
| Swift | 6.4 | Elm with Swift, Lua with Swift, Swift with Nim |
| Nim | 2.2 | Nim with R, Swift with Nim |
| PowerShell | 7+ (`pwsh`) or 5.1 | Clojure with PowerShell, PowerShell with V |
| POSIX shell (`sh` / `bash`) | 5.3 | Bash with Pascal, Rust with Shell, Shell with Pascal, Shell with VB.NET |
| Haxe + Neko | 4.3 / 2.4 | Haxe with Erlang, Haxe with Groovy, Haxe with Perl |
| GCC ObjC (`gcc-objc` + `libobjc`) | 16.2 | Groovy with Objective-C, OCaml with Objective-C, TypeScript with Objective-C |
| Julia | 1.13 | Julia with SQL, Scala with Julia |
| SQLite CLI | 3.54 | Ada with SQL, JavaScript with SQL, Julia with SQL |
| OCaml | 5.4 | OCaml with Go, OCaml with Objective-C, OCaml with SCSS |
| Go | 1.25 | OCaml with Go |
| PHP | 8.5 | C with PHP, PHP with Dart, R with PHP |
| gfortran | 15.2 | Elixir with Fortran, Fortran with COBOL |
| GnuCOBOL | 3.2 | Fortran with COBOL |
| V | 0.5 | V with C++ |

### Platform notes

- The **C/C++ with Assembly** samples build on Linux and Windows; the assembly
  adapts to the target object format and calling convention automatically.
- The **Haskell with Assembly** samples are **Linux only**. The assembly helpers
  are freestanding programs that use raw system calls (`syscall` on x86-64,
  `int 0x80` on i386) and therefore do not run on Windows.
- **Clojure with PowerShell** needs PowerShell 7+ (`pwsh`) on Linux and macOS; on
  Windows it finds the built-in `powershell` automatically.
- **Fortran with COBOL** is **Linux only**: the Fortran host invokes the helper as
  `./average_calculator`, and GnuCOBOL's Windows builds do not currently work with
  GCC 16.
- **Ada with Kotlin**, **Ada with Lisp**, **Ada with SQL**, **Groovy with
  Objective-C**, **TypeScript with Objective-C** and all three **OCaml** samples
  need MSYS2 on `PATH` on Windows: `mingw64\bin` for GNAT and the Objective-C
  runtime, and `ucrt64\bin` plus `OCAMLLIB` for OCaml.
- **Bash with Pascal**, **Rust with Shell**, **Shell with Pascal** and **Shell with
  VB.NET** need a POSIX shell; on Windows that means Git Bash or MSYS2.
- **Rust with Shell** probes for a working shell instead of trusting `PATH`,
  because on Windows `System32\bash.exe` — the WSL relay — shadows Git Bash for
  `CreateProcess` even when Git Bash comes first in `PATH`. Set
  `SHELL_INTERPRETER` to skip the search.
- **Haxe with Groovy** starts the Groovy interpreter through `java` rather than
  through the `groovy` shim, so `GROOVY_HOME` must be set. **Elm with Scala** hits
  the same shim problem and routes through `cmd /c` instead. **Python with SCSS**
  does the same for `sass`, because Python's `subprocess` passes its argument
  vector straight to `CreateProcess`, which cannot execute a `.cmd` file.
- **V with R** builds with `-cc tcc` on Windows: MinGW-w64's linker rejects an
  intrinsic in V's runtime, while V's bundled TinyCC links it correctly.
- Everything else is portable across Windows, Linux and macOS.

## Repository layout

```text
.
├── Ada/          Ada + JavaScript, Kotlin, Lisp, and SQL
├── Bash/         Bash + Pascal
├── C/            C + x86 assembly (32-bit and 64-bit), C + Elixir, C + PHP, C + Python
├── C++/          C++ + x86 assembly (32-bit and 64-bit), and C++ + Lua
├── Clojure/      Clojure + Lua, and Clojure + PowerShell
├── Dart/         Dart + Haskell
├── Elixir/       Elixir + Fortran
├── Elm/          Elm + Prolog, Scala, and Swift
├── Erlang/       Erlang + Haskell
├── F#/           F# + Lisp
├── Fortran/      Fortran + COBOL
├── Groovy/       Groovy + Objective-C
├── Haskell/      Haskell + assembly, and Haskell + Scala
├── Haxe/         Haxe + Erlang, Groovy, and Perl
├── Java/         Java + C#, Clojure, Groovy, Kotlin, Scala
├── JavaScript/   Node.js + C#, Dart, SCSS, and SQL
├── Julia/        Julia + SQL
├── Kotlin/       Kotlin + Prolog
├── Lua/          Lua + R, and Lua + Swift
├── Nim/          Nim + R
├── OCaml/        OCaml + Go, Objective-C, and SCSS
├── Perl/         Perl + Pascal, and Perl + Prolog
├── PHP/          PHP + Dart
├── PowerShell/   PowerShell + V
├── Python/       Python + C++, Java, Prolog, and SCSS
├── R/            R + PHP
├── Ruby/         Ruby + Rust
├── Rust/         Rust + Shell
├── Scala/        Scala + Julia, and Scala + VB.NET
├── Shell/        Shell + Pascal, and Shell + VB.NET
├── Swift/        Swift + Nim
├── TypeScript/   TypeScript + C#, Objective-C, and Python
└── V/            V + C++, and V + R
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

## Planned samples

These 25 combinations were drawn at random from a pool of 50 languages
(`assembly` and `tiger` excluded): the pool was shuffled and consecutive entries
were paired, so every language appears exactly once. **Twenty** are now built and
listed in the index above; the remaining five cannot be built with the toolchains
available here.

| # | Combination | Status |
| --- | --- | --- |
| 1 | Bash with CSS | not feasible — CSS is not executable logic |
| 2 | F# with Lisp | **built** |
| 3 | Elm with Prolog | **built** |
| 4 | Simula with Shell | needs a Simula compiler |
| 5 | TypeScript with Python | **built** |
| 6 | Julia with SQL | **built** |
| 7 | Erlang with Haskell | **built** |
| 8 | JavaScript with SCSS | **built** |
| 9 | Ruby with Rust | **built** |
| 10 | Haxe with Perl | **built** |
| 11 | Groovy with Objective-C | **built** |
| 12 | PHP with Dart | **built** |
| 13 | Clojure with PowerShell | **built** |
| 14 | Fortran with COBOL | **built** (Linux) |
| 15 | Java with C# | **built** |
| 16 | OCaml with Go | **built** |
| 17 | Swift with Nim | **built** |
| 18 | C with Elixir | **built** |
| 19 | Scala with VB / VB.NET | **built** |
| 20 | Ada with Kotlin | **built** |
| 21 | Lua with R | **built** |
| 22 | V with C++ | **built** |
| 23 | VBA with Pascal | needs a VBA host (Microsoft Office) |
| 24 | HTML with Zig | not feasible — HTML is not executable logic |
| 25 | KQL with D | needs a KQL engine |

### Batch 2

With the first batch exhausted, a second draw was made from the same pool — this
time excluding combinations already covered, and excluding languages that cannot
host a process (`sql` and `scss` can only ever be a guest, since a query or
stylesheet language has nothing to spawn a child with). All ten are built and
listed in the index above.

| # | Combination | Status |
| --- | --- | --- |
| 1 | Elixir with Fortran | **built** |
| 2 | Shell with VB / VB.NET | **built** |
| 3 | Dart with Haskell | **built** |
| 4 | C++ with Lua | **built** |
| 5 | Haxe with Groovy | **built** |
| 6 | Ada with SQL | **built** |
| 7 | Elm with Swift | **built** |
| 8 | C with Python | **built** |
| 9 | OCaml with SCSS | **built** |
| 10 | R with PHP | **built** |

### Batch 3

A third draw, with the same rules. All ten are built and listed in the index
above.

| # | Combination | Status |
| --- | --- | --- |
| 1 | Rust with Shell | **built** |
| 2 | Nim with R | **built** |
| 3 | Elm with Scala | **built** |
| 4 | Bash with Pascal | **built** |
| 5 | Ada with Lisp | **built** |
| 6 | JavaScript with SQL | **built** |
| 7 | PowerShell with V | **built** |
| 8 | TypeScript with C# | **built** |
| 9 | OCaml with Objective-C | **built** |
| 10 | Lua with Swift | **built** |

### Batch 4

A fourth draw, again excluding every combination already covered. All ten are
built and listed in the index above.

| # | Combination | Status |
| --- | --- | --- |
| 1 | TypeScript with Objective-C | **built** |
| 2 | Shell with Pascal | **built** |
| 3 | Ada with JavaScript | **built** |
| 4 | V with R | **built** |
| 5 | Haxe with Erlang | **built** |
| 6 | Kotlin with Prolog | **built** |
| 7 | C with PHP | **built** |
| 8 | Clojure with Lua | **built** |
| 9 | Scala with Julia | **built** |
| 10 | Python with SCSS | **built** |

## Contributing

New samples are welcome. Keep them small, keep them self-contained, and make
sure the folder contains a `README.md` with prerequisites, build commands and
the expected output, plus any `.gitignore` entries needed for build artefacts.

