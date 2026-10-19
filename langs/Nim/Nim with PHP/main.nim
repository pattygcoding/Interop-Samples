# Interop sample: Nim driving a PHP program.
#
# Nim passes the numbers as command-line arguments to the PHP helper and reads
# the average it prints back from stdout.
#
# See README.md for build and run instructions.

import std/[os, osproc, strutils]

const defaultNumbers = @[10.0, 20.0, 30.0, 40.0, 50.0]

proc isNumber(token: string): bool =
  ## True when the token looks like a decimal number.
  if token.len == 0:
    return false

  var seenDigit = false

  for index, character in token:
    if character in {'0' .. '9'}:
      seenDigit = true
    elif character == '.':
      discard
    elif character == '-' and index == 0:
      discard
    else:
      return false

  return seenDigit

proc parseNumbers(tokens: seq[string]): seq[float] =
  ## Convert command-line tokens to floats, skipping anything invalid.
  var numbers: seq[float] = @[]

  for token in tokens:
    if isNumber(token):
      numbers.add(parseFloat(token))
    else:
      stderr.writeLine("warning: skipping non-numeric argument '" & token & "'")

  return numbers

proc calculateAverage(numbers: seq[float]): float =
  ## Run the PHP helper and return the average it prints.
  var command = "php average_calculator.php"

  for value in numbers:
    command.add(" " & $value)

  let outcome = execCmdEx(command)

  if outcome.exitCode != 0:
    let detail = outcome.output.strip()

    raise newException(
      IOError,
      if detail.len == 0: "the PHP helper exited with status " & $outcome.exitCode else: detail,
    )

  return parseFloat(outcome.output.strip())

when isMainModule:
  var numbers: seq[float] = @[]

  if paramCount() == 0:
    numbers = defaultNumbers
  else:
    var tokens: seq[string] = @[]

    for index in 1 .. paramCount():
      tokens.add(paramStr(index))

    numbers = parseNumbers(tokens)

  if numbers.len == 0:
    stderr.writeLine("error: no numbers to average")
    quit(1)

  try:
    let average = calculateAverage(numbers)
    stdout.writeLine("The average of " & $numbers.len & " value(s) is: " &
      formatFloat(average, ffDecimal, 2))
  except CatchableError as error:
    stderr.writeLine("error: " & error.msg)
    quit(1)
