-- R / Python / Bash / Nextflow(groovy) syntax highlighting.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "r", "python", "bash", "groovy" })
    end,
  },
}
