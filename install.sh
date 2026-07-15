#!/usr/bin/env bash
# install.sh — link these dotfiles into place (macOS / Ubuntu / WSL-Ubuntu).
#
#   ./install.sh              link configs + bootstrap TPM & LazyVim
#   ./install.sh --packages   also install CLI packages via Homebrew first
#
# Non-destructive: any existing target is copied into a timestamped backup dir
# before a symlink replaces it. Nothing is deleted.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ---- platform ----
if [[ "$(uname)" == "Darwin" ]]; then PLATFORM=macos
elif grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null; then PLATFORM=wsl
else PLATFORM=ubuntu; fi
echo ">> platform: $PLATFORM"

# ---- helper: back up then symlink ----
link() {  # link <src-in-repo> <dest>
  local src="$DOTFILES/$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      echo "   ok (already linked): $dest"; return
    fi
    mkdir -p "$BACKUP_DIR/$(dirname "${dest#$HOME/}")"
    cp -a "$dest" "$BACKUP_DIR/${dest#$HOME/}"
    rm -rf "$dest"
    echo "   backed up + relinking: $dest"
  fi
  ln -s "$src" "$dest"
  echo "   linked: $dest -> $src"
}

# ---- optional: packages ----
if [[ "${1:-}" == "--packages" ]]; then
  echo ">> installing packages via Homebrew"
  command -v brew >/dev/null || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$([[ "$PLATFORM" == macos ]] && /opt/homebrew/bin/brew shellenv \
        || /home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  brew install tmux neovim git fzf ripgrep fd bat eza zoxide git-delta \
               yazi lazygit btop tree-sitter
  [[ "$PLATFORM" == macos ]] && brew install --cask font-jetbrains-mono-nerd-font bash
fi

# ---- tmux ----
echo ">> tmux"
link tmux/tmux.conf "$HOME/.tmux.conf"
[[ -d "$HOME/.tmux/plugins/tpm" ]] || \
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# ---- bash (source line only; ~/.bashrc kept intact) ----
echo ">> bash"
SRC_LINE="source \"$DOTFILES/bash/init.bash\""
grep -qF "$SRC_LINE" "$HOME/.bashrc" 2>/dev/null || {
  mkdir -p "$BACKUP_DIR"; cp -a "$HOME/.bashrc" "$BACKUP_DIR/.bashrc" 2>/dev/null || true
  printf '\n# dotfiles\n%s\n' "$SRC_LINE" >> "$HOME/.bashrc"
  echo "   appended source line to ~/.bashrc"
}

# ---- git delta (include; ~/.gitconfig kept intact) ----
echo ">> git"
git config --global include.path "$DOTFILES/git/delta.gitconfig"
echo "   set include.path -> git/delta.gitconfig"

# ---- lazygit / yazi ----
echo ">> lazygit / yazi"
link lazygit/config.yml "$HOME/.config/lazygit/config.yml"
link yazi/theme.toml    "$HOME/.config/yazi/theme.toml"

# ---- ghostty (skip on WSL; Windows Terminal is used there) ----
if [[ "$PLATFORM" != wsl ]]; then
  echo ">> ghostty"
  link ghostty/config "$HOME/.config/ghostty/config"
else
  echo ">> WSL: paste windows-terminal/github-dark.json into Windows Terminal settings"
fi

# ---- neovim (LazyVim starter + our plugin files) ----
echo ">> neovim"
if [[ ! -d "$HOME/.config/nvim" ]]; then
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
fi
for f in "$DOTFILES"/nvim/plugins/*.lua; do
  link "nvim/plugins/$(basename "$f")" "$HOME/.config/nvim/lua/plugins/$(basename "$f")"
done

# ---- done ----
echo ""
echo ">> done."
[[ -d "$BACKUP_DIR" ]] && echo "   previous files backed up in: $BACKUP_DIR"
cat <<'EOF'

   Next:
     1. Nerd Font: macOS/Ubuntu handled by --packages / your font step;
        WSL — install JetBrainsMono NF on the *Windows* side and select it.
     2. Open tmux, press  prefix + I  to install plugins.
     3. Open  nvim  once; let lazy.nvim finish, then :checkhealth.
     4. Verify:  for c in nvim tmux lazygit yazi delta bat eza fd rg zoxide btop; do command -v $c || echo MISSING $c; done
EOF
