#!/usr/bin/env julia

# Interop sample: Julia driving the SQLite command-line shell.
#
# Julia loads the numbers into a temporary SQLite database and runs the query in
# `average_calculator.sql`, so the mean is computed in SQL.
#
# See README.md for build and run instructions.

using Printf

const DEFAULT_NUMBERS = [10.0, 20.0, 30.0, 40.0, 50.0]
const QUERY_FILE = joinpath(@__DIR__, "average_calculator.sql")

"Run one SQL statement against `db` and return the shell's output."
function sqlite(db, statement)
    output = IOBuffer()
    run(pipeline(`sqlite3 -batch $db`; stdin = IOBuffer(statement), stdout = output))
    return String(take!(output))
end

"Convert command-line tokens to floats, skipping anything invalid."
function parse_numbers(tokens)
    numbers = Float64[]

    for token in tokens
        value = tryparse(Float64, token)

        if value === nothing
            println(stderr, "warning: skipping non-numeric argument '$token'")
        else
            push!(numbers, value)
        end
    end

    return numbers
end

function main()
    numbers = isempty(ARGS) ? DEFAULT_NUMBERS : parse_numbers(ARGS)

    if isempty(numbers)
        println(stderr, "error: no numbers to average")
        exit(1)
    end

    query = read(QUERY_FILE, String)
    db = tempname()

    try
        sqlite(db, "CREATE TABLE numbers (value REAL);")

        for number in numbers
            sqlite(db, "INSERT INTO numbers (value) VALUES ($(number));")
        end

        average = parse(Float64, strip(sqlite(db, query)))
        @printf("The average of %d value(s) is: %.2f\n", length(numbers), average)
    catch error
        println(stderr, "error: ", sprint(showerror, error))
        exit(1)
    finally
        rm(db, force = true)
    end
end

main()
