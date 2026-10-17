#!/usr/bin/env Rscript

# Interop sample: R driving a PHP program.
#
# R passes the numbers as command-line arguments to `average_calculator.php` and
# reads the average it prints back from stdout.
#
# See README.md for build and run instructions.

args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  numbers <- c(10, 20, 30, 40, 50)
} else {
  numbers <- suppressWarnings(as.numeric(args))
  invalid <- is.na(numbers)

  if (any(invalid)) {
    message(sprintf("warning: skipping non-numeric argument '%s'", args[invalid][1]))
    numbers <- numbers[!invalid]
  }
}

if (length(numbers) == 0) {
  message("error: no numbers to average")
  quit(status = 1)
}

# system2 merges stderr into the result and records the exit status as an
# attribute when the command fails.
output <- suppressWarnings(
  system2("php", c("average_calculator.php", as.character(numbers)),
          stdout = TRUE, stderr = TRUE)
)

status <- attr(output, "status")

if (!is.null(status) && status != 0) {
  message(paste(output, collapse = "\n"))
  quit(status = 1)
}

average <- suppressWarnings(as.numeric(output[1]))

if (is.na(average)) {
  message(sprintf("error: unexpected output from PHP: %s", output[1]))
  quit(status = 1)
}

cat(sprintf("The average of %d value(s) is: %.2f\n", length(numbers), average))
