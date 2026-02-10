-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", ":Neotree reveal<CR>", desc = "File explorer" },
  },
  opts = {
    filesystem = {
      hijack_netrw_behavior = "open_default",
      filtered_items = {
        visible = false, -- hidden files are not shown by default
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          "node_modules",
          ".git",
          ".cache",
          "__pycache__",
        },
        hide_by_pattern = {
          "*.pyc",
          "*.pyo",
          ".venv",
          "venv",
          "env",
          ".env",
          "*.egg-info",
          ".pytest_cache",
          ".mypy_cache",
          ".tox",
          "dist",
          "build",
          ".next",
          ".nuxt",
          "target", -- Rust
          ".DS_Store",
        },
        never_show = {
          ".git",
          ".DS_Store",
          "thumbs.db",
        },
      },
      window = {
        mappings = {
          ["<leader>e"] = "close_window",
          ["H"] = "toggle_hidden", -- Toggle hidden files
          ["I"] = "toggle_gitignored", -- Toggle gitignored files
        },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
      },
      git_status = {
        symbols = {
          added = "✚",
          deleted = "✖",
          modified = "",
          renamed = "󰁕",
          untracked = "",
          ignored = "",
          unstaged = "󰄱",
          staged = "",
          conflict = "",
        },
      },
    },
  },
}
