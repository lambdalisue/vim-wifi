wifi.vim
==============================================================================
![Version 0.1.0](https://img.shields.io/badge/version-0.1.0-yellow.svg?style=flat-square)
![Support Neovim 0.1.6 or above](https://img.shields.io/badge/support-Neovim%200.1.6%20or%20above-green.svg?style=flat-square)
![Support Vim 8.0 or above](https://img.shields.io/badge/support-Vim%208.0.0%20or%20above-yellowgreen.svg?style=flat-square)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Doc](https://img.shields.io/badge/doc-%3Ah%20wifi-orange.svg?style=flat-square)](doc/wifi.txt)

![wifi.vim in tabline](https://media.githubusercontent.com/media/lambdalisue/screenshots/master/wifi.vim/tabline_with_lightline.png)

*wifi.vim* is a statusline/tabline component for Neovim/Vim.
It uses a job feature of Neovim/Vim to retrieve wifi informations so that the plugin won't block the main thread.

**NOTE: Supports macOS, Linux, and Termux. PR is welcome.**

> [!IMPORTANT]
> **macOS 14+ SSID Limitation**: Due to Apple's privacy changes introduced in macOS 14 (Sonoma), WiFi SSID access now requires Location Services permission. **CLI tools (including Vim/Neovim and terminal emulators) cannot request this permission**, so SSID will not be available on modern macOS.
>
> **What still works:**
> - ✅ RSSI (signal strength)
> - ✅ Transmission rate
> - ✅ Signal graph
>
> **What doesn't work on macOS 14+:**
> - ❌ SSID (network name) - will be empty
>
> This is an **intentional Apple design decision**, not a bug. For technical details, see:
> - [Apple Developer Forums: macOS get SSID changes?](https://developer.apple.com/forums/thread/732431)
> - Official requirement: _"SSID information is not available unless Location Services is enabled and the user has authorized the calling app to use location services."_
> - CLI tools have no mechanism to request Location Services authorization

The implementation was translated to Vim script from a Bash script found on https://github.com/b4b4r07/dotfiles/blob/master/bin/wifi.


Install
-------------------------------------------------------------------------------
Use [junegunn/vim-plug] or [Shougo/dein.vim] like:

```vim
" Plug.vim
Plug 'lambdalisue/wifi.vim'

" dein.vim
call dein#add('lambdalisue/wifi.vim')
```

Or copy contents of the repository into your runtimepath manually.

[junegunn/vim-plug]: https://github.com/junegunn/vim-plug
[Shougo/dein.vim]: https://github.com/Shougo/dein.vim


Usage
-------------------------------------------------------------------------------

Use a `wifi#component()` like:

```vim
set statusline=...%{wifi#component()}...
set tabline=...%{wifi#component()}...
```

Or with [itchyny/lightline.vim](https://github.com/itchyny/lightline.vim)

```vim
let g:lightline = {
      \ ...
      \ 'component_function': {
      \   ...
      \   'wifi': 'wifi#component',
      \   ...
      \ },
      \ ...
      \}
```

Additionally, assign 1 to corresponding variables to immediately reflect the
changes to `statusline` or `tabline`.

```vim
let g:wifi#update_tabline = 1    " If wifi#component() is used in tabline.
let g:wifi#update_statusline = 1 " If wifi#component() is used in statusline.
```

See more detail on [wifi.txt](./doc/wifi.txt)


See also
-------------------------------------------------------------------------------

- [lambdalisue/battery.vim](https://github.com/lambdalisue/battery.vim) - A statusline/tabline component of Neovim/Vim.
