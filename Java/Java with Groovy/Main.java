import java.util.Arrays;

/**
 * Interop sample: Java calling a Groovy class.
 *
 * <p>{@code AverageCalculator.groovy} is compiled to bytecode with
 * {@code groovyc}, after which Java treats it like any other class. The Groovy
 * runtime must be on the classpath at run time.
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

