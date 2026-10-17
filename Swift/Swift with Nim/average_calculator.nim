# Interop sample: reads whitespace-separated numbers from standard input and
# writes their arithmetic mean to standard output.
#
# Invoked by main.swift; see README.md for build and run instructions.

import std/strutils

proc main() =
  var numbers: seq[float] = @[]

  for token in readAll(stdin).splitWhitespace():
    try:
      numbers.add(parseFloat(token))
    except ValueError:
      stderr.writeLine("error: '" & token & "' is not a number")
      quit(1)

  if numbers.len == 0:
    stderr.writeLine("error: no numbers on stdin")
    quit(1)

  var sum = 0.0
  for value in numbers:
    sum += value

  let average = sum / float(numbers.len)
  stdout.writeLine(formatFloat(average, ffDecimal, 15))

when isMainModule:
  main()
