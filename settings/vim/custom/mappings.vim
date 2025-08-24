"----------------------------------------
" Custom Key Mappings
"
" Author : Shriram V
" Email  : shri314@yahoo.com
"----------------------------------------

"----------------------------------------
" Functions required for mappings
"----------------------------------------
function! s:ToggleSwitchBuffer()
   if index(split(&switchbuf, ','), "split") == -1
      set switchbuf+=split
   else
      set switchbuf-=split
   endif
   echo 'switchbuf ='&switchbuf
endfunction

command! -nargs=0 ToggleSwitchBuffer call s:ToggleSwitchBuffer()

" Display help for supported <F12><keys>
function! s:F12Help()
   echo "F12 - show F12 help\n"
   echo "h   - toggle wordhighlight\n"
   echo "i   - toggle paste\n"
   echo "l   - toggle list\n"
   echo "n   - toggle number\n"
   echo "q   - toggle quickfix\n"
   echo "g   - toggle GitGutterSignsToggle\n"
   echo "u   - toggle GitGutterLineHighlights\n"
   echo "s   - toggle switchbuf\n"
   echo "d   - display git-show for hash under cursor\n"
endfunction

function! s:EnhanceMapping(mode_cmd, mapping, enhancement)
   let current = maparg(a:mapping, 'n', 0, 1)
   if !empty(current)
      execute a:mode_cmd . ' <buffer> ' . a:mapping . ' ' . current.rhs . a:enhancement
   endif
endfunction

augroup EnhanceMappings
   autocmd!
   autocmd VimEnter * call s:EnhanceMapping('nmap', ']c', 'zz')
   autocmd VimEnter * call s:EnhanceMapping('nmap', '[c', 'zz')
augroup END

"----------------------------------------
" Actual Mappings
"----------------------------------------
" use :qa to close all windows individually with q
cnoreabbrev <expr> qa getcmdtype() == ':' && getcmdline() == 'qa' ? 'windo q' : 'qa'

" use :xa to save and close all windows individually with x
cnoreabbrev <expr> xa getcmdtype() == ':' && getcmdline() == 'xa' ? 'windo x' : 'xa'

" wildmenu customizations
cnoremap <expr> <Down> wildmenumode() ? "\<C-n>" : "\<Down>"
cnoremap <expr> <Up> wildmenumode() ? "\<C-p>" : "\<Up>"
cnoremap <expr> <Right> wildmenumode() ? "\<C-y>" : "\<Right>"
cnoremap <expr> <CR> wildmenumode() ? "\<C-y>" : "\<CR>"
cnoremap <expr> <Left> wildmenumode() ? "\<C-e>" : "\<Left>"
cnoremap <expr> <Esc> wildmenumode() ? "\<C-e>" : "\<Esc>"

" always keep the next word to be found at the center of the screen
nmap n nzz
nmap N Nzz

"https://stackoverflow.com/questions/23695727/vim-highlight-a-word-with-without-moving-cursor
nnoremap * *``
nnoremap # #``

" Window size
map - <C-W>-
map = <C-W>+
map _ <C-W><
map + <C-W>>

map <F5>  :diffupdate<CR>:syntax sync fromstart<CR>:GitGutter<CR>:nohl<CR>
map <F8>   :cn<CR>m'z.`'
map <F7>   :cp<CR>m'z.`'

"F12<key> to apply special properties
map <F12><F12> :call <SID>F12Help()<CR>
map <F12>n :setl number!<CR>:echo 'number ='&number<CR>
map <F12>i :setl paste!<CR>:echo 'paste ='&paste<CR>
map <F12>l :setl list!<CR>:echo 'list ='&list<CR>
map <F12>s :ToggleSwitchBuffer<CR>
map <F12>q :QfixToggle<CR>:<BS><C-L>
map <F12>g :GitGutterSignsToggle<CR>
map <F12>u :GitGutterLineHighlightsToggle<CR>
map <F12>d :OpenGitShow <C-R>=expand('<cword>')<CR><CR>
map <F12>D :OpenGitShow origin/main:<C-R>=expand('<cfile>')<CR>

" vim: set shiftwidth=3:
