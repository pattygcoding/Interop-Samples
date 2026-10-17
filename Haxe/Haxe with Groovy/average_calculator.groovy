#!/usr/bin/env groovy

/**
 * Interop sample: prints the arithmetic mean of the numbers given on the
 * command line.
 *
 * Invoked by Main.hx; see README.md for build and run instructions.
 */

if (args.length == 0) {
    System.err.println('error: no numbers supplied')
    System.exit(1)
}

def numbers = args.collect { token ->
    try {
        return token as Double
    } catch (NumberFormatException ignored) {
        System.err.println("error: '${token}' is not a number")
        System.exit(1)
    }
}

// Format with the root locale so the decimal separator is stable.
println String.format(Locale.ROOT, '%.2f', numbers.sum() / numbers.size())
