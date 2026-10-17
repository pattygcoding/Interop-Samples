//! Interop sample: Rust driving an SBCL Lisp script.
//!
//! Rust passes the numbers as command-line arguments to the Lisp helper and
//! reads the average it prints back from stdout.
//!
//! See README.md for build and run instructions.

use std::env;
use std::process::{exit, Command};

const DEFAULT_NUMBERS: [f64; 5] = [10.0, 20.0, 30.0, 40.0, 50.0];

/// Convert command-line tokens to floats, skipping anything invalid.
fn parse_numbers(tokens: &[String]) -> Vec<f64> {
    let mut numbers = Vec::new();

    for token in tokens {
        match token.parse::<f64>() {
            Ok(value) => numbers.push(value),
            Err(_) => eprintln!("warning: skipping non-numeric argument '{}'", token),
        }
    }

    numbers
}

/// Run the Lisp helper and return the average it prints.
fn calculate_average(numbers: &[f64]) -> Result<f64, String> {
    let arguments: Vec<String> = numbers.iter().map(|value| value.to_string()).collect();

    let output = Command::new("sbcl")
        .args(["--script", "average_calculator.lisp"])
        .args(&arguments)
        .output()
        .map_err(|error| format!("could not run sbcl: {}", error))?;

    if !output.status.success() {
        let detail = String::from_utf8_lossy(&output.stderr).trim().to_string();

        return Err(if detail.is_empty() {
            format!("the Lisp helper exited with status {:?}", output.status.code())
        } else {
            detail
        });
    }

    let text = String::from_utf8_lossy(&output.stdout).trim().to_string();

    text.parse::<f64>()
        .map_err(|_| format!("unexpected output from the Lisp helper: {:?}", text))
}

fn main() {
    let arguments: Vec<String> = env::args().skip(1).collect();

    let numbers = if arguments.is_empty() {
        DEFAULT_NUMBERS.to_vec()
    } else {
        parse_numbers(&arguments)
    };

    if numbers.is_empty() {
        eprintln!("error: no numbers to average");
        exit(1);
    }

    match calculate_average(&numbers) {
        Ok(average) => println!("The average of {} value(s) is: {:.2}", numbers.len(), average),
        Err(message) => {
            eprintln!("error: {}", message);
            exit(1);
        }
    }
}
