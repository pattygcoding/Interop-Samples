#!/usr/bin/env julia

# Interop sample: prints the arithmetic mean of the numbers given on the command
# line.
#
# Invoked by main.scala; see README.md for build and run instructions.

using Printf

if isempty(ARGS)
    println(stderr, "error: no numbers supplied")
    exit(1)
end

numbers = Float64[]

for token in ARGS
    value = tryparse(Float64, token)

    if value === nothing
        println(stderr, "error: '$token' is not a number")
        exit(1)
    end

    push!(numbers, value)
end

@printf("%.2f\n", sum(numbers) / length(numbers))
