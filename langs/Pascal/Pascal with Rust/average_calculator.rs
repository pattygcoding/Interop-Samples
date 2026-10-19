//! Interop sample: prints the arithmetic mean of the numbers given on the command
//! line.
//!
//! Invoked by main.pas; see README.md for build and run instructions.

use std::env;
use std::process::exit;

fn main() {
    let arguments: Vec<String> = env::args().skip(1).collect();

    if arguments.is_empty() {
        eprintln!("error: no numbers supplied");
        exit(1);
    }

    let mut total = 0.0;
    let mut count = 0;

    for token in &arguments {
        match token.parse::<f64>() {
            Ok(value) => {
                total += value;
                count += 1;
            }
            Err(_) => {
                eprintln!("error: '{}' is not a number", token);
                exit(1);
            }
        }
    }

    println!("{:.2}", total / count as f64);
}
