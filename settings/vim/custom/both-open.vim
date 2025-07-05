"----------------------------------------
" Open both .hpp and .cpp files side by side
"
" Author : Shriram V
" Email  : shri314@yahoo.com
"----------------------------------------

"----------------------------------------
" Core Functions
"----------------------------------------
function! s:Both()
   if expand('%:e') == 'hpp'
      let l:cur_winid = win_getid(winnr())
      let l:old_splitright = &splitright
      try
         let &splitright = 1
         vsp %:r.cpp
      finally
         let &splitright = l:old_splitright
         call win_gotoid(l:cur_winid)
      endtry
   elseif expand('%:e') == 'cpp'
      let l:cur_winid = win_getid(winnr())
      let l:old_splitright = &splitright
      try
         let &splitright = 0
         vsp %:r.hpp
      finally
         let &splitright = l:old_splitright
         call win_gotoid(l:cur_winid)
      endtry
   endif
endfunction

"----------------------------------------
" Exported Commands
"----------------------------------------
command! -nargs=0 Both call s:Both()

" vim: set shiftwidth=3:
