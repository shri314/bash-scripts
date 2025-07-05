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
   vert new
   let git_output = system('git show ' . shellescape(a:What) . ' --')
   call setline(1, split(git_output, '\n'))
   setl filetype=git
   setl nolist
   setl buftype=nofile noswapfile nomodifiable
endfunction

"----------------------------------------
" Exported Commands
"----------------------------------------
command! -nargs=1 OpenGitShow call s:OpenGitShow(<q-args>)

" vim: set shiftwidth=3:
