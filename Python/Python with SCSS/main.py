#!/usr/bin/env python3
"""Interop sample: Python driving the Dart Sass compiler.

The SCSS module in `average_calculator.scss` computes the mean of a list of
numbers. Python configures it with the numbers under test, compiles it with
`sass`, and reads the result back out of the generated CSS.

See README.md for build and run instructions.
"""

from __future__ import annotations

import re
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
MODULE_DIRECTORY = str(HERE)

# On Windows `sass` is a .cmd shim, which CreateProcess cannot run directly, so
# the command goes through the command processor.
SASS = ["cmd", "/c", "sass"] if sys.platform == "win32" else ["sass"]

AVERAGE_PATTERN = re.compile(r"--average:\s*(-?\d+(?:\.\d+)?)")


def calculate_average(numbers: list[float]) -> float:
    """Compile the SCSS module configured with `numbers` and return the mean."""
    if not numbers:
        raise ValueError("calculate_average expects a non-empty sequence")

    with tempfile.TemporaryDirectory(prefix="scss-average-") as directory:
        entry = Path(directory) / "entry.scss"
        output = Path(directory) / "result.css"

        # Configure the module with the numbers under test, then compile it.
        values = ", ".join(str(value) for value in numbers)
        entry.write_text(
            f'@use "average_calculator" with ($numbers: ({values}));\n', encoding="utf-8"
        )

        result = subprocess.run(
            [*SASS, "--no-source-map", "--load-path", MODULE_DIRECTORY, str(entry), str(output)],
            capture_output=True,
            text=True,
            check=False,
        )

        if result.returncode != 0:
            raise RuntimeError(
                result.stderr.strip() or f"sass exited with code {result.returncode}"
            )

        css = output.read_text(encoding="utf-8")

    match = AVERAGE_PATTERN.search(css)

    if match is None:
        raise RuntimeError(f"could not find --average in the compiled CSS:\n{css}")

    return float(match.group(1))


def parse_numbers(tokens: list[str]) -> list[float]:
    """Convert command-line tokens to floats, skipping anything invalid."""
    numbers = []

    for token in tokens:
        try:
            numbers.append(float(token))
        except ValueError:
            print(f"warning: skipping non-numeric argument {token!r}", file=sys.stderr)

    return numbers


def main(argv: list[str]) -> int:
    numbers = parse_numbers(argv[1:]) if len(argv) > 1 else [10, 20, 30, 40, 50]

    if not numbers:
        print("error: no numbers to average", file=sys.stderr)
        return 1

    try:
        average = calculate_average(numbers)
    except (ValueError, RuntimeError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print(f"The average of {len(numbers)} value(s) is: {average:.2f}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
