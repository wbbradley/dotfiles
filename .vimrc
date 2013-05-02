" Link to this file from your $HOME
" ln -s $SRC_ROOT/dotfiles/.vimrc .vimrc
"

"set runtimepath^=~/.vim/bundle/vim-gitgutter
let g:ctrlp_use_caching = 1
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_show_hidden = 1
let g:ctrlp_extensions = ['tag']
" let g:ctrlp_custom_ignore = { 'dir': '/env$', 'file': '\v\.(pyc)$' }
let g:ctrlp_custom_ignore = { 'file': '\v\.(pyc)$' }
set wildignore+=*.pyc
set wildchar=<Tab> wildmenu wildmode=full

filetype off

call pathogen#infect()

set rtp^=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'kien/ctrlp.vim'
"Bundle 'Lokaltog/vim-powerline'
Bundle 'davidhalter/jedi-vim'
"Bundle 'groenewege/vim-less.git'

if has("gui_running")
	let g:Powerline_symbols = 'fancy'
else
	let g:Powerline_symbols = 'compatible'
endif

let g:jedi#use_tabs_not_buffers = 0
let g:jedi#popup_on_dot = 0
let g:jedi#show_function_definition = "0"

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
set laststatus=2
set encoding=utf-8
set ttyfast

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set completeopt=longest,menuone
" :inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" map home row to exit Insert mode
imap jj <Esc>
imap hh <Esc>
imap kk <Esc>
imap lll <Esc>
nmap <F5> :e<CR>

function! FindPromptNoFilter()
	let str = input("Search: ", "")
	if str == ""
		return
	endif

	:silent! execute "grep -srn --binary-files=without-match --exclude='*.log' --exclude-dir=migrations --exclude-dir=.git . -e " . str
	
	:cw
endfunction

function! FindPrompt()
	let str = input("Search: ", "")
	if str == ""
		return
	endif

	:silent! execute "grep -srn --binary-files=without-match --exclude='*.log' --exclude-dir=migrations --exclude-dir=.git --exclude-dir=env . -e " . str
	
	:cw
endfunction

function! FindWordNoFilter()
	let str = expand("<cword>")
	if str == ""
		return
	endif

	:silent! execute "grep -srn --binary-files=without-match --exclude='*.log' --exclude-dir=migrations --exclude-dir=.git . -e " . str
	
	:cw
endfunction

function! FindWord()
	let str = expand("<cword>")
	if str == ""
		return
	endif

	:silent! execute "grep -srn --binary-files=without-match --exclude='*.log' --exclude-dir=migrations --exclude-dir=.git --exclude-dir=env . -e " . str
	
	:cw
endfunction

map <F3> :call FindWord()<CR>
map <F4> :call FindWordNoFilter()<CR>
nmap F :call FindPrompt()<CR>
nmap E :call FindPromptNoFilter()<CR>
nmap T :CtrlPTag<CR>
vmap <Tab> =
nmap O :ls<CR>:b

:if $VIM_CRONTAB == "true"
:set nobackup
:set nowritebackup
:endif

nmap <F9> :set autowrite<CR>:cp<CR>:set noautowrite<CR>zz
nmap <F10> :set autowrite<CR>:cn<CR>:set noautowrite<CR>zz
nmap C i/*  */<CR><Esc>klllli
nmap <F11> :w<CR>
imap <F11> <Esc>:w<CR>

" F4 - swap header and cpp files
" nmap <F4> :wa<CR> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
" imap <F4> <Esc> <F4>
" vmap <F4> <Esc> <F4>

" F7 - incremental build
nmap <F7> :wa<CR> :!clear <CR><CR> :make<CR><CR>
imap <F7> <Esc> <F7>
vmap <F7> <Esc> <F7>

" map Shift Tab to outdent
nmap <S-Tab> V<
vmap <S-Tab> <

" map Tab to indent
" nmap <Tab> V>
vmap <Tab> >

" C-F7 - clean build
nmap <C-F7> :!make clean <CR><CR> <F7>
imap <C-F7> <Esc> <C-F7>
vmap <C-F7> <Esc> <C-F7>

vmap <silent> ,y "xy<CR>:wviminfo! ~/.viminfo
nmap <silent> ,p :rviminfo! ~/.viminfo<CR>"xp

vmap <C-c> y:call system("pbcopy", getreg("\""))<CR>
" nmap <C-v> :call setreg("\"",system("pbpaste"))<CR>p

set tags=~/tags

nnoremap s :exec "normal i".nr2char(getchar())."\el"<CR>
nnoremap S :exec "normal a".nr2char(getchar())."\el"<CR>


" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

set cino=:0g0
set sw=4
set ts=4
autocmd FileType python setlocal sw=4 sts=4 ts=4 expandtab

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

