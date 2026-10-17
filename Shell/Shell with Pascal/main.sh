#!/bin/sh
#
# Interop sample: a POSIX shell driving a compiled Free Pascal program.
#
# The script passes the numbers as command-line arguments to the Pascal helper
# and reads the average it prints back from stdout.
#
# See README.md for build and run instructions.

set -eu

project_directory=$(cd "$(dirname "$0")" && pwd)
executable="$project_directory/average_calculator"

if [ "$#" -eq 0 ]; then
  set -- 10 20 30 40 50
fi

# Rebuild the argument list, keeping only the values that look like numbers.
numbers=""

for argument in "$@"; do
  case "$argument" in
    "" | *[!0-9.+-]*)
      echo "warning: skipping non-numeric argument '$argument'" >&2
      continue
      ;;
  esac

  numbers="$numbers $argument"
done

if [ -z "$numbers" ]; then
  echo "error: no numbers to average" >&2
  exit 1
fi

# Word splitting is intentional here: rebuild the argument list from $numbers.
# shellcheck disable=SC2086
set -- $numbers
count=$#

# The helper writes its own diagnostics to stderr, which passes straight through.
if ! average=$("$executable" "$@"); then
  echo "error: the Pascal helper failed" >&2
  exit 1
fi

printf 'The average of %d value(s) is: %s\n' "$count" "$average"
