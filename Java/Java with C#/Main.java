import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.stream.Collectors;

/**
 * Interop sample: Java driving a C# program.
 *
 * <p>Java starts the .NET console app, writes a JSON array of numbers to its
 * standard input and reads the average back from its standard output - the same
 * protocol the JavaScript with C# sample uses.
 *
 * <p>See README.md for build and run instructions.
 */
public final class Main {

    private static final int[] DEFAULT_NUMBERS = {10, 20, 30, 40, 50};

    private Main() {
    }

    public static void main(String[] args) throws IOException, InterruptedException {
        int[] numbers = args.length > 0 ? parse(args) : DEFAULT_NUMBERS;

        if (numbers.length == 0) {
            System.err.println("error: no integers to average");
            System.exit(1);
        }

        String json = Arrays.stream(numbers)
                .mapToObj(Integer::toString)
                .collect(Collectors.joining(",", "[", "]"));

        ProcessBuilder builder = new ProcessBuilder(
                "dotnet", "run",
                "--project", projectDirectory().toString(),
                "-v", "quiet");
        Process process = builder.start();

        try (Writer stdin = new OutputStreamWriter(process.getOutputStream(), StandardCharsets.UTF_8)) {
            stdin.write(json);
        }

        String stdout = readAll(process.getInputStream());
        int exitCode = process.waitFor();
        String stderr = readAll(process.getErrorStream());

        if (exitCode != 0) {
            String detail = stderr.strip();
            System.err.println("error: "
                    + (detail.isEmpty() ? "dotnet exited with code " + exitCode : detail));
            System.exit(1);
        }

        double average = Double.parseDouble(stdout.strip());

        System.out.printf("The average of %d value(s) is: %.2f%n", numbers.length, average);
    }

    /** The directory holding this class, so the C# project is found from anywhere. */
    private static Path projectDirectory() {
        try {
            Path location = Paths.get(
                    Main.class.getProtectionDomain().getCodeSource().getLocation().toURI());
            return Files.isDirectory(location) ? location : location.getParent();
        } catch (Exception ex) {
            return Paths.get(".");
        }
    }

    private static String readAll(InputStream stream) throws IOException {
        StringBuilder builder = new StringBuilder();

        try (BufferedReader reader =
                     new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line).append('\n');
            }
        }

        return builder.toString();
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
