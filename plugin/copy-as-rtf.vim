" Vim plugin for copying syntax highlighted code as RTF on Windows/macOS/X11
" Last Change: 2020-07-10
" Maintainer:	Nathan Witmer <nwitmer@gmail.com>
" License: WTFPL

if exists('g:loaded_copy_as_rtf')
  finish
endif
let g:loaded_copy_as_rtf = 1

" Set this to 1 to tell copy_as_rtf to use the local buffer instead of a scratch
" buffer with the selected code. Use this if the syntax highlighting isn't
" correctly handling your code when removed from its context in its original
" file.
if !exists('g:copy_as_rtf_using_local_buffer')
  let g:copy_as_rtf_using_local_buffer = 0
endif

" Set this to 1 to preserve the indentation as-is when converting to RTF.
" Otherwise, the selected lines are outdented as far as possible before
" conversion.
if !exists('g:copy_as_rtf_preserve_indent')
  let g:copy_as_rtf_preserve_indent = 0
endif

if has('win32') && has('clipboard')
  function s:Copy_as_RTF()
    %yank *
    silent exec '!start /min powershell -noprofile "gcb | scb -as"'
  endfunction
elseif has('x11') && executable('xclip')
  function s:Copy_as_RTF()
    silent exe '%!xclip -selection clipboard -t "text/html" -i'
  endfunction
elseif executable('pbcopy') && executable('textutil')
  function s:Copy_as_RTF()
    silent exe '%!textutil -convert rtf -stdin -stdout | pbcopy'
  endfunction
else
  echomsg 'Cannot load copy-as-rtf plugin: unsupported platform'
  finish
endif

" copy the current buffer or selected text as RTF
"
" bufnr - the buffer number of the current buffer
" line1 - the start line of the selection
" line2 - the ending line of the selection
function! s:CopyRTF(bufnr, line1, line2)

  " check at runtime since this plugin may not load before this one
  if !exists(':TOhtml')
    echoerr 'cannot load copy-as-rtf plugin, TOhtml command not found.'
    finish
  endif

  " save the alternate file and restore it at the end
  let l:alternate=bufnr(@#)

  if g:copy_as_rtf_using_local_buffer
    let lines = getline(a:line1, a:line2)

    if !g:copy_as_rtf_preserve_indent
      call s:RemoveCommonIndentation(a:line1, a:line2)
    endif
    call tohtml#Convert2HTML(a:line1, a:line2)
    call Copy_as_RTF()

    silent bd!
    silent call setline(a:line1, lines)
  else

    " open a new scratch buffer
    let orig_ft = &ft
    let l:orig_bg = &background
    let l:orig_nu = &number
    let l:orig_nuw = &numberwidth
    if exists("b:is_bash")
      let l:is_bash = b:is_bash
    endif
    new __copy_as_rtf__
    " enable the same syntax highlighting
    if exists("l:is_bash")
      let b:is_bash=l:is_bash
    endif
    let &ft=orig_ft
    let &background=l:orig_bg
    let &number=l:orig_nu
    let &numberwidth=l:orig_nuw
    set buftype=nofile
    set bufhidden=hide
    setlocal noswapfile

    " copy the selection into the scratch buffer
    call setline(1, getbufline(a:bufnr, a:line1, a:line2))

    if !g:copy_as_rtf_preserve_indent
      call s:RemoveCommonIndentation(1, line('$'))
    endif

    call tohtml#Convert2HTML(1, line('$'))
    call s:Copy_as_RTF()
    silent bd!
    silent bd!
  endif

  let @# = l:alternate
  echomsg "RTF copied to clipboard"
endfunction

" outdent selection to the least indented level
function! s:RemoveCommonIndentation(line1, line2)
  " normalize indentation
  silent exe a:line1 . ',' . a:line2 . 'retab'

  let lines_with_code = filter(range(a:line1, a:line2), 'match(getline(v:val), ''\S'') >= 0')
  let minimum_indent = min(map(lines_with_code, 'indent(v:val)'))
  let pattern = '^\s\{' . minimum_indent . '}'
  call setline(a:line1, map(getline(a:line1, a:line2), 'substitute(v:val, pattern, "", "")'))
endfunction

command! -range=% CopyRTF :call s:CopyRTF(bufnr('%'),<line1>,<line2>)
