return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration

    -- Only one of these is needed.
    "nvim-telescope/telescope.nvim", -- optional
  },
  config = true,
  keys = {
    { "<leader>gs", ":Neogit<cr>", desc = "Status" },
    { "<leader>gc", ":Neogit commit<cr>", desc = "Commit" },
    { "<leader>gp", ":Neogit pull<cr>", desc = "Pull" },
    { "<leader>gP", ":Neogit push<cr>", desc = "Push" },
    { "<leader>gb", ":Telescope git_branches<cr>", desc = "Branches" },
    { "<leader>gB", ":G blame<cr>", desc = "Blame" },
  },
}
