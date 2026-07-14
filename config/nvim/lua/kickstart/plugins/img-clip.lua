-- Paste screenshots straight into markdown: writes the image to a file and
-- inserts the ![](...) reference. Handles the WSL -> Windows clipboard bridge,
-- so Win+Shift+S then <leader>mi just works.
--
-- Tuned for the ccc-knowledge docs convention: images land in assets/images/
-- (or assets-it/images/ for IT-internal docs) and are referenced as
-- ../assets/images/... — every content folder is one level deep, so the
-- relative path resolves the same everywhere.
return {
  "HakonHarnes/img-clip.nvim",
  ft = { "markdown" },
  opts = {
    default = {
      dir_path = "../assets/images",   -- relative to the doc -> assets/images
      relative_to_current_file = true, -- cwd-independent
      relative_template_path = true,   -- inserts ../assets/images/... in the doc
      prompt_for_file_name = true,     -- name it (kebab-case, please)
      file_name = "%Y%m%d-%H%M%S",     -- fallback if you skip the prompt
      template = "![$CURSOR]($FILE_PATH)",
    },
  },
  keys = {
    { "<leader>mi", "<cmd>PasteImage<cr>", desc = "[M]arkdown paste [i]mage -> assets/images" },
    {
      "<leader>mI",
      function()
        require("img-clip").pasteImage {
          dir_path = "../assets-it/images",
          relative_to_current_file = true,
        }
      end,
      desc = "[M]arkdown paste [I]mage -> assets-it (IT-internal)",
    },
  },
}
