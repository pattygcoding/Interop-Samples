using System;
using System.Linq;
using Newtonsoft.Json;

class Program
{
    static void Main(string[] args)
    {
        if (args.Length < 1)
        {
            Console.WriteLine("Usage: dotnet run <json_array>");
            return;
        }

        // Parse the JSON array passed from JavaScript
        string jsonArray = args[0];
        double[] numbers = JsonConvert.DeserializeObject<double[]>(jsonArray);

        // Calculate the average
        double average = numbers.Average();

        // Print the average, which will be captured by the JavaScript script
        Console.WriteLine(average);
    }
}
