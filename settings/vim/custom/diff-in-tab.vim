"----------------------------------------
" Open diffs in new tab
"
" Author : Shriram V
" Email  : shri314@yahoo.com
"----------------------------------------

"----------------------------------------
" Core Functions
"----------------------------------------
" Delete empty buffers (utility function for diff)
function! s:DeleteEmptyBuffers()
   let [l:i, l:n; l:empty] = [1, bufnr('$')]
   while l:i <= l:n
      if bufexists(l:i) && bufname(l:i) == ''
         call add(l:empty, l:i)
      endif
      let l:i += 1
   endwhile

   if len(l:empty) > 0
      silent! execute 'bdelete' join(l:empty)
   endif
endfunction

" Show diff between multiple files in new tab
function! s:DiffInNewTab(file1, ...)
   let l:cmd = 'tabnew ' .. a:file1
   let l:sep = '|vert botright diffsp '
   for l:file in a:000
      let l:cmd ..= l:sep .. l:file
   endfor
   execute l:cmd
   wincmd =
   tabdo call s:DeleteEmptyBuffers()
endfunction

"----------------------------------------
" Exported Commands
"----------------------------------------
command! -nargs=+ -complete=file DiffInNewTab call s:DiffInNewTab(<f-args>)

" vim: set shiftwidth=3:
