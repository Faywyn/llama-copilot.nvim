require("utils")

local M = {}

-- Config --
local default_config = {
  host = "localhost",
  port = "11434",
  model = "codellama:7b-code",
  max_completion_size = -1 -- use -1 for limitless
}
M.config = {}
for k, v in pairs(default_config) do M.config[k] = v end

M.setup = function(conf) for k, v in pairs(conf) do M.config[k] = v end end
M.res_buff = vim.api.nvim_create_buf(false, true)
M.res_txt = ""
M.line = 0


-- Add data response to M.res_buff
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
  vim.schedule(function()
    if (not M.float_win or not vim.api.nvim_win_is_valid(M.float_win)) and M.running then
      M.running = false
      io.popen("kill " .. job.pid)
      return
    end
  end)

  M.res_txt = M.res_txt .. res
  M.res_txt = M.res_txt:gsub("```", "")

  -- Check max line
  local line_count = #vim.split(M.res_txt, "\n")
  if (M.config.max_completion_size > 0 and M.config.max_completion_size <= line_count and M.running) then
    M.running = false
    io.popen("kill " .. job.pid)
  end


  -- Add to buffer
  if (M.res_txt == "\n") then
    M.res_txt = ""
  end
  if (M.res_txt ~= "") then
    vim.schedule(function()
      Reduce_Array(vim.split(M.res_txt, "\n"), M.config.max_completion_size)
      Append_to_buffer(M.res_buff, res)
    end)
  end
end

-- Reset buffer
local function reset_buffer()
  M.res_txt = ""
  vim.api.nvim_buf_set_lines(M.res_buff, 0, -1, true, {})
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
      if (M.running) then
        on_update(chunk, job)
      end
    end,
  })
end

-- Start code completion
local function generate_code()
  -- Get above code
  M.line = vim.api.nvim_win_get_cursor(0)[1]
  local lines_arr = vim.api.nvim_buf_get_lines(0, 0, M.line, false)

  local prompt = table.concat(lines_arr, "\n")

  M.float_win = Create_Compl_Window(M.res_buff, M.config.max_completion_size)

  if (Check_Plugins()) then
    request(prompt)
  else
    vim.api.nvim_buf_set_lines(M.res_buff, 0, -1, true,
      vim.split("[LlamaCopilot] You need to install the plenary.nvim plugin", "\n")
    )
  end
end

-- Accept code
local function accept_code()
  -- Add M.res_buf content to current buffer

  if (M.float_win) then
    vim.api.nvim_win_close(M.float_win, true)
  end

  Append_to_buffe_line(0, M.res_txt, M.line)
end

vim.api.nvim_create_user_command("LlamaCopilotComplet", generate_code, {})
vim.api.nvim_create_user_command("LlamaCopilotAccept", accept_code, {})
Check_Plugins()

return M
