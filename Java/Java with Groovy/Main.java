public class Main {
    public static void main(String[] args) {
        int[] numbers = {10, 20, 30, 40, 50};

        // Call the Groovy function to calculate the average
        double average = AverageCalculator.calculateAverage(numbers);

        System.out.println("The average is: " + average);
    }
}
