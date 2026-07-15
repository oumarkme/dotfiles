-- Send R/Python selections to a tmux REPL pane.
-- Default keymap: Ctrl-c Ctrl-c sends the paragraph / visual selection
-- to the last-active tmux pane.
return {
  "jpalardy/vim-slime",
  init = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_bracketed_paste = 1
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
  end,
}
