# Coding standards (global)

When writing, editing, or reviewing code, follow the language-specific standard
in `~/.claude/standards/<language>.md` for the language of the file in front of
you. Read that file if you haven't already this session.

| Language | File |
|----------|------|
| Python | `~/.claude/standards/python.md` |
| Bash / shell | `~/.claude/standards/bash.md` |
| Lua (Neovim) | `~/.claude/standards/lua.md` |
| C# / .NET | `~/.claude/standards/csharp.md` |
| Terraform / OpenTofu (`.tf`) | `~/.claude/standards/terraform.md` |
| Ansible (playbooks/roles, YAML) | `~/.claude/standards/ansible.md` |

If a language has no file here, apply that language's widely-accepted idiomatic
style and its standard formatter/linter defaults, and mention which you're
following.

## Universal rules (all languages)

- **Match the file you're in.** Existing style, naming, and structure in the
  surrounding code win over any rule below.
- Prefer clarity over cleverness. Small, focused functions; descriptive names;
  no dead code.
- Handle errors explicitly — never silently swallow them.
- Comment the *why*, not the *what*. Don't narrate obvious code.
- No secrets in code (keys, tokens, passwords, connection strings).
- Don't add dependencies without reason; prefer the standard library.
- Make the smallest change that solves the problem; don't refactor unrelated code.
