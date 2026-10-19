/**
 * Interop sample: Java calling a Groovy class.
 *
 * <p>Groovy classes compile to ordinary JVM bytecode, so Java can call this
 * exactly like a hand-written Java class.
 */
class AverageCalculator {

    /**
     * Returns the arithmetic mean of {@code numbers}, or 0.0 when empty.
     *
     * @param numbers values to average (may be {@code null})
     * @return the mean as a {@code double}
     */
    static double calculateAverage(int[] numbers) {
        if (numbers == null || numbers.length == 0) {
            return 0.0d
        }
        return (numbers.sum() as double) / numbers.length
    }
}

