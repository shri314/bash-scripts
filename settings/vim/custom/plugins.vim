"----------------------------------------
" Plugin management functionality
"
" Author : Shriram V
" Email  : shri314@yahoo.com
"----------------------------------------

"----------------------------------------
" Plugin Loading Function
"----------------------------------------
" To get or keep plugins updated, please run ':VundleUpdate' on the vim command prompt regularly
function! s:PluginEIf(uri)
   let l:status_all = eval("$VundlePlugin__all")
   let l:status_plu = eval("$VundlePlugin__" .. substitute(a:uri, "[-/.]", "_", "g"))
   if l:status_all != "0" || l:status_plu != "0"
      "echo "Y Plugin a:uri" .. l:status_plu
      Plugin a:uri
   else
      "echo "N Plugin a:uri" .. l:status_plu
   endif
endfunction

command! -nargs=1 EPlugin call s:PluginEIf(<args>)

"----------------------------------------
" Vundle Configuration
"----------------------------------------
set runtimepath+=~/.vim/bundle/Vundle.vim "required for vundle

try
   filetype off                           "required for vundle
   call vundle#begin()                    "required for vundle

   Plugin 'VundleVim/Vundle.vim'
   EPlugin 'airblade/vim-gitgutter'
   EPlugin 'webdevel/tabulous'
   EPlugin 'shri314/vim-git-conflict-inspector'
   EPlugin 'junegunn/fzf'

finally
   call vundle#end()                      "required for vundle
   filetype plugin indent on              "required for vundle
endtry

filetype plugin on
runtime! ftplugin/man.vim

" vim: set shiftwidth=3:
