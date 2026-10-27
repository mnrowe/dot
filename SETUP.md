# Fresh Machine Setup

Quick reference for standing up a new box from this repo. Linux / WSL is the
main target; Windows is the host for WezTerm + WSL.

---

## TL;DR

**Linux / WSL**

```sh
sudo apt-get update && sudo apt-get install -y git curl build-essential unzip ripgrep fzf jq xclip
mkdir -p ~/Repos && git clone https://github.com/mnrowe/dot ~/Repos/dot
cd ~/Repos/dot && ./bootstrap --server
exec bash -l
```

**Windows host** (PowerShell, then finish inside WSL)

```powershell
wsl --install -d Ubuntu
winget install -e --id Microsoft.PowerShell
winget install -e --id wez.wezterm
winget install -e --id Git.Git
```

Then in the Ubuntu shell: run the Linux steps above, plus
[fonts + wezterm config](#windows-host).

---

## 1. Where to clone

Clone to **`~/Repos/dot`**. The configs symlink to wherever the repo is, but
these expect that exact path:

| Thing | Expects |
|---|---|
| `$DOTFILES` (bashrc) | `~/Repos/dot` |
| `dot` alias, `savedot`, `CDPATH` | `$DOTFILES` |
| `clone` / `$GHREPOS` | `~/Repos/github.com/$USER/` |

If you cloned somewhere else, either move it and re-run the config scripts, or
`export DOTFILES=...` in `~/.bash_private`.

## 2. Prerequisites (need sudo)

| Package | Why |
|---|---|
| `git curl` | everything |
| `build-essential` (`gcc make`) | treesitter parsers, telescope-fzf-native, LuaSnip |
| `unzip ripgrep` | Mason, telescope live grep (`:checkhealth` warns without them) |
| `fzf` | `tmux-sessionizer` (prefix `f`, `Ctrl-F`) |
| `jq` | `install-golang` |
| `xclip` | tmux copy (`y`). On WSL needs WSLg; otherwise see [troubleshooting](#troubleshooting) |

Fedora: `sudo dnf install -y git curl gcc make unzip ripgrep fzf jq xclip`

## 3. Bootstrap

```sh
cd ~/Repos/dot
./bootstrap            # interactive menu
./bootstrap --minimal  # tmux + nvim + bash/tmux/nvim/scripts config
./bootstrap --server   # + nvm/node, go, ansible, lazygit, claude
./bootstrap --desktop  # + wezterm, UbuntuMono Nerd Font, podman  (real Linux desktop only)
```

Use `--server` on WSL and headless boxes. `--desktop` on WSL tries `winget.exe`
from inside Linux — do the Windows bits from the Windows side instead.

Each step keeps going if one fails; scroll back for `[ERROR]` lines.

### Running pieces individually

```sh
./scripts/install/install-<tool>    # tmux neovim nvm nodejs golang ansible lazygit
                                    # claude wezterm ubuntumono podman docker
./scripts/config/config-<tool>      # bash tmux nvim scripts lazygit claude wezterm i3
./scripts/config/config-dot-basic   # re-link bash, nvim, tmux, scripts (prompts first)
./scripts/config/config-dot-all     # re-link everything (prompts first)
```

Install scripts are safe to re-run; config scripts just re-create symlinks.

## 4. What gets linked where

| Source (`config/…`) | Target |
|---|---|
| `bash/bashrc`, `bash/inputrc`, `bash/dircolors` | `~/.bashrc`, `~/.inputrc`, `~/.dircolors` |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` (TPM + plugins in `~/.config/tmux/plugins/`) |
| `nvim/` | `~/.config/nvim` |
| `lazygit/` | `~/.config/lazygit` (existing dir backed up to `.backup`) |
| `i3/` | `~/.config/i3` |
| `wezterm/wezterm.lua` | `~/.wezterm.lua` (Linux symlink; **copied** on Windows/WSL) |
| `scripts/` (repo root) | `~/.local/bin/scripts` (on `PATH`) |
| `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/standards/` | `~/.claude/` (only those, never the whole dir) |

> `bootstrap` overwrites `~/.bashrc`. Back up the stock one first if you care:
> `cp ~/.bashrc ~/.bashrc.orig`

## 5. Things not in git — restore by hand

| File | Used for |
|---|---|
| `~/.ssh/` keys | git push, ssh-agent auto-start in login shells |
| `~/.env` | auto-exported by `envx` on every shell |
| `~/.sshpass` | `sshh` alias |
| `~/Documents/obsd` | Obsidian vault: `day`, `inbox`, `obsu`, nvim `<leader>o*`, tmux prefix `o` |

Then:

```sh
gh auth login                  # or add ~/.ssh key to GitHub
git -C ~/Repos/dot remote set-url origin git@github.com:mnrowe/dot.git
claude                         # log in
```

## 6. First launch

- **tmux**: `ta` (attach or create `default`). Plugins are installed by
  `config-tmux`; if missing, press `prefix I` inside tmux.
- **nvim**: first start installs plugins via lazy.nvim and LSPs via Mason. Let
  it finish, restart, then `:checkhealth`.
- **node**: `nvm` is loaded from bashrc; `node -v` should work in a new shell.
- **go**: lives in `~/.local/go`, binaries in `~/.local/bin`.

## Windows host

1. Install the apps:
   ```powershell
   wsl --install -d Ubuntu          # wezterm launches the distro named "Ubuntu"
   winget install -e --id Microsoft.PowerShell   # wezterm default shell: C:\Program Files\PowerShell\7\pwsh.exe
   winget install -e --id wez.wezterm
   winget install -e --id Git.Git
   ```
2. Inside WSL, after the Linux steps:
   ```sh
   ~/Repos/dot/scripts/install/install-ubuntumono   # installs "UbuntuMono Nerd Font" on Windows via PowerShell
   ~/Repos/dot/scripts/config/config-wezterm        # copies wezterm.lua to C:\Users\<you>\.wezterm.lua
   ```
   If `config-wezterm` gets the Windows username wrong:
   ```sh
   winuser=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
   cp ~/Repos/dot/config/wezterm/wezterm.lua "/mnt/c/Users/$winuser/.wezterm.lua"
   ```
3. Re-run step 2's copy after editing `wezterm.lua` — Windows gets a copy, not a link.

WezTerm opens a PowerShell tab plus an Ubuntu tab on startup.

## Per-machine differences

Handled by hostname in `config/bash/bashrc` and `scripts/weekly`:

| Host | Notes |
|---|---|
| `wilco`, `ctrl` | personal; `OBSD`, `oo`, `or` point at `/home/rwe/Documents/obsd` |
| `DTM017` | work; same aliases under `/home/mrowe` |

Anything else machine-specific goes in `~/.bash_private` / `~/.bash_work`
(gitignored). nvim `<leader>o*` keymaps hardcode `/home/rwe/...` — edit
`config/nvim/lua/keymaps.lua` on a box with a different username.

## Keybind cheat sheet

**tmux** (prefix `Ctrl-a`)

| Key | Action |
|---|---|
| `f` | sessionizer: fzf a project dir → session with nvim+claude, lazygit, terminal windows |
| `t` | plain session in `~` |
| `o` | Obsidian vault session |
| `h j k l` | move between panes |
| `^` | last window |
| `0` | kill session |
| `r` | reload config |
| `[` then `v` / `y` | copy mode: select / yank to clipboard |
| `I` / `Ctrl-s` / `Ctrl-r` | TPM install / resurrect save / resurrect restore |

**bash**: vi mode · `Ctrl-F` sessionizer · `ta` tmux · `dot` cd to repo ·
`nv` nvim · `nvc` edit nvim config · `savedot "msg"` commit+push this repo ·
`clone user/repo` → `~/Repos/github.com/user/repo`

**nvim**: leader is `Space` · `<leader>e` Neo-tree · `<leader>f` format ·
`Ctrl-h/j/k/l` windows · `<leader>o*` Obsidian · `<leader>9*` 99 (Claude Opus) ·
`<Esc><Esc>` leave terminal mode

**WezTerm**: `Ctrl-Shift-L` launcher (pwsh / PowerShell / WSL) ·
`Ctrl-Alt-1..4` jump to tab

## Troubleshooting

| Symptom | Fix |
|---|---|
| prefix `f` / `Ctrl-F` does nothing | `ls -l ~/.local/bin/scripts` should point at the repo's `scripts/`; re-run `config-scripts`. Needs `fzf`. |
| `prefix r` errors | config must be at `~/.config/tmux/tmux.conf`; re-run `config-tmux` |
| tmux plugins missing | `~/.config/tmux/plugins/tpm/bin/install_plugins` |
| tmux copy doesn't reach Windows clipboard | no WSLg → change `xclip -in -selection clipboard` to `clip.exe` in `tmux.conf` |
| `dot` / `savedot` can't find repo | clone isn't at `~/Repos/dot` — see [§1](#1-where-to-clone) |
| `git status` in repo shows `config/bash/bashrc` modified after install | `install-neovim` appended a PATH line; bashrc already handles `/opt/nvim-*`, so `git checkout config/bash/bashrc` |
| nvim plugins fail to build | missing `gcc`/`make`/`unzip` — install prerequisites, then `:Lazy sync` |
| tmux hangs on start in WSL | `@continuum-restore` is intentionally off; leave it off |
