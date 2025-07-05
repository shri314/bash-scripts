"----------------------------------------
" Tmux window integration for Vim
"
" Author : Shriram V
" Email  : shri314@yahoo.com
"----------------------------------------

"----------------------------------------
" Core Functions
"----------------------------------------
function! s:TmuxSwitchPane(direction)
   if a:direction == "h"
      let l:tmux_cmd = 'if-shell "test #{pane_at_left}   -eq 0" "select-pane -L"'
   elseif a:direction == "j"
      let l:tmux_cmd = 'if-shell "test #{pane_at_bottom} -eq 0" "select-pane -D"'
   elseif a:direction == "k"
      let l:tmux_cmd = 'if-shell "test #{pane_at_top}    -eq 0" "select-pane -U"'
   elseif a:direction == "l"
      let l:tmux_cmd = 'if-shell "test #{pane_at_right}  -eq 0" "select-pane -R"'
   else
      return
   endif

   if winnr("1" .. a:direction) == winnr()
      if $TMUX != "" && !has("gui_running")
         if trim(system("tmux display-message -p '#{window_zoomed_flag}'")) == "0"
            silent call system("tmux " .. l:tmux_cmd)
         endif
      endif
   else
      call win_gotoid(win_getid(winnr("1" .. a:direction)))
   endif
endfunction

"----------------------------------------
" Key Mappings
"----------------------------------------
" Make default vim window navigation keys work seamlessly across tmux
nmap <silent> <C-w><Left>  :call <SID>TmuxSwitchPane("h")<CR>
nmap <silent> <C-w><Down>  :call <SID>TmuxSwitchPane("j")<CR>
nmap <silent> <C-w><Up>    :call <SID>TmuxSwitchPane("k")<CR>
nmap <silent> <C-w><Right> :call <SID>TmuxSwitchPane("l")<CR>
nmap <silent> <C-w>h       :call <SID>TmuxSwitchPane("h")<CR>
nmap <silent> <C-w>j       :call <SID>TmuxSwitchPane("j")<CR>
nmap <silent> <C-w>k       :call <SID>TmuxSwitchPane("k")<CR>
nmap <silent> <C-w>l       :call <SID>TmuxSwitchPane("l")<CR>

" vim: set shiftwidth=3:
