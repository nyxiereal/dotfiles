local Cursor = {}
Cursor.__index = Cursor

function Cursor:complete(context, callback)
  local lines = vim.api.nvim_buf_get_lines(context.bufnr, 0, -1, false)
  local contents = table.concat(lines, "\n")
  if vim.bo[context.bufnr].endofline then
    contents = contents .. "\n"
  end

  local payload = vim.json.encode {
    filepath = context.filepath ~= "" and context.filepath or "untitled",
    contents = contents,
    line = context.row,
    column = vim.str_utfindex(context.line_prefix, "utf-16"),
    language = context.filetype,
    version = context.changedtick,
    workspace_root = vim.uv.cwd(),
    model = self.model,
  }
  local handle = { cancelled = false }
  handle.process = vim.system({
    "curl",
    "--silent",
    "--show-error",
    "--fail-with-body",
    "--max-time",
    tostring(math.ceil(self.timeout_ms / 1000)),
    "--header",
    "content-type: application/json",
    "--data-binary",
    "@-",
    self.endpoint,
  }, { stdin = payload, text = true }, function(result)
    if handle.cancelled then
      return
    end
    if result.code ~= 0 then
      self.last_error = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
      callback { type = "error", error = self.last_error }
      return
    end
    local ok, response = pcall(vim.json.decode, result.stdout)
    if not ok or type(response.completion) ~= "string" then
      self.last_error = "invalid inline completion response"
      callback { type = "error", error = self.last_error }
      return
    end
    self.last_error = nil
    callback { type = "completed", text = response.completion }
  end)

  function handle.cancel()
    handle.cancelled = true
    if handle.process then
      handle.process:kill(15)
    end
  end

  return handle
end

function Cursor:warmup(callback)
  callback(true)
end

function Cursor:status(callback)
  local available = vim.fn.executable "curl" == 1
  local ready = available and not self.last_error
  callback {
    provider = "cursor",
    endpoint = self.endpoint,
    ready = ready,
    error = not available and "curl not found" or self.last_error,
    cli = { available = available, command = { "curl" } },
    transport = { running = ready, initialized = available },
    thread = {},
  }
end

local M = {}

function M.new(opts)
  local config = opts.cursor or {}
  return setmetatable({
    endpoint = config.endpoint or "http://127.0.0.1:8787/v1/inline-completions",
    timeout_ms = config.timeout_ms or 60000,
    model = config.model,
    last_error = nil,
  }, Cursor)
end

return M
