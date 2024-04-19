local ok, utils = pcall(require, "utils")
if not ok then
  print "[LlamaCopilot] Loading error"
end
local M = {}

-- Config --
local default_config = {
  host = "localhost",
  port = "11434",
  model = "codellama:7b-code",
  max_completion_size = 15, -- use -1 for limitless
  debug = false,
}
M.config = {}
for k, v in pairs(default_config) do M.config[k] = v end

M.setup = function(conf) for k, v in pairs(conf) do M.config[k] = v end end
M.res_buff = vim.api.nvim_create_buf(false, true)
M.res_txt = ""
M.line = 0

utils.setup {
  debug = M.config.debug
}
local log_debug = utils.log_debug
local log = utils.log

-- Add data response to M.res_buff
local function on_update(chunk, job)
  local _, body = pcall(vim.json.decode, chunk)
  local res

  if (body == nil or body.response == nil) then
    res = ""
  else
    res = body.response
  end

  -- Check if window still open
  local status, err = pcall(function()
    vim.schedule(function()
      if (not M.float_win or not vim.api.nvim_win_is_valid(M.float_win)) and M.running then
        log_debug("Killing job for closed window")
        io.popen("kill " .. job.pid)
        M.running = false
        return
      end
    end)
  end)

  if not status then
    log_debug("Error while scheduling window cheking: " .. vim.inspect(err))
  end


  M.res_txt = M.res_txt .. res
  M.res_txt = M.res_txt:gsub("```", "")

  -- Check max line
  local line_count = #vim.split(M.res_txt, "\n")
  if (M.config.max_completion_size > 0 and M.config.max_completion_size <= line_count and M.running) then
    log_debug("Killing job for max_completion_size")
    io.popen("kill " .. job.pid)
    M.running = false
  end


  -- Add to buffer
  if (M.res_txt == "\n") then
    M.res_txt = ""
  end
  if (M.res_txt ~= "") then
    status, err = pcall(vim.schedule, function()
      utils.reduce_array(vim.split(M.res_txt, "\n"), M.config.max_completion_size)
      utils.append_to_buffer(M.res_buff, res)
    end)
    if not status then
      log_debug("Error while scheduling append_to_buffer: " .. vim.inspect(err))
    end
  end
end

-- Reset buffer
local function reset_buffer()
  M.res_txt = ""
  local status, err = pcall(vim.api.nvim_buf_set_lines, M.res_buff, 0, -1, true, {})
  if not status then
    log_debug("Error while reseting buffer: " .. vim.inspect(err))
  end
end

-- Ask ollama
local function request(prompt)
  reset_buffer()
  M.running = true

  local adress = "http://" .. M.config.host .. ":" .. M.config.port .. "/api/generate"
  local status, err = pcall(require("plenary.curl").post, adress, {
    body = vim.json.encode({
      model = M.config.model,
      prompt = prompt,
      stream = true,
    }),
    stream = function(_, chunk, job)
      if (M.running) then
        on_update(chunk, job)
      end
    end,
  })

  if not status then
    log_debug("Error while calling plenary.post function: " .. vim.inspect(err))
  end
end

-- Start code completion
local function generate_code()
  log_debug(":LlamaCopilotComplet command")
  -- Get above code
  M.line = vim.api.nvim_win_get_cursor(0)[1]
  local lines_arr = vim.api.nvim_buf_get_lines(0, 0, M.line, false)

  local prompt = table.concat(lines_arr, "\n")

  M.float_win = utils.create_compl_window(M.res_buff, M.config.max_completion_size)

  if (utils.check_plugins()) then
    request(prompt)
  else
    vim.api.nvim_buf_set_lines(M.res_buff, 0, -1, true,
      vim.split("[LlamaCopilot] You need to install the required plugins", "\n")
    )
    log("You need to install the required plugins")
  end
end

-- Accept code
local function accept_code()
  log_debug(":LlamaCopilotAccept command")

  -- Add M.res_buf content to current buffer
  if (M.float_win) then
    vim.api.nvim_win_close(M.float_win, true)
  end

  utils.append_to_buffe_line(0, M.res_txt, M.line)
end

vim.api.nvim_create_user_command("LlamaCopilotComplet", generate_code, {})
vim.api.nvim_create_user_command("LlamaCopilotAccept", accept_code, {})
utils.check_plugins()

return M
