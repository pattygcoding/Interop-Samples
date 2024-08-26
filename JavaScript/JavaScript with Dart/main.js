const { exec } = require('child_process');

function calculateAverage(numbers) {
    // Convert the list of numbers to a JSON string
    const numbersJson = JSON.stringify(numbers);

    // Call the Dart program and pass the numbers as a command-line argument
    exec(`dart average_calculator.dart ${numbersJson}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error.message}`);
            return;
        }
        if (stderr) {
            console.error(`stderr: ${stderr}`);
            return;
        }

        // Print the output from the Dart program
        console.log(`The average is: ${stdout.trim()}`);
    });
}

// Example usage
const numbers = [10, 20, 30, 40, 50];
calculateAverage(numbers);
