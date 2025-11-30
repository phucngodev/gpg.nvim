<a href="https://dotfyle.com/plugins/benoror/gpg.nvim">
  <img src="https://dotfyle.com/plugins/benoror/gpg.nvim/shield" />
</a>

# gpg.nvim

Editing GPG encrypted files symmetrically in Vim 8+

![Demo](https://github.com/user-attachments/assets/2127cbe4-4199-4d0f-b9a3-b94798184cae)

## Features

- Transparent encryption/decryption of `.gpg` files
- Support for specific file types (e.g., `.md.gpg` files are treated as markdown)
- Secure handling (disables swap files, undofiles, and shada for encrypted buffers)
- Configurable GPG options and executable path
- Improved error handling and user feedback
- Vim 8+ compatible only

## Install

### For vim-plug (Vim 8+):
```vim
Plug 'benoror/gpg.nvim'
```

### For Pathogen (Vim 8+):
```bash
cd ~/.vim/bundle
git clone https://github.com/benoror/gpg.nvim.git
```

## Requirements

- `gpg`
- Vim 8.0+

## Configuration

The plugin provides several configuration options that can be set in your `.vimrc`:

```vim
" Path to GPG executable (default: 'gpg')
let g:gpg_executable = 'gpg'

" GPG recipient for encryption (default: uses --default-recipient-self)
let g:gpg_recipient = 'your@email.com'

" Additional GPG encryption options (default: '--default-recipient-self -ae')
let g:gpg_encrypt_options = '--default-recipient-self -ae'

" Additional GPG decryption options (default: '--decrypt')
let g:gpg_decrypt_options = '--decrypt'

" Show detailed error messages (default: 1)
let g:gpg_show_error = 1

" Disable GPG autocmds if needed (default: 0)
let g:gpg_disable_autocmds = 0
```

## Usage

All `*.gpg` files will be symmetrically decrypted/encrypted transparently using `gpg` tools. Simply open any `.gpg` file in Vim and it will be automatically decrypted for editing. When you save the file, it will be encrypted again.

For `.md.gpg` files, the plugin will set the filetype to markdown so you get proper syntax highlighting.

### Commands

The plugin provides these additional commands:

- `:GpgEncrypt` - Manually encrypt the current buffer
- `:GpgDecrypt` - Manually decrypt the current buffer

## How It Works

The plugin sets up several autocmds that:

1. Before reading: Sets up secure buffer options (no swap file, binary mode, etc.)
2. After reading: Decrypts the file content and sets appropriate filetypes
3. Before writing: Encrypts the content
4. After writing: Restores the unencrypted view

## Security

The plugin takes several security measures:

- Disables swap files to prevent unencrypted data from being written to disk
- Disables undofiles to prevent unencrypted data from being stored
- Disables shada to prevent history from being saved
- Disables backup files to prevent unencrypted data from being stored

## Compatibility

Vim 8+ compatible only.

## Credits

### Based off

- From @nickali https://gist.github.com/nickali/89f3743e305db015d0f3ad4ffd325ccb
  - https://nali.org/wiki/tech/apps/neovim/#gpg-decrypting-and-encrypting-transparently-with-neovim
- Proposed first by @traut https://gist.github.com/traut/cd19ae2817ab13e0bade1f8a9995029f
  - https://www.reddit.com/r/nvim/comments/112a5bi/editing_gpg_encrypted_files_in_neovim/

### Inspired by

https://github.com/jamessan/vim-gnupg

## Further reading

- [Setup GPG on macOS](https://dev.to/zemse/setup-gpg-on-macos-2iib)