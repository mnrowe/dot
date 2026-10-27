# Workflow

How I actually work across `~/Repos` with this setup: tmux + nvim + Claude
Code for building, a cheap API model for homelab apps, and `overlord` as the
map that ties the repos together.

---

## TL;DR

| Need | Use |
|---|---|
| Work in a repo | `prefix f` → pick repo → nvim \| Claude Code, lazygit, terminal |
| Rewrite one function/block | 99 in nvim: select it, `<leader>9v` |
| Question across many repos | `prefix f` → `overlord` → ask Claude there |
| Several tasks at once | one tmux session per repo, or a worktree per task |
| Change live infrastructure | Claude writes and plans, **I** apply |
| Recurring checks | `/schedule` (cloud) or a `claude -p` script (local) |
| AI inside homelab apps | Anthropic API (Haiku) behind LiteLLM, not my subscription |

---

## 1. What each piece is for

| Piece | Covers | Cost |
|---|---|---|
| **Claude subscription** | Claude Code, claude.ai, desktop/mobile | already paying |
| **Anthropic API key** | apps in the cluster (Karakeep, FreshRSS, Open WebUI) | ~$2/yr on Haiku, capped |
| **Local models** | only if a job must stay on my network (Paperless) | power |

The subscription is for **me** (interactive, plus my own scripts). Apps get
their own API key. Never put subscription credentials into third-party apps.

## 2. The daily loop

### Start

```sh
ta                 # attach/create the default tmux session
# prefix f  (or Ctrl-F in bash) → fzf over ~/, ~/Documents, ~/Repos
```

Picking a repo creates a session with three windows:

| Window | Layout |
|---|---|
| `claude` | nvim + Neo-tree (60%) \| Claude Code (40%) |
| `git` | lazygit |
| `terminal` | clean shell |

Sessions survive reboots via tmux-resurrect (`prefix Ctrl-s` / `prefix Ctrl-r`),
including the `claude` pane. Use `claude --continue` to pick the conversation back up.

### Work a task

1. **Say the outcome, not the steps.** "Make `install-claude` use the
   native installer and keep the macOS path", not a list of edits.
2. **Use plan mode (`Shift-Tab`) for anything non-trivial.** Read the plan, push
   back, then let it go.
3. **Review in the `git` window.** lazygit shows the diff; stage or discard hunk by hunk.
4. **Commit there too**, or `savedot "msg"` for this repo.
5. **Optional:** `/code-review` before pushing anything that matters.

### Small, local edits: 99 in nvim

[99](https://github.com/ThePrimeagen/99) is for the opposite of the Claude
Code pane: one function or block, edited in place, without a conversation.
It calls the `claude` CLI (`ClaudeCodeProvider`, model `opus`), so it runs on
the subscription too.

| Key | Mode | Does |
|---|---|---|
| `<leader>9v` | visual | prompt for a change to the selection, replaced in place |
| `<leader>9s` | visual | cancel all in-flight 99 requests |
| `<leader>9l` | normal | open the last request's log |

- **Pick by scope.** One selection → 99. Anything spanning files, needing
  commands, or needing a plan → the Claude Code pane.
- **Context:** 99 auto-adds `AGENT.md` and `CLAUDE.md` files from the current
  file's directory up to the project root (`md_files` in
  `config/nvim/lua/kickstart/plugins/99.lua`). A repo's `CLAUDE.md` steers 99 too.
- **It's alpha and tuned for Lua/TypeScript.** It sends the whole file with
  the selection, and replacements occasionally land wrong. Check the result
  (`u` undoes it), and expect weaker results on HCL/YAML.
- `@file` / `#rule` completion is off because it needs nvim-cmp and this
  config uses blink.cmp.
- Debug logs go to `/tmp/<project>.99.debug`. Delete them if a prompt
  contained anything sensitive.

### Parallel work

- **Different repos:** a session per repo, switched with `prefix f`. Each has its
  own Claude Code with its own context.
- **Same repo, independent tasks:** ask Claude to do one in a git worktree so
  the branches don't collide, then merge in lazygit.
- **Broad search** ("where do we set the Cilium IP pool?"): Claude Code uses
  subagents on its own. No setup needed.

Two or three parallel sessions is the sweet spot. Beyond that I'm the
bottleneck as reviewer, and it eats plan limits.

## 3. overlord: the cross-repo hub

`~/Repos/overlord/README.md` is the map: what each repo is, how they connect,
and the housekeeping list.

- Open it with `prefix f` → `overlord`. Claude Code started there can read
  every sibling repo, so ask cross-repo questions here: "which repos still
  manage Proxmox VMs?", "what replaced linux-dev-playbook's jellyfin role?"
- When a repo changes role (new repo, archived, moved into git), update the
  README in the same sitting.
- Claude keeps homelab facts (hardware, node state, AI decisions) in its
  memory for this directory, so later sessions start informed. Still re-check
  live state before acting on it.

## 4. Infrastructure rules

The repos that touch real systems: `talos-argocd-homelab`, `home-lab-builds`,
`tofu`, `acme`, `gitlab`, `linux-dev-playbook`.

| Claude does | I do |
|---|---|
| write/edit `.tf`, manifests, roles | `tofu apply` / `terraform apply` |
| `tofu plan`, `kubectl diff`, `ansible-playbook --check` | `kubectl apply`, real playbook runs |
| read logs, `kubectl get/describe`, `talosctl get` | `talosctl apply-config`, upgrades, reboots |
| draft SOPS-encrypted secrets (`sops -e`) | rotate credentials |

- **ArgoCD repo:** Claude edits, I commit and push, and Argo syncs. Git is the apply step.
- **Secrets:** never in plaintext in git. Use SOPS + age (see `talos-argocd-homelab/.sops.yaml`).
  Local-only `*.tfvars`/`*.tfstate` stay gitignored.
- **Per-repo rules go in that repo's `CLAUDE.md`** ("never run apply", the
  cluster layout, gotchas). Global coding standards come from this repo's
  `.claude/` (linked by `config-claude`).

## 5. Recurring and background jobs

**Cloud, on a schedule (`/schedule` in Claude Code).** Good for reports that
don't need my network:
- Weekly: check my GitHub repos for stale branches and open PRs, and summarize.

**Local, headless (`claude -p`).** Uses my subscription; for things that need
the LAN or local files. Run by hand or from cron on this box:

```sh
# Weekly repo health → read in the morning
claude -p "For each git repo in ~/Repos: report uncommitted changes, \
unpushed commits, and tracked files matching *.tfstate*, *.tfvars or .env. \
Output a markdown table." > ~/Documents/obsd/inbox/repo-health-$(date +%F).md
```

Keep these read-only. Anything that changes things runs interactively, where I can review it.

## 6. Homelab AI (apps)

```
Karakeep ─┐
FreshRSS ─┼─► LiteLLM (talos-argocd-homelab/my-apps/ai) ─► Anthropic API (Haiku)
Open WebUI┘                                            └─► local model (optional)
```

- One API key in the Claude Console with a **$5/month limit**, stored as a
  SOPS secret.
- LiteLLM gives every app the same OpenAI-style endpoint and a key per app,
  so I can see per-app usage and swap models without touching the apps.
- Paperless: keep it local (RX 580 VM on `helios`) or skip AI there. Those
  documents shouldn't leave the house.
- Don't buy a GPU for this. At my volume the API costs less than the
  electricity a local model would use.

## 7. New machine

```sh
./bootstrap --server     # includes claude, links ~/.claude config
claude                   # log in with the subscription
```

Then clone the repos into `~/Repos` and `prefix f` works immediately. See
[SETUP.md](SETUP.md) for the details.
