" Vim compiler file for Go (golang)
" Compiler:     Go (golang)
" Maintainer:   Richard Johnson <vim@rjohnson.id.au>
" Last Change:  2012 Nov 24
" Version:      0.1
" Contributors:
"   This is mostly based on the excellent pylint compiler plugin
"
" Installation:
"   Drop golang.vim in ~/.vim/compiler directory.
"
"   Add the following line to the autocmd section of .vimrc
"
"      autocmd FileType go compiler golang
"
"   Set the g:golang_goroot variable to where your go installation can be
"   found.  This must be an absolute path
"  
"      let g:golang_goroot = "/home/richard/go"
"
"   The plugin assumes a standard project layout with the files stored in a
"   src directory.  The GOPATH is set to one directory below the src folder.
"
" Usage:
"   Golang is called after a buffer with Python code is saved. QuickFix
"   window is opened to show errors, warnings and hints provided by Golang.
"
"   This is realized with :Golang command. To disable calling Golang every
"   time a buffer is saved put into .vimrc file
"
"       let g:golang_onwrite = 0
"
"   Displaying code rate calculated by Golang can be avoided by setting
"
"   Openning of QuickFix window can be disabled with
"
"       let g:golang_cwindow = 0
"
"   Of course, standard :make command can be used as in case of every
"   other compiler.
"
"   Setting highlights for the lines can be disabled with
"
"       let g:golang_inline_highlight = 0
"

if exists('current_compiler')
    finish
endif
let current_compiler = 'golang'

if !exists('g:golang_onwrite')
    let g:golang_onwrite = 1
endif

if !exists('g:golang_cwindow')
    let g:golang_cwindow = 1
endif

if !exists('g:golang_inline_highlight')
    let g:golang_inline_highlight = 1
endif

if exists(':Golang') != 2
    command Golang :call Golang(0)
endif

if exists(":CompilerSet") != 2          " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

au CursorHold <buffer> call s:GetGolangMessage()
au CursorMoved <buffer> call s:GetGolangMessage()

let $GOROOT=golang_goroot
let $GOPATH=substitute(expand("%:p:h"),"\\(.*\\)/src.*","\\1",'g')
let $PATHESCAPED=substitute(expand("%:p:h"),"\/","\\\\/",'g')
CompilerSet makeprg=cd\ %:p:h;\ $GOROOT/bin/go\ build\ 2>&1\\\|sed\ -e\ \'s\/^\\(.*\\)\.go/$PATHESCAPED\\/\\1.go\/g\'
CompilerSet efm=%f:%l:%m

if g:golang_onwrite
    augroup python
        au!
        au BufWritePost * call Golang(1)
    augroup end
endif

if !exists("*s:Golang")
function! Golang(writing)
    if has('win32') || has('win16') || has('win95') || has('win64')
        setlocal sp=>%s
    else
        setlocal sp=>%s\ 2>&1
    endif

    " If check is executed by buffer write - do not jump to first error
    if !a:writing
        silent make
    else
        silent make!
    endif

    if g:golang_inline_highlight
        call GolangHighlight() 
    endif

    if g:golang_cwindow
        cwindow
    endif

endfunction
endif

if !exists("*s:GolangHighlight")
    function! GolangHighlight()
        highlight link GoError SpellBad

        "clear all already highlighted
        if exists("b:cleared")
            if b:cleared == 0
                silent call s:ClearHighlight()
                let b:cleared = 1
            endif
        else
            let b:cleared = 1
        endif

        let b:matchedlines = {}

        " get all messages from qicklist
        let l:list = getqflist()
        for l:item in l:list
            " highlight lines with errors (only word characters) without end
            " of line
            let l:matchDict = {}
            let l:matchDict['linenum'] = l:item.lnum
            let l:matchDict['message'] = l:item.text
            if bufnr('%') == item.bufnr
                if !has_key(b:matchedlines, l:item.lnum)
                    let b:matchedlines[l:item.lnum] = l:matchDict
                    call matchadd("GoError", '\w\%' . l:item.lnum . 'l\n\@!')
                endif
            endif
        endfor
        let b:cleared = 0
    endfunction
endif

" keep track of whether or not we are showing a message
let b:showing_message = 0

" WideMsg() prints [long] message up to (&columns-1) length
" guaranteed without "Press Enter" prompt.
if !exists("*s:WideMsg")
    function s:WideMsg(msg)
        let x=&ruler | let y=&showcmd
        set noruler noshowcmd
        redraw
        echo a:msg
        let &ruler=x | let &showcmd=y
    endfun
endif

if !exists('*s:GetGolangMessage')
function s:GetGolangMessage()
    let l:cursorPos = getpos(".")

    " Bail if Golang hasn't been called yet.
    if !exists('b:matchedlines')
        return
    endif
    " if there's a message for the line the cursor is currently on, echo
    " it to the console
    if has_key(b:matchedlines, l:cursorPos[1])
        let l:golangMatch = get(b:matchedlines, l:cursorPos[1])
        call s:WideMsg(l:golangMatch['message'])
        let b:showing_message = 1
        return
    endif
	" otherwise, if we're showing a message, clear it
    if b:showing_message == 1
        echo
        let b:showing_message = 0
    endif
endfunction
endif

if !exists('*s:ClearHighlight')
    function s:ClearHighlight()
        let l:matches = getmatches()
        for l:matchId in l:matches
            call matchdelete(l:matchId['id'])
        endfor
        let b:matchedlines = {}
        let b:cleared = 1
    endfunction
endif

au BufRead * call s:ClearHighlight()
