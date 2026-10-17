# Interop sample: prints the arithmetic mean of the numbers given on the command
# line.
#
# Invoked by Main.hs; see README.md for build and run instructions.

import std/[os, strutils]

if paramCount() == 0:
  stderr.writeLine("error: no numbers supplied")
  quit(1)

var numbers: seq[float] = @[]

for index in 1 .. paramCount():
  let token = paramStr(index)

  try:
    numbers.add(parseFloat(token))
  except ValueError:
    stderr.writeLine("error: '" & token & "' is not a number")
    quit(1)

var total = 0.0
for value in numbers:
  total += value

stdout.writeLine(formatFloat(total / float(numbers.len), ffDecimal, 2))
