// Interop sample: Swift driving a Ruby script.
//
// Swift passes the numbers as command-line arguments to the Ruby helper and
// reads the average it prints back from stdout.
//
// See README.md for build and run instructions.

import Foundation

#if os(Windows)
let pathSeparator = ";"
// `Process` hands its target straight to `CreateProcess`, which cannot start a
// `.cmd` or `.bat` shim — so those are collected separately and only used as a
// last resort, through the command processor.
let directSuffixes = [".exe", ""]
let scriptSuffixes = [".cmd", ".bat"]
#else
let pathSeparator = ":"
let directSuffixes = [""]
let scriptSuffixes = [String]()
#endif

let defaultNumbers = [10.0, 20.0, 30.0, 40.0, 50.0]

func writeError(_ message: String) {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
}

func fail(_ message: String) -> Never {
    writeError("error: \(message)")
    exit(1)
}

// Convert command-line tokens to doubles, skipping anything invalid.
func parseNumbers(_ tokens: [String]) -> [Double] {
    var numbers: [Double] = []

    for token in tokens {
        if let value = Double(token) {
            numbers.append(value)
        } else {
            writeError("warning: skipping non-numeric argument '\(token)'")
        }
    }

    return numbers
}

// Read an environment variable, matching the name case-insensitively.
//
// Windows spells the lookup path `Path` rather than `PATH`, and Foundation
// preserves whatever casing the process was started with.
func environmentValue(_ name: String) -> String? {
    let environment = ProcessInfo.processInfo.environment

    if let direct = environment[name] {
        return direct
    }

    return environment.first { $0.key.caseInsensitiveCompare(name) == .orderedSame }?.value
}

// Locate a way to run the named program, preferring a real executable over a
// batch shim.
func locate(_ name: String) -> (command: URL, isScript: Bool)? {
    guard let path = environmentValue("PATH") else {
        return nil
    }

    let fileManager = FileManager.default
    var script: URL?

    for directory in path.split(separator: Character(pathSeparator)) where !directory.isEmpty {
        let base = URL(fileURLWithPath: String(directory))

        for suffix in directSuffixes {
            let candidate = base.appendingPathComponent(name + suffix)

            if fileManager.isExecutableFile(atPath: candidate.path) {
                return (candidate, false)
            }
        }

        if script == nil {
            for suffix in scriptSuffixes {
                let candidate = base.appendingPathComponent(name + suffix)

                if fileManager.isExecutableFile(atPath: candidate.path) {
                    script = candidate
                }
            }
        }
    }

    return script.map { ($0, true) }
}

let arguments = Array(CommandLine.arguments.dropFirst())
let numbers = arguments.isEmpty ? defaultNumbers : parseNumbers(arguments)

if numbers.isEmpty {
    fail("no numbers to average")
}

guard let ruby = locate("ruby") else {
    fail("could not find ruby on PATH")
}

let helperArguments = ["average_calculator.rb"] + numbers.map { String($0) }

let process = Process()

if ruby.isScript {
    process.executableURL = URL(fileURLWithPath: environmentValue("COMSPEC") ?? "cmd.exe")
    process.arguments = ["/c", ruby.command.path] + helperArguments
} else {
    process.executableURL = ruby.command
    process.arguments = helperArguments
}

let stdoutPipe = Pipe()
let stderrPipe = Pipe()

process.standardOutput = stdoutPipe
process.standardError = stderrPipe

do {
    try process.run()
} catch {
    fail("could not run ruby: \(error)")
}

let outputData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
process.waitUntilExit()

if process.terminationStatus != 0 {
    let data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
    let message = String(data: data, encoding: .utf8) ?? "the Ruby helper failed"
    fail(message.trimmingCharacters(in: .whitespacesAndNewlines))
}

guard let text = String(data: outputData, encoding: .utf8),
      let average = Double(text.trimmingCharacters(in: .whitespacesAndNewlines)) else {
    fail("unexpected output from the Ruby helper")
}

print(String(format: "The average of %d value(s) is: %.2f", numbers.count, average))
