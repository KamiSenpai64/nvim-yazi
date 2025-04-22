# nvim-yazi

A Neovim plugin for seamless integration with the [Yazi](https://yazi-rs.github.io/) terminal file manager.

## Features

- Open Yazi file manager in a floating window from Neovim
- Select files in Yazi and open them in Neovim buffers
- Navigate between Neovim and Yazi with custom keybindings
- Support for custom configuration options
- Return to the exact location in Neovim after file selection
- File preview integration with Neovim buffers

## Requirements

- Neovim 0.7.0+
- [Yazi](https://yazi-rs.github.io/) installed and available in your PATH

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'yourusername/nvim-yazi',
  requires = { 'nvim-lua/plenary.nvim' }
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'yourusername/nvim-yazi',
  dependencies = { 'nvim-lua/plenary.nvim' }
}
```

## Configuration

Add to your Neovim configuration:

```lua
require('yazi').setup({
  -- Width of the Yazi window, can be an integer or a float between 0 and 1
  width = 0.8,
  
  -- Height of the Yazi window, can be an integer or a float between 0 and 1
  height = 0.8,
  
  -- Position of the Yazi window
  position = "center", -- "center", "top", "bottom", "left", "right"
  
  -- Border style for the floating window
  border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
  
  -- Transparency level of the floating window (0-100)
  transparency = 0,
  
  -- Default keymaps
  keymaps = {
    open = "<leader>y",        -- Open Yazi
    open_current = "<leader>Y", -- Open Yazi in current file directory
    quit = "q",                -- Quit Yazi and return to Neovim
    select = "<CR>"            -- Select file and open in Neovim
  },
  
  -- Set to true to automatically open selected file in Neovim
  auto_open_on_select = true,
  
  -- Events to trigger when interacting with Yazi
  -- Available events: "before_open", "after_open", "before_close", "after_close", "on_select"
  on_select = function(selected_file)
    -- Custom logic when a file is selected
  end
})
```

## Usage

- Use the configured keymap (default: `<leader>y`) to open Yazi in a floating window
- Navigate and select files in Yazi as usual
- Press Enter to select a file and open it in Neovim
- Press q to close Yazi and return to Neovim

## Commands

- `:Yazi` - Open Yazi in current working directory
- `:YaziCurrentFile` - Open Yazi in the directory of the current file
- `:YaziClose` - Close the Yazi window

## License

MIT# nvim-yazi
