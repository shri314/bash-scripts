"----------------------------------------
" Neovim Configuration
"
" Author : Shriram V
" Email  : shri314@yahoo.com
"----------------------------------------

" Set up Vim compatibility
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Source Vim settings (this will load all plugins and settings)
source ~/.vimrc

"lua require('claude-code').setup()
set noautoread

" Clipboard friendly settings
"set clipboard=unnamed
set mouse=a

" Live substitution preview
set inccommand=nosplit

" Terminal mode improvements
autocmd TermOpen * setlocal nonumber norelativenumber
autocmd TermOpen * startinsert

" Terminal mode mappings
autocmd TermOpen * tnoremap <buffer> <Esc> <C-\><C-n>
autocmd TermOpen * tnoremap <buffer> <C-v><Esc> <Esc>

" vim: set shiftwidth=3:
