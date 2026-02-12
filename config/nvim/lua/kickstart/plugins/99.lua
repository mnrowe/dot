return {
  "ThePrimeagen/99",
  config = function()
    local _99 = require "99"

    -- Get current working directory for logging
    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)

    -- Get OpenRouter API key from environment
    local openrouter_api_key = vim.fn.getenv "OPENROUTER_API_KEY"

    _99.setup {
      -- Use Claude Code as the AI provider (default)
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
    }

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

    -- Valid Anthropic models for ClaudeCodeProvider
    local claude_models = {
      haiku = true,
      sonnet = true,
      opus = true,
      ["claude-haiku-4-5-20251001"] = true,
      ["claude-sonnet-4-5-20250929"] = true,
      ["claude-opus-4-6"] = true,
    }

    -- Check if a model is valid for ClaudeCodeProvider
    local function is_claude_model(model_name)
      return claude_models[model_name] == true
    end

    -- Model switching commands with validation
    local function switch_model(model_name)
      local state = _99.__get_state()

      -- Check if trying to use non-Claude model with ClaudeCodeProvider
      if state.provider == _99.Providers.ClaudeCodeProvider and not is_claude_model(model_name) then
        vim.notify(
          "99: ERROR - Cannot use model '"
            .. model_name
            .. "' with ClaudeCodeProvider. "
            .. "Only Anthropic models (haiku, sonnet, opus) are supported with your Pro subscription.",
          vim.log.levels.ERROR
        )
        return false
      end

      state.model = model_name
      vim.notify("99: Switched to " .. model_name, vim.log.levels.INFO)
      return true
    end

    -- Provider and model switching for non-Claude providers
    local function switch_provider_and_model(provider, model_name, display_name)
      local state = _99.__get_state()
      state.provider = provider
      state.model = model_name
      vim.notify("99: Switched to " .. display_name, vim.log.levels.INFO)
    end

    -- Switch back to Claude Code provider with optional model
    local function switch_to_claude(model_name)
      local state = _99.__get_state()
      state.provider = _99.Providers.ClaudeCodeProvider

      if model_name then
        if is_claude_model(model_name) then
          state.model = model_name
          vim.notify("99: Switched to Claude Code provider with " .. model_name, vim.log.levels.INFO)
        else
          vim.notify("99: ERROR - Model '" .. model_name .. "' is not a valid Anthropic model", vim.log.levels.ERROR)
        end
      else
        vim.notify("99: Switched back to Claude Code provider", vim.log.levels.INFO)
      end
    end

    -- Create vim commands for easy model switching
    vim.api.nvim_create_user_command("AiHaiku", function()
      switch_to_claude()
      switch_model "haiku"
    end, { desc = "Switch 99 to Haiku (cheapest, fastest) via ClaudeCodeProvider" })

    vim.api.nvim_create_user_command("AiSonnet via ClaudeCodeProvider", function()
      switch_to_claude()
      switch_model "sonnet"
    end, { desc = "Switch 99 to Sonnet (balanced) via ClaudeCodeProvider" })

    vim.api.nvim_create_user_command("AiOpus", function()
      switch_to_claude()
      switch_model "opus"
    end, { desc = "Switch 99 to Opus (most powerful) via ClaudeCodeProvider" })

    -- OpenRouter kimi2.5 command via OpenCodeProvider
    vim.api.nvim_create_user_command("AiKimi", function()
      if openrouter_api_key == "" or openrouter_api_key == vim.NIL then
        vim.notify("99: OPENROUTER_API_KEY not found in environment", vim.log.levels.ERROR)
        return
      end

      switch_provider_and_model(
        _99.Providers.OpenCodeProvider,
        "moonshotai/kimi-k2.5",
        "kimi 2.5 (OpenRouter)"
      )
    end, { desc = "Switch 99 to kimi 2.5 via OpenRouter" })

    -- Show current model and provider
    vim.api.nvim_create_user_command("AiModel", function()
      local state = _99.__get_state()
      local provider_name = "Unknown"

      if state.provider == _99.Providers.ClaudeCodeProvider then
        provider_name = "ClaudeCodeProvider"
      elseif type(state.provider) == "table" then
        -- OpenRouter or other custom provider
        provider_name = "OpenRouter"
      end

      vim.notify("99: Using " .. provider_name .. " with model: " .. state.model, vim.log.levels.INFO)
    end, { desc = "Show current 99 provider and model" })

    -- Optional: Keybindings for quick switching
    vim.keymap.set("n", "<leader>9h", function()
      switch_to_claude()
      switch_model "haiku"
    end, { desc = "Model: Haiku" })

    vim.keymap.set("n", "<leader>9s", function()
      switch_to_claude()
      switch_model "sonnet"
    end, { desc = "Model: Sonnet" })

    vim.keymap.set("n", "<leader>9o", function()
      switch_to_claude()
      switch_model "opus"
    end, { desc = "Model: Opus" })

    vim.keymap.set("n", "<leader>9k", function()
      if openrouter_api_key == "" or openrouter_api_key == vim.NIL then
        vim.notify("99: OPENROUTER_API_KEY not found in environment", vim.log.levels.ERROR)
        return
      end

      switch_provider_and_model(
        _99.Providers.OpenCodeProvider,
        "moonshotai/kimi-k2.5",
        "kimi 2.5 (OpenRouter)"
      )
    end, { desc = "Model: kimi 2.5" })

    vim.keymap.set("n", "<leader>9m", function()
      local state = _99.__get_state()
      local provider_name = "Unknown"

      if state.provider == _99.Providers.ClaudeCodeProvider then
        provider_name = "ClaudeCodeProvider"
      elseif type(state.provider) == "table" then
        provider_name = "OpenRouter"
      end

      vim.notify("99: Using " .. provider_name .. " with model: " .. state.model, vim.log.levels.INFO)
    end, { desc = "Show provider and model" })

    -- Global function to get current 99 status for statusline
    _G.get_99_status = function()
      local ok, state = pcall(_99.__get_state)
      if not ok or not state then
        return ""
      end

      local provider_short = ""
      if state.provider == _99.Providers.ClaudeCodeProvider then
        provider_short = "Claude"
      elseif type(state.provider) == "table" then
        provider_short = "OR" -- OpenRouter
      end

      local model_short = state.model or "?"
      -- Shorten common model names
      if model_short == "haiku" then
        model_short = "H"
      elseif model_short == "sonnet" then
        model_short = "S"
      elseif model_short == "opus" then
        model_short = "O"
      elseif model_short:match "kimi" then
        model_short = "K"
      end

      return string.format("[AI:%s:%s]", provider_short, model_short)
    end

    -- Add to statusline (append to existing statusline)
    vim.opt.statusline:append "%{%v:lua.get_99_status()%}"
  end,
}
