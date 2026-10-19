#!/usr/bin/env ruby

# Interop sample: Ruby driving a compiled Rust program.
#
# Ruby writes the numbers to the Rust helper's standard input and reads the
# average back from its standard output.
#
# See README.md for build and run instructions.

require 'open3'

EXE_SUFFIX = File::ALT_SEPARATOR ? '.exe' : ''
EXECUTABLE = File.join(__dir__, "average_calculator#{EXE_SUFFIX}")

# Run the Rust helper and return the average it computes.
def calculate_average(numbers, executable: EXECUTABLE)
  raise ArgumentError, 'calculate_average expects a non-empty array' if numbers.empty?

  # The two-element array form ([command, argv0]) executes the helper directly
  # instead of handing a command line to the shell, which matters because the
  # sample directory name contains a space.
  stdout, status = Open3.capture2([executable.to_s, executable.to_s], stdin_data: numbers.join(' '))

  raise "the Rust helper exited with status #{status.exitstatus}" unless status.success?

  Float(stdout.strip)
end

# Convert command-line tokens to floats, skipping anything invalid.
def parse_numbers(tokens)
  tokens.filter_map do |token|
    Float(token)
  rescue ArgumentError
    warn "warning: skipping non-numeric argument '#{token}'"
    nil
  end
end

numbers = ARGV.empty? ? [10, 20, 30, 40, 50] : parse_numbers(ARGV)

if numbers.empty?
  warn 'error: no numbers to average'
  exit 1
end

begin
  average = calculate_average(numbers)
rescue StandardError => e
  warn "error: #{e.message}"
  exit 1
end

puts format('The average of %d value(s) is: %.2f', numbers.length, average)
