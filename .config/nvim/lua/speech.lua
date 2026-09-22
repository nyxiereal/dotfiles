local M = {}

local model = vim.fn.expand "~/.local/share/whisper/ggml-small.bin"
local vad_model = vim.fn.expand "~/.local/share/whisper/ggml-silero-v6.2.0.bin"
local state = { active = false, queue = {}, seen = {} }

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Speech to text" })
end

local function ready_chunks(files, recording)
  if recording then
    table.remove(files)
  end
  return files
end

M._ready_chunks = ready_chunks

local function finish()
  if state.active or state.recorder or state.transcribing or #state.queue > 0 then
    return
  end

  if state.timer then
    state.timer:stop()
    state.timer:close()
  end
  if state.dir then
    vim.fn.delete(state.dir, "rf")
  end

  state = { active = false, queue = {}, seen = {} }
  notify "Stopped"
end

local scan

local function transcribe_next()
  if state.transcribing or #state.queue == 0 then
    finish()
    return
  end

  if not vim.api.nvim_buf_is_valid(state.buf) then
    state.queue = {}
    if state.recorder then
      state.active = false
      state.recorder:kill(2)
    end
    finish()
    return
  end

  local chunk = table.remove(state.queue, 1)
  state.transcribing = true

  local line_count = vim.api.nvim_buf_line_count(state.buf)
  local context =
    table.concat(vim.api.nvim_buf_get_lines(state.buf, math.max(0, line_count - 5), line_count, false), " ")
  local command = {
    "whisper-cli",
    "-m",
    model,
    "-f",
    chunk,
    "-l",
    "auto",
    "-nt",
    "-np",
    "-sns",
    "--vad",
    "-vm",
    vad_model,
  }
  if context ~= "" then
    vim.list_extend(command, { "--prompt", context })
  end

  vim.system(command, { text = true }, function(result)
    vim.schedule(function()
      vim.fn.delete(chunk)
      state.transcribing = false

      if result.code ~= 0 then
        notify(vim.trim(result.stderr or "Transcription failed"), vim.log.levels.ERROR)
      elseif vim.api.nvim_buf_is_valid(state.buf) then
        local text = vim.trim(result.stdout or "")
        if text ~= "" then
          vim.api.nvim_buf_set_lines(state.buf, -1, -1, false, vim.split(text, "\n", { trimempty = true }))
        end
      end

      scan()
    end)
  end)
end

scan = function()
  if not state.dir then
    return
  end

  local files = vim.fn.glob(state.dir .. "/chunk-*.wav", false, true)
  table.sort(files)
  for _, file in ipairs(ready_chunks(files, state.recorder ~= nil)) do
    if not state.seen[file] then
      state.seen[file] = true
      table.insert(state.queue, file)
    end
  end

  transcribe_next()
end

local function start()
  if vim.fn.executable "ffmpeg" == 0 or vim.fn.executable "whisper-cli" == 0 then
    notify("Install ffmpeg and whisper-cpp", vim.log.levels.ERROR)
    return
  end
  if vim.uv.fs_stat(model) == nil or vim.uv.fs_stat(vad_model) == nil then
    notify("Missing model in ~/.local/share/whisper", vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable "pactl" == 1 then
    local mute = vim.system({ "pactl", "get-source-mute", "@DEFAULT_SOURCE@" }, { text = true }):wait()
    if mute.stdout and mute.stdout:match "yes" then
      notify("Microphone is muted", vim.log.levels.WARN)
      return
    end
  end
  if not vim.bo.modifiable then
    notify("Current buffer is not editable", vim.log.levels.ERROR)
    return
  end

  state.active = true
  state.buf = vim.api.nvim_get_current_buf()
  state.dir = vim.fn.tempname()
  vim.fn.mkdir(state.dir, "p")

  local command = {
    "ffmpeg",
    "-nostdin",
    "-hide_banner",
    "-loglevel",
    "error",
    "-f",
    "pulse",
    "-i",
    "default",
    "-ac",
    "1",
    "-ar",
    "16000",
    "-c:a",
    "pcm_s16le",
    "-f",
    "segment",
    "-segment_time",
    "5",
    "-reset_timestamps",
    "1",
    state.dir .. "/chunk-%06d.wav",
  }

  state.recorder = vim.system(command, { text = true }, function(result)
    vim.schedule(function()
      local stopped = not state.active
      state.active = false
      state.recorder = nil
      if not stopped and result.code ~= 0 then
        notify(vim.trim(result.stderr or "Recording failed"), vim.log.levels.ERROR)
      end
      scan()
    end)
  end)

  state.timer = vim.uv.new_timer()
  state.timer:start(1000, 1000, vim.schedule_wrap(scan))
  notify "Recording into this buffer"
end

function M.toggle()
  if state.active then
    state.active = false
    state.recorder:kill(2)
    notify "Stopping after the final transcription…"
  elseif state.dir then
    notify "Still transcribing…"
  else
    start()
  end
end

return M
