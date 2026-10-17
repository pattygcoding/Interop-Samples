#!/usr/bin/env ruby
# frozen_string_literal: true

# Interop sample: prints the arithmetic mean of the numbers given on the
# command line.
#
# Invoked by main.swift; see README.md for build and run instructions.

if ARGV.empty?
  warn 'error: no numbers supplied'
  exit 1
end

numbers = ARGV.map do |token|
  Float(token)
rescue ArgumentError
  warn "error: '#{token}' is not a number"
  exit 1
end

puts format('%.2f', numbers.sum / numbers.length)
