local M = {}

-- Config --
local default_config = {
  host = "localhost",
  port = "11434",
  model = "codellama:7b-code"
}
M.config = {}
for k, v in pairs(default_config) do M.config[k] = v end

M.setup = function(conf) for k, v in pairs(conf) do M.config[k] = v end end
-- Config --

-- Buffers
local res_buff = vim.api.nvim_create_buf(false, true)
local res_txt = ""

-- Check requirement
local function check_plugins()
  local ok, _ = pcall(require, "plenary")
  if not ok then
    print "[LlamaCopilot] You need to install the plenary.nvim plugin"
    return false
  end
  return true
end

-- Create floating window with buffer
local function create_window(buffer)
  -- Get new window size
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.5)
  local posX = math.floor((vim.o.columns - width) / 2)

  local opts = {
    relative = 'editor',
    row = 3,
    col = posX,
    width = width,
    height = height,
    border = "rounded",
  }

  local f_type = vim.bo.filetype
  vim.api.nvim_buf_set_option(buffer, 'filetype', f_type)

  M.float_win = vim.api.nvim_open_win(buffer, true, opts)
end


-- Add data response to res_buff
local function on_update(chunk, job)
  local _, body = pcall(function()
    return vim.json.decode(chunk)
  end)

  local res

  if (body == nil or body.response == nil) then
    res = ""
  else
    res = body.response
  end

  -- Check if window still open
  if (not M.float_win or not vim.api.nvim_win_is_valid(M.float_win)) and M.running then
    M.running = false
    io.popen("kill " .. job.pid)
    return
  end

  -- Add to buffer
  res_txt = res_txt .. res
  res_txt = res_txt:gsub("```", "")
  if (res_txt == "\n") then
    res_txt = ""
  end
  if (res_txt ~= "") then
    vim.api.nvim_buf_set_lines(res_buff, 0, -1, true, vim.split(res_txt, "\n"))
  end
end

-- Reset buffer
local function reset_buffer()
  res_txt = ""
  local default_text = "Loading ...\n\n"
      .. "----------\n"
      .. "Here is some information about the plugin:\n"
      .. "  - Exiting this window will stop the process\n"
      .. "  - In order to add the completed code, copy and paste it !"
  vim.api.nvim_buf_set_lines(res_buff, 0, -1, true, vim.split(default_text, "\n")) -- Clear
end

-- Ask ollama
local function request(prompt)
  reset_buffer()
  M.running = true

  local adress = "http://" .. M.config.host .. ":" .. M.config.port .. "/api/generate"
  require("plenary.curl").post(adress, {
    body = vim.json.encode({
      model = M.config.model,
      prompt = prompt,
      stream = true,
    }),
    stream = function(_, chunk, job)
      vim.schedule(function()
        if (M.running) then
          on_update(chunk, job)
        end
      end)
    end,
  })
end

-- Start code completion
local function generate_code()
  -- Get above code
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local lines_arr = vim.api.nvim_buf_get_lines(0, 0, line, false)

  local prompt = table.concat(lines_arr, "\n")

  create_window(res_buff)

  if (check_plugins()) then
    request(prompt)
  else
    vim.api.nvim_buf_set_lines(res_buff, 0, -1, true,
      vim.split("[LlamaCopilot] You need to install the plenary.nvim plugin", "\n")
    )
  end
end

vim.api.nvim_create_user_command("LlamaCopilot", generate_code, {})
check_plugins()

return M
