// Interop sample: prints the arithmetic mean of the numbers given on the
// command line.
//
// Invoked by main.js; see README.md for build and run instructions.

import Foundation

let arguments = Array(CommandLine.arguments.dropFirst())

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("error: \(message)\n".utf8))
    exit(1)
}

if arguments.isEmpty {
    fail("no numbers supplied")
}

var total = 0.0
var count = 0

for argument in arguments {
    guard let value = Double(argument) else {
        fail("'\(argument)' is not a number")
    }

    total += value
    count += 1
}

// The POSIX locale keeps the decimal separator a dot on every machine.
let average = total / Double(count)
print(String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), average))
