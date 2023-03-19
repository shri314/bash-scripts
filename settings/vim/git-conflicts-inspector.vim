" .vimrc file
"
" Author   : Shriram V
" Email    : shri314@yahoo.com
"
" Vim Conflits Naviator


function! ConflictsNavigate(BackwardSearch, AcceptMatchCurPos, WrapAround)
   let srchFlags = ""
   if a:BackwardSearch    is v:true  | let srchFlags .= "b" | endif
   if a:AcceptMatchCurPos is v:true  | let srchFlags .= "c" | endif
   if a:WrapAround        is v:true  | let srchFlags .= "w" | endif
   if a:WrapAround        is v:false | let srchFlags .= "W" | endif
   let ret = search('^[<]\{7\}', l:srchFlags)
   if ret > 0
      normal m'z.`'
   endif
   return ret
endfunction


function! ConflictsGetInfo()
   let cp = line('.')
   let re = search("^[>]\\{7\\}", "cWn")
   if(cp > re)
      return v:null
   endif

   let lb = search("^[<]\\{7\\}", "cWnb")
   if(cp < lb)
      return v:null
   endif

   call cursor(lb, 0)
   let re_intervening = search("^[>]\\{7\\}", "cWn")
   if(re_intervening != re)
      return v:null
   endif
   let le = search("^[|]\\{7\\}", "Wn")
   let rb = search("^[=]\\{7\\}", "Wn")
   call cursor(cp, 0)

   let mb = le
   let me = rb

   if le == 0 | let le = rb | endif

   if lb != 0 && rb != 0 && re != 0
      let ret = {}
      if v:true  | let ret['left']   = {'first': lb, 'last': le} | endif
      if mb != 0 | let ret['parent'] = {'first': mb, 'last': me} | endif
      if v:true  | let ret['right']  = {'first': rb, 'last': re} | endif
      return ret
   else
      return v:null
   endif
endfunction


let g:DiffWin=0
function! ConflictsDiff3Switch()
   let l:nr=winnr()
   if g:DiffWin == 0
      wincmd h
      wincmd h
      wincmd h | if &diff == 1 | set diff! | endif
      wincmd l | if &diff == 0 | set diff! | endif
      wincmd l | if &diff == 0 | set diff! | endif
      let g:DiffWin = 1
      echo "011"
   elseif g:DiffWin == 1
      wincmd h
      wincmd h
      wincmd h | if &diff == 0 | set diff! | endif
      wincmd l | if &diff == 0 | set diff! | endif
      wincmd l | if &diff == 1 | set diff! | endif
      let g:DiffWin = 2
      echo "110"
   elseif g:DiffWin == 2
      wincmd h
      wincmd h
      wincmd h | if &diff == 0 | set diff! | endif
      wincmd l | if &diff == 1 | set diff! | endif
      wincmd l | if &diff == 0 | set diff! | endif
      let g:DiffWin = 3
      echo "101"
   elseif g:DiffWin == 3
      wincmd h
      wincmd h
      wincmd h | if &diff == 0 | set diff! | endif
      wincmd l | if &diff == 0 | set diff! | endif
      wincmd l | if &diff == 0 | set diff! | endif
      let g:DiffWin = 0
      echo "111"
   endif
   execute l:nr .. "wincmd w"
endfunction


function! ConflictsInspect()
   if v:version < 801
      echohl ErrorMsg | :echo "This functionality requires Vim 8.1..." | :echohl None
      return
   endif

   let markers = ConflictsGetInfo()
   if markers is v:null
      call ConflictsNavigate(v:false, v:false, v:true)
      let markers1 = ConflictsGetInfo()
      if markers1 is v:null
         echohl ErrorMsg | echo "No conflicts found in the entire buffer" | echohl None
      else
         echohl WarningMsg | echo "Moved to next conflict" | echohl None
      endif
      return
   endif

   let done = 0
   try
      let textL = getbufline(bufnr("%"), markers["left"]["first"],   markers["left"]["last"])
      if has_key(markers, 'parent')
         let textP = getbufline(bufnr("%"), markers["parent"]["first"], markers["parent"]["last"])
      else
         let textP = v:null
      endif
      let textR = getbufline(bufnr("%"), markers["right"]["first"],  markers["right"]["last"])

      if bufnr('CVLeft')   > 0 | silent! bdelete! CVLeft   | endif
      if bufnr('CVParent') > 0 | silent! bdelete! CVParent | endif
      if bufnr('CVRight')  > 0 | silent! bdelete! CVRight  | endif

      tab new
      setl buftype=nofile noswapfile modifiable
      call setbufline(bufnr("%"), 1, textL)
      let g:CVLeft = textL[0]
      silent! file! CVLeft
      setl statusline=%!g:CVLeft
      :1d _
      :$d _
      :0
      let b:old_undolevels = &undolevels
      setl undolevels=-1
      exe "normal a \<BS>\<Esc>"
      let &undolevels = b:old_undolevels
      setl nomodifiable number
      diffthis
      map <buffer> ?? :call ConflictsDiff3Switch()<CR>

      if textP isnot v:null
         vertical rightbelow new
         setl buftype=nofile noswapfile modifiable
         let g:CVParent = textP[0]
         silent! file! CVParent
         setl statusline=%!g:CVParent
         let r = setbufline(bufnr('CVParent'), 1, textP)
         :1d _
         :$d _
         :0
         let b:old_undolevels = &undolevels
         setl undolevels=-1
         exe "normal a \<BS>\<Esc>"
         let &undolevels = b:old_undolevels
         setl nomodifiable number
         diffthis
         map <buffer> ?? :call ConflictsDiff3Switch()<CR>
      endif

      vertical rightbelow new
      setl buftype=nofile noswapfile modifiable
      silent! file! CVRight
      let g:CVRight = textR[-1]
      setl statusline=%!g:CVRight
      let r = setbufline(bufnr('CVRight'), 1, textR)
      :1d _
      :$d _
      :0
      let b:old_undolevels = &undolevels
      setl undolevels=-1
      exe "normal a \<BS>\<Esc>"
      let &undolevels = b:old_undolevels
      setl nomodifiable number
      diffthis
      map <buffer> ?? :call ConflictsDiff3Switch()<CR>
      wincmd =
      done = 1
   catch
      "if bufnr('CVLeft')   > 0 | silent! bdelete! CVLeft   | endif
      "if bufnr('CVParent') > 0 | silent! bdelete! CVParent | endif
      "if bufnr('CVRight')  > 0 | silent! bdelete! CVRight  | endif
      echo v:errmsg
   finally
       if done | echo 'conflict diff is ready in the tab...' | sleep 1 | endif
       let g:DiffWin = 0
   endtry
endfunction


function! ConflictsPickLeft()
   if v:version < 801
      echohl ErrorMsg | :echo "This functionality requires Vim 8.1..." | :echohl None
      return
   endif

   let markers = ConflictsGetInfo()
   if markers is v:null
      echohl ErrorMsg | echo "No conflict under the cursor..." | echohl None
      return
   endif

   execute markers["left"]["last"] . "," . markers["right"]["last"] . "d _"
   execute markers["left"]["first"] . "d _"
endfunction


function! ConflictsPickRight()
   if v:version < 801
      echohl ErrorMsg | :echo "This functionality requires Vim 8.1..." | :echohl None
      return
   endif

   let markers = ConflictsGetInfo()
   if markers is v:null
      echohl ErrorMsg | echo "No conflict under the cursor..." | echohl None
      return
   endif

   execute markers["right"]["last"] . "d _"
   execute markers["left"]["first"] . "," . markers["right"]["first"] . "d _"
endfunction
