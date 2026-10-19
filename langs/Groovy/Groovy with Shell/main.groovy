#!/usr/bin/env groovy

/**
 * Interop sample: Groovy driving a POSIX shell script.
 *
 * Groovy passes the numbers as command-line arguments to the shell script and
 * reads the average it prints back from stdout.
 *
 * See README.md for build and run instructions.
 */

import groovy.transform.Field

@Field final List<String> SHELL_CANDIDATES = System.getProperty('os.name').toLowerCase().contains('windows')
    ? ['bash', 'sh', 'C:/Program Files/Git/bin/bash.exe', 'C:/msys64/usr/bin/bash.exe']
    : ['sh', 'bash']

@Field final List<Double> DEFAULT_NUMBERS = [10.0, 20.0, 30.0, 40.0, 50.0]

/**
 * Find a POSIX shell to run the script with.
 *
 * On Windows a bare `bash` is hijacked by `System32\bash.exe` — the WSL relay,
 * which fails when no distribution is installed — because `CreateProcess`
 * searches `System32` before `PATH`. The candidates are therefore probed and the
 * first one that actually runs is used. `SHELL_INTERPRETER` overrides the search.
 */
String shell() {
    def explicit = System.getenv('SHELL_INTERPRETER')

    if (explicit) {
        return explicit
    }

    for (candidate in SHELL_CANDIDATES) {
        try {
            def probe = new ProcessBuilder([candidate, '-c', 'exit 0'])
                .redirectOutput(ProcessBuilder.Redirect.DISCARD)
                .redirectError(ProcessBuilder.Redirect.DISCARD)
                .start()

            if (probe.waitFor() == 0) {
                return candidate
            }
        } catch (IOException ignored) {
            // Not a usable interpreter; try the next candidate.
        }
    }

    throw new RuntimeException(
        'no POSIX shell found; set SHELL_INTERPRETER to a working one (Git Bash or MSYS2 on Windows)'
    )
}

/** Run the shell helper and return the average it prints. */
double calculateAverage(String interpreter, List<Double> numbers) {
    if (!numbers) {
        throw new IllegalArgumentException('calculateAverage expects a non-empty list')
    }

    def command = [interpreter, 'average_calculator.sh'] + numbers.collect { it.toString() }

    def process = new ProcessBuilder(command).start()

    def output = new StringBuilder()
    def errors = new StringBuilder()
    process.consumeProcessOutput(output, errors)
    process.waitFor()

    if (process.exitValue() != 0) {
        def detail = errors.toString().trim()
        throw new RuntimeException(detail ?: "the shell helper exited with code ${process.exitValue()}")
    }

    def text = output.toString().trim()

    if (!(text ==~ /-?\d+(\.\d+)?/)) {
        throw new RuntimeException("unexpected output from the shell helper: '${text}'")
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
    def average = calculateAverage(shell(), numbers)

    // Format with the root locale so the decimal separator is stable.
    println String.format(Locale.ROOT, 'The average of %d value(s) is: %.2f', numbers.size(), average)
} catch (Exception error) {
    System.err.println("error: ${error.message}")
    System.exit(1)
}
