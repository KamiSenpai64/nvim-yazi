local M = {}
local api = vim.api
local fn = vim.fn

-- Default configuration
local default_config = {
  width = 0.8,
  height = 0.8,
  position = "center",
  border = "rounded",
  transparency = 0,
  keymaps = {
    open = "<leader>y",
    open_current = "<leader>Y",
    quit = "q",
    select = "<CR>"
  },
  auto_open_on_select = true,
  on_select = function(selected_file)
    -- Default behavior is to open the file
    vim.cmd("edit " .. selected_file)
  end
}

-- Plugin state
local state = {
  buf = nil,
  win = nil,
  job_id = nil,
  last_dir = nil,
  initial_window = nil,
  temp_file = nil
}

-- Merge user config with defaults
M.config = default_config

function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
  
  -- Set up commands
  api.nvim_create_user_command("Yazi", function()
    M.open()
  end, {})
  
  api.nvim_create_user_command("YaziCurrentFile", function()
    M.open_current_file()
  end, {})
  
  api.nvim_create_user_command("YaziClose", function()
    M.close()
  end, {})
  
  -- Set up keymaps
  if M.config.keymaps.open then
    vim.keymap.set("n", M.config.keymaps.open, M.open, { noremap = true, silent = true })
  end
  
  if M.config.keymaps.open_current then
    vim.keymap.set("n", M.config.keymaps.open_current, M.open_current_file, { noremap = true, silent = true })
  end
end

-- Create a temporary file to store selected files from Yazi
local function create_temp_file()
  local temp_file = os.tmpname()
  state.temp_file = temp_file
  return temp_file
end

-- Create the floating window for Yazi
local function create_floating_window()
  -- Calculate window size and position
  local width, height
  local ui = api.nvim_list_uis()[1]
  
  if type(M.config.width) == "number" and M.config.width <= 1 and M.config.width > 0 then
    width = math.floor(ui.width * M.config.width)
  else
    width = M.config.width
  end
  
  if type(M.config.height) == "number" and M.config.height <= 1 and M.config.height > 0 then
    height = math.floor(ui.height * M.config.height)
  else
    height = M.config.height
  end
  
  -- Calculate position
  local row, col
  local position = M.config.position
  
  if position == "center" then
    row = math.floor((ui.height - height) / 2)
    col = math.floor((ui.width - width) / 2)
  elseif position == "top" then
    row = 0
    col = math.floor((ui.width - width) / 2)
  elseif position == "bottom" then
    row = ui.height - height
    col = math.floor((ui.width - width) / 2)
  elseif position == "left" then
    row = math.floor((ui.height - height) / 2)
    col = 0
  elseif position == "right" then
    row = math.floor((ui.height - height) / 2)
    col = ui.width - width
  end
  
  -- Create buffer
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  
  -- Window options
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = M.config.border
  }
  
  local win = api.nvim_open_win(buf, true, win_opts)
  
  -- Set window options
  api.nvim_win_set_option(win, "winblend", M.config.transparency)
  api.nvim_win_set_option(win, "winhighlight", "Normal:Normal,FloatBorder:FloatBorder")
  
  -- Store state
  state.buf = buf
  state.win = win
  state.initial_window = api.nvim_get_current_win()
  
  return buf, win
end

-- Open Yazi in a specific directory
local function open_in_directory(dir)
  -- Save current directory
  state.last_dir = dir or fn.getcwd()
  
  -- Create temp file and window
  local temp_file = create_temp_file()
  local buf, _ = create_floating_window()
  
  -- Prepare Yazi command with selection output
  local cmd = {"yazi", "--chooser-file", temp_file}
  
  if dir then
    table.insert(cmd, dir)
  end
  
  -- Start job
  state.job_id = fn.termopen(table.concat(cmd, " "), {
    on_exit = function(job_id, exit_code, _)
      if exit_code == 0 then
        -- Read selected file(s) from temp file
        local selected_file = nil
        local file = io.open(temp_file, "r")
        
        if file then
          selected_file = file:read("*line")
          file:close()
          os.remove(temp_file)
        end
        
        -- Close Yazi window
        M.close()
        
        -- Handle selected file if exists
        if selected_file and #selected_file > 0 then
          if type(M.config.on_select) == "function" then
            M.config.on_select(selected_file)
          elseif M.config.auto_open_on_select then
            vim.cmd("edit " .. selected_file)
          end
        end
      else
        M.close()
      end
    end
  })
  
  -- Set up buffer-local keymaps
  if M.config.keymaps.quit then
    vim.keymap.set("t", M.config.keymaps.quit, function()
      M.close()
    end, { buffer = buf, noremap = true, silent = true })
  end
end

-- Open Yazi in current working directory
function M.open()
  open_in_directory()
end

-- Open Yazi in the directory of the current file
function M.open_current_file()
  local current_file = api.nvim_buf_get_name(0)
  local dir = fn.fnamemodify(current_file, ":h")
  
  if #dir > 0 then
    open_in_directory(dir)
  else
    open_in_directory()
  end
end

-- Close Yazi window
function M.close()
  if state.job_id then
    fn.jobstop(state.job_id)
    state.job_id = nil
  end
  
  if state.win and api.nvim_win_is_valid(state.win) then
    api.nvim_win_close(state.win, true)
    state.win = nil
  end
  
  if state.buf and api.nvim_buf_is_valid(state.buf) then
    api.nvim_buf_delete(state.buf, { force = true })
    state.buf = nil
  end
  
  -- Return to initial window if it exists and is valid
  if state.initial_window and api.nvim_win_is_valid(state.initial_window) then
    api.nvim_set_current_win(state.initial_window)
  end
  
  -- Clean up temp file if it exists
  if state.temp_file and fn.filereadable(state.temp_file) == 1 then
    os.remove(state.temp_file)
    state.temp_file = nil
  end
end

return M