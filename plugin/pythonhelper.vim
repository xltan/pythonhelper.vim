" File: pythonhelper.vim
" Author: Michal Vitecek <fuf-at-mageo-dot-cz>
" Maintainer: Marius Gedminas <marius@gedmin.as>
" Version: 0.90
" Last Modified: 2016-08-31
"
" Overview
" --------
" Vim script to help moving around in larger Python source files. It displays
" current class, method or function the cursor is placed in on the status
" line for every python file. It's more clever than Yegappan Lakshmanan's
" taglist.vim because it takes into account indetation and comments to
" determine what tag the cursor is placed in.
"
" Requirements
" ------------
" This script needs only VIM compiled with Python interpreter. It doesn't rely
" on exuberant ctags utility. You can determine whether your VIM has Python
" support by issuing command :ver and looking for +python in the list of
" features.
"
" Installation
" ------------
" 1. Make sure your Vim has python feature on (+python). If not, you will need
"    to recompile it with --with-pythoninterp option to the configure script
" 2. Copy pythonhelper.vim and pythonhelper.py to the $HOME/.vim/plugin directory
" 3. Add something like this to your .vimrc:
"
"      " color of the current tag in the status line (bold cyan on black)
"      highlight User1 gui=bold guifg=cyan guibg=black
"      " color of the modified flag in the status line (bold black on red)
"      highlight User2 gui=bold guifg=black guibg=red
"      " the status line will be displayed for every window
"      set laststatus=2
"      " set the status line to display some useful information
"      set stl=%-f%r\ %2*%m%*\ \ \ \ %1*%{TagInStatusLine()}%*%=[%l:%c]\ \ \ \ [buf\ %n]
"
" 4. Run Vim and open any python file.
"
python import sys, vim
python if vim.eval('expand("<sfile>:p:h")') not in sys.path:
  \        sys.path.append(vim.eval('expand("<sfile>:p:h")'))
python import pythonhelper

" VIM functions {{{

function! PHCursorHold()
    " only python is supported {{{
    if (!exists('b:current_syntax') || (b:current_syntax != 'python'))
        let w:PHStatusLine = ''
        return
    endif
    " }}}

    " call python function findTag() with the current buffer number and changed ticks
    execute 'python pythonhelper.findTag(' . expand("<abuf>") . ', ' . b:changedtick . ')'
endfunction


function! PHBufferDelete()
    " set PHStatusLine for this window to empty string
    let w:PHStatusLine = ""

    " call python function deleteTags() with the cur
    execute 'python pythonhelper.deleteTags(' . expand("<abuf>") . ')'
endfunction


function! TagInStatusLine()
    " return value of w:PHStatusLine in case it's set
    if (exists("w:PHStatusLine"))
        return w:PHStatusLine
    " otherwise just return empty string
    else
        return ""
    endif
endfunction


function! PHPreviousClassMethod()
    call search('^[ \t]*\(class\|def\)\>', 'bw')
endfunction


function! PHNextClassMethod()
    call search('^[ \t]*\(class\|def\)\>', 'w')
endfunction


function! PHPreviousClass()
    call search('^[ \t]*class\>', 'bw')
endfunction


function! PHNextClass()
    call search('^[ \t]*class\>', 'w')
endfunction


function! PHPreviousMethod()
    call search('^[ \t]*def\>', 'bw')
endfunction


function! PHNextMethod()
    call search('^[ \t]*def\>', 'w')
endfunction

" }}}


" event binding, vim customizing {{{

" autocommands binding
autocmd CursorMoved * call PHCursorHold()
autocmd CursorMovedI * call PHCursorHold()
autocmd BufDelete * silent call PHBufferDelete()

" }}}

" vim:foldmethod=marker
