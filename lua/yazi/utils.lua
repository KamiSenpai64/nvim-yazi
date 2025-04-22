-- Utility functions for Yazi plugin

local M = {}
local api = vim.api
local fn = vim.fn

-- Check if Yazi is installed
function M.check_yazi_installed()
  local is_installed = fn.executable("yazi")
  if is_installed == 0 then
    vim.notify(
      "Yazi is not installed or not found in PATH. Please install Yazi: https://yazi-rs.github.io/",
      vim.log.levels.ERROR
    )
    return false
  end
  return true
end

-- Get version information of Yazi
function M.get_yazi_version()
  local version = vim.fn.system("yazi --version")
  return version:match("yazi%s+([%d%.]+)")
end

-- Creates animation effect when opening/closing windows
function M.animate_window(win, start_opts, end_opts, duration)
  duration = duration or 10
  local steps = 10
  local step_time = duration / steps
  
  local function interpolate(start, end_val, progress)
    return start + ((end_val - start) * progress)
  end
  
  local timer = vim.loop.new_timer()
  
  timer:start(0, step_time, vim.schedule_wrap(function()
    local t = 0
    local step_timer = vim.loop.new_timer()
    
    step_timer:start(0, step_time, vim.schedule_wrap(function()
      t = t + 1
      local progress = t / steps
      
      if progress > 1 then
        progress = 1
        step_timer:stop()
        step_timer:close()
      end
      
      local current_opts = {}
      
      for k, v in pairs(start_opts) do
        if type(v) == "number" and end_opts[k] and type(end_opts[k]) == "number" then
          current_opts[k] = math.floor(interpolate(v, end_opts[k], progress))
        end
      end
      
      if api.nvim_win_is_valid(win) then
        api.nvim_win_set_config(win, current_opts)
      else
        step_timer:stop()
        step_timer:close()
      end
    end))
  end))
  
  return timer
end

-- Get dimensions for floating window
function M.get_centered_window_config(width_percentage, height_percentage, border)
  local ui = api.nvim_list_uis()[1]
  
  local width = math.floor(ui.width * width_percentage)
  local height = math.floor(ui.height * height_percentage)
  
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)
  
  return {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = border or "rounded"
  }
end

-- Detect if running in a GUI Neovim
function M.is_gui()
  return vim.g.gui or vim.g.neovide or vim.g.nvui or vim.g.gonvim or fn.exists("g:gui_running") == 1
end

-- Get the cursor position in the terminal buffer
function M.get_terminal_cursor()
  local current_pos = api.nvim_win_get_cursor(0)
  return current_pos[1], current_pos[2]
end

-- Safely close a buffer without side effects
function M.safe_close_buffer(buf)
  if buf and api.nvim_buf_is_valid(buf) then
    -- Save buffer options
    local buflisted = api.nvim_buf_get_option(buf, "buflisted")
    
    -- Set temporary options for clean deletion
    api.nvim_buf_set_option(buf, "buflisted", false)
    api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    
    -- Try to delete buffer
    local success, err = pcall(api.nvim_buf_delete, buf, { force = true })
    
    -- If failed, restore options
    if not success then
      vim.notify("Failed to close buffer: " .. err, vim.log.levels.DEBUG)
      api.nvim_buf_set_option(buf, "buflisted", buflisted)
    end
  end
end

return M