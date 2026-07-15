-- UI quieting + Nextflow filetype, applied at startup.
-- Lives in lua/plugins/ so the whole customization set is symlinkable
-- without editing LazyVim's own config/options.lua.
return {
  {
    "LazyVim/LazyVim",
    init = function()
      vim.opt.mouse = "a"         -- mouse on in all modes (LazyVim default; explicit)
      vim.opt.mousemodel = "extend" -- right-click extends selection (no popup menu)
      vim.opt.laststatus = 3      -- single global statusline
      vim.opt.signcolumn = "yes"  -- no gutter jitter
      -- Nextflow has no LSP; treat .nf and nextflow.config as groovy.
      vim.filetype.add({
        extension = { nf = "groovy" },
        filename  = { ["nextflow.config"] = "groovy" },
      })
    end,
  },
}
