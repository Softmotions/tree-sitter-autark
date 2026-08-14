set nocompatible
set nomore

let s:root = fnamemodify(expand('<sfile>'), ':p:h:h')
execute 'set runtimepath^=' . fnameescape(s:root)

filetype plugin on
syntax on

execute 'edit ' . fnameescape(s:root . '/examples/Autark')

if &filetype !=# 'autark'
  echoerr 'expected filetype=autark, got ' . &filetype
  cquit 1
endif

if !exists('b:current_syntax') || b:current_syntax !=# 'autark'
  echoerr 'Autark syntax was not loaded'
  cquit 2
endif

if &l:commentstring !=# '# %s'
  echoerr 'unexpected commentstring: ' . &l:commentstring
  cquit 3
endif

qa!
