# dotfiles/bash/init.bash
# Sourced from ~/.bashrc (install.sh appends the source line).
# Keeps the user's own ~/.bashrc (conda/brew init, etc.) intact.

# ---- modern CLI ----
export BAT_THEME="ansi"                    # bat/delta follow terminal ANSI colors
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout reverse --border \
  --color=bg+:#161b22,fg+:#e6edf3,hl:#f85149,hl+:#f85149 \
  --color=info:#bc8cff,prompt:#58a6ff,pointer:#58a6ff,border:#30363d"

command -v zoxide >/dev/null && eval "$(zoxide init bash)"    # `z <dir>` smart cd
command -v fzf    >/dev/null && eval "$(fzf --bash)"          # Ctrl-T / Ctrl-R / Alt-C

if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --group-directories-first --git'
  alias la='eza -lah --group-directories-first --git'
fi

# ---- tmux session helpers ----
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
