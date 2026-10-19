// Interop sample: Go driving a SWI-Prolog program.
//
// Go passes the numbers as command-line arguments to the Prolog helper and reads
// the average it prints back from stdout.
//
// See README.md for build and run instructions.
package main

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

var defaultNumbers = []float64{10, 20, 30, 40, 50}

// parseNumbers converts command-line tokens to floats, skipping anything invalid.
func parseNumbers(tokens []string) []float64 {
	numbers := make([]float64, 0, len(tokens))

	for _, token := range tokens {
		value, err := strconv.ParseFloat(token, 64)

		if err != nil {
			fmt.Fprintf(os.Stderr, "warning: skipping non-numeric argument '%s'\n", token)
			continue
		}

		numbers = append(numbers, value)
	}

	return numbers
}

// calculateAverage runs the Prolog helper and returns the average it prints.
func calculateAverage(numbers []float64) (float64, error) {
	// `--` stops SWI-Prolog from treating the numbers as options.
	arguments := []string{"-q", "-f", "average_calculator.pl", "-g", "main", "--"}

	for _, number := range numbers {
		arguments = append(arguments, strconv.FormatFloat(number, 'f', -1, 64))
	}

	command := exec.Command("swipl", arguments...)

	// The helper's diagnostics go straight to our own stderr.
	command.Stderr = os.Stderr

	output, err := command.Output()

	if err != nil {
		return 0, fmt.Errorf("the Prolog helper failed: %v", err)
	}

	text := strings.TrimSpace(string(output))

	value, err := strconv.ParseFloat(text, 64)

	if err != nil {
		return 0, fmt.Errorf("unexpected output from the Prolog helper: %q", text)
	}

	return value, nil
}

func main() {
	args := os.Args[1:]
	numbers := defaultNumbers

	if len(args) > 0 {
		numbers = parseNumbers(args)
	}

	if len(numbers) == 0 {
		fmt.Fprintln(os.Stderr, "error: no numbers to average")
		os.Exit(1)
	}

	average, err := calculateAverage(numbers)

	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("The average of %d value(s) is: %.2f\n", len(numbers), average)
}
