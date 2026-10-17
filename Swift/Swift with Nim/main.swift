// Interop sample: Swift driving a compiled Nim program.
//
// Swift writes the numbers to the Nim helper's standard input and reads the
// average back from its standard output.
//
// See README.md for build and run instructions.

import Foundation

#if os(Windows)
let executableName = "average_calculator.exe"
#else
let executableName = "average_calculator"
#endif

let executableURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent(executableName)

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

let arguments = Array(CommandLine.arguments.dropFirst())
let numbers = arguments.isEmpty ? defaultNumbers : parseNumbers(arguments)

if numbers.isEmpty {
    fail("no numbers to average")
}

let process = Process()
process.executableURL = executableURL

let stdinPipe = Pipe()
let stdoutPipe = Pipe()
let stderrPipe = Pipe()

process.standardInput = stdinPipe
process.standardOutput = stdoutPipe
process.standardError = stderrPipe

do {
    try process.run()
} catch {
    fail("could not run \(executableName): \(error)")
}

// Feed the numbers in, then close stdin so the helper sees end-of-input.
stdinPipe.fileHandleForWriting.write(Data(numbers.map { String($0) }.joined(separator: " ").utf8))
try? stdinPipe.fileHandleForWriting.close()

let outputData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
process.waitUntilExit()

if process.terminationStatus != 0 {
    let data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
    let message = String(data: data, encoding: .utf8) ?? "the Nim helper failed"
    fail(message.trimmingCharacters(in: .whitespacesAndNewlines))
}

guard let text = String(data: outputData, encoding: .utf8),
      let average = Double(text.trimmingCharacters(in: .whitespacesAndNewlines)) else {
    fail("unexpected output from the Nim helper")
}

print(String(format: "The average of %d value(s) is: %.2f", numbers.count, average))
