return {
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")

    -- Get current working directory for logging
    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)

    _99.setup({
      -- Use Claude Code as the AI provider
      provider = _99.ClaudeCodeProvider,
      model = "claude-sonnet-4-5",

      -- Logging configuration (helps with debugging)
      logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
      },

      -- Completions: #rules and @files in the prompt buffer
      completion = {
        -- Configure @file completion
        files = {
          enabled = true,
          max_file_size = 102400, -- bytes, skip files larger than this
          max_files = 5000, -- cap on total discovered files
        },

        -- Use cmp for autocomplete
        source = "cmp",
      },

      -- Auto-add markdown files based on location
      md_files = {
        "AGENT.md",
      },
    })

    -- Visual selection AI completion (only works in visual mode)
    vim.keymap.set("v", "<leader>9v", function()
      _99.visual()
    end, { desc = "[9] Visual AI completion" })

    -- Stop all AI requests
    vim.keymap.set("v", "<leader>9s", function()
      _99.stop_all_requests()
    end, { desc = "[9] Stop all AI requests" })

    -- View logs for debugging
    vim.keymap.set("n", "<leader>9l", function()
      _99.view_logs()
    end, { desc = "[9] View logs" })
  end,
}
