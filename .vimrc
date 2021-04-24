set nocompatible              " be iMproved, required
filetype off                  " required
set nobackup                  " no backup files
set noswapfile                " no swap files

filetype plugin indent on	" required

set termguicolors			" Enable 'true color' support in the terminal
set	background=dark			" let vim now that we are using a dark terminal theme
colorscheme gruvbox			" set gruvbox as our default theme
syntax enable				" enable syntax processing

set splitbelow
set splitright

" Disable annoying beeping
set noerrorbells
set vb t_vb=

filetype plugin on
syntax on
set encoding=utf-8

set number					" show line numbers
set relativenumber			" show relative line numbers
set showcmd					" show command in bottom bar
set cursorline				" highlight current line
set wildmenu				" visual autocomplete for command menu
set showmatch				" highlight matching [{()}]

" Enable autocompletion:
set wildmode=longest,list,full
" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" YAML documents are required to have a 2 space indentation
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

set tabstop=4				" number of visual spaces per TAB
set softtabstop=4
set shiftwidth=4
set noexpandtab

let &t_EI = "\<Esc>[1 q"
let &t_SR = "\<Esc>[3 q"
let &t_SI = "\<Esc>[5 q"

" Make sure we have a block cursor
autocmd VimEnter * silent exec "! echo -ne '\e[1 q'"
" Make sure we reset the block cursor on exit
autocmd VimLeave * silent exec "! echo -ne '\e[5 q'"

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Directory browser settings
let g:netrw_banner = 0 " Removing the banner
let g:netrw_liststyle = 3 " Changing directory view to tree-style
let g:netrw_browse_split = 3 " Open files in a new tab
let g:netrw_altv = 1 " Change from left splitting to right splitting
let g:netrw_winsize = 25 " Set the directory explorer width to 25% of the page
"augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Vexplore
"augroup END

au filetype go inoremap <buffer> . .<C-x><C-o>
