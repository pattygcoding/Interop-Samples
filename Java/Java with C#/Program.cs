using System;
using System.Globalization;
using System.Text.Json;

/// <summary>
/// Interop sample: reads a JSON array of numbers from standard input and writes
/// the arithmetic mean to standard output.
///
/// Invoked by <c>Main.java</c>; see README.md for build and run instructions.
/// </summary>
internal static class Program
{
    private static int Main()
    {
        string input = Console.In.ReadToEnd();

        if (string.IsNullOrWhiteSpace(input))
        {
            Console.Error.WriteLine("error: expected a JSON array of numbers on stdin");
            return 1;
        }

        try
        {
            double[] numbers = JsonSerializer.Deserialize<double[]>(input) ?? Array.Empty<double>();

            if (numbers.Length == 0)
            {
                Console.Error.WriteLine("error: the array is empty");
                return 1;
            }

            double sum = 0.0;
            foreach (double value in numbers)
            {
                sum += value;
            }

            double average = sum / numbers.Length;

            // Invariant culture keeps the decimal separator machine-independent.
            Console.Out.WriteLine(average.ToString("0.##########", CultureInfo.InvariantCulture));
            return 0;
        }
        catch (JsonException ex)
        {
            Console.Error.WriteLine($"error: invalid JSON: {ex.Message}");
            return 1;
        }
    }
}
