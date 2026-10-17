#!/usr/bin/env python3
"""Interop sample: querying SWI-Prolog from Python with PySwip.

PySwip embeds SWI-Prolog in the Python process, so the two languages share one
address space and Prolog terms come back as ordinary Python values.

See README.md for installation and run instructions.
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    from pyswip import Prolog
except ImportError:  # dependency guard
    print(
        "error: PySwip is not installed. Install it with: pip install pyswip",
        file=sys.stderr,
    )
    raise SystemExit(1)

KNOWLEDGE_BASE = Path(__file__).resolve().with_name("family.pro")


def values_of(query, variable: str = "X") -> list:
    """Run ``query`` and return the bindings of ``variable`` without duplicates."""
    return list(dict.fromkeys(solution[variable] for solution in query))


def main() -> int:
    if not KNOWLEDGE_BASE.is_file():
        print(f"error: knowledge base not found at {KNOWLEDGE_BASE}", file=sys.stderr)
        return 1

    prolog = Prolog()
    prolog.consult(str(KNOWLEDGE_BASE))

    print("Parents of jane:")
    for name in values_of(prolog.query("parent(X, jane)")):
        print(f"  - {name}")

    print("\nFather of jane:")
    for name in values_of(prolog.query("father(X, jane)")):
        print(f"  - {name}")

    print("\nAncestors of jane:")
    for name in values_of(prolog.query("ancestor(X, jane)")):
        print(f"  - {name}")

    print("\nSiblings of jane:")
    for name in values_of(prolog.query("sibling(X, jane)")):
        print(f"  - {name}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

