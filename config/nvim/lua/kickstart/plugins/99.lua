return {
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")

    -- Get current working directory for logging
    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)

    _99.setup({
      -- Use Claude Code as the AI provider
      provider = _99.Providers.ClaudeCodeProvider,
      model = "haiku", -- Use short alias (automatically uses latest version)

      -- Logging configuration (helps with debugging)
      logger = {
        level = _99.DEBUG,
        path = "/tmp/" .. basename .. ".99.debug",
        print_on_error = true,
      },

      -- Completions: #rules and @files in the prompt buffer
      -- NOTE: Disabled for now since we're using blink.cmp instead of nvim-cmp
      -- completion = {
      --   files = {
      --     enabled = true,
      --     max_file_size = 102400,
      --     max_files = 5000,
      --   },
      --   source = "cmp",
      -- },

      -- Auto-add markdown files based on location
      md_files = {
        "AGENT.md",
      },
    })

    -- Visual selection AI completion (only works in visual mode)
    vim.keymap.set("v", "<leader>9v", function()
      _99.visual()
    end, { desc = "AI completion" })

    -- Stop all AI requests
    vim.keymap.set("v", "<leader>9s", function()
      _99.stop_all_requests()
    end, { desc = "Stop AI requests" })

    -- View logs for debugging
    vim.keymap.set("n", "<leader>9l", function()
      _99.view_logs()
    end, { desc = "View logs" })

    -- Model switching commands
    local function switch_model(model_name)
      local state = _99.__get_state()
      state.model = model_name
      vim.notify("99: Switched to " .. model_name, vim.log.levels.INFO)
    end

    -- Create vim commands for easy model switching
    vim.api.nvim_create_user_command("AiHaiku", function()
      switch_model("haiku")
    end, { desc = "Switch 99 to Haiku (cheapest, fastest)" })

    vim.api.nvim_create_user_command("AiSonnet", function()
      switch_model("sonnet")
    end, { desc = "Switch 99 to Sonnet (balanced)" })

    vim.api.nvim_create_user_command("AiOpus", function()
      switch_model("opus")
    end, { desc = "Switch 99 to Opus (most powerful)" })

    -- Show current model
    vim.api.nvim_create_user_command("AiModel", function()
      local state = _99.__get_state()
      vim.notify("99: Current model is " .. state.model, vim.log.levels.INFO)
    end, { desc = "Show current 99 model" })

    -- Optional: Keybindings for quick switching
    vim.keymap.set("n", "<leader>9h", function()
      switch_model("haiku")
    end, { desc = "Model: Haiku" })

    vim.keymap.set("n", "<leader>9s", function()
      switch_model("sonnet")
    end, { desc = "Model: Sonnet" })

    vim.keymap.set("n", "<leader>9o", function()
      switch_model("opus")
    end, { desc = "Model: Opus" })

    vim.keymap.set("n", "<leader>9m", function()
      local state = _99.__get_state()
      vim.notify("99: Current model is " .. state.model, vim.log.levels.INFO)
    end, { desc = "Show model" })
  end,
}
