#!/bin/sh
#
# Interop sample: a POSIX shell driving a VB.NET program.
#
# The shell passes the numbers as command-line arguments to the .NET console app
# and reads the average it prints back from stdout.
#
# See README.md for build and run instructions.

set -eu

project_directory=$(dirname "$0")

if [ "$#" -eq 0 ]; then
  set -- 10 20 30 40 50
fi

# Keep only the arguments that look like numbers.
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

average=$(dotnet run --project "$project_directory" -v quiet -- "$@")

printf 'The average of %d value(s) is: %s\n' "$count" "$average"
