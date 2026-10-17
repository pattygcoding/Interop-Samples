/**
 * Interop sample: prints the arithmetic mean of the numbers given on the command
 * line.
 *
 * Invoked by main.f90; see README.md for build and run instructions.
 */

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public final class AverageCalculator {
    public static void main(String[] args) {
        if (args.length == 0) {
            System.err.println("error: no numbers supplied");
            System.exit(1);
        }

        List<Double> numbers = new ArrayList<>();

        for (String token : args) {
            try {
                numbers.add(Double.parseDouble(token));
            } catch (NumberFormatException error) {
                System.err.printf("error: '%s' is not a number%n", token);
                System.exit(1);
            }
        }

        double total = 0.0;

        for (double value : numbers) {
            total += value;
        }

        // Format with the root locale so the decimal separator is stable.
        System.out.printf(Locale.ROOT, "%.2f%n", total / numbers.size());
    }

    private AverageCalculator() {
    }
}
