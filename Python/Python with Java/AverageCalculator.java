import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

/**
 * Interop sample: reads whitespace-separated numbers from standard input and
 * writes their arithmetic mean to standard output.
 *
 * <p>Invoked by {@code main.py}; see README.md for build and run instructions.
 */
public final class AverageCalculator {

    private AverageCalculator() {
    }

    public static void main(String[] args) throws IOException {
        List<Double> numbers = new ArrayList<>();

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(System.in))) {
            String line;
            while ((line = reader.readLine()) != null) {
                for (String token : line.trim().split("\\s+")) {
                    if (token.isEmpty()) {
                        continue;
                    }
                    try {
                        numbers.add(Double.parseDouble(token));
                    } catch (NumberFormatException ex) {
                        System.err.println("error: '" + token + "' is not a number");
                        System.exit(1);
                    }
                }
            }
        }

        if (numbers.isEmpty()) {
            System.err.println("error: no numbers on stdin");
            System.exit(1);
        }

        double sum = 0.0;
        for (double value : numbers) {
            sum += value;
        }

        System.out.println(sum / numbers.size());
    }
}

