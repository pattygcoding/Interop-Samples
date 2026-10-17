#!/usr/bin/env bash
#
# Interop sample: Bash driving a compiled Free Pascal program.
#
# The script passes the numbers as command-line arguments to the Pascal helper
# and reads the average it prints back from stdout.
#
# See README.md for build and run instructions.

set -eo pipefail

project_directory=$(cd "$(dirname "$0")" && pwd)
executable="$project_directory/average_calculator"

if [ "$#" -eq 0 ]; then
  set -- 10 20 30 40 50
fi

numbers=()

for argument in "$@"; do
  case "$argument" in
    "" | *[!0-9.+-]*)
      echo "warning: skipping non-numeric argument '$argument'" >&2
      continue
      ;;
  esac

  numbers+=("$argument")
done

if [ "${#numbers[@]}" -eq 0 ]; then
  echo "error: no numbers to average" >&2
  exit 1
fi

# The helper writes its own diagnostics to stderr, which passes straight through.
if ! average=$("$executable" "${numbers[@]}"); then
  echo "error: the Pascal helper failed" >&2
  exit 1
fi

printf 'The average of %d value(s) is: %s\n' "${#numbers[@]}" "$average"
