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
    { "<leader>gs", ":Neogit<cr>", desc = "Neogit status" },
    { "<leader>gc", ":Neogit commit<cr>", desc = "Neogit commit" },
    { "<leader>gp", ":Neogit pull<cr>", desc = "Neogit pull" },
    { "<leader>gP", ":Neogit push<cr>", desc = "Neogit push" },
    { "<leader>gb", ":Telescope git_branches<cr>", desc = "Telescope Git Branches" },
    { "<leader>gB", ":G blame<cr>", desc = "Git Blame" },
  },
}
