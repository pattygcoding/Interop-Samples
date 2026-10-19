#!/usr/bin/env python3
"""Interop sample: Python driving a compiled C++ program.

The child process reads whitespace-separated numbers from standard input and
writes the arithmetic mean to standard output. Keeping the wire format this
simple means the C++ side needs no third-party JSON library.

See README.md for build and run instructions.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

EXECUTABLE = Path(__file__).with_name(
    "average_calculator" + (".exe" if sys.platform == "win32" else "")
)


def calculate_average(numbers, executable: Path = EXECUTABLE) -> float:
    """Return the average of ``numbers`` as computed by the C++ helper."""
    if not numbers:
        raise ValueError("calculate_average expects a non-empty sequence")

    payload = " ".join(str(number) for number in numbers)

    result = subprocess.run(
        [str(executable)],
        input=payload,
        capture_output=True,
        text=True,
        check=False,
    )

    if result.returncode != 0:
        message = result.stderr.strip() or f"helper exited with code {result.returncode}"
        raise RuntimeError(message)

    try:
        return float(result.stdout.strip())
    except ValueError as error:
        raise RuntimeError(
            f"unexpected output from the C++ helper: {result.stdout!r}"
        ) from error


def parse_numbers(tokens) -> list[float]:
    """Convert command-line tokens to floats, skipping anything invalid."""
    numbers = []
    for token in tokens:
        try:
            numbers.append(float(token))
        except ValueError:
            print(f"warning: skipping non-numeric argument {token!r}", file=sys.stderr)
    return numbers


def main(argv) -> int:
    numbers = parse_numbers(argv[1:]) if len(argv) > 1 else [10, 20, 30, 40, 50]

    try:
        average = calculate_average(numbers)
    except (ValueError, RuntimeError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print(f"The average of {len(numbers)} value(s) is: {average:.2f}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

