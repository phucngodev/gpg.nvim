" GPG plugin for Vim 8+
" Provides transparent GPG encryption/decryption for .gpg files

" Only load once
if exists('g:loaded_gpg')
  finish
endif
let g:loaded_gpg = 1

" Create augroup for GPG functionality
augroup customGpg
  autocmd!
augroup END

" Set up options before reading GPG files
augroup customGpg
  autocmd BufReadPre,FileReadPre *.gpg
    \ if empty(&buftype) && !&modified && expand('<amatch>') =~# '\.gpg$' && !exists('g:disable_gpg_autocmds') | call s:PrepareGpgRead() | endif
  " Set filetype for markdown files after they are read
  autocmd BufReadPost *.gpg
    \ if empty(&buftype) && expand('<afile>') =~# '\.md\.gpg$' && !exists('g:disable_gpg_autocmds') | call s:SetMarkdownFiletype() | endif
  autocmd BufReadPost,FileReadPost *.gpg
    \ if empty(&buftype) && expand('<amatch>') =~# '\.gpg$' && !exists('g:disable_gpg_autocmds') | call s:DecryptGpgFile() | endif
  autocmd BufWritePre,FileWritePre *.gpg
    \ if empty(&buftype) && expand('<amatch>') =~# '\.gpg$' && !exists('g:disable_gpg_autocmds') | call s:EncryptGpgFile() | endif
  autocmd BufWritePost *.gpg
    \ if empty(&buftype) && expand('<amatch>') =~# '\.gpg$' && !exists('g:disable_gpg_autocmds') | call s:UndoEncryption() | endif
augroup END

function! s:PrepareGpgRead()
  " Use try-catch to prevent errors from propagating
  try
    " Make sure nothing is written to shada file while editing an encrypted file
    setlocal shada=
    " We don't want a swap file, as it writes unencrypted data to disk
    setlocal noswapfile
    " Switch to binary mode to read the encrypted file
    setlocal bin
    " Disable undofile as it stores unencrypted data on your disk
    setlocal noundofile
    " Also avoid backups for this buffer
    setlocal nobackup nowritebackup

    " Save the current 'ch' value to a buffer-local variable
    let b:ch_save = &ch
    let &ch = 2
  catch
    " If there's an error, just continue without changes
    return
  endtry
endfunction

function! s:SetMarkdownFiletype()
  " Set filetype to markdown for .md.gpg files
  try
    let &filetype = 'markdown'
  catch
    " If there's an error, just continue without changes
    return
  endtry
endfunction

function! s:DecryptGpgFile()
  " Use try-catch to handle potential errors during decryption
  try
    " Check if the file actually exists and is readable before attempting to decrypt
    let l:filename = expand('<afile>')
    if !filereadable(l:filename)
      return
    endif

    " Decrypt the file content
    silent execute "'[,']!gpg --decrypt 2> /dev/null"

    " Switch to normal mode for editing
    setlocal nobin

    " Restore the 'ch' value from the buffer-local variable
    if exists('b:ch_save')
      let &ch = b:ch_save
      unlet b:ch_save
    endif

    " Execute the BufReadPost autocmd for the base filename
    execute 'doautocmd BufReadPost ' . expand('%:r')
  catch
    " If there's an error during decryption, just continue
    return
  endtry
endfunction

function! s:EncryptGpgFile()
  " Use try-catch to handle potential errors during encryption
  try
    " Encrypt the file content before writing
    silent execute "'[,']!gpg --default-recipient-self -ae 2> /dev/null"
  catch
    " If there's an error during encryption, just continue
    return
  endtry
endfunction

function! s:UndoEncryption()
  " Use try-catch to handle potential errors during undo
  try
    " Undo the encryption so we are back to normal text after file has been written
    silent undo
  catch
    " If there's an error during undo, just continue
    return
  endtry
endfunction