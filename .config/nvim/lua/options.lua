require "nvchad.options"

vim.cmd.runtime "plugin/spellfile.lua"
require("nvim.spellfile").config { confirm = false }

vim.opt.spell = true
vim.opt.spelllang = { "pl", "en_us" }
vim.opt.spellfile = vim.fn.stdpath "config" .. "/spell/custom.utf-8.add"
