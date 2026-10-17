import java.util.Locale

/**
 * Interop sample: Kotlin driving a SWI-Prolog program.
 *
 * Kotlin passes the numbers as command-line arguments to the Prolog helper and
 * reads the average it prints back from stdout.
 *
 * See README.md for build and run instructions.
 */
fun main(args: Array<String>) {
    val numbers = if (args.isEmpty()) listOf(10.0, 20.0, 30.0, 40.0, 50.0) else parseNumbers(args)

    if (numbers.isEmpty()) {
        System.err.println("error: no numbers to average")
        System.exit(1)
    }

    val average = try {
        calculateAverage(numbers)
    } catch (error: RuntimeException) {
        System.err.println("error: ${error.message}")
        System.exit(1)
        return
    }

    // Format with the root locale so the decimal separator is stable.
    println(String.format(Locale.ROOT, "The average of %d value(s) is: %.2f", numbers.size, average))
}

/** Convert command-line tokens to doubles, skipping anything invalid. */
private fun parseNumbers(tokens: Array<String>): List<Double> {
    val numbers = mutableListOf<Double>()

    for (token in tokens) {
        val value = token.toDoubleOrNull()

        if (value == null) {
            System.err.println("warning: skipping non-numeric argument '$token'")
        } else {
            numbers.add(value)
        }
    }

    return numbers
}

/** Run the Prolog helper and return the average it prints. */
private fun calculateAverage(numbers: List<Double>): Double {
    val command = mutableListOf("swipl", "-q", "-f", "average_calculator.pl", "-g", "main", "--")
    numbers.mapTo(command) { it.toString() }

    val process = ProcessBuilder(command).start()
    val stdout = process.inputStream.bufferedReader().readText()
    val stderr = process.errorStream.bufferedReader().readText()
    val exitCode = process.waitFor()

    if (exitCode != 0) {
        val detail = stderr.trim()
        throw RuntimeException(detail.ifEmpty { "swipl exited with code $exitCode" })
    }

    return stdout.trim().toDoubleOrNull()
        ?: throw RuntimeException("unexpected output from the Prolog helper: '${stdout.trim()}'")
}
