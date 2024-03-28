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
local function on_update(_, data)
  -- Check if window still open
  if not M.float_win or not vim.api.nvim_win_is_valid(M.float_win) then
    if M.jobid then vim.fn.jobstop(M.jobid) end
  end

  -- Get response data and add to buffer
  if (data[1] ~= "") then
    local res = vim.json.decode(data[1]).response
    if (res == nil) then
      res = ""
    end
    res_txt = res_txt .. res
    if (res_txt == "\n") then
      res_txt = ""
    end
    if (res_txt ~= "") then
      res_txt = res_txt:gsub("```", "")
      vim.api.nvim_buf_set_lines(res_buff, 0, -1, true, vim.split(res_txt, "\n"))
    end
  end
end

-- Ask llm with prompt
local function request(prompt)
  local cmd = "curl --silent --no-buffer -X POST http://"
      .. M.config.host .. ":" .. M.config.port .. "/api/generate -d "
      .. "'{\"model\": \"" .. M.config.model
      .. "\",\"prompt\":\"" .. prompt .. "\",\"stream\": true}'"


  res_txt = ""
  vim.api.nvim_buf_set_lines(res_buff, 0, -1, true, {}) -- Clear
  M.jobid = vim.fn.jobstart(cmd, { on_stdout = on_update })
end

-- Start code completion
local function generate_code()
  -- Get above code
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local lines_arr = vim.api.nvim_buf_get_lines(0, 0, line, false)

  local prompt = table.concat(lines_arr, "\n")
      :gsub("\"", "\\\"")
      :gsub("\n", "\\n")
      :gsub("\t", "\\t")

  create_window(res_buff)
  request(prompt)
end

vim.api.nvim_create_user_command("LlamaCopilot", generate_code, {})

return M
