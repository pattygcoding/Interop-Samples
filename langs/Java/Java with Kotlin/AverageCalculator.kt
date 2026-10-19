package com.example

/**
 * Interop sample: Java calling a Kotlin object.
 *
 * The `@JvmStatic` annotation exposes [calculateAverage] as a plain static
 * method, so Java can call it directly without touching the Kotlin runtime's
 * `INSTANCE` field.
 */
object AverageCalculator {

    /**
     * Returns the arithmetic mean of [numbers], or 0.0 when the array is empty.
     */
    @JvmStatic
    fun calculateAverage(numbers: IntArray): Double =
        if (numbers.isEmpty()) 0.0 else numbers.average()
}

