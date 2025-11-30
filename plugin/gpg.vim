" GPG plugin for Vim 8+
" Provides transparent GPG encryption/decryption for .gpg files

" Only load once
if exists('g:loaded_gpg')
  finish
endif
let g:loaded_gpg = 1

" Default configuration options
if !exists('g:gpg_executable')
  let g:gpg_executable = 'gpg'
endif

if !exists('g:gpg_recipient')
  let g:gpg_recipient = ''
endif

if !exists('g:gpg_encrypt_options')
  let g:gpg_encrypt_options = '--default-recipient-self -ae'
endif

if !exists('g:gpg_decrypt_options')
  let g:gpg_decrypt_options = '--decrypt'
endif

if !exists('g:gpg_show_error')
  let g:gpg_show_error = 1
endif

if !exists('g:gpg_disable_autocmds')
  let g:gpg_disable_autocmds = 0
endif

" Validate GPG executable exists
function! s:ValidateGPG()
  if !executable(g:gpg_executable)
    echohl ErrorMsg
    echomsg 'GPG executable not found: ' . g:gpg_executable
    echohl None
    return 0
  endif
  return 1
endfunction

" Create augroup for GPG functionality
augroup customGpg
  autocmd!
augroup END

" Set up options before reading GPG files
augroup customGpg
  autocmd BufReadPre,FileReadPre *.gpg
    \ if empty(&buftype) && !&modified && expand('<amatch>') =~# '\.gpg$' && !g:gpg_disable_autocmds | call s:PrepareGpgRead() | endif
  " Set filetype for markdown files after they are read
  autocmd BufReadPost *.gpg
    \ if empty(&buftype) && expand('<afile>') =~# '\.md\.gpg$' && !g:gpg_disable_autocmds | call s:SetMarkdownFiletype() | endif
  autocmd BufReadPost,FileReadPost *.gpg
    \ if empty(&buftype) && expand('<amatch>') =~# '\.gpg$' && !g:gpg_disable_autocmds | call s:DecryptGpgFile() | endif
  autocmd BufWritePre,FileWritePre *.gpg
    \ if empty(&buftype) && expand('<amatch>') =~# '\.gpg$' && !g:gpg_disable_autocmds | call s:EncryptGpgFile() | endif
  autocmd BufWritePost *.gpg
    \ if empty(&buftype) && expand('<amatch>') =~# '\.gpg$' && !g:gpg_disable_autocmds | call s:UndoEncryption() | endif
augroup END

function! s:PrepareGpgRead()
  " Use try-catch to prevent errors from propagating
  try
    " Validate GPG executable exists
    if !s:ValidateGPG()
      return
    endif

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

    " Mark this buffer as a GPG buffer
    let b:gpg_encrypted = 1
  catch
    call s:HandleError('Error preparing GPG file for reading')
    return
  endtry
endfunction

function! s:SetMarkdownFiletype()
  " Set filetype to markdown for .md.gpg files
  try
    let &filetype = 'markdown'
  catch
    call s:HandleError('Error setting markdown filetype')
    return
  endtry
endfunction

function! s:DecryptGpgFile()
  " Use try-catch to handle potential errors during decryption
  try
    " Check if the file actually exists and is readable before attempting to decrypt
    let l:filename = expand('<afile>')
    if !filereadable(l:filename)
      call s:HandleError('File not readable: ' . l:filename)
      return
    endif

    " Store original buffer content for error recovery
    let b:gpg_original_content = getline(1, '$')

    " Execute GPG decryption on the current buffer content using the pipe operator
    " This is the standard Vim approach for filtering buffer content through external commands
    let l:decrypt_cmd = g:gpg_executable . ' ' . g:gpg_decrypt_options
    silent execute "'[,']!" . l:decrypt_cmd . " 2>/dev/null"

    " Check if decryption succeeded by checking shell error after the command
    if v:shell_error != 0
      " If decryption failed, restore original content and show error
      call setline(1, b:gpg_original_content)
      call s:HandleError('GPG decryption failed: Check your GPG configuration and passphrase')
      return
    endif

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
    call s:HandleError('Error during GPG decryption')
    " Restore original content on error
    if exists('b:gpg_original_content')
      call setline(1, b:gpg_original_content)
    endif
    return
  endtry
endfunction

function! s:EncryptGpgFile()
  " Use try-catch to handle potential errors during encryption
  try
    " Validate GPG executable exists
    if !s:ValidateGPG()
      return
    endif

    " Store original content for error recovery
    let b:gpg_unencrypted_content = getline(1, '$')

    " Execute GPG encryption on the current buffer content using the pipe operator
    let l:encrypt_cmd = g:gpg_executable . ' ' . g:gpg_encrypt_options
    silent execute "'[,']!" . l:encrypt_cmd . " 2>/dev/null"

    " Check if encryption succeeded
    if v:shell_error != 0
      call s:HandleError('GPG encryption failed: Check your GPG configuration')
      " Restore original content on error
      if exists('b:gpg_unencrypted_content')
        call setline(1, b:gpg_unencrypted_content)
      endif
      return
    endif
  catch
    call s:HandleError('Error during GPG encryption')
    " Restore original content on error
    if exists('b:gpg_unencrypted_content')
      call setline(1, b:gpg_unencrypted_content)
    endif
    return
  endtry
endfunction

function! s:UndoEncryption()
  " Use try-catch to handle potential errors during undo
  try
    " Only undo if this is a GPG buffer
    if !exists('b:gpg_encrypted')
      return
    endif

    " Restore the unencrypted content
    if exists('b:gpg_unencrypted_content')
      silent %delete _
      call setline(1, b:gpg_unencrypted_content)
      unlet b:gpg_unencrypted_content
    else
      " Fallback to undo if we don't have stored content
      silent undo
    endif
  catch
    call s:HandleError('Error restoring unencrypted content')
    return
  endtry
endfunction

function! s:HandleError(msg)
  if g:gpg_show_error
    echohl ErrorMsg
    echomsg 'GPG Plugin Error: ' . a:msg
    echohl None
  endif
endfunction

" Command to manually re-encrypt current buffer
command! GpgEncrypt call s:EncryptGpgFile()

" Command to manually decrypt current buffer
command! GpgDecrypt call s:DecryptGpgFile()