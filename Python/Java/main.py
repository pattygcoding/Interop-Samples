import subprocess
import json

def calculate_average(numbers):
    # Convert the list of numbers to a JSON string
    numbers_json = json.dumps(numbers)

    # Run the Java program as a subprocess
    result = subprocess.run(
        ["java", "AverageCalculator", numbers_json],
        capture_output=True,
        text=True
    )

    # Get the output from the Java program
    average = result.stdout.strip()
    return float(average)

# Example usage
numbers = [10, 20, 30, 40, 50]
average = calculate_average(numbers)
print(f"The average is: {average}")
