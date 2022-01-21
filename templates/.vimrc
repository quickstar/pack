set packpath^=~/.vim

set nocompatible              " be iMproved, required
filetype off                  " required
set nobackup                  " no backup files
set noswapfile                " no swap

let mapleader = ","

filetype plugin indent on	" required

set termguicolors			" Enable 'true color' support in the terminal
set	background=dark			" let vim now that we are using a dark terminal theme
packadd! dracula			" enable syntax processing
syntax enable				" enable syntax processing
colorscheme dracula			" set dracula as our default theme

" transparent bg
autocmd vimenter * hi Normal guibg=NONE ctermbg=NONE

set splitbelow
set splitright

" This allows buffers to be hidden if you've modified a buffer.
" This is almost a must if you wish to use buffers in this way.
set hidden

" Disable annoying beeping
set noerrorbells
set vb t_vb=

filetype plugin on
syntax on
set encoding=utf-8

set number					         " show line numbers
set relativenumber			         " show relative line numbers
set showcmd					         " show command in bottom bar
set cursorline				         " highlight current line
set wildmenu				         " visual autocomplete for command menu
set showmatch				         " highlight matching [{()}]
set timeoutlen=1000 ttimeoutlen=0    " remove delay when switch between insert and command mode

" Enable autocompletion:
set wildmode=longest,list,full
" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" YAML documents are required to have a 2 space indentation
autocmd FileType yaml,yml setlocal ts=2 sts=2 sw=2 expandtab

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

let g:tmux_navigator_no_mappings = 1

execute "set <M-h>=\eh"
execute "set <M-j>=\ej"
execute "set <M-k>=\ek"
execute "set <M-l>=\el"
execute "set <M-H>=\eH"
execute "set <M-J>=\eJ"
execute "set <M-K>=\eK"
execute "set <M-L>=\eL"

nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <M-¨> :TmuxNavigatePrevious<cr>

" Maps Alt-[h,j,k,l] to resizing a window split
nnoremap <silent> <M-H> <C-w>5<
nnoremap <silent> <M-J> <C-W>5-
nnoremap <silent> <M-K> <C-W>5+
nnoremap <silent> <M-L> <C-w>5>

" Show all open buffers and their status
nnoremap <C-@> :ls<CR>:b
nnoremap <C-l> :bnext<CR>
nnoremap <C-h> :bprevious<CR>

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

" Reveal current file in netrw
map <Leader>f :let @/=expand("%:t") <Bar> execute 'Lexplore' expand("%:h") <Bar> normal n<CR>

" Autmatically show autocomplete menu wehn pressing a . in a go file
au filetype go inoremap <buffer> . .<C-x><C-o>

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_powerline_fonts = 1

