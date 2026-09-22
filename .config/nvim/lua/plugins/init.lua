return {
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "vim", "lua", "vimdoc", "html", "css", "markdown", "markdown_inline" },
    },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {},
  },
  {
    "ixigo/agentify.nvim",
    event = "VeryLazy",
    opts = {
      provider = "cursor",
      filetypes = { allow = { "markdown", "text" } },
      cursor = { endpoint = "http://127.0.0.1:8787/v1/inline-completions" },
      codex = { warmup_on_insert = false },
    },
    config = function(_, opts)
      require("agentify.provider").create = require("cursor_completion").new
      local agentify = require "agentify"
      agentify.setup(opts)
      vim.keymap.set("i", "<M-l>", agentify.accept, { desc = "Accept AI suggestion" })
      vim.keymap.set("i", "<M-w>", agentify.accept_word, { desc = "Accept AI suggestion word" })
      vim.keymap.set("i", "<M-]>", agentify.dismiss, { desc = "Dismiss AI suggestion" })
    end,
  },
}
