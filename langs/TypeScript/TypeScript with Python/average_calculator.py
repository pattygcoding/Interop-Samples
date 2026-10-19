#!/usr/bin/env python3
"""Interop sample: reads a JSON array of numbers from standard input and writes
the arithmetic mean to standard output.

Invoked by main.ts; see README.md for build and run instructions.
"""

from __future__ import annotations

import json
import sys


def main() -> int:
    raw = sys.stdin.read()

    if not raw.strip():
        print("error: expected a JSON array of numbers on stdin", file=sys.stderr)
        return 1

    try:
        numbers = json.loads(raw)
    except json.JSONDecodeError as error:
        print(f"error: invalid JSON: {error}", file=sys.stderr)
        return 1

    if not isinstance(numbers, list) or not numbers:
        print("error: expected a non-empty JSON array", file=sys.stderr)
        return 1

    try:
        values = [float(value) for value in numbers]
    except (TypeError, ValueError):
        print("error: every element must be a number", file=sys.stderr)
        return 1

    print(sum(values) / len(values))
    return 0


if __name__ == "__main__":
    sys.exit(main())
