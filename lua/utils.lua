-- Check require plugins
local require_plugins = { "plenary" }
function Check_Plugins()
  local valid = true
  for _, v in pairs(require_plugins) do
    local ok, _ = pcall(require, v)
    if not ok then
      print("[LlamaCopilot] You need to install " .. v .. " plugin")
      valid = false
    end
  end
  return valid
end

-- Create floating window with buffer
function Create_Compl_Window(buffer, height_)
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

  local f_type = vim.bo.filetype
  vim.api.nvim_buf_set_option(buffer, 'filetype', f_type)

  return vim.api.nvim_open_win(buffer, true, opts)
end

-- Reduce array size
function Reduce_Array(arr, length)
  if (length == -1 or #arr <= length) then
    return arr
  else
    while #arr > length do
      table.remove(arr)
    end
    return table
  end
end

-- Append to buffer
function Append_to_buffer(buf, str)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local last_line = lines[#lines]
  local new_lines = vim.split(str, "\n")

  vim.api.nvim_buf_set_text(buf, #lines - 1, #last_line, #lines - 1, #last_line, new_lines)
end

-- Append to buffer line
function Append_to_buffe_line(buf, str, line)
  local new_lines = vim.split(str, "\n")

  vim.api.nvim_buf_set_text(buf, line, 0, line, 0, new_lines)
end
