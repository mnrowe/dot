# Lua standards (Neovim focus)

Canonical sources:
- Neovim Lua guide: `:help lua-guide` — https://neovim.io/doc/user/lua-guide.html
- Olivine Labs Lua Style Guide: https://github.com/luarocks/lua-style-guide
- Luvit style (widely followed): https://github.com/luvit/luvit/blob/master/CONTRIBUTING.md

## Tooling
- Format with **stylua** (2-space indent is the common Neovim default).
- Lint with **luacheck**; declare globals it doesn't know (e.g. `vim`).

## Style
- 2-space indent, `snake_case` for locals/functions, `PascalCase` for "classes"
  (metatable modules), `UPPER_SNAKE` for constants.
- **`local` everything.** Never create accidental globals — a stray global is a
  common Lua/Neovim bug. `local M = {}` module pattern; return `M`.
- Prefer `require("mod")` at top of file; avoid re-requiring in hot paths.
- One statement per line; no semicolons unless disambiguating.

## Neovim specifics
- Use the `vim.api` / `vim.fn` / `vim.uv` (libuv) APIs; prefer `vim.keymap.set`
  over `nvim_set_keymap`, and `vim.opt` over `vim.o` for list/map options.
- Guard optional plugins with `pcall(require, "x")` and handle the failure.
- Set buffer/window-local options with the right scope (`vim.bo`, `vim.wo`).
- Autocommands via `vim.api.nvim_create_autocmd` with a named `group`
  (`clear = true`) so re-sourcing doesn't stack them.
- Defer heavy work; keep plugin `config`/`setup` fast (lazy-load where possible).

## Correctness
- Check for `nil` before indexing; Lua is 1-indexed — mind off-by-ones.
- `pcall`/`xpcall` around anything that can error at startup; fail soft with a
  clear `vim.notify(..., vim.log.levels.ERROR)`.
