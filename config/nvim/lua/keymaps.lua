-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Obsidian
-- navigate the vault
vim.keymap.set("n", "<leader>oo", ":cd /home/rwe/Documents/obsd<cr>")
-- search for files in full vault
vim.keymap.set("n", "<leader>os", ":Telescope find_files search_dirs=/home/rwe/Documents/obsd/notes<cr>")
vim.keymap.set("n", "<leader>oz", ":Telescope live_grep search_dirs=/home/rwe/Documents/obsd/notes<cr>")
-- move file in current buffer to zettelkasten folder
vim.keymap.set("n", "<leader>ok", ":!mv '%:p' /home/rwe/Documents/obsd/notes/<cr>:bd<cr>")
vim.keymap.set("n", "<leader>ox", ":!rm '%:p'<cr>:bd<cr>")

-- local obsd_value = vim.fn.getenv "ODR"
-- if obsd_value == "work" then
--   vim.keymap.set("n", "<leader>oo", ":cd /home/mrowe/docs/obsd_w<cr>")
--   vim.keymap.set("n", "<leader>os", ":Telescope find_files search_dirs=/home/mrowe/Documents/obsd_w<cr>")
--   vim.keymap.set("n", "<leader>oz", ":Telescope live_grep search_dirs=/home/mrowe/Documents/obsd_w<cr>")
--   -- move file in current buffer to zettelkasten folder
--   vim.keymap.set("n", "<leader>ok", ":!mv '%:p' /home/mrowe/Documents/obsd_w/zettelkasten<cr>:bd<cr>")
-- end

-- convert note to note template and remove leading white space
vim.keymap.set("n", "<leader>on", ":ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- convert note to daily template and remove leading white space
vim.keymap.set("n", "<leader>od", ":ObsidianTemplate daily<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- convert note to daily template and remove leading white space
vim.keymap.set("n", "<leader>ow", ":ObsidianTemplate weekly<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- convert note to daily template and remove leading white space
vim.keymap.set("n", "<leader>om", ":ObsidianTemplate monthly<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>")
-- check obsidian backlinks on a note
vim.keymap.set("n", "<leader>ol", ":ObsidianBacklinks<cr>")
-- strip date from note title and replace dashes with spaces
-- must have cursor on title
vim.keymap.set("n", "<leader>of", [[:s/\d\{10,13}// | s/-//g<CR>]])
-- delete file in current buffer
vim.keymap.set("n", "<leader>orm", ":!rm '%:p'<cr>:bd<cr>")

-- vim: ts=2 sts=2 sw=2 et
