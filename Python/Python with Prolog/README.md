# Python with Prolog

Queries a **SWI-Prolog** knowledge base from Python with
[PySwip](https://github.com/yuce/pyswip). PySwip embeds SWI-Prolog in the Python
process, so Prolog terms come back as ordinary Python values.

| | |
|---|---|
| **Host language** | Python 3 |
| **Guest language** | Prolog (SWI-Prolog) |
| **Bridge** | In-process embedding via PySwip |
| **Files** | `main.py`, `family.pro` |

## Prerequisites

- **Python 3.9+**
- **SWI-Prolog** installed and on your `PATH`
- The **PySwip** package:

  ```bash
  pip install pyswip
  ```

## Build & run

There is nothing to compile:

```bash
python3 main.py
```

## Expected output

```text
Parents of jane:
  - doe
  - mark

Father of jane:
  - mark

Ancestors of jane:
  - doe
  - mark
  - john

Siblings of jane:
  - tom
```

## How it works

`main.py` loads the knowledge base and issues Prolog queries through PySwip:

```python
prolog = Prolog()
prolog.consult(str(KNOWLEDGE_BASE))

for name in values_of(prolog.query("ancestor(X, jane)")):
    print(f"  - {name}")
```

`family.pro` asserts only the primitive `parent/2` and gender facts. The
`father/2`, `mother/2`, `sibling/2` and `ancestor/2` relations are **derived
rules**, so Python can ask high-level questions without duplicating the logic.
`ancestor/2` is defined recursively and can therefore return the same ancestor
along several paths; `values_of` de-duplicates the bindings while preserving
order.
