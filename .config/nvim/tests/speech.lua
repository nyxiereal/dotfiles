vim.opt.runtimepath:prepend(vim.fn.getcwd())

local speech = require "speech"
assert(vim.deep_equal(speech._ready_chunks({ "0.wav", "1.wav" }, true), { "0.wav" }))
assert(vim.deep_equal(speech._ready_chunks({ "0.wav", "1.wav" }, false), { "0.wav", "1.wav" }))
