#!/usr/bin/env python3
"""Interop sample: prints the arithmetic mean of the numbers given on the
command line.

Invoked by main.dart; see README.md for build and run instructions.
"""

from __future__ import annotations

import sys


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("error: no numbers supplied", file=sys.stderr)
        return 1

    numbers: list[float] = []

    for token in argv[1:]:
        try:
            numbers.append(float(token))
        except ValueError:
            print(f"error: '{token}' is not a number", file=sys.stderr)
            return 1

    print(f"{sum(numbers) / len(numbers):.2f}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
