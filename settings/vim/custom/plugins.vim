"----------------------------------------
" Plugin management functionality
"
" Author : Shriram V
" Email  : shri314@yahoo.com
"----------------------------------------

"----------------------------------------
" Plugin Loading Environ Control Function
"----------------------------------------
" To get or keep plugins updated, please run ':PlugUpdate' on the vim command prompt regularly
function! s:PlugEIf(uri)
   let l:verbose = eval("$VimPlug__verbose")
   let l:status_all = eval("$VimPlug__all")
   let l:status_plu = eval("$VimPlug__" .. substitute(a:uri, "[-/.]", "_", "g"))
   if l:status_all != "0" || l:status_plu != "0"
      if l:verbose == "1" | echo "Y Plugin " .. a:uri .. " : " .. l:status_plu | endif
      Plug a:uri
   else
      if l:verbose == "1" | echo "N Plugin " .. a:uri .. " : " .. l:status_plu | endif
   endif
endfunction

command! -nargs=1 EPlug call s:PlugEIf(<args>)

"----------------------------------------
" vim-plug Configuration
"----------------------------------------
source ~/.vim/autoload/vim-plug/plug.vim
try
   call plug#begin('~/.vim/plugged')

   EPlug 'airblade/vim-gitgutter'
   EPlug 'webdevel/tabulous'
   EPlug 'shri314/vim-git-conflict-inspector'
   EPlug 'junegunn/fzf'
   EPlug 'octol/vim-cpp-enhanced-highlight'

finally
   call plug#end()
endtry

filetype plugin on
filetype plugin indent on
runtime! ftplugin/man.vim

" vim: set shiftwidth=3:
