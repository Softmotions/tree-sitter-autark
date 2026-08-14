" Vim filetype detection for Autark build scripts.
augroup filetypedetect_autark
  autocmd!
  autocmd BufNewFile,BufRead Autark,*.autark setfiletype autark
augroup END
