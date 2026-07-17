# Python standards

Canonical sources (defer to these; this file is the working summary):
- PEP 8 — style: https://peps.python.org/pep-0008/
- PEP 20 — the Zen of Python: https://peps.python.org/pep-0020/
- PEP 257 — docstrings: https://peps.python.org/pep-0257/
- PEP 484 / typing — type hints: https://peps.python.org/pep-0484/
- Google Python Style Guide: https://google.github.io/styleguide/pyguide.html

## Tooling (let tools enforce style)
- Format with **ruff format** (or black); lint with **ruff**. Don't hand-argue
  formatting — run the formatter.
- Type-check with **mypy** (or pyright) where types are used.
- Target the project's Python version; check `pyproject.toml` / `setup.cfg`.

## Style
- 4-space indent, `snake_case` for functions/vars, `PascalCase` for classes,
  `UPPER_SNAKE` for constants. Lines ≤ 88 (ruff/black default).
- **Type-hint public functions.** Return types too.
- f-strings for formatting; never `%` or `.format()` in new code.
- `pathlib.Path` over `os.path`; context managers (`with`) for files/locks/conns.
- Prefer comprehensions for simple maps/filters; a loop when it's clearer.
- Dataclasses (or pydantic if already used) for structured data, not bare dicts.

## Correctness & safety
- Catch **specific** exceptions, never bare `except:`. Don't swallow — log or
  re-raise with context.
- No mutable default arguments (`def f(x=[])`); use `None` + init inside.
- Guard `if __name__ == "__main__":` for scripts.
- Validate/parameterize any SQL or shell input; never string-format untrusted
  data into queries or commands.

## Docs & tests
- One-line docstring for non-obvious functions (PEP 257); expand for public APIs.
- Prefer **pytest**; test behavior and edge cases, not implementation detail.
