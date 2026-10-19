// Interop sample: prints the arithmetic mean of the numbers given on the
// command line.
//
// Invoked by main.ps1; see README.md for build and run instructions.
module main

import os

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

fn main() {
	if os.args.len < 2 {
		eprintln('error: no numbers supplied')
		exit(1)
	}

	mut total := 0.0
	mut count := 0

	for index in 1 .. os.args.len {
		token := os.args[index]

		if !is_number(token) {
			eprintln("error: '${token}' is not a number")
			exit(1)
		}

		total += token.f64()
		count++
	}

	println('${total / count:.2f}')
}
