# vim-copy-as-rtf

This plugin provides a `CopyRTF` command for OS X systems that copies the
current buffer or selected text to the clipboard as syntax-highlighted RTF text.

This plugin was inspired by the
[rtf-highlight](https://github.com/dharanasoft/rtf-highlight) plugin, but only
uses commands available by default on OS X and an HTML conversion plugin that
ships with vim.

## Requirements

* OS X
* The `:TOhtml` plugin, which ships with vim and is enabled by default

## Installation

Use [pathogen](https://github.com/tpope/vim-pathogen/) and clone this repo to
`~/.vim/bundle`.

## Usage

When the plugin is loaded, the following command is available:

    :CopyRTF

It operates on either the current buffer or the currently selected text. After
the command executes, the RTF text will be available on the system clipboard.

For customization of how the text is generated, see the vim documentation for
the `:TOhtml` command.
