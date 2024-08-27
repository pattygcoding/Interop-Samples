package com.example

object AverageCalculator {
    @JvmStatic
    fun calculateAverage(numbers: IntArray): Double {
        return if (numbers.isNotEmpty()) {
            numbers.average()
        } else {
            0.0
        }
    }
}
