//! Interop sample: reads whitespace-separated numbers from standard input and
//! writes their arithmetic mean to standard output.
//!
//! Invoked by main.rb; see README.md for build and run instructions.

use std::io::{self, Read};
use std::process;

fn main() {
    let mut input = String::new();

    if let Err(error) = io::stdin().read_to_string(&mut input) {
        eprintln!("error: could not read stdin: {}", error);
        process::exit(1);
    }

    let mut numbers: Vec<f64> = Vec::new();

    for token in input.split_whitespace() {
        match token.parse::<f64>() {
            Ok(value) => numbers.push(value),
            Err(_) => {
                eprintln!("error: '{}' is not a number", token);
                process::exit(1);
            }
        }
    }

    if numbers.is_empty() {
        eprintln!("error: no numbers on stdin");
        process::exit(1);
    }

    let sum: f64 = numbers.iter().sum();
    let average = sum / numbers.len() as f64;

    // 15 significant digits is more than enough for a mean of IEEE-754 doubles.
    println!("{:.15}", average);
}
