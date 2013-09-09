set clipboard=unnamed
set t_Co=256
set number
set cpoptions+=n
set splitbelow
set splitright
set modelines=0

highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=11 gui=NONE guifg=DarkGrey guibg=NONE

"set runtimepath^=~/.vim/bundle/vim-gitgutter
let g:ctrlp_use_caching = 1
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_show_hidden = 1
let g:ctrlp_extensions = ['tag']
" let g:ctrlp_custom_ignore = { 'dir': '/env$', 'file': '\v\.(pyc)$' }
let g:ctrlp_custom_ignore = 'node_modules\'
set wildignore+=*.swp
set wildignore+=*.pyc
set wildignore+=*.png
set wildignore+=*.jpg
set wildignore+=*.jpeg
set wildignore+=*.pyc
set wildignore+=media
set wildignore+=bootstrap-3.0.0
set wildchar=<Tab> wildmenu wildmode=full

filetype off

call pathogen#infect()

set rtp^=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'othree/html5.vim'
Bundle 'kien/ctrlp.vim'
Bundle 'vim-scripts/django.vim'
Bundle 'Lokaltog/vim-powerline'
Bundle 'nvie/vim-flake8'
Bundle 'airblade/vim-gitgutter'
Bundle 'tpope/vim-fugitive'
Bundle 'kchmck/vim-coffee-script.git'
Bundle 'jimmyhchan/dustjs.vim.git'
Bundle 'juvenn/mustache.vim.git'
Bundle 'groenewege/vim-less'
Bundle 'rking/ag.vim'

let g:gitgutter_escape_grep = 1
let g:gitgutter_eager = 0

let g:Powerline_symbols = 'fancy'
let g:jedi#use_tabs_not_buffers = 0
let g:jedi#popup_on_dot = 0
let g:jedi#show_function_definition = "0"

let g:pyindent_open_paren = '&sw'
let g:pyindent_continue = '&sw'

au BufNewFile,BufReadPost *.coffee setl shiftwidth=2 expandtab

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
set undofile
set undodir=~/.vim/undodir

nnoremap ; :

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
vmap Q gq
nmap Q :q<CR>
nmap O :CtrlPMRUFiles<CR>

" map home row to exit Insert mode
imap jj <Esc>
imap hh <Esc>
imap kk <Esc>
imap lll <Esc>
nmap <F5> :e!<CR>

function! FindPromptNoFilter()
	let str = input("Search: ", "")
	if str == ""
		return
	endif

	:silent! execute "Ag " . str	
	:cw
endfunction

function! FindPrompt()
	let str = input("Search: ", "")
	if str == ""
		return
	endif

	:silent! execute "Ag " . str	
	:cw
endfunction

function! FindWordNoFilter()
	let str = expand("<cword>")
	if str == ""
		return
	endif

	:silent! execute "Ag " . str	
	:cw
endfunction

function! DeleteAllLinesWithThisWord()
	let str = expand("<cword>")
	if str == ""
		return
	endif
	:silent! execute "g/" . str . "/d"
endfunction

function! FindWord()
	let str = expand("<cword>")
	if str == ""
		return
	endif

	:silent! execute "Ag " . str	
	:cw
endfunction

map <F3> :call FindWord()<CR>
map <F4> :call FindWordNoFilter()<CR>
nmap F :call FindPrompt()<CR>
nmap E :call FindPromptNoFilter()<CR>
nmap T :CtrlPTag<CR>
:map <F2> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
nnoremap <leader>d :set modifiable<CR>:call DeleteAllLinesWithThisWord()<CR>:set nomodifiable<CR>
let g:ctrlp_working_path_mode = 0
vmap <Tab> =

:if $VIM_CRONTAB == "true"
:set nobackup
:set nowritebackup
:endif

nmap <F9> :set autowrite<CR>:cp<CR>:set noautowrite<CR>zz
nmap <F10> :set autowrite<CR>:cn<CR>:set noautowrite<CR>zz

nnoremap <leader><space> :noh<cr>:match<cr>
nnoremap <leader>t viwy:tabnew<CR>:e ~/vim-todo.txt<CR>ggPa<CR><Esc>:wq<CR>
nnoremap <leader>T :tabnew<CR>:e ~/vim-todo.txt<CR>
nnoremap <leader>q :conf qa<CR>
nnoremap <leader>v <C-w>v<C-w>l<C-w>n<C-w>h

nmap 90 :e ~/.vimrc<CR>
nmap 91 :e ~/local.vimrc<CR>
nmap 92 :e ~/.bash_profile<CR>
nmap 93 :e ~/local.bashrc<CR>


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

set tags+=tags;/

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

augroup myvimrc
	au!
	au BufWritePost local.vimrc,.vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC
augroup END

set rtp+=$GOROOT/misc/vim
filetype plugin indent on
au BufRead,BufNewFile *.go set filetype=go

au BufReadPost *.prepp set syntax=python

set ignorecase
set smartcase
set gdefault
set visualbell
set showmatch
" set list
" set listchars=tab:▸\ ,eol:¬

set gfn=Menlo\ Regular:h14
syn match Braces display '[<>{}()\[\]]'
set matchtime=0
color ir_black
set nowrap

silent! source ~/local.vimrc

augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END

hi CursorLine cterm=NONE ctermbg=darkgray ctermfg=NONE guibg=#222222 guifg=NONE
hi CursorLineNR cterm=NONE ctermbg=darkgray ctermfg=NONE guibg=#333333 guifg=NONE
nnoremap <Leader>c :set cursorline!<CR>
set cursorline

:nnoremap <silent> <Leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>

nnoremap <leader>g :call GitGrepWord()<CR><CR>


function! s:get_last_python_class()
    let l:retval = ""
    let l:last_line_declaring_a_class = search('^\s*class', 'bnW')
    let l:last_line_starting_with_a_word_other_than_class = search('^\ \(\<\)\@=\(class\)\@!', 'bnW')
    if l:last_line_starting_with_a_word_other_than_class < l:last_line_declaring_a_class
        let l:nameline = getline(l:last_line_declaring_a_class)
        let l:classend = matchend(l:nameline, '\s*class\s\+')
        let l:classnameend = matchend(l:nameline, '\s*class\s\+[A-Za-z0-9_]\+')
        let l:retval = strpart(l:nameline, l:classend, l:classnameend-l:classend)
    endif
    return l:retval
endfunction
 
function! s:get_last_python_def()
    let l:retval = ""
    let l:last_line_declaring_a_def = search('^\s*def', 'bnW')
    let l:last_line_starting_with_a_word_other_than_def = search('^\ \(\<\)\@=\(def\)\@!', 'bnW')
    if l:last_line_starting_with_a_word_other_than_def < l:last_line_declaring_a_def
        let l:nameline = getline(l:last_line_declaring_a_def)
        let l:defend = matchend(l:nameline, '\s*def\s\+')
        let l:defnameend = matchend(l:nameline, '\s*def\s\+[A-Za-z0-9_]\+')
        let l:retval = strpart(l:nameline, l:defend, l:defnameend-l:defend)
    endif
    return l:retval
endfunction
 
function! s:compose_python_location()
    let l:pyloc = s:get_last_python_class()
    if !empty(pyloc)
        let pyloc = pyloc . "."
    endif
    let pyloc = pyloc . s:get_last_python_def()
    return pyloc
endfunction
 
function! <SID>EchoPythonLocation()
    echo s:compose_python_location()
endfunction
 
command! PythonLocation :call <SID>EchoPythonLocation()
nnoremap <Leader>? :PythonLocation<CR>
