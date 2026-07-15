# dotfiles

Portable terminal dev environment for **macOS / Ubuntu / WSL-Ubuntu**.

**Stack:** bash · tmux · Neovim (LazyVim) · yazi · lazygit · delta · bat · fzf ·
ripgrep · fd · eza · zoxide · btop · Claude Code
**Theme:** GitHub Dark everywhere · **Font:** JetBrainsMono Nerd Font

## Structure

```
dotfiles/
├── install.sh                 # link everything into place (backs up first)
├── term_setup.md              # full step-by-step guide (packages + record/validate/cleanup)
├── tmux/tmux.conf             # -> ~/.tmux.conf
├── bash/init.bash             # sourced from ~/.bashrc (aliases, env, t(), dev())
├── git/delta.gitconfig        # included via `git config --global include.path`
├── lazygit/config.yml         # -> ~/.config/lazygit/config.yml
├── yazi/theme.toml            # -> ~/.config/yazi/theme.toml
├── ghostty/config             # -> ~/.config/ghostty/config  (macOS / native Linux)
├── windows-terminal/github-dark.json   # manual paste for WSL
└── nvim/plugins/*.lua         # -> ~/.config/nvim/lua/plugins/  (over LazyVim starter)
```

## Install

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh            # link configs + bootstrap TPM & LazyVim
# or, on a fresh machine, also install the CLI tools:
./install.sh --packages
```

`install.sh` is **non-destructive**: any existing target is copied into
`~/.dotfiles_backup_<timestamp>/` before a symlink replaces it, and your own
`~/.bashrc` / `~/.gitconfig` are kept (only a `source` line and an `include.path`
are added). To undo, `cp -a` the files back from that backup dir.

## Post-install

1. **Nerd Font** — macOS: installed by `--packages`. Native Ubuntu: drop
   JetBrainsMono NF into `~/.local/share/fonts` and `fc-cache -f`. **WSL: install
   the font on the *Windows* side** and select it in Windows Terminal (installing
   it inside WSL does nothing).
2. **tmux** — start a session, press `prefix + I` to install plugins.
3. **Neovim** — open `nvim` once; let lazy.nvim finish, then `:checkhealth`.
4. **Windows Terminal (WSL only)** — paste `windows-terminal/github-dark.json`
   into the `schemes` array and set the profile `colorScheme` + font.

## Notes

- Requires **Neovim >= 0.11.2** (LazyVim). Homebrew provides it; Ubuntu apt does not.
- REPL: open R/Python in one tmux pane, edit in Neovim in another, send lines with
  `Ctrl-c Ctrl-c` (vim-slime targets the last-active pane).
- `gs4` (remote job server) is **not** a target — there, run only tmux to keep
  jobs alive over SSH. Don't run `install.sh` on it.
- See `term_setup.md` for the full guided flow, including the
  record → apply → validate → cleanup safety procedure.
```
