# Ansible standards

Applies to Ansible playbooks, roles, and inventories (YAML). Canonical sources:
- Ansible best practices / "Tips and tricks":
  https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html
- Role directory structure:
  https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html

## Tooling (run before "done")
- **ansible-lint** — fix its findings; it encodes most of these rules.
- **yamllint** for YAML hygiene.
- **molecule** for role testing where roles are non-trivial.
- Dry-run with `--check --diff` before applying to real hosts.

## Tasks
- **Name every task** with a clear, action-first description.
- **Use FQCN**: `ansible.builtin.copy`, not `copy`. Same for collection modules.
- **Use modules, not `command`/`shell`.** If you must, add `changed_when` /
  `creates` / `removed_when` so the task is idempotent, and prefer `command`
  over `shell` (no shell unless you need pipes/globs).
- Everything **idempotent** — a second run reports no changes. No task should
  report `changed` when nothing changed.
- Use **handlers** (`notify`) for restarts/reloads, not inline restarts.
- `loop:` (not the deprecated `with_*`) for iteration; `when:` for conditionals.

## Structure & style
- Standard role layout: `tasks/`, `handlers/`, `defaults/`, `vars/`, `templates/`,
  `files/`, `meta/`. Keep `tasks/main.yml` a thin include of focused files.
- 2-space indent; lowercase `true`/`false` booleans; quote strings that could be
  misread as bool/number/version (`"1.0"`, `"yes"`).
- `snake_case` variable names; prefix role vars with the role name to avoid
  collisions. Defaults in `defaults/` (low precedence), not `vars/`.
- Pin collection/role versions in `requirements.yml`.

## Secrets & safety
- **Secrets live in Ansible Vault** (or an external secrets manager) — never
  plaintext in playbooks/vars committed to git.
- Add `no_log: true` on tasks that handle secrets so they aren't printed.
- Scope with `hosts:` precisely; use `--limit` for blast-radius control.
- Set `become:` only where needed, not globally.
