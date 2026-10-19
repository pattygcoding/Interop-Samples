#!/usr/bin/env python3
"""Interop sample: prints the arithmetic mean of the numbers given on the
command line.

Invoked by main.c; see README.md for build and run instructions.
"""

from __future__ import annotations

import sys


def parse_numbers(tokens: list[str]) -> list[float]:
    """Convert command-line tokens to floats, skipping anything invalid."""
    numbers = []

    for token in tokens:
        try:
            numbers.append(float(token))
        except ValueError:
            print(f"error: '{token}' is not a number", file=sys.stderr)
            raise SystemExit(1)

    return numbers


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("error: no numbers supplied", file=sys.stderr)
        return 1

    numbers = parse_numbers(argv[1:])
    print(f"{sum(numbers) / len(numbers):.2f}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
