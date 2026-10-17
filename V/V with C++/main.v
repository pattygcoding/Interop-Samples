// Interop sample: V driving a compiled C++ program.
//
// V passes the numbers as command-line arguments to the C++ helper and reads
// the average it prints back from stdout.
//
// See README.md for build and run instructions.
module main

import os

const executable_name = if os.user_os() == 'windows' {
	'average_calculator.exe'
} else {
	'average_calculator'
}

const default_numbers = [10.0, 20.0, 30.0, 40.0, 50.0]

// is_number reports whether the token looks like a decimal number.
fn is_number(token string) bool {
	if token.len == 0 {
		return false
	}

	mut seen_digit := false

	for index, character in token {
		if character >= `0` && character <= `9` {
			seen_digit = true
			continue
		}

		if character == `.` {
			continue
		}

		if character == `-` && index == 0 {
			continue
		}

		return false
	}

	return seen_digit
}

// parse_numbers converts command-line tokens to floats, skipping anything invalid.
fn parse_numbers(tokens []string) []f64 {
	mut numbers := []f64{}

	for token in tokens {
		if is_number(token) {
			numbers << token.f64()
		} else {
			eprintln("warning: skipping non-numeric argument '${token}'")
		}
	}

	return numbers
}

// calculate_average runs the C++ helper and returns the average it prints.
fn calculate_average(numbers []f64) !f64 {
	mut arguments := [executable_name]

	for number in numbers {
		arguments << number.str()
	}

	result := os.execute(arguments.join(' '))

	if result.exit_code != 0 {
		detail := result.output.trim_space()

		if detail == '' {
			return error('the C++ helper exited with code ${result.exit_code}')
		}

		return error(detail)
	}

	return result.output.trim_space().f64()
}

fn main() {
	numbers := if os.args.len > 1 { parse_numbers(os.args[1..]) } else { default_numbers }

	if numbers.len == 0 {
		eprintln('error: no numbers to average')
		exit(1)
	}

	average := calculate_average(numbers) or {
		eprintln('error: ${err}')
		exit(1)
	}

	println('The average of ${numbers.len} value(s) is: ${average:.2f}')
}
