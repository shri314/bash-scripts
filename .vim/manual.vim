" 
" Vim filetype plugin file
" Language:   man
" Maintainer:   Nam SungHyun <namsh@kldp.org>
" Modified by Shriram V to suit the requirements
"
" To make the ":Man" command available before editing a manual page, source
" this script from your startup vimrc file.

" If 'filetype' isn't "man", we must have been called to only define ":Man".
if &filetype == "man"

  " Only do this when not done yet for this buffer
  if exists("b:did_ftplugin")
    finish
  endif
  let b:did_ftplugin = 1

  " allow dot in manual page name.
  setlocal iskeyword+=\.

endif

if exists(":Man") != 2
  com -nargs=1 Man call s:GetPage(<f-args>)
  nmap K :call <SID>PreGetPage(0)<CR>
  nmap  :call <SID>PopPage()<CR>
endif

" Define functions only once.
if !exists("s:man_tag_depth")

let s:man_tag_depth = 0

if $OSTYPE =~ "solaris"
  let s:man_sect_arg = "-s"
  let s:man_find_arg = "-l"
else
  let s:man_sect_arg = ""
  let s:man_find_arg = "-w"
endif

func <SID>PreGetPage(cnt)
  if a:cnt == 0
    let old_isk = &iskeyword
    setl iskeyword+=(,)
    let str = expand("<cword>")
    let &iskeyword = old_isk
    let page = substitute(str, '(*\(\k\+\).*', '\1', '')
    let sect = substitute(str, '\(\k\+\)(\([^()]*\)).*', '\2', '')
    if match(sect, '^[0-9 ]\+$') == -1
      let sect = ""
    endif
    if sect == page
      let sect = ""
    endif
  else
    let sect = a:cnt
    let page = expand("<cword>")
  endif
  call s:GetPage(sect, page)
endfunc

func <SID>GetCmdArg(sect, page)
  if a:sect == ''
    return "-a -S2:3:1:8:5:4:6:7:9 ".a:page
  endif
  return "-a -S2:3:1:8:5:4:6:7:9 ".s:man_sect_arg.' '.a:sect.' '.a:page
endfunc

func <SID>FindPage(sect, page)
  let where = system("/usr/bin/man ".s:man_find_arg.' '.s:GetCmdArg(a:sect, a:page)." | sed 's,[/]\\([^/]*\\)$, #/\\1,' | uniq  -f1 | sed -e 's/ #//'")
  if where !~ "^/"
    if substitute(where, ".* \\(.*$\\)", "\\1", "") !~ "^/"
      return 0
    endif
  endif
  return 1
endfunc

func <SID>GetPage(...)
  if a:0 >= 2
    let sect = a:1
    let page = a:2
  elseif a:0 >= 1
    let sect = ""
    let page = a:1
  else
    return
  endif

  " To support:       nmap K :Man <cword>
  if page == '<cword>'
    let page = expand('<cword>')
  endif

  let lowercasepage = tolower(page)

  if sect != "" && s:FindPage(sect, page) == 0 
    if s:FindPage(sect, lowercasepage) == 0
      let sect = ""
    endif
  endif

  if s:FindPage(sect, page) == 0 
    if s:FindPage(sect, lowercasepage) == 0
      echo "\nCannot find '".page."'."
      return
    else
      let page = lowercasepage
      unlet lowercasepage
    endif
  endif

  " Use an existing "man" window if it exists, otherwise open a new one.
  if &filetype != "man"
    let thiswin = winnr()
    exe "norm! \<C-W>b"
    if winnr() == 1
      new
    else
      exe "norm! " . thiswin . "\<C-W>w"
      while 1
        if &filetype == "man"
          break
        endif
        exe "norm! \<C-W>w"
        if thiswin == winnr()
          new
          break
        endif
      endwhile
    endif
  endif
  
  exec "let s:man_tag_buf_".s:man_tag_depth." = ".bufnr("%")
  exec "let s:man_tag_lin_".s:man_tag_depth." = ".line(".")
  exec "let s:man_tag_col_".s:man_tag_depth." = ".col(".")

  let s:man_tag_depth = s:man_tag_depth + 1

  silent exec "edit $HOME/".page.".".sect."~"

  set ma
  silent exec "norm 1GdG"
  let $MANWIDTH = winwidth(0)
  silent exec "r!/usr/bin/man ".s:man_find_arg.' '.s:GetCmdArg(sect, page)." 2>/dev/null | sed 's,[/]\\([^/]*\\)$, @/\\1,' | uniq  -f1 | sed -e 's/ [@]//' | xargs /usr/bin/man 2>/dev/null | col -b | uniq"
  " Is it OK?  It's for remove blank or message line.
  if getline(1) =~ "^\s*$"
     silent exec "norm 1Gd/^[^[:space:]]\<cr>G1"
  endif
  if getline('$') == ''
    silent exec "norm G?^\s*[^\s]\<cr>2jdG"
  endif
  1
  setl ft=man nomod
  setl ts=8
"  setl expandtab
"  silent exec "retab"
  setl bufhidden=hide
  setl nobuflisted
  setl nomodifiable
  setl readonly
  setl noswapfile
endfunc

func <SID>PopPage()
  if &filetype != "man"
    let thiswin = winnr()
    exe "norm! \<C-W>b"
    if winnr() == 1
    else
      exe "norm! " . thiswin . "\<C-W>w"
      while 1
        if &filetype == "man"
          break
        endif
        exe "norm! \<C-W>w"
        if thiswin == winnr()
          break
        endif
      endwhile
    endif
  endif

  if &filetype == "man"
    if s:man_tag_depth > 1
      let s:man_tag_depth = s:man_tag_depth - 1
      exec "let s:man_tag_buf=s:man_tag_buf_".s:man_tag_depth
      exec "let s:man_tag_lin=s:man_tag_lin_".s:man_tag_depth
      exec "let s:man_tag_col=s:man_tag_col_".s:man_tag_depth
      exec s:man_tag_buf."b"
      exec s:man_tag_lin
      exec "norm ".s:man_tag_col."|"
      exec "unlet s:man_tag_buf_".s:man_tag_depth
      exec "unlet s:man_tag_lin_".s:man_tag_depth
      exec "unlet s:man_tag_col_".s:man_tag_depth
      unlet s:man_tag_buf s:man_tag_lin s:man_tag_col
    endif
  endif
endfunc

endif

" vim: set sw=2:
