local M = {}

local health_start = vim.fn["health#report_start"]
local health_ok = vim.fn["health#report_ok"]
local health_warn = vim.fn["health#report_warn"]
local health_error = vim.fn["health#report_error"]

local utils = require("yazi.utils")

function M.check()
  health_start("nvim-yazi health check")
  
  -- Check Neovim version
  local nvim_version = vim.version()
  local nvim_version_str = string.format("%d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch)
  
  if nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 7) then
    health_ok("Neovim version: " .. nvim_version_str)
  else
    health_error("Neovim version: " .. nvim_version_str .. ". Minimum required version is 0.7.0")
  end
  
  -- Check if Yazi is installed
  if vim.fn.executable("yazi") == 1 then
    local version = utils.get_yazi_version()
    if version then
      health_ok("Yazi installed, version: " .. version)
    else
      health_ok("Yazi is installed, but could not determine version")
    end
  else
    health_error(
      "Yazi is not installed or not found in PATH. Please install Yazi: https://yazi-rs.github.io/",
      { "Install Yazi and make sure it's in your PATH" }
    )
  end
  
  -- Check for recommended plugins
  if vim.fn.exists("g:loaded_plenary") == 1 then
    health_ok("Found plenary.nvim")
  else
    health_warn("Could not find plenary.nvim", {
      "While not required, plenary.nvim is recommended for better functionality",
      "Install with your plugin manager, e.g.: use {'nvim-lua/plenary.nvim'}"
    })
  end
end

return M