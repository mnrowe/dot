# Scripts

Portable scripts for dotfiles deployment.

## opencode-model

Switch between AI models and launch opencode with OpenRouter.

### Setup on New Machines

1. **Clone dotfiles and setup symlinks** (if not already done)
2. **Create `~/.env` with your API key**:
   ```bash
   cat > ~/.env << 'EOF'
   OPENROUTER_API_KEY=your-api-key-here
   ANTHROPIC_API_KEY=${OPENROUTER_API_KEY}
   ANTHROPIC_BASE_URL=https://openrouter.ai/api/v1
   ANTHROPIC_MODEL=anthropic/claude-opus-4-6
   EOF
   chmod 600 ~/.env
   ```

3. **Install opencode** (if not already installed):
   ```bash
   npm install -g opencode
   ```

4. **Reload your shell**:
   ```bash
   source ~/.bashrc
   ```

### Usage

```bash
# Launch opencode with specific model
opencode-model claude           # Launch with Claude Opus in current dir
opencode-model sonnet ~/project # Launch with Sonnet in ~/project
opencode-model gpt4             # Launch with GPT-4

# Or use the aliases (defined in ~/.bash_personal)
oc-claude      # Launch Claude Opus in current dir
oc-sonnet      # Launch Sonnet in current dir
oc-gpt4        # Launch GPT-4 in current dir
occ            # Short alias for Claude
ocs            # Short alias for Sonnet

# Check configuration
oc-current     # Show current model
oc-list        # List available models
```

### Available Models

- `claude`, `claude-opus` → Claude Opus 4.6 (most capable)
- `claude-sonnet`, `sonnet` → Claude Sonnet 4.5 (balanced)
- `gpt4`, `gpt4-turbo` → GPT-4 Turbo
- `gpt4o` → GPT-4o
- `gemini`, `gemini-pro` → Gemini Pro

### Security Notes

- `~/.env` is stored in your home directory, NOT in the dotfiles repo
- It should have `600` permissions (only you can read/write)
- Never commit API keys to git
- The `.gitignore` is configured to exclude `.env` files
