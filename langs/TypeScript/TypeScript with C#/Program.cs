using System;
using System.Globalization;

/// <summary>
/// Interop sample: prints the arithmetic mean of the numbers given on the
/// command line.
///
/// Invoked by <c>main.ts</c>; see README.md for build and run instructions.
/// </summary>
internal static class Program
{
    private static int Main(string[] args)
    {
        if (args.Length == 0)
        {
            Console.Error.WriteLine("error: no numbers supplied");
            return 1;
        }

        double total = 0.0;

        foreach (string argument in args)
        {
            if (!double.TryParse(argument, NumberStyles.Float, CultureInfo.InvariantCulture, out double value))
            {
                Console.Error.WriteLine($"error: '{argument}' is not a number");
                return 1;
            }

            total += value;
        }

        double average = total / args.Length;

        // Invariant culture keeps the decimal separator machine-independent.
        Console.Out.WriteLine(average.ToString("0.00", CultureInfo.InvariantCulture));
        return 0;
    }
}
