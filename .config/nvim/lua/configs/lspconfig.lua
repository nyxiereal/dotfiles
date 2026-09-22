require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("ltex_plus", {
  settings = { ltex = { language = "pl-PL" } },
})

vim.lsp.enable { "html", "cssls", "ltex_plus" }
