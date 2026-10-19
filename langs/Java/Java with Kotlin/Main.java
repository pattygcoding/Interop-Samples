import com.example.AverageCalculator;

import java.util.Arrays;

/**
 * Interop sample: Java calling a Kotlin object.
 *
 * <p>{@code AverageCalculator.kt} is compiled to bytecode ahead of time; Java
 * then calls the generated static forwarder like any other method. Note the
 * import of the Kotlin package {@code com.example}.
 *
 * <p>See README.md for build and run instructions.
 */
public final class Main {

    private static final int[] DEFAULT_NUMBERS = {10, 20, 30, 40, 50};

    private Main() {
    }

    public static void main(String[] args) {
        int[] numbers = args.length > 0 ? parse(args) : DEFAULT_NUMBERS;

        if (numbers.length == 0) {
            System.err.println("error: no integers to average");
            System.exit(1);
        }

        double average = AverageCalculator.calculateAverage(numbers);

        System.out.printf("The average of %d value(s) is: %.2f%n", numbers.length, average);
    }

    /** Parse the command line, skipping anything that is not an integer. */
    private static int[] parse(String[] args) {
        int[] values = new int[args.length];
        int count = 0;

        for (String argument : args) {
            try {
                values[count++] = Integer.parseInt(argument.trim());
            } catch (NumberFormatException ex) {
                System.err.println("warning: skipping non-integer argument '" + argument + "'");
            }
        }

        return Arrays.copyOf(values, count);
    }
}

