" nvim-yazi: Neovim plugin for Yazi file manager integration
" Maintainer: Your Name
" License: MIT

" Prevent loading the plugin twice
if exists('g:loaded_nvim_yazi')
  finish
endif
let g:loaded_nvim_yazi = 1

" Define commands
command! -nargs=0 Yazi lua require('yazi').open()
command! -nargs=0 YaziCurrentFile lua require('yazi').open_current_file()
command! -nargs=0 YaziClose lua require('yazi').close()

" Define health check
if exists(':checkhealth')
  command! -nargs=0 CheckHealthYazi lua require('yazi.health').check()
endif

" Set up Yazi with default config if the user hasn't called setup() yet
augroup NvimYazi
  autocmd!
  autocmd VimEnter * lua if not vim.g.nvim_yazi_setup_done then require('yazi').setup() vim.g.nvim_yazi_setup_done = true end
augroup END