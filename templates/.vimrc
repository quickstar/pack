set packpath^=~/.vim

set nocompatible              " be iMproved, required
filetype off                  " required
set nobackup                  " no backup files
set noswapfile                " no swap

nnoremap <Space> <Nop>
let mapleader = " "

filetype plugin indent on	" required

" Enable 'true color' support in the terminal if available
if &t_Co >= 256 || has("gui_running")
	if (has("termguicolors"))
		set termguicolors
	endif
endif

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

" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_powerline_fonts = 1

" Autmatically show autocomplete menu wehn pressing a . in a go file
au filetype go inoremap <buffer> . .<C-x><C-o>

" Configure vimdiff options
set diffopt=internal,filler,vertical,context:3,foldcolumn:1,indent-heuristic,algorithm:patience

" In diff mode, navigate up and down changed hunks via <alt-[j|k]>
nnoremap <expr> <C-j> &diff ? ']czz' : '<C-w>j'
nnoremap <expr> <C-k> &diff ? '[czz' : '<C-w>k'

nmap <silent> <leader>q :call <SID>SmartQuit()<CR>

function s:SmartQuit()
	if get(s:, 'is_started_as_vim_diff', 0)
		qall
		return
	endif
	quit
endfunction

" Detect if vim is started as a diff tool (vim -d, vimdiff)
" - Disable syntax highlighting
" - Disable spell checking
" - Disable relative number
" NOTE: Does not work when you start Vim as usual and enter diff mode using :diffthis
if &diff
  let s:is_started_as_vim_diff = 1
  syntax off
  setlocal nospell
  set relativenumber&
endif

augroup aug_diffs
  au!
  " Inspect whether some windows are in diff mode, and apply changes for such windows
  " Run asynchronously, to ensure '&diff' option is properly set by Vim
  au WinEnter,BufEnter * call timer_start(50, 'CheckDiffMode')
augroup END

" In diff mode:
" - Disable syntax highlighting
" - Disable spell checking
function CheckDiffMode(timer)
  let curwin = winnr()

  " Check each window
  for _win in range(1, winnr('$'))
    exe "noautocmd " . _win . "wincmd w"

    call s:change_option_in_diffmode('b:', 'syntax', 'off')
    call s:change_option_in_diffmode('w:', 'spell', 0, 1)
  endfor

  " Get back to original window
  exe "noautocmd " . curwin . "wincmd w"
endfunction

" Detect window or buffer local option is in sync with diff mode
function s:change_option_in_diffmode(scope, option, value, ...)
  let isBoolean = get(a:, "1", 0)
  let backupVarname = a:scope . "_old_" . a:option

  " Entering diff mode
  if &diff && !exists(backupVarname)
    exe "let " . backupVarname . "=&" . a:option
    call s:set_option(a:option, a:value, 1, isBoolean)
  endif

  " Exiting diff mode
  if !&diff && exists(backupVarname)
    let oldValue = eval(backupVarname)
    call s:set_option(a:option, oldValue, 1, isBoolean)
    exe "unlet " . backupVarname
  endif
endfunction

function s:set_option(option, value, ...)
  let isLocal = get(a:, "1", 0)
  let isBoolean = get(a:, "2", 0)
  if isBoolean
    exe (isLocal ? "setlocal " : "set ") . (a:value ? "" : "no") . a:option
  else
    exe (isLocal ? "setlocal " : "set ") . a:option . "=" . a:value
  endif
endfunction

" Configure gitgutter plugin
let g:gitgutter_enabled = 1
set updatetime=1000
nmap <C-j> <Plug>(GitGutterNextHunk)
nmap <C-k> <Plug>(GitGutterPrevHunk)

" Moving lines up or down. The mappings work in normal, insert and visual modes,
" allowing you to move the current line, or a selected block of lines.
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv
