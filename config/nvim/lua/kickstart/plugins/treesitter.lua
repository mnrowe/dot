return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Safely load treesitter configs
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.notify("nvim-treesitter.configs not found, trying alternative...", vim.log.levels.WARN)
        return
      end

      configs.setup({
        ensure_installed = { "bash", "c", "diff", "html", "lua", "luadoc", "markdown", "markdown_inline", "query", "vim", "vimdoc" },
        auto_install = true,
        highlight = {
          enable = true,
        },
      })
    end,
  },
}
