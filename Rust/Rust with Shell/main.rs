//! Interop sample: Rust driving a POSIX shell script.
//!
//! Rust passes the numbers as command-line arguments to the shell script and
//! reads the average it prints back from stdout.
//!
//! See README.md for build and run instructions.

use std::env;
use std::process::{exit, Command, Stdio};

const DEFAULT_NUMBERS: [f64; 5] = [10.0, 20.0, 30.0, 40.0, 50.0];

/// Find a POSIX shell to run the script with.
///
/// On Windows a bare `bash` is hijacked by `System32\bash.exe` — the WSL relay,
/// which fails when no distribution is installed — because `CreateProcess`
/// searches `System32` before `PATH`. The candidates are therefore probed and the
/// first one that actually runs is used. `SHELL_INTERPRETER` overrides the search.
fn shell() -> Result<String, String> {
    if let Ok(explicit) = env::var("SHELL_INTERPRETER") {
        if !explicit.is_empty() {
            return Ok(explicit);
        }
    }

    let candidates: &[&str] = if cfg!(windows) {
        &[
            "bash",
            "sh",
            r"C:\Program Files\Git\bin\bash.exe",
            r"C:\msys64\usr\bin\bash.exe",
        ]
    } else {
        &["sh", "bash"]
    };

    for candidate in candidates {
        let works = Command::new(candidate)
            .args(["-c", "exit 0"])
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()
            .map(|status| status.success())
            .unwrap_or(false);

        if works {
            return Ok((*candidate).to_string());
        }
    }

    Err(String::from(
        "no POSIX shell found; set SHELL_INTERPRETER to a working one (Git Bash or MSYS2 on Windows)",
    ))
}

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

/// Run the shell helper and return the average it prints.
fn calculate_average(interpreter: &str, numbers: &[f64]) -> Result<f64, String> {
    let arguments: Vec<String> = numbers.iter().map(|value| value.to_string()).collect();

    let output = Command::new(interpreter)
        .arg("average_calculator.sh")
        .args(&arguments)
        .output()
        .map_err(|error| format!("could not run {}: {}", interpreter, error))?;

    if !output.status.success() {
        let detail = String::from_utf8_lossy(&output.stderr).trim().to_string();

        return Err(if detail.is_empty() {
            format!("the shell helper exited with status {:?}", output.status.code())
        } else {
            detail
        });
    }

    String::from_utf8_lossy(&output.stdout)
        .trim()
        .parse::<f64>()
        .map_err(|_| String::from("unexpected output from the shell helper"))
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

    let interpreter = match shell() {
        Ok(found) => found,
        Err(message) => {
            eprintln!("error: {}", message);
            exit(1);
        }
    };

    match calculate_average(&interpreter, &numbers) {
        Ok(average) => println!("The average of {} value(s) is: {:.2}", numbers.len(), average),
        Err(message) => {
            eprintln!("error: {}", message);
            exit(1);
        }
    }
}

