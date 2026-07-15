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
├── ghostty/config             # -> ~/.config/ghostty/config  (Ghostty; skip if macOS Terminal.app)
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

1. **No terminal setup** — colors are painted by the configs and icons are ASCII
   (no Nerd Font needed). `install.sh` makes macOS Terminal.app dark automatically;
   Windows Terminal is already dark. (Want glyph icons? install JetBrainsMono NF,
   select it as the terminal font, then flip `have_nerd_font`/`nerdFontsVersion`.)
2. **tmux** — start a session, press `prefix + I` to install plugins.
3. **Neovim** — open `nvim` once; let lazy.nvim finish, then `:checkhealth`.
4. **(Optional) Windows Terminal exact palette** — paste
   `windows-terminal/github-dark.json` into `schemes` and apply it. Not required —
   the default dark palette is already close.

## Notes

- Requires **Neovim >= 0.11.2** (LazyVim). Homebrew provides it; Ubuntu apt does not.
- You theme both terminals (GitHub Dark) yourself; the tools use **ANSI** colors so
  tmux/lazygit/yazi/fzf follow that palette exactly on both. Neovim uses the truecolor
  GitHub theme on Windows Terminal and the terminal's ANSI palette on Terminal.app.
  Icons are ASCII (no Nerd Font needed).
- On macOS, `install.sh --packages` installs `bash` (a formula; the default
  /bin/bash is 3.2). First `--packages` run also triggers a Homebrew auto-update
  that can add a few minutes.
- REPL: open R/Python in one tmux pane, edit in Neovim in another, send lines with
  `Ctrl-c Ctrl-c` (vim-slime targets the last-active pane).
- `gs4` (remote job server) is **not** a target — there, run only tmux to keep
  jobs alive over SSH. Don't run `install.sh` on it.
- See `USAGE.zh-TW.md` for the day-to-day usage manual (Traditional Chinese), and `term_setup.md` for the full guided install flow, including the
  record → apply → validate → cleanup safety procedure.
```
