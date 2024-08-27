class AverageCalculator {
    static double calculateAverage(int[] numbers) {
        if (numbers.length == 0) {
            return 0.0
        }

        double sum = numbers.sum()
        return sum / numbers.length
    }
}
