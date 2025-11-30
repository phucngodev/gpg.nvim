<a href="https://dotfyle.com/plugins/benoror/gpg.nvim">
  <img src="https://dotfyle.com/plugins/benoror/gpg.nvim/shield" />
</a>

# gpg.nvim

Editing GPG encrypted files symmetrically in Vim 8+ and Neovim

![Demo](https://github.com/user-attachments/assets/2127cbe4-4199-4d0f-b9a3-b94798184cae)

## Features

- Transparent encryption/decryption of `.gpg` files
- Support for specific file types (e.g., `.md.gpg` files are treated as markdown)
- Secure handling (disables swap files, undofiles, and shada for encrypted buffers)
- Works with both Vim 8+ and Neovim

## Install

### For vim-plug (Neovim/Vim 8+):
```vim
Plug 'benoror/gpg.nvim'
```

### For packer.nvim (Neovim):
```lua
use 'benoror/gpg.nvim'
```

### For lazy.nvim (Neovim):
```lua
{
   "benoror/gpg.nvim",
}
```

### For Pathogen (Vim 8+/Neovim):
```bash
cd ~/.vim/bundle  # or ~/.config/nvim/bundle for Neovim
git clone https://github.com/benoror/gpg.nvim.git
```

## Requirements

- `gpg`
- Optional: `pinentry-mac`
- Vim 8.0+ or Neovim 0.5+

## Usage

All `*.gpg` files will be symmetrically decrypted/encrypted transparently using `gpg` tools. Simply open any `.gpg` file in Vim or Neovim and it will be automatically decrypted for editing. When you save the file, it will be encrypted again.

For `.md.gpg` files, the plugin will set the filetype to markdown so you get proper syntax highlighting.

## How It Works

The plugin sets up several autocmds that:

1. Before reading: Sets up secure buffer options (no swap file, binary mode, etc.)
2. After reading: Decrypts the file content and sets appropriate filetypes
3. Before writing: Encrypts the content
4. After writing: Restores the unencrypted view

## Compatibility

- **Neovim**: Uses Lua API (`vim.api.nvim_*` functions) from `plugin/gpg.lua`
- **Vim 8+**: Uses Vimscript autocmds from `plugin/gpg.vim`

Both implementations provide the same functionality.

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
