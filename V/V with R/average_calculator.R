#!/usr/bin/env Rscript

# Interop sample: prints the arithmetic mean of the numbers given on the
# command line.
#
# Invoked by main.v; see README.md for build and run instructions.

args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  message("error: no numbers supplied")
  quit(status = 1)
}

numbers <- suppressWarnings(as.numeric(args))

if (any(is.na(numbers))) {
  message("error: every argument must be a number")
  quit(status = 1)
}

cat(sprintf("%.2f\n", mean(numbers)))
