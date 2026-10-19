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
| [Ada with Java](langs/Ada/Ada%20with%20Java/README.md) | Ada | Java | Child process + argv/stdout | Any |
| [Ada with JavaScript](langs/Ada/Ada%20with%20JavaScript/README.md) | Ada | JavaScript (Node.js) | Child process + stdin/stdout | Any |
| [Ada with Kotlin](langs/Ada/Ada%20with%20Kotlin/README.md) | Ada | Kotlin | Child process + stdin/stdout | Any |
| [Ada with Lisp](langs/Ada/Ada%20with%20Lisp/README.md) | Ada | Common Lisp (SBCL) | Child process + stdin/stdout | Any |
| [Ada with SQL](langs/Ada/Ada%20with%20SQL/README.md) | Ada | SQL (SQLite) | Child process + `sqlite3` shell | Any |
| [Bash with Pascal](langs/Bash/Bash%20with%20Pascal/README.md) | Bash | Free Pascal | Child process + argv/stdout | Any |
| [C with Assembly (32-bit)](langs/C/C%20with%20Assembly%20(32bit)/README.md) | C | x86-32 assembly | Native linking, `cdecl` | Linux, Windows |
| [C with Assembly (64-bit)](langs/C/C%20with%20Assembly%20(64bit)/README.md) | C | x86-64 assembly | Native linking, System V / MS x64 ABI | Linux, Windows |
| [C with Elixir](langs/C/C%20with%20Elixir/README.md) | C | Elixir | Child process + `popen` pipe | Any |
| [C with PHP](langs/C/C%20with%20PHP/README.md) | C | PHP | Child process + `popen` pipe | Any |
| [C with Python](langs/C/C%20with%20Python/README.md) | C | Python 3 | Child process + `popen` pipe | Any |
| [C++ with Assembly (32-bit)](langs/C%2B%2B/C%2B%2B%20with%20Assembly%20(32bit)/README.md) | C++ | x86-32 assembly | Native linking, `extern "C"` | Linux, Windows |
| [C++ with Assembly (64-bit)](langs/C%2B%2B/C%2B%2B%20with%20Assembly%20(64bit)/README.md) | C++ | x86-64 assembly | Native linking, `extern "C"` | Linux, Windows |
| [C++ with C](langs/C%2B%2B/C%2B%2B%20with%20C/README.md) | C++ | C | Child process + `popen` pipe | Any |
| [C++ with Lua](langs/C%2B%2B/C%2B%2B%20with%20Lua/README.md) | C++ | Lua | Child process + `popen` pipe | Any |
| [Clojure with Lua](langs/Clojure/Clojure%20with%20Lua/README.md) | Clojure | Lua | Child process + argv/stdout | Any |
| [Clojure with PowerShell](langs/Clojure/Clojure%20with%20PowerShell/README.md) | Clojure | PowerShell | Child process + argv/stdout | Any |
| [Dart with Haskell](langs/Dart/Dart%20with%20Haskell/README.md) | Dart | Haskell | Child process + argv/stdout | Any |
| [Dart with Python](langs/Dart/Dart%20with%20Python/README.md) | Dart | Python 3 | Child process + argv/stdout | Any |
| [Elixir with Fortran](langs/Elixir/Elixir%20with%20Fortran/README.md) | Elixir | Fortran | Child process + argv/stdout | Any |
| [Elm with D](langs/Elm/Elm%20with%20D/README.md) | Elm | D | Ports + Node host, child process | Any |
| [Elm with Prolog](langs/Elm/Elm%20with%20Prolog/README.md) | Elm | SWI-Prolog | Ports + Node host, child process | Any |
| [Elm with Scala](langs/Elm/Elm%20with%20Scala/README.md) | Elm | Scala 3 | Ports + Node host, child process | Any |
| [Elm with Swift](langs/Elm/Elm%20with%20Swift/README.md) | Elm | Swift | Ports + Node host, child process | Any |
| [Erlang with Haskell](langs/Erlang/Erlang%20with%20Haskell/README.md) | Erlang | Haskell | Erlang port + argv/stdout | Any |
| [F# with Lisp](langs/F%23/F%23%20with%20Lisp/README.md) | F# | Common Lisp (SBCL) | Child process + stdin/stdout | Any |
| [F# with SCSS](langs/F%23/F%23%20with%20SCSS/README.md) | F# | SCSS (Dart Sass) | Child process + generated CSS | Any |
| [Fortran with COBOL](langs/Fortran/Fortran%20with%20COBOL/README.md) | Fortran | COBOL (GnuCOBOL) | Child process + shell redirection | Linux |
| [Fortran with Java](langs/Fortran/Fortran%20with%20Java/README.md) | Fortran | Java | Child process + shell redirection | Any |
| [Go with Prolog](langs/Go/Go%20with%20Prolog/README.md) | Go | SWI-Prolog | Child process + argv/stdout | Any |
| [Go with Scala](langs/Go/Go%20with%20Scala/README.md) | Go | Scala 3 | Child process + argv/stdout | Any |
| [Groovy with C](langs/Groovy/Groovy%20with%20C/README.md) | Groovy | C | Child process + argv/stdout | Any |
| [Groovy with Objective-C](langs/Groovy/Groovy%20with%20Objective-C/README.md) | Groovy | Objective-C | Child process + argv/stdout | Any |
| [Groovy with Shell](langs/Groovy/Groovy%20with%20Shell/README.md) | Groovy | Shell (POSIX `sh`) | Child process + argv/stdout | Any |
| [Haskell with Assembly (32-bit)](langs/Haskell/Haskell%20with%20Assembly%20(32bit)/README.md) | Haskell | x86-32 assembly | Child process + text files | Linux i386 |
| [Haskell with Assembly (64-bit)](langs/Haskell/Haskell%20with%20Assembly%20(64bit)/README.md) | Haskell | x86-64 assembly | Child process + text files | Linux x86-64 |
| [Haskell with Clojure](langs/Haskell/Haskell%20with%20Clojure/README.md) | Haskell | Clojure | Child process + argv/stdout | Any |
| [Haskell with Nim](langs/Haskell/Haskell%20with%20Nim/README.md) | Haskell | Nim | Child process + argv/stdout | Any |
| [Haskell with Scala](langs/Haskell/Haskell%20with%20Scala/README.md) | Haskell | Scala 3 | Child process + stdin/stdout | Any |
| [Haxe with Erlang](langs/Haxe/Haxe%20with%20Erlang/README.md) | Haxe (Neko) | Erlang | Child process + argv/stdout | Any |
| [Haxe with Groovy](langs/Haxe/Haxe%20with%20Groovy/README.md) | Haxe (Neko) | Groovy | Child process + argv/stdout | Any |
| [Haxe with Perl](langs/Haxe/Haxe%20with%20Perl/README.md) | Haxe (Neko) | Perl | Child process + argv/stdout | Any |
| [Haxe with SCSS](langs/Haxe/Haxe%20with%20SCSS/README.md) | Haxe (Neko) | SCSS (Dart Sass) | Child process + generated CSS | Any |
| [Java with C#](langs/Java/Java%20with%20C%23/README.md) | Java | C# (.NET) | Child process + JSON on stdin/stdout | Any |
| [Java with Clojure](langs/Java/Java%20with%20Clojure/README.md) | Java | Clojure | In-process JVM API | Any (JVM) |
| [Java with Groovy](langs/Java/Java%20with%20Groovy/README.md) | Java | Groovy | Shared JVM bytecode | Any (JVM) |
| [Java with Kotlin](langs/Java/Java%20with%20Kotlin/README.md) | Java | Kotlin | Shared JVM bytecode | Any (JVM) |
| [Java with Scala](langs/Java/Java%20with%20Scala/README.md) | Java | Scala 3 | Shared JVM bytecode | Any (JVM) |
| [JavaScript with C#](langs/JavaScript/JavaScript%20with%20C%23/README.md) | Node.js | C# (.NET) | Child process + JSON on stdin/stdout | Any |
| [JavaScript with Dart](langs/JavaScript/JavaScript%20with%20Dart/README.md) | Node.js | Dart | Child process + JSON on stdin/stdout | Any |
| [JavaScript with Perl](langs/JavaScript/JavaScript%20with%20Perl/README.md) | Node.js | Perl | Child process + argv/stdout | Any |
| [JavaScript with SCSS](langs/JavaScript/JavaScript%20with%20SCSS/README.md) | Node.js | SCSS (Dart Sass) | In-process Sass compiler | Any |
| [JavaScript with SQL](langs/JavaScript/JavaScript%20with%20SQL/README.md) | Node.js | SQL (SQLite) | Child process + `sqlite3` shell | Any |
| [Julia with SQL](langs/Julia/Julia%20with%20SQL/README.md) | Julia | SQL (SQLite) | Child process + `sqlite3` shell | Any |
| [Kotlin with Prolog](langs/Kotlin/Kotlin%20with%20Prolog/README.md) | Kotlin | SWI-Prolog | Child process + argv/stdout | Any |
| [Lua with R](langs/Lua/Lua%20with%20R/README.md) | Lua | R | Child process + `io.popen` pipe | Any |
| [Lua with Swift](langs/Lua/Lua%20with%20Swift/README.md) | Lua | Swift | Child process + `io.popen` pipe | Any |
| [Nim with PHP](langs/Nim/Nim%20with%20PHP/README.md) | Nim | PHP | Child process + argv/stdout | Any |
| [Nim with R](langs/Nim/Nim%20with%20R/README.md) | Nim | R | Child process + argv/stdout | Any |
| [OCaml with Go](langs/OCaml/OCaml%20with%20Go/README.md) | OCaml | Go | Child process + temporary files | Any |
| [OCaml with Objective-C](langs/OCaml/OCaml%20with%20Objective-C/README.md) | OCaml | Objective-C | Child process + shell redirection | Any |
| [OCaml with SCSS](langs/OCaml/OCaml%20with%20SCSS/README.md) | OCaml | SCSS (Dart Sass) | Child process + generated CSS | Any |
| [Objective-C with Lisp](langs/Objective-C/Objective-C%20with%20Lisp/README.md) | Objective-C | Common Lisp (SBCL) | Child process + `popen` pipe | Any |
| [Pascal with Rust](langs/Pascal/Pascal%20with%20Rust/README.md) | Free Pascal | Rust | Child process + argv/stdout | Any |
| [Perl with Pascal](langs/Perl/Perl%20with%20Pascal/README.md) | Perl | Free Pascal | Child process + temporary file | Any |
| [Perl with Prolog](langs/Perl/Perl%20with%20Prolog/README.md) | Perl | SWI-Prolog | Child process + argv/stdout | Any |
| [PHP with Dart](langs/PHP/PHP%20with%20Dart/README.md) | PHP | Dart | Child process + argv/stdout | Any |
| [PowerShell with V](langs/PowerShell/PowerShell%20with%20V/README.md) | PowerShell | V | Child process + argv/stdout | Any |
| [Python with C++](langs/Python/Python%20with%20C%2B%2B/README.md) | Python | C++17 | Child process + stdin/stdout | Any |
| [Python with Java](langs/Python/Python%20with%20Java/README.md) | Python | Java | Child process + stdin/stdout | Any |
| [Python with Prolog](langs/Python/Python%20with%20Prolog/README.md) | Python | SWI-Prolog | In-process embedding (PySwip) | Any |
| [Python with SCSS](langs/Python/Python%20with%20SCSS/README.md) | Python | SCSS (Dart Sass) | Child process + generated CSS | Any |
| [R with PHP](langs/R/R%20with%20PHP/README.md) | R | PHP | Child process + argv/stdout | Any |
| [Ruby with Rust](langs/Ruby/Ruby%20with%20Rust/README.md) | Ruby | Rust | Child process + stdin/stdout | Any |
| [Rust with Lisp](langs/Rust/Rust%20with%20Lisp/README.md) | Rust | Common Lisp (SBCL) | Child process + argv/stdout | Any |
| [Rust with Shell](langs/Rust/Rust%20with%20Shell/README.md) | Rust | Shell (POSIX `sh`) | Child process + argv/stdout | Any |
| [Scala with Julia](langs/Scala/Scala%20with%20Julia/README.md) | Scala 3 | Julia | Child process + argv/stdout | Any |
| [Scala with VB / VB.NET](langs/Scala/Scala%20with%20VB.NET/README.md) | Scala 3 | VB.NET | Child process + argv/stdout | Any |
| [Shell with Pascal](langs/Shell/Shell%20with%20Pascal/README.md) | Shell | Free Pascal | Child process + argv/stdout | Any |
| [Shell with VB.NET](langs/Shell/Shell%20with%20VB.NET/README.md) | Shell | VB.NET | Child process + argv/stdout | Any |
| [Swift with Nim](langs/Swift/Swift%20with%20Nim/README.md) | Swift | Nim | Child process + stdin/stdout | Any |
| [Swift with Ruby](langs/Swift/Swift%20with%20Ruby/README.md) | Swift | Ruby | Child process + argv/stdout | Any |
| [TypeScript with C#](langs/TypeScript/TypeScript%20with%20C%23/README.md) | TypeScript (Node.js) | C# (.NET) | Child process + argv/stdout | Any |
| [TypeScript with Objective-C](langs/TypeScript/TypeScript%20with%20Objective-C/README.md) | TypeScript (Node.js) | Objective-C | Child process + argv/stdout | Any |
| [TypeScript with Python](langs/TypeScript/TypeScript%20with%20Python/README.md) | TypeScript (Node.js) | Python 3 | Child process + JSON on stdin/stdout | Any |
| [V with C++](langs/V/V%20with%20C%2B%2B/README.md) | V | C++17 | Child process + argv/stdout | Any |
| [V with R](langs/V/V%20with%20R/README.md) | V | R | Child process + argv/stdout | Any |
| [VB / VB.NET with D](langs/VB.NET/VB.NET%20with%20D/README.md) | VB.NET | D | Child process + argv/stdout | Any |

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
| GCC / G++ (or MinGW-w64) | 15.2 | C, C++, C with Elixir, C with PHP, C with Python, C++ with C, C++ with Lua, Groovy with C, Nim with R, Python with C++, V with C++ |
| GNAT (`gcc-ada`) | 16.2 | Ada with Java, Ada with JavaScript, Ada with Kotlin, Ada with Lisp, Ada with SQL |
| GHC | 9.8 | all Haskell samples, Dart with Haskell, Haskell with Clojure, Haskell with Nim |
| JDK | 21 | all Java samples, Python with Java, Ada with Java, Ada with Kotlin, Fortran with Java, Haskell with Clojure, Haxe with Groovy, Kotlin with Prolog |
| Clojure CLI | 1.12 | Clojure with Lua, Clojure with PowerShell, Haskell with Clojure, Java with Clojure |
| Groovy | 5.1 | Groovy with C, Groovy with Objective-C, Groovy with Shell, Haxe with Groovy, Java with Groovy |
| Kotlin compiler | 2.0 | Ada with Kotlin, Java with Kotlin, Kotlin with Prolog |
| Scala CLI (or Scala 3) | 3.9 | Elm with Scala, Go with Scala, Haskell with Scala, Java with Scala, Scala with Julia, Scala with VB / VB.NET |
| Node.js | 22 | all JavaScript samples, Ada with JavaScript, Elm with D, JavaScript with Perl, TypeScript with C#, TypeScript with Objective-C, TypeScript with Python |
| TypeScript | 5.7 | TypeScript with C#, TypeScript with Objective-C, TypeScript with Python |
| Dart Sass | 1.105 | F# with SCSS, Haxe with SCSS, JavaScript with SCSS, OCaml with SCSS, Python with SCSS |
| .NET SDK | 8.0 | F# with Lisp, F# with SCSS, Java with C#, JavaScript with C#, Scala with VB / VB.NET, Shell with VB.NET, TypeScript with C#, VB / VB.NET with D |
| Dart SDK | 3.13 | Dart with Haskell, Dart with Python, JavaScript with Dart, PHP with Dart |
| Elm | 0.19.2 | Elm with D, Elm with Prolog, Elm with Scala, Elm with Swift |
| Python | 3.14 | all Python samples, C with Python, Dart with Python, Python with SCSS, TypeScript with Python |
| PySwip | latest | Python with Prolog |
| SWI-Prolog | 10.0 | Elm with Prolog, Go with Prolog, Kotlin with Prolog, Perl with Prolog, Python with Prolog |
| Free Pascal | 3.2 | Bash with Pascal, Pascal with Rust, Perl with Pascal, Shell with Pascal |
| Elixir | 1.20 | C with Elixir |
| R | 4.6 | Lua with R, Nim with R, R with PHP, V with R |
| Lua | 5.1 | Clojure with Lua, C++ with Lua, Lua with R, Lua with Swift |
| Ruby | 3.4 | Ruby with Rust, Swift with Ruby |
| Rust (`rustc`) | 1.98 | Pascal with Rust, Ruby with Rust, Rust with Lisp, Rust with Shell |
| SBCL | 2.6 | Ada with Lisp, F# with Lisp, Objective-C with Lisp, Rust with Lisp |
| Erlang/OTP | 29 | Erlang with Haskell, Haxe with Erlang |
| Swift | 6.4 | Elm with Swift, Lua with Swift, Swift with Nim, Swift with Ruby |
| Nim | 2.2 | Haskell with Nim, Nim with PHP, Nim with R, Swift with Nim |
| PowerShell | 7+ (`pwsh`) or 5.1 | Clojure with PowerShell, PowerShell with V |
| POSIX shell (`sh` / `bash`) | 5.3 | Bash with Pascal, Groovy with Shell, Rust with Shell, Shell with Pascal, Shell with VB.NET |
| Haxe + Neko | 4.3 / 2.4 | Haxe with Erlang, Haxe with Groovy, Haxe with Perl, Haxe with SCSS |
| GCC ObjC (`gcc-objc` + `libobjc`) | 16.2 | Groovy with Objective-C, Objective-C with Lisp, OCaml with Objective-C, TypeScript with Objective-C |
| Julia | 1.13 | Julia with SQL, Scala with Julia |
| SQLite CLI | 3.54 | Ada with SQL, JavaScript with SQL, Julia with SQL |
| OCaml | 5.4 | OCaml with Go, OCaml with Objective-C, OCaml with SCSS |
| Go | 1.25 | Go with Prolog, Go with Scala, OCaml with Go |
| PHP | 8.5 | C with PHP, Nim with PHP, PHP with Dart, R with PHP |
| Perl | 5.16 | JavaScript with Perl, Perl with Pascal, Perl with Prolog |
| gfortran | 15.2 | Elixir with Fortran, Fortran with COBOL, Fortran with Java |
| GnuCOBOL | 3.2 | Fortran with COBOL |
| DMD (`dmd`) | 2.113 | Elm with D, VB / VB.NET with D |
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
- **Bash with Pascal**, **Rust with Shell**, **Groovy with Shell**, **Shell with
  Pascal** and **Shell with VB.NET** need a POSIX shell; on Windows that means Git
  Bash or MSYS2.
- **Rust with Shell**, **Groovy with Shell** probe for a working shell instead of
  trusting `PATH`, because on Windows `System32\bash.exe` — the WSL relay —
  shadows Git Bash for `CreateProcess` even when Git Bash comes first in `PATH`.
  Set `SHELL_INTERPRETER` to skip the search.
- **Haxe with Groovy** starts the Groovy interpreter through `java` rather than
  through the `groovy` shim, so `GROOVY_HOME` must be set. **Elm with Scala** hits
  the same shim problem and routes through `cmd /c` instead. **Python with SCSS**
  does the same for `sass`, because Python's `subprocess` passes its argument
  vector straight to `CreateProcess`, which cannot execute a `.cmd` file; **Haxe
  with SCSS** has the opposite problem — Neko's `Process` cannot start a shim
  either — and solves it with `Sys.command`, which goes through the command
  processor.
- **VB / VB.NET with D** and **Elm with D** may need DMD's own `windows\bin64`
  folder on `PATH` on Windows: DMD links against the Visual C++ 2013 runtime, and
  that folder ships a copy of `msvcr120.dll` for machines without the
  redistributable installed.
- **Pascal with Rust** may need FPC's FCL directory on the unit search path.
  Packaged installs — including scoop's — leave it out, so FPC reports
  `Can't find unit Process`; pass
  `-Fu<fpc>/units/<target>/fcl-process` to fix it.
- **Elm with D**, **F# with SCSS**, **Haxe with SCSS**, **Python with SCSS** and
  **R with PHP** round out the samples that shell out to a compiler or a shim
  rather than a plain interpreter.
- **Swift with Ruby** resolves the interpreter itself instead of trusting the
  platform to search `PATH`, because Foundation reports the Windows lookup path as
  `Path` rather than `PATH`, and because MSYS2 fills every directory it touches
  with `ruby.bat`/`ruby.cmd` shims that `CreateProcess` cannot start.
- **V with R** builds with `-cc tcc` on Windows: MinGW-w64's linker rejects an
  intrinsic in V's runtime, while V's bundled TinyCC links it correctly.
- Everything else is portable across Windows, Linux and macOS.

## Repository layout

Every host language is a folder in `langs/`, and each sample lives in a folder
beside it, named after the pair it joins:

```text
.
├── langs/
│   ├── Ada/            Ada + Java, JavaScript, Kotlin, Lisp, and SQL
│   │   ├── Ada with Java/        (one sample: its programs + its README)
│   │   └── ...
│   ├── Bash/           Bash + Pascal
│   ├── C/              C + x86 assembly (32-bit and 64-bit), C + Elixir, C + PHP, C + Python
│   ├── C++/            C++ + x86 assembly (32-bit and 64-bit), C++ + C, and C++ + Lua
│   ├── Clojure/        Clojure + Lua, and Clojure + PowerShell
│   ├── Dart/           Dart + Haskell, and Dart + Python
│   ├── Elixir/         Elixir + Fortran
│   ├── Elm/            Elm + D, Prolog, Scala, and Swift
│   ├── Erlang/         Erlang + Haskell
│   ├── F#/             F# + Lisp, and F# + SCSS
│   ├── Fortran/        Fortran + COBOL, and Fortran + Java
│   ├── Go/             Go + Prolog, and Go + Scala
│   ├── Groovy/         Groovy + C, Objective-C, and Shell
│   ├── Haskell/        Haskell + assembly, Clojure, Nim, and Scala
│   ├── Haxe/           Haxe + Erlang, Groovy, Perl, and SCSS
│   ├── Java/           Java + C#, Clojure, Groovy, Kotlin, Scala
│   ├── JavaScript/     Node.js + C#, Dart, Perl, SCSS, and SQL
│   ├── Julia/          Julia + SQL
│   ├── Kotlin/         Kotlin + Prolog
│   ├── Lua/            Lua + R, and Lua + Swift
│   ├── Nim/            Nim + PHP, and Nim + R
│   ├── OCaml/          OCaml + Go, Objective-C, and SCSS
│   ├── Objective-C/    Objective-C + Lisp
│   ├── Pascal/         Pascal + Rust
│   ├── Perl/           Perl + Pascal, and Perl + Prolog
│   ├── PHP/            PHP + Dart
│   ├── PowerShell/     PowerShell + V
│   ├── Python/         Python + C++, Java, Prolog, and SCSS
│   ├── R/              R + PHP
│   ├── Ruby/           Ruby + Rust
│   ├── Rust/           Rust + Lisp, and Rust + Shell
│   ├── Scala/          Scala + Julia, and Scala + VB.NET
│   ├── Shell/          Shell + Pascal, and Shell + VB.NET
│   ├── Swift/          Swift + Nim, and Swift + Ruby
│   ├── TypeScript/     TypeScript + C#, Objective-C, and Python
│   ├── V/              V + C++, and V + R
│   └── VB.NET/         VB.NET + D
├── public/, src/, tools/, index.html ...   the showcase site (see below)
└── README.md
```

## Getting started

Pick any sample folder, open its `README.md`, and follow the build and run steps.
For example:

```bash
cd "langs/C/C with Assembly (64bit)"
nasm -f elf64 calculate_average.asm -o calculate_average.o
gcc -O2 -Wall -Wextra main.c calculate_average.o -o average
./average
```

```text
The average of 5 value(s) is: 30.00
```

## Showcase site

Every sample is browsable as a web dashboard - the same shape as the author's
[Connect Four showcase](https://connectfour.pattygcoding.com/), built the same way
(Vue 3 + TypeScript + Vite + Tailwind) and served at
**<https://interop.pattygcoding.com/>**:

- **Languages** lists the 37 host languages, each with how many samples it holds.
- **Samples** lists the 88 pairings, one row per pair: the host language in the left
  half and the guest in the right, filterable by host language, bridge style (child
  process, native linking, ports, in-process API, JVM bytecode, embedding) and guest
  language.
- Every pairing is drawn as two halves side by side - the host language and its
  program(s) in the left half, the guest and its helper in the right, 50/50 - so the
  interop is visible without switching files. The pairings read guest-alphabetical, and
  a **Pairing** switcher in the header moves a host's page between them.
- Each pairing has three tabs: **Source Code** (both halves, Prism highlighting, line
  numbers, a copy button per file), **Docs** (the sample's own `README.md`, rendered)
  and **Expected Output** (the fenced block from that README).

```sh
npm start          # generate the data, then run the dev server
npm run build      # regenerate the data, type-check, write dist/
npm run data       # only regenerate public/interop-data.js
npm run typecheck  # vue-tsc --noEmit
```

`npm start` and `npm run build` run the generator first, so the Python command
never has to be remembered: `tools/generate-data.mjs` finds `python3`/`python` and
runs `tools/generate_dashboard.py` for you. That script reads the *real*
repository - the `langs/<Language>/` directories, each sample's README table and
expected-output block, and the README's sample index for the platform column - and
writes two things from it: `public/interop-data.js`, which the page loads with a
`<script>` tag (so it needs no fetch and no CORS), and [`docs/links.md`](docs/links.md),
the list of every address. The payload is generated and untracked; a checkout that has
not run the generator yet boots and says so.

### Addresses

Every address in the dashboard names a **pairing**, never a language on its own:
`/c-elixir` is C driving Elixir, `/cpp-lua` is C++ driving Lua, and
`/c-assembly-32bit` / `/c-assembly-64bit` are the two assembly variants (a pair that
appears twice keeps the bracket from its folder name). The sidebar entries are real
links, so they can be copied, bookmarked or opened in a new tab.

The **Languages** list is a way into those pairings, not a page of its own: each row
opens the first pairing that host offers - the guest that sorts first - so clicking
`C++` lands on `/cpp-assembly-32bit`. The same is true of an address that does name a
language (`/cpp`, `?item=cpp`, or the `cpp` subdomain): the page resolves it to that
host's first pairing and rewrites the address to match, so what is on screen is always
what the address says. From there the header's **Pairing** switcher moves between the
host's pairings, each one a full address of its own; the list the visitor was browsing
stays as it was.

A tab can be named on the path (`/c-elixir/docs`), a nested `/cpp/cpp-lua` reads the
same as the flat form, and the site root (`/`) opens the very first pairing. **Every
address is listed in [`docs/links.md`](docs/links.md)** - one section per host
language, generated from the same data the dashboard reads. The same
pairings can also be named on a subdomain - `c-elixir.interop.pattygcoding.com` for the
sample, or `c.interop.pattygcoding.com` for that host's first one - because the
dashboard reads the leftmost host label when it is an id it knows and ignores anything
else (`www`, or the apex domain itself). That only needs a wildcard `CNAME`
(`*.interop` -> `pattygcoding.github.io`) beside the record for `interop` itself;
without it, the path form is the one to use.

GitHub Pages has no rewrite rules, so those pretty paths are backed by
`public/404.html`: it is served for a path Pages cannot find, rebuilds the request
as `index.html?item=<id>&tab=<tab>` and leaves the address bar untouched, and the
page then writes the pretty path back with the History API. `?item=` and `?tab=` are
read on load in both shapes, so older links keep working.

`public/logo.png` is the tab icon: the portfolio's own mark - the very file
`pattygcoding.com` serves as its favicon, so every site in the family shows one icon.
It is a hand-copied asset rather than a generated one, and both `index.html` and the
shim above link it, so replacing the file is all it takes to change the icon.

To preview the **built** site the way Pages serves it:

```sh
npm run build                     # writes dist/
python tools/serve.py             # then open http://localhost:8000/c-elixir
```

Use that rather than `python -m http.server`: the dashboard's addresses are pretty
paths, which are not files, and a bare file server answers them with its own 404
page - so *refreshing* one of those screens looks broken locally even though the
deployed site is fine.

### Deploying

`.github/workflows/deploy.yml` does all of it: on every push to `main` it installs
Node 22 and Python 3.12, runs `npm ci` and `npm run build`, uploads `dist/` as the
Pages artifact and publishes it. Publishing from an artifact needs a one-time
setting per repository:

```sh
gh api -X PUT repos/pattygcoding/Interop-Samples/pages -f build_type=workflow
```

or **Settings -> Pages -> Build and deployment -> Source: GitHub Actions**. Until that
switch is flipped the workflow fails in its *build* job at `actions/configure-pages`
(the log says `Get Pages site failed`), even though the DNS record may already point at
GitHub. The custom domain (`interop.pattygcoding.com`, kept in `public/CNAME` for the
record) is set the same way as for the other showcases:

```sh
gh api -X PUT repos/pattygcoding/Interop-Samples/pages -f cname=interop.pattygcoding.com
```

then point a `CNAME` record for `interop` at `pattygcoding.github.io` in DNS.


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

### Batch 5

A fifth draw, again excluding every combination already covered. All ten are built
and listed in the index above. This batch brings in **D** as a guest language and
**Fortran** as a host, both for the first time.

| # | Combination | Status |
| --- | --- | --- |
| 1 | Dart with Python | **built** |
| 2 | Go with Scala | **built** |
| 3 | Swift with Ruby | **built** |
| 4 | Haskell with Nim | **built** |
| 5 | Groovy with Shell | **built** |
| 6 | C++ with C | **built** |
| 7 | VB / VB.NET with D | **built** |
| 8 | Haxe with SCSS | **built** |
| 9 | Fortran with Java | **built** |
| 10 | Rust with Lisp | **built** |

### Batch 6

A sixth draw, again excluding every combination already covered. All ten are built
and listed in the index above. This batch brings in **Objective-C** and **Pascal**
as hosts for the first time.

| # | Combination | Status |
| --- | --- | --- |
| 1 | Ada with Java | **built** |
| 2 | Objective-C with Lisp | **built** |
| 3 | Haskell with Clojure | **built** |
| 4 | Pascal with Rust | **built** |
| 5 | JavaScript with Perl | **built** |
| 6 | F# with SCSS | **built** |
| 7 | Go with Prolog | **built** |
| 8 | Nim with PHP | **built** |
| 9 | Elm with D | **built** |
| 10 | Groovy with C | **built** |

## Contributing

New samples are welcome. Keep them small, keep them self-contained, and make
sure the folder contains a `README.md` with prerequisites, build commands and
the expected output, plus any `.gitignore` entries needed for build artefacts.

