require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<leader>sc", "z=", { desc = "Choose spelling correction" })
map("n", "<leader>st", function()
  require("speech").toggle()
end, { desc = "Toggle speech to text" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
