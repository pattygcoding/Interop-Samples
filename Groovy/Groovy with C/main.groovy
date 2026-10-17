#!/usr/bin/env groovy

/**
 * Interop sample: Groovy driving a compiled C program.
 *
 * Groovy passes the numbers as command-line arguments to the C helper and reads
 * the average it prints back from stdout.
 *
 * See README.md for build and run instructions.
 */

import groovy.transform.Field

@Field final String EXECUTABLE = 'average_calculator' + (System.getProperty('os.name').toLowerCase().contains('windows') ? '.exe' : '')
@Field final List<Double> DEFAULT_NUMBERS = [10.0, 20.0, 30.0, 40.0, 50.0]

/** Run the C helper and return the average it prints. */
double calculateAverage(List<Double> numbers) {
    if (!numbers) {
        throw new IllegalArgumentException('calculateAverage expects a non-empty list')
    }

    def process = new ProcessBuilder([EXECUTABLE] + numbers.collect { it.toString() }).start()

    def output = new StringBuilder()
    def errors = new StringBuilder()
    process.consumeProcessOutput(output, errors)
    process.waitFor()

    if (process.exitValue() != 0) {
        def detail = errors.toString().trim()
        throw new RuntimeException(detail ?: "the C helper exited with code ${process.exitValue()}")
    }

    def text = output.toString().trim()

    if (!(text ==~ /-?\d+(\.\d+)?/)) {
        throw new RuntimeException("unexpected output from the C helper: '${text}'")
    }

    return text as Double
}

/** Convert command-line tokens to doubles, skipping anything invalid. */
List<Double> parseNumbers(List<String> tokens) {
    tokens.collect { token ->
        try {
            return token as Double
        } catch (NumberFormatException ignored) {
            System.err.println("warning: skipping non-numeric argument '${token}'")
            return null
        }
    }.findAll { it != null }
}

def numbers = args ? parseNumbers(args as List<String>) : DEFAULT_NUMBERS

if (!numbers) {
    System.err.println('error: no numbers to average')
    System.exit(1)
}

try {
    def average = calculateAverage(numbers)

    // Format with the root locale so the decimal separator is stable.
    println String.format(Locale.ROOT, 'The average of %d value(s) is: %.2f', numbers.size(), average)
} catch (Exception error) {
    System.err.println("error: ${error.message}")
    System.exit(1)
}
