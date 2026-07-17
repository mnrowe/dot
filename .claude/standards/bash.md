# Bash / shell standards

Canonical sources:
- Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- ShellCheck (run it on everything): https://www.shellcheck.net/

## Safety header (non-interactive scripts)
- Start with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Set `IFS=$'\n\t'` when word-splitting matters.
- **Quote every expansion**: `"$var"`, `"${arr[@]}"`. Unquoted vars are the #1
  shell bug.

## Style
- `lower_snake_case` for variables and functions; `UPPER_SNAKE` for exported/env
  and constants. `readonly`/`local` where appropriate.
- `local` for all function variables — never leak into global scope.
- `$(...)` for command substitution, never backticks.
- `[[ ... ]]` for tests, not `[ ... ]`. `(( ... ))` for arithmetic.
- Prefer `printf` over `echo` for anything with escapes or variables.

## Correctness
- Check commands can fail: `if ! cmd; then ...`, or handle `$?` explicitly.
- Use `mktemp` for temp files; `trap 'rm -rf "$tmp"' EXIT` to clean up.
- Loop over arrays, not unquoted string splitting: `for f in "${files[@]}"`.
- Validate arguments and print a usage message; exit non-zero on error.

## When to stop using bash
If it needs arrays of structured data, real error handling, or is over ~100
lines — reach for Python instead. Say so rather than writing fragile shell.

## Always
- Run **ShellCheck** and fix its warnings before considering a script done.
