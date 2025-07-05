"----------------------------------------
" Quickfix window management
"
" Author : Shriram V
" Email  : shri314@yahoo.com
"----------------------------------------

"----------------------------------------
" State Variables
"----------------------------------------
let g:ErrTog=0

"----------------------------------------
" Core Functions
"----------------------------------------
function! s:QfixOpen()
   cclose
   top copen 5
   setl wrap
   normal gg
   call search('error:', 'cW')
   let g:ErrTog=1
endfunction

" Run command and populate quickfix window with results
function! s:QfixRun(cmd)
   cexpr system(a:cmd)
   call s:QfixOpen()
endfunction

" Toggle quickfix window open/closed
function! s:QfixToggle()
   if g:ErrTog == 0
      call s:QfixOpen()
   else
      cclose
      let g:ErrTog=0
   endif
endfunction

"----------------------------------------
" Exported Commands
"----------------------------------------
command! -nargs=+ -complete=shellcmd QfixRun call s:QfixRun(<q-args>)
command! -nargs=0 QfixToggle call s:QfixToggle()

" vim: set shiftwidth=3:
