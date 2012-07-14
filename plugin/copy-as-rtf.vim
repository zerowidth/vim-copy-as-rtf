" Vim plugin for copying syntax highlighted code as RTF on OS X systems
" Last Change: 2012-07-14
" Maintainer:	Nathan Witmer <nwitmer@gmail.com>
" License: WTFPL

if exists('g:loaded_copy_as_rtf')
  finish
endif
let g:loaded_copy_as_rtf = 1

if !executable('pbcopy') || !executable('textutil')
  echomsg 'cannot load copy-as-rtf plugin, not on a mac?'
  finish
endif

" copy the current buffer or selected text as RTF
function! s:CopyRTF(line1,line2)

  if !exists(':TOhtml')
    echoerr 'TOhtml command not found, is the plugin enabled and available?'
    return
  endif

  let lines = getline(a:line1, a:line2)
  call s:RemoveCommonIndentation(a:line1, a:line2)
  call tohtml#Convert2HTML(a:line1, a:line2)
  silent exe "%!textutil -convert rtf -stdin -stdout | pbcopy"
  silent bd!
  silent call setline(a:line1, lines)
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

command! -range=% CopyRTF :call s:CopyRTF(<line1>,<line2>)
