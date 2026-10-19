import clojure.java.api.Clojure;
import clojure.lang.IFn;

import java.util.Arrays;

/**
 * Interop sample: Java calling a Clojure namespace.
 *
 * <p>The arithmetic lives in {@code average_calculator.clj}. Java brings the
 * Clojure runtime up through its public API, loads the namespace and invokes
 * the {@code calculate-average} function like any other {@link IFn}.
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

        // A namespace must be required before its vars can be resolved.
        Clojure.var("clojure.core", "require").invoke(Clojure.read("average-calculator"));

        IFn calculateAverage = Clojure.var("average-calculator", "calculate-average");
        Number result = (Number) calculateAverage.invoke(numbers);

        System.out.printf("The average of %d value(s) is: %.2f%n",
                numbers.length, result.doubleValue());
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

