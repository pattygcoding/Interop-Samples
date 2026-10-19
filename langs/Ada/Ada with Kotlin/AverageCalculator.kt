import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.Locale
import kotlin.system.exitProcess

/**
 * Interop sample: reads whitespace-separated numbers from standard input and
 * prints their arithmetic mean.
 *
 * Invoked by main.adb; see README.md for build and run instructions.
 */
fun main() {
    val numbers = mutableListOf<Double>()

    BufferedReader(InputStreamReader(System.`in`)).forEachLine { line ->
        for (token in line.trim().split(Regex("\\s+"))) {
            if (token.isEmpty()) {
                continue
            }

            val value = token.toDoubleOrNull()

            if (value == null) {
                System.err.println("error: '$token' is not a number")
                exitProcess(1)
            }

            numbers.add(value)
        }
    }

    if (numbers.isEmpty()) {
        System.err.println("error: no numbers on stdin")
        exitProcess(1)
    }

    // Format with the root locale so the decimal separator is stable.
    println(String.format(Locale.ROOT, "%.2f", numbers.sum() / numbers.size))
}
