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
| Is this video/post worth my time? | `fabric -y <url> -p summarize` |
| Learn from a video properly | `ytnote <url>` → watch → write from memory → `ytnote --check` |
| Go deep on a topic | Claude Research (claude.ai) or deep research in Claude Code |

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

## 7. Learning: Sample, Delve, Absorb

From Jeff McJunkin's Antisyphon talk ([video](https://www.youtube.com/watch?v=H7n9t1uCjTE),
[slides](https://bit.ly/learningwithai)). Sample far more than you study,
study far more than you lab, and test yourself on what you keep.

| Phase | Goal | Ratio | Tools here |
|---|---|---|---|
| **Sample** | find what's worth it | 10-100x | FreshRSS (by topic), `fabric ... -p summarize` |
| **Delve** | go deep on the best 5-10% | 3-5x | `ytnote`, Claude Research, NotebookLM audio overviews |
| **Absorb** | lock it in, apply it | 1x | write from memory, `ytnote --check`, Recall Checks, lab time |

### Weekly cadence

| Do | Amount | Time |
|---|---|---|
| Sample videos, posts, reports | 10-30 | ~1 h, spread out |
| Listen passively (NotebookLM audio, podcasts) | 5-10 | 2-3 h (commute, chores) |
| Watch/read in full with `ytnote` | 1-5 | 1-2 h |
| Test myself (Recall Checks, quiz) | 1 | 30 min |
| Research it in the lab (`helios`) | 1 | 1-4 h |
| Share it (blog post, team lunch) | 1/month | - |

### Sample: decide fast

```sh
fabric -y "https://www.youtube.com/watch?v=..." -p summarize   # YouTube
fabric -u "https://example.com/post" -p summarize               # web page
```

Fabric runs through Claude Code (`fabric --setup` → Claude Code vendor), so it
uses the subscription. **Its summaries are for deciding, never for the vault:**
notes are written in my own words.

### Delve: one video, done properly

```sh
ytnote https://www.youtube.com/watch?v=...     # YouTube: note + cached captions
ytnote --file talk.mp4                         # local file, Whisper at --check
ytnote --file "https://.../playlist.m3u8"      # any stream yt-dlp can fetch
```

1. **Before:** write 2-3 questions in the note.
2. **During:** timestamps + one-liners, at 1.25-1.5x. Pause after each
   section and say it back.
3. **After, video closed:** fill in *From memory*: main ideas, surprises,
   doubts, **one 48-hour action**.
4. `ytnote --check <note>`: Claude compares my notes to the transcript and
   appends what I missed or got wrong, plus recall questions. It refuses to run
   until *From memory* is written.
5. Fix the note myself, answer the Recall Check in my own words, and split
   anything worth keeping into a concept note with `inbox <concept>`.

No download button? If it streams, it downloads: DevTools → Network → copy
the `.m3u8`/`.mp4` URL → `ytnote --file "<url>"`. Personal study only; don't
re-share paid content. `auto-editor talk.mp4` cuts the silences first.

**Rate-limited captions (HTTP 429):** wait an hour, or
`YTNOTE_COOKIES=firefox ytnote <url>`. `YTNOTE_WHISPER_MODEL=base.en` is
faster but less accurate than the default `small.en`.

### Delve: research a topic

- **claude.ai → Research** in the message box: multi-source, cited report in
  a few minutes. Paste it into NotebookLM for an audio overview.
- **Claude Code deep research:** ask for deep research on a topic and to save
  the report into the vault. Uses more plan quota; keep it for topics worth an hour.
- Ask narrow questions ("Longhorn replica count for a 3-node homelab"), and
  check the citations on anything I'll act on.

### Absorb: make it stick

- Test within hours, again a few days later, then weekly. Testing beats re-reading.
- Sunday review (15 min): answer 5 Recall Checks cold, update one note.
- Anki only for facts that need instant recall (ports, flags, syntax).
- Lab it: one thing per week on `helios`. Pitch lab time at work as research
  for a concrete proposal, not "lab time".

### Tools for this section

| Tool | Install | What for |
|---|---|---|
| `yt-dlp` + `deno` | `install-yt-dlp` | captions, downloads (`yt-dlp -U` to update) |
| `fabric` | `install-fabric`, then `fabric --setup` | Sample summaries |
| `whisper-ctranslate2` | `install-whisper` | local transcripts for `ytnote --file` |
| `auto-editor` | `install-auto-editor` | cut silences from talks |
| `ytnote` | in `scripts/` | the Delve/Absorb note loop |

## 8. New machine

```sh
./bootstrap --server     # includes claude, links ~/.claude config
claude                   # log in with the subscription
```

Then clone the repos into `~/Repos` and `prefix f` works immediately. See
[SETUP.md](SETUP.md) for the details.
