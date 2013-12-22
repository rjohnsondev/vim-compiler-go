Vim compiler file for Go (golang)
=================================

Compiles Go files in the background and usefully underlines and reports
errors to the QuickFix window:

![](demo.png?raw=true)

Installation:
-------------

### Pathogen

Just clone this repo into your bundles directory:

    git clone https://github.com/rjohnsondev/vim-compiler-go.git ~/.vim/bundle/vim-compiler-go

Either ensure the $GOROOT environment variable is set, or otherwise set the
g:golang_goroot variable in .vimrc to where your go installation can be found.
This must be an absolute path:

    let g:golang_goroot = "/home/richard/go"

### Manual installation

Drop golang.vim in ~/.vim/compiler directory.

Add the following line to the autocmd section of .vimrc

    autocmd FileType go compiler golang

Set the g:golang_goroot variable to where your go installation can be
found.  This must be an absolute path

    let g:golang_goroot = "/home/richard/go"

The plugin assumes a standard project layout with the files stored in a
src directory.  The GOPATH is set to one directory below the src folder.

Usage:
------

Golang is called after a buffer with Go code is saved. The QuickFix
window is opened to show errors, warnings and hints provided by Golang.

To disable calling Golang every time a buffer is saved, put into .vimrc file:

    let g:golang_onwrite = 0

The QuickFix window can be disabled with:

    let g:golang_cwindow = 0

Setting highlights for the lines can be disabled with:

    let g:golang_inline_highlight = 0

Of course, standard :make command can be used as is the case with every
other compiler.
