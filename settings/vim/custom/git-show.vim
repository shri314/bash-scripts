"----------------------------------------
" Git show command functionality
"
" Author : Shriram V
" Email  : shri314@yahoo.com
"----------------------------------------

"----------------------------------------
" Core Functions
"----------------------------------------
" Display git-show for hash under cursor in a new window
function! s:OpenGitShow(What)
   execute "vert new | 0r ! " .. expandcmd("git show '" .. a:What .. "' --")
   setl filetype=git
   setl nolist
   setl buftype=nofile noswapfile nomodifiable
endfunction

"----------------------------------------
" Exported Commands
"----------------------------------------
command! -nargs=1 OpenGitShow call s:OpenGitShow(<q-args>)

" vim: set shiftwidth=3:
