set packpath^=~/.vim

set nocompatible               " be iMproved, required
set backspace=indent,eol,start " allow backspacing over autoindent, line breaks and and start of insert
filetype off                   " required
set nobackup                   " no backup files
set noswapfile                 " no swap
set scrolloff=5

nnoremap <Space> <Nop>
let mapleader = " "

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

nnoremap <silent> <M-h> :TmuxNavigateLeft<CR>
nnoremap <silent> <M-j> :TmuxNavigateDown<CR>
nnoremap <silent> <M-k> :TmuxNavigateUp<CR>
nnoremap <silent> <M-l> :TmuxNavigateRight<CR>
nnoremap <silent> <M-ö> :TmuxNavigatePrevious<CR>

" Maps Alt-[H,J,K,L] to resizing a window split
nnoremap <silent> <M-H> <C-w>5<
nnoremap <silent> <M-J> <C-W>5-
nnoremap <silent> <M-K> <C-W>5+
nnoremap <silent> <M-L> <C-w>5>

" Opens netrw in the current directory
nnoremap <leader>pv :Ex<CR>

nnoremap <C-P> :GFiles<cr>
nnoremap <leader>r :GFiles<cr>
nnoremap <leader>p :Files<cr>

" In normal mode, pressing <leader>y will yank the current line into the system clipboard
nnoremap <leader>y "+y

" In visual mode, pressing <leader>y will yank the highlighted selection into the system clipboard
xnoremap <leader>y "+y

function! s:TermNav(direction)
  if &filetype ==# 'toggleterm'
    execute "ToggleTerm"
  elseif winnr('$') > 1
    execute "wincmd " . a:direction
  else
    execute "TmuxNavigate" . a:direction
  endif
endfunction

"nnoremap <C-j> :ToggleTerm<CR>
"tnoremap <C-j> :ToggleTerm<CR>

" Add this to your .vimrc or init.vim

function! ToggleTerm()
  " Check if the terminal buffer is already open and visible
  let l:term_bufnr = bufnr('$')
  while l:term_bufnr >= 1
    if getbufvar(l:term_bufnr, '&buftype') == 'terminal'
      " Check if the terminal buffer is visible in any window
      let l:winid = win_findbuf(l:term_bufnr)[0]
      if l:winid
        " If visible, hide the terminal by closing its window
        execute l:winid . 'wincmd c'
        return
      endif
    endif
    let l:term_bufnr -= 1
  endwhile

  " If no terminal buffer is found or none are visible, open a new one
  botright split :term
endfunction

tnoremap <M-h> <C-\><C-n>:call s:TermNav('Left')<CR>
tnoremap <M-j> <C-\><C-n>:call s:TermNav('Down')<CR>
tnoremap <M-k> <C-\><C-n>:call s:TermNav('Up')<CR>
tnoremap <M-l> <C-\><C-n>:call s:TermNav('Right')<CR>

" Show all open buffers and their status
nnoremap <C-@> :Buffers<CR>
nnoremap <C-l> :bnext<CR>
nnoremap <C-h> :bprevious<CR>

" Directory browser settings
let g:netrw_banner = 0 " Removing the banner
let g:netrw_liststyle = 3 " Changing directory view to tree-style
"let g:netrw_browse_split = 3 " Open files in a new tab
let g:netrw_altv = 1 " Change from left splitting to right splitting
let g:netrw_winsize = 25 " Set the directory explorer width to 25% of the page

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

" In diff mode, navigate up and down changed chunks via <ctrl-[j|k]>
nnoremap <expr> <C-j> &diff ? ']czz' : '<C-w>j'
nnoremap <expr> <C-k> &diff ? '[czz' : '<C-w>k'

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
function! CheckDiffMode(timer)
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

" Moving lines up or down. The mappings work in normal, insert and visual modes,
" allowing you to move the current line, or a selected block of lines.
nnoremap <C-J> :m .+1<CR>==
nnoremap <C-K> :m .-2<CR>==
inoremap <C-J> <Esc>:m .+1<CR>==gi
inoremap <C-K> <Esc>:m .-2<CR>==gi
vnoremap <C-J> :m '>+1<CR>gv=gv
vnoremap <C-K> :m '<-2<CR>gv=gv

" possible values: 'local' (default), 'remote', 'base'
let g:mergetool_prefer_revision = 'local'

" (m) - for working tree version of merged file
" (r) - for 'remote' revision
" (l) - for 'local' revision
" let g:mergetool_layout = 'bmr'

nmap <leader>mt <plug>(MergetoolToggle)
nnoremap <silent> <leader>mb :call mergetool#toggle_layout('mr,b')<CR>

nmap <expr> <C-h> &diff? '<Plug>(MergetoolDiffExchangeLeft)' : '<C-h>'
nmap <expr> <C-l> &diff? '<Plug>(MergetoolDiffExchangeRight)' : '<C-l>'
nmap <expr> <C-j> &diff? '<Plug>(MergetoolDiffExchangeDown)' : '<C-j>'
nmap <expr> <C-k> &diff? '<Plug>(MergetoolDiffExchangeUp)' : '<C-k>'

" Configure gitgutter plugin
let g:gitgutter_enabled = 1
set updatetime=1000
nmap <C-j> <Plug>(GitGutterNextHunk)
nmap <C-k> <Plug>(GitGutterPrevHunk)

