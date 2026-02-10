return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter',
  opts = {
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },

    -- Document existing key chains
    spec = {
      { '<leader>s', group = 'Search', mode = { 'n', 'v' } },
      { '<leader>t', group = 'Toggle' },
      { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
      { '<leader>g', group = 'Git' },
      { '<leader>o', group = 'Obsidian' },
      { '<leader>or', group = 'Remove/Delete' },
      { '<leader>p', group = 'Project' },
      { '<leader>9', group = '99 AI' },
    },
  },
}
