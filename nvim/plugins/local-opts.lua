-- UI quieting + Nextflow filetype, applied at startup.
-- Lives in lua/plugins/ so the whole customization set is symlinkable
-- without editing LazyVim's own config/options.lua.
return {
  {
    "LazyVim/LazyVim",
    init = function()
      vim.g.have_nerd_font = false -- ASCII icons; no terminal Nerd Font needed
      vim.opt.mouse = "a"         -- mouse on in all modes (LazyVim default; explicit)
      vim.opt.mousemodel = "extend" -- right-click extends selection (no popup menu)
      vim.opt.laststatus = 3      -- single global statusline
      vim.opt.signcolumn = "yes"  -- no gutter jitter
      -- macOS Terminal.app has no true color; use the terminal's ANSI palette
      -- instead of emitting broken truecolor escapes.
      if vim.env.TERM_PROGRAM == "Apple_Terminal" then
        vim.opt.termguicolors = false
      end
      -- Nextflow has no LSP; treat .nf and nextflow.config as groovy.
      vim.filetype.add({
        extension = { nf = "groovy" },
        filename  = { ["nextflow.config"] = "groovy" },
      })
    end,
  },
}
