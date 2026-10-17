#!/bin/sh
#
# Interop sample: prints the arithmetic mean of the numbers given on the
# command line.
#
# POSIX sh has no floating-point arithmetic, so the sum is done with awk, which
# every POSIX system provides.
#
# Invoked by main.groovy; see README.md for build and run instructions.

if [ "$#" -eq 0 ]; then
  echo "error: no numbers supplied" >&2
  exit 1
fi

# Reject anything that is not a number before doing any arithmetic.
for argument in "$@"; do
  case "$argument" in
    "" | *[!0-9.+-]*)
      echo "error: '$argument' is not a number" >&2
      exit 1
      ;;
  esac
done

printf '%s\n' "$@" | awk '{ total += $1; count += 1 } END { printf "%.2f\n", total / count }'
