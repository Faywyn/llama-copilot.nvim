local utils = {}
utils.setup = function(conf) for k, v in pairs(conf) do utils[k] = v end end

-- Log function
local function log(str)
  print("[LlamaCopilot] " .. str)
end
utils.log = log

-- Log function for debug
local function log_debug(str)
  if utils.debug then
    print("[LlamaCopilot Debug] " .. str)
  end
end
utils.log_debug = log_debug

-- Check require plugins
local require_plugins = { "plenary" }
local function check_plugins()
  log_debug("Checking required plugins ...")
  local valid = true
  for _, v in pairs(require_plugins) do
    local ok, _ = pcall(require, v)
    if not ok then
      log("You need to install " .. v .. " plugin")
      valid = false
    end
  end
  return valid
end
utils.check_plugins = check_plugins

-- Create floating window with buffer
local function create_compl_window(buffer, height_)
  -- Get new window size
  local posX = -vim.api.nvim_win_get_cursor(0)[2]
  local width = vim.o.columns
  local height

  if (height_ == -1) then height = math.floor(vim.o.lines * 0.5) else height = height_ end

  local opts = {
    relative = 'cursor',
    row = 1,
    col = posX,
    width = width,
    height = height,
    border = "single",
  }

  log_debug("Creating window opt: " .. vim.inspect(opts))
  local f_type = vim.bo.filetype
  local status, err = pcall(vim.api.nvim_buf_set_option, buffer, 'filetype', f_type)
  if not status then
    utils.log_debug("Error while creating window " .. vim.inspect(err))
  end

  return vim.api.nvim_open_win(buffer, true, opts)
end
utils.create_compl_window = create_compl_window

-- Reduce array size
local function reduce_array(arr, length)
  if (length == -1 or #arr <= length) then
    return arr
  else
    while #arr > length do
      table.remove(arr)
    end
    return table
  end
end
utils.reduce_array = reduce_array

-- Append to buffer
local function append_to_buffer(buf, str)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local last_line = lines[#lines]
  local new_lines = vim.split(str, "\n")

  local status, err = pcall(vim.api.nvim_buf_set_text, buf, #lines - 1, #last_line, #lines - 1, #last_line, new_lines)
  if not status then
    log_debug("Error while appending to buffer: " .. vim.inspect(err))
  end
end
utils.append_to_buffer = append_to_buffer

-- Append to buffer line
local function append_to_buffe_line(buf, str, line)
  local new_lines = vim.split(str, "\n")

  local status, err = pcall(vim.api.nvim_buf_set_text, buf, line, 0, line, 0, new_lines)
  if not status then
    log_debug("Error while appending to buffer at line (" .. line .. "): " .. vim.inspect(err))
  end
end
utils.append_to_buffe_line = append_to_buffe_line

return utils
