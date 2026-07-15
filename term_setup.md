# term_setup.md — Terminal Dev Environment (macOS / Ubuntu / WSL-Ubuntu)

Stack: **bash + tmux + Neovim(LazyVim) + Claude Code**, plus `yazi`, `lazygit`,
`delta`, `bat`, `fzf`, `ripgrep`, `fd`, `eza`, `zoxide`, `btop`.
Theme: **GitHub Dark** everywhere. Font: **JetBrainsMono Nerd Font**.

> How to run: give this file to Claude Code —
> *"Follow term_setup.md to set up this machine. Use the required order: first
> record (back up) my current settings, then apply the new ones, then validate
> everything, and only remove the old settings after validation passes. Detect the
> platform first and stop if any step fails."*

Scope: this is for **dev machines only** (macOS, native Ubuntu, WSL-Ubuntu).
Do **not** run it on the remote job server `gs4` — that host only needs tmux for
session persistence and no editor/tooling.

---

## Execution workflow (required order)

Every run of this document follows these four phases in order. Do not skip ahead,
and never delete anything until phase 3 passes.

1. **Record** — back up every config this doc touches into one timestamped
   directory (§6, first step) and print its path.
2. **Apply** — install packages and write the new configs (§1–§7).
3. **Validate** — run §8. Every tool must resolve; Neovim and tmux must start
   cleanly. If any check fails, **STOP and restore from the backup** (§10 rollback)
   — do not remove anything.
4. **Clean up** — only after validation fully passes, remove the old settings /
   backup (§10 cleanup).

---

## 0. Platform detection

Set `PLATFORM` to one of `macos` / `wsl` / `ubuntu` and reuse it below.

```bash
if [[ "$(uname)" == "Darwin" ]]; then
  PLATFORM=macos
elif grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then
  PLATFORM=wsl
else
  PLATFORM=ubuntu
fi
echo "PLATFORM=$PLATFORM"
```

---

## 1. Homebrew (all three platforms)

Unified package manager → identical package names/versions on every machine,
and a current Neovim (LazyVim needs >= 0.11.2, which apt does not provide).

```bash
# Install Homebrew if missing
command -v brew >/dev/null || \
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to bash PATH (Linux path differs from macOS)
if [[ "$PLATFORM" == "macos" ]]; then
  BREW_ENV='eval "$(/opt/homebrew/bin/brew shellenv)"'   # Apple Silicon
  # Intel Macs: use /usr/local/bin/brew instead
else
  BREW_ENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
fi
grep -qF "$BREW_ENV" ~/.bashrc || echo "$BREW_ENV" >> ~/.bashrc
eval "$BREW_ENV"
```

Linux prerequisite for Homebrew itself: `sudo apt-get install -y build-essential procps curl file git`.

> apt-only alternative (skip Homebrew): install base tools with
> `sudo apt install tmux git fzf ripgrep fd-find bat btop`, but you must still get
> Neovim from the official tarball (github.com/neovim/neovim/releases, the
> `nvim-linux-x86_64.tar.gz` asset) and install `yazi lazygit eza zoxide git-delta`
> from their GitHub release binaries. Homebrew is the recommended path.

---

## 2. Packages

```bash
brew install \
  tmux neovim git \
  fzf ripgrep fd bat eza zoxide git-delta \
  yazi lazygit btop \
  tree-sitter
```

Notes:
- Via Homebrew the binaries are named `fd` and `bat` (no `fdfind`/`batcat` aliasing needed).
- `git-delta` installs the `delta` binary.
- C compiler for treesitter: macOS → `xcode-select --install`; Linux → already
  covered by `build-essential`.
- Verify Neovim version: `nvim --version | head -1` must be **>= 0.11.2**.

---

## 3. Nerd Font (JetBrainsMono)

Icons in yazi/lazygit/Neovim require a Nerd Font v3.0+.

```bash
if [[ "$PLATFORM" == "macos" ]]; then
  brew install --cask font-jetbrains-mono-nerd-font

elif [[ "$PLATFORM" == "ubuntu" ]]; then
  mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
  curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -o JetBrainsMono.zip && rm JetBrainsMono.zip
  fc-cache -f
fi
```

**WSL is special**: the font must be installed on the **Windows** side (Windows
Terminal renders the glyphs, not WSL). Manual step for the user:
1. Download `JetBrainsMono.zip` from github.com/ryanoasis/nerd-fonts/releases/latest
2. Extract, select all `.ttf`, right-click → *Install*
3. Set it in Windows Terminal (see §9).

---

## 4. Claude Code

Already installed on this machine — just confirm it resolves:

```bash
claude --version   # if this fails, PATH needs a fresh shell; then: claude doctor
```

> Reference only (not needed here): the native installer for a fresh machine is
> `curl -fsSL https://claude.ai/install.sh | bash`.

---

## 5. bash as the shell

Make tmux always spawn bash (project preference over zsh).

```bash
# macOS default /bin/bash is 3.2 — install modern bash (optional but recommended)
[[ "$PLATFORM" == "macos" ]] && brew install bash
```

tmux is pinned to bash in §6.1 via `default-command`. `~/.bashrc` (not `.bash_profile`)
holds all interactive config below, which tmux panes source automatically.

---

## 6. Config files

### Phase 1 — Record (back up before writing anything)

Copy every file/dir this doc touches into one timestamped directory, and drop a
marker file so the cleanup step (§10) can find it later.

```bash
BACKUP_DIR="$HOME/.term_setup_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "$BACKUP_DIR" > "$HOME/.term_setup_last_backup"   # marker for §10

for p in \
  ~/.bashrc ~/.tmux.conf ~/.gitconfig \
  ~/.config/nvim ~/.config/lazygit ~/.config/yazi ~/.config/ghostty \
  ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim; do
  if [[ -e "$p" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${p#$HOME/}")"
    cp -a "$p" "$BACKUP_DIR/${p#$HOME/}"
  fi
done
echo "Recorded existing config to: $BACKUP_DIR"

# nvim must be empty for a fresh LazyVim clone; originals are safe in $BACKUP_DIR
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

### 6.1 `~/.tmux.conf`

```bash
# ---- shell ----
set -g default-command bash

# ---- base ----
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -sg escape-time 10
set -g history-limit 50000          # Claude Code output is long

# ---- true color ----
set -g default-terminal "tmux-256color"
set -as terminal-overrides ",*:RGB"

# ---- splits keep cwd ----
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# ---- popups: prefix+g lazygit, prefix+e yazi ----
bind g display-popup -w 90% -h 90% -E "lazygit"
bind e display-popup -w 90% -h 90% -E "yazi"
bind r source-file ~/.tmux.conf \; display "reloaded"

# ---- GitHub Dark minimal status bar (top) ----
set -g status-position top
set -g status-justify left
set -g status-style "bg=#0d1117,fg=#e6edf3"
set -g status-left "#[bg=#58a6ff,fg=#0d1117,bold] #S #[bg=#0d1117] "
set -g status-left-length 30
set -g status-right "#[fg=#8b949e]#{b:pane_current_path} #[fg=#6e7681]%H:%M "
setw -g window-status-format "#[fg=#6e7681] #I #W "
setw -g window-status-current-format "#[bg=#161b22,fg=#58a6ff,bold] #I #W "
setw -g window-status-separator ""
set -g pane-border-style "fg=#30363d"
set -g pane-active-border-style "fg=#58a6ff"
set -g message-style "bg=#161b22,fg=#e6edf3"

# ---- plugins (TPM) ----
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'christoomey/vim-tmux-navigator'
run '~/.tmux/plugins/tpm/tpm'
```

Install TPM (plugin manager), then load plugins:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# After starting tmux, press: prefix + I   (capital i) to install the plugins
```

### 6.2 Neovim — LazyVim starter + lean overrides

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

Write these files (each under `~/.config/nvim/lua/`):

`lua/plugins/colorscheme.lua` — GitHub Dark theme

```lua
return {
  { "projekt0n/github-nvim-theme", name = "github-theme", priority = 1000 },
  { "LazyVim/LazyVim", opts = { colorscheme = "github_dark_default" } },
}
```

`lua/plugins/slime.lua` — send R/Python selections to a tmux REPL pane
(default keymap: `Ctrl-c Ctrl-c` sends the paragraph/visual selection to the
last-active tmux pane).

```lua
return {
  "jpalardy/vim-slime",
  init = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_bracketed_paste = 1
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
  end,
}
```

`lua/plugins/treesitter.lua` — add R / Python / Bash / Nextflow(groovy) parsers

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "r", "python", "bash", "groovy" })
    end,
  },
}
```

Append to `lua/config/options.lua` (Nextflow filetype + quiet UI):

```lua
vim.opt.laststatus = 3         -- single global statusline
vim.opt.signcolumn = "yes"     -- no gutter jitter
-- Nextflow has no LSP; treat .nf and nextflow.config as groovy for highlighting
vim.filetype.add({
  extension = { nf = "groovy" },
  filename  = { ["nextflow.config"] = "groovy" },
})
```

### 6.3 `~/.config/lazygit/config.yml`

```yaml
gui:
  nerdFontsVersion: "3"
  showFileTree: true
  theme:
    activeBorderColor:    ["#58a6ff", bold]
    inactiveBorderColor:  ["#30363d"]
    selectedLineBgColor:  ["#161b22"]
    unstagedChangesColor: ["#f85149"]
```

### 6.4 `~/.config/yazi/theme.toml`

```toml
[mgr]
cwd     = { fg = "#58a6ff" }
hovered = { bg = "#161b22" }
[status]
separator_style = { fg = "#30363d", bg = "#30363d" }
```

### 6.5 git + delta (append to `~/.gitconfig`)

```ini
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    navigate = true
    line-numbers = true
    syntax-theme = ansi        # follows the terminal's GitHub Dark palette
[merge]
    conflictStyle = zdiff3
```

### 6.6 `~/.bashrc` additions

```bash
# ---- modern CLI ----
export BAT_THEME="ansi"                    # bat/delta follow terminal ANSI colors
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout reverse --border \
  --color=bg+:#161b22,fg+:#e6edf3,hl:#f85149,hl+:#f85149 \
  --color=info:#bc8cff,prompt:#58a6ff,pointer:#58a6ff,border:#30363d"
eval "$(zoxide init bash)"                 # `z <dir>` smart cd
eval "$(fzf --bash)"                       # Ctrl-T / Ctrl-R / Alt-C keybindings
alias ls='eza --group-directories-first'
alias ll='eza -lh --group-directories-first --git'
alias la='eza -lah --group-directories-first --git'

# ---- session helpers ----
# attach or create a named session:  t fshd
t() { tmux attach -t "$1" 2>/dev/null || tmux new -s "$1"; }

# editor-over-two-shells layout:  dev fshd
dev() {
  local s="${1:-dev}"
  tmux has-session -t "$s" 2>/dev/null && { tmux attach -t "$s"; return; }
  local editor
  editor=$(tmux new-session -d -s "$s" -P -F '#{pane_id}')
  tmux split-window -v -l 30% -t "$editor"     # bottom shell strip
  tmux split-window -h -l 50%                  # split it into two shells
  tmux select-pane -t "$editor"
  tmux send-keys -t "$editor" 'nvim' C-m
  tmux attach -t "$s"
}
```

---

## 7. Terminal emulator + GitHub Dark theme

### macOS / native Ubuntu — Ghostty

`~/.config/ghostty/config`:

```ini
theme = GitHub-Dark
font-family = JetBrainsMono Nerd Font
font-size = 14
window-padding-x = 8
window-padding-y = 6
```

### WSL — Windows Terminal

Add this scheme to the `"schemes"` array in Windows Terminal `settings.json`,
then set the Ubuntu profile's `"colorScheme": "GitHub Dark"` and font
`"JetBrainsMono Nerd Font"`:

```json
{
  "name": "GitHub Dark",
  "background": "#0d1117", "foreground": "#e6edf3",
  "cursorColor": "#e6edf3", "selectionBackground": "#264f78",
  "black": "#484f58",  "red": "#ff7b72",  "green": "#3fb950",
  "yellow": "#d29922", "blue": "#58a6ff", "purple": "#bc8cff",
  "cyan": "#39c5cf",   "white": "#b1bac4",
  "brightBlack": "#6e7681",  "brightRed": "#ffa198",
  "brightGreen": "#56d364",  "brightYellow": "#e3b341",
  "brightBlue": "#79c0ff",   "brightPurple": "#d2a8ff",
  "brightCyan": "#56d4dd",   "brightWhite": "#ffffff"
}
```

---

## 8. First launch & verification

```bash
# 1) Neovim: plugins auto-install on first open; wait, then quit and reopen.
nvim   # let lazy.nvim finish; run :checkhealth ; then :Lazy for status ; :q

# 2) tmux: start a session, install TPM plugins.
tmux new -s test
#   inside tmux: press  prefix + I   to install plugins, then  prefix + r  to reload

# 3) Verify tools resolve
for c in nvim tmux lazygit yazi delta bat eza fd rg zoxide btop; do
  command -v "$c" >/dev/null && echo "ok  $c" || echo "MISSING  $c"
done
```

**Validation gate**: proceed to cleanup (§10) only if all of the following hold —
every tool printed `ok` (no `MISSING`), `nvim --version` is >= 0.11.2, `nvim`
opens and `:checkhealth` shows no errors, and `tmux` starts with the status bar
rendering. If any fail, do the §10 rollback instead.

Optional (only if you edit R inside Neovim and want R LSP later):

```bash
Rscript -e 'install.packages("languageserver", repos="https://cran.r-project.org")'
```

---

## 9. Gotchas / stability notes

- **Neovim version**: LazyVim requires >= 0.11.2. If `nvim --version` is lower,
  the apt package leaked onto PATH — use the Homebrew `nvim` (`brew link neovim`)
  or the official tarball.
- **WSL font**: installing the Nerd Font *inside* WSL does nothing; it must be on
  Windows and selected in Windows Terminal (§3, §7).
- **macOS bash**: `/bin/bash` is 3.2. `brew install bash` gives 5.x; tmux uses
  whatever `bash` resolves first on PATH via `default-command bash`.
- **REPL workflow**: open R or Python in one tmux pane, edit in Neovim in another,
  send lines with `Ctrl-c Ctrl-c` (vim-slime targets the last-active pane).
- **`gs4`**: excluded by design. There, only run `tmux` to keep jobs alive over
  SSH; do not install this toolchain.
- **Reproducibility**: keep these files in a `~/dotfiles` git repo and symlink
  them, so all three machines stay identical.

---

## 10. Phase 4 — Cleanup / rollback

Run exactly one of these after §8, based on the validation gate.

### Cleanup — validation PASSED → remove the old settings

```bash
BACKUP_DIR="$(cat "$HOME/.term_setup_last_backup")"
echo "Removing recorded old settings at: $BACKUP_DIR"
rm -rf "$BACKUP_DIR"
rm -f  "$HOME/.term_setup_last_backup"
# also clear any legacy stray backups from older runs
rm -f  ~/.tmux.conf.bak
echo "Cleanup done — new environment is live."
```

### Rollback — validation FAILED → restore, delete nothing new

```bash
BACKUP_DIR="$(cat "$HOME/.term_setup_last_backup")"
echo "Restoring previous settings from: $BACKUP_DIR"
# restore each recorded path back to $HOME (overwrites the just-applied config)
( cd "$BACKUP_DIR" && cp -a . "$HOME/" )
echo "Rollback done — report which validation step failed before retrying."
```

The backup directory is kept until a run validates successfully, so a failed run
is always recoverable.
```
