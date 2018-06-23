" Use Vim settings, rather then Vi settings (much better!).
set laststatus=2
set encoding=utf-8
set ttyfast
set undofile
set undodir=~/.vim/undodir

set clipboard=unnamedplus
set makeprg=make\ -j8
set t_Co=256
set number
set cpoptions+=n
set splitbelow
set splitright
set modeline
set modelines=1
set noesckeys

set textwidth=100

"set runtimepath^=~/.vim/bundle/vim-gitgutter
let g:ctrlp_use_caching = 1
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_show_hidden = 1
let g:ctrlp_extensions = ['tag']
let g:ctrlp_custom_ignore = ''
let g:ctrlp_regexp = 0
let g:ctrlp_lazy_update = 1
let g:ctrlp_switch_buffer = 0
" let g:ctrlp_user_command = 'find %s -type f'       " MacOSX/Linux

set wildignore+=migrations
set wildignore+=build
set wildignore+=*.trace
set wildignore+=env
set wildignore+=.mypy_cache
set wildignore+=bower_components
set wildignore+=htmlcov
set wildignore+=.sass-cache
set wildignore+=node_modules
set wildignore+=docs
set wildignore+=tools
set wildignore+=TableGen
set wildignore+=llvm-c
" set wildignore+=assets
set wildignore+=*.swp
set wildignore+=*.o
set wildignore+=*.bc
set wildignore+=.coverage
set wildignore+=*.pyc
set wildignore+=*.png
set wildignore+=*.egg
set wildignore+=*.jpg
set wildignore+=*.s
set wildignore+=*.jpeg
set wildignore+=*.class
set wildignore+=vcrpy_*
set wildignore+=vendor
set wildignore+=.elasticbeanstalk
set wildignore+=*.zx
set wildignore+=media
set wildignore+=.git
set wildignore+=bootstrap-3.0.0
set wildignore+=site-packages
set wildchar=<Tab> wildmenu wildmode=full

filetype off

" call pathogen#infect()

set rtp^=~/.vim/bundle/vundle/

call vundle#begin()

" Plugin 'OmniSharp/omnisharp-vim'
" Plugin 'tpope/vim-fireplace'
" Plugin 'othree/html5.vim'
" Plugin 'vim-scripts/YankRing.vim'
" Plugin 'maxbrunsfeld/vim-yankstack'
" Plugin 'jmcantrell/vim-virtualenv'
Plugin 'kien/ctrlp.vim'
" Plugin 'vim-scripts/django.vim'
Plugin 'nvie/vim-flake8'
" Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
" Plugin 'tpope/vim-dispatch'
" Plugin 'tpope/vim-unimpaired'
" Plugin 'kchmck/vim-coffee-script.git'
" Plugin 'jimmyhchan/dustjs.vim.git'
" Plugin 'juvenn/mustache.vim.git'
" Plugin 'Lokaltog/vim-easymotion'
" Plugin 'groenewege/vim-less'
Plugin 'rking/ag.vim'
" Plugin 'fweep/vim-tabber'
" Plugin 'pangloss/vim-javascript'
" Plugin 'mxw/vim-jsx'
" Plugin 'scrooloose/syntastic'
Plugin 'hynek/vim-python-pep8-indent.git'
Plugin 'christoomey/vim-tmux-navigator'
" Plugin 'sjl/threesome.vim.git'
Plugin 'bling/vim-airline'
" Plugin 'toyamarinyon/vim-swift'
" Plugin 'ryanss/vim-hackernews'
Plugin 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plugin 'terryma/vim-expand-region'
Plugin 'terryma/vim-multiple-cursors'
" Plugin 'solarnz/thrift.vim'
Plugin 'hdima/python-syntax'
Plugin 'zionlang/vim-zion'
" Plugin 'IN3D/vim-raml'
" Plugin 'elzr/vim-json'
" Plugin 'Superbil/llvm.vim'
" Plugin 'flowtype/vim-flow'
call vundle#end()


let g:airline#extensions#ale#enabled = 1

nnoremap <Leader>ht :GhcModType<cr>
nnoremap <Leader>htc :GhcModTypeClear<cr>
autocmd FileType haskell nnoremap <buffer> <leader>? :call ale#cursor#ShowCursorDetail()<CR>

let g:gitgutter_max_signs = 2000
let g:airline_powerline_fonts = 1
" let g:airline_section_z = ''
let g:airline_section_warning = ''
" let g:syntastic_python_pylint_post_args='--disable=W0511,E1103,E1101,F0401,R0913,C0103,W0142,C0111,C0103,W0232,E0611,R0201,R0903,E1002,W0613'
" let g:syntastic_go_checkers = ['go', 'golint', 'govet', 'errcheck']
let g:syntastic_javascript_checkers = ['jsxhint']
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }

let g:gitgutter_escape_grep = 1
let g:gitgutter_eager = 0

let g:Powerline_symbols = 'fancy'
let g:jedi#use_tabs_not_buffers = 0
let g:jedi#popup_on_dot = 0
let g:jedi#show_function_definition = "0"

let g:pyindent_open_paren = '&sw'
let g:pyindent_continue = '&sw'

" let g:go_highlight_functions = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_structs = 1
" let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"
let g:vim_json_syntax_conceal = 0
let g:jsx_ext_required = 0

let g:OmniSharp_selector_ui = 'ctrlp'  " Use ctrlp.vim

augroup filetypedetect
    au BufRead,BufNewFile *.pyi setfiletype python
    " associate *.foo with php filetype
augroup END

augroup omnisharp_commands
    autocmd FileType cs nnoremap gd :OmniSharpGotoDefinition<cr>
    autocmd FileType cs nnoremap <leader>ft :OmniSharpFindType<cr>
    autocmd FileType cs nnoremap <leader>fu :OmniSharpFindUsages<cr>
augroup END

" Make the quickfix window take up the entirety of the bottom of the window
" when it opens
autocmd FileType qf wincmd J

autocmd BufNewFile,BufReadPost *.coffee setl shiftwidth=2 expandtab
" autocmd BufNewFile,BufReadPost *.js set autoindent noexpandtab ts=2 sw=2
" autocmd BufNewFile,BufReadPost *.jsx set autoindent noexpandtab ts=2 sw=2

autocmd FileType go nmap <Leader>s <Plug>(go-implements)
autocmd FileType go nmap <Leader>i <Plug>(go-info)
autocmd FileType go nmap <Leader>gd <Plug>(go-doc)
autocmd FileType go nmap <Leader>gv <Plug>(go-doc-vertical)
autocmd FileType go nmap <Leader>gb <Plug>(go-doc-browser)
autocmd FileType go nmap <leader>r <Plug>(go-run)
autocmd FileType go nmap <leader>b <Plug>(go-build)
autocmd FileType go nmap <leader>t <Plug>(go-test)
autocmd FileType go nmap <leader>c <Plug>(go-coverage)
autocmd FileType go nmap <Leader>ds <Plug>(go-def-split)
autocmd FileType go nmap <Leader>dv <Plug>(go-def-vertical)
autocmd FileType go nmap <Leader>dt <Plug>(go-def-tab)
autocmd FileType go nmap <Leader>e <Plug>(go-rename)
autocmd FileType go nmap <C-]> :GoDef<CR>zz
autocmd FileType config set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab

nnoremap ; :
nnoremap <C-]> <C-]>zz
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz
nnoremap <leader>rm! :call delete(expand('%')) \| bdelete!<CR>
nnoremap <leader>+ viwyo"""<Esc>pA."""<Esc>_wvU<Esc>V:s/_/ /<CR>:noh<CR>:match<CR>
nnoremap <C-b> :echo "You're not in tmux!"<CR>
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz

nnoremap <Leader>} mhv%='h
nnoremap <Leader><Leader> mhva}='h
autocmd Syntax cpp call EnhanceCppSyntax()

" set clipboard=unnamedplus

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set lazyredraw
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
" :inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
vnoremap Q gq
vnoremap gQ gq
nnoremap gQ gq

nmap <leader>f :CtrlP<CR><C-\>w
nmap <CR><CR> :!<CR>

" map home row to exit Insert mode
inoremap jk <Esc>
nmap <leader>' i'<CR>'<Esc>gqj
nmap <leader>" i"<CR>"<Esc>gqj
vnoremap . :norm.<CR>

function! FindPromptNoFilter()
	let str = input("Search: ", "")
	if str == ""
		return
	endif

	:silent! execute "Ag -a '" . str . "'"
	:cw
endfunction

function! FindPrompt()
	let str = input("Search: ", "")
	if str == ""
		return
	endif

	:silent! execute "Ag '" . str . "'"
	:cw
endfunction

function! FindWordNoFilter()
	let str = expand("<cword>")
	if str == ""
		return
	endif

	:silent! execute "Ag -a '" . str . "'"
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

	:silent! execute "Ag '" . str . "'"
	:cw
endfunction

" Add highlighting for function definition in C++
function! EnhanceCppSyntax()
  syn match cppFuncDef "::\~\?\zs\h\w*\ze([^)]*\()\s*\(const\)\?\)\?$"
  hi def link cppFuncDef Special
endfunction

nnoremap <leader>~ :!build-ctags<CR>
nnoremap <leader>` :!build-ctags<CR>
nnoremap <leader>[ :set paste<CR>i
inoremap <leader>] <Esc>:set nopaste<CR>

nnoremap <F3> :call FindWord()<CR>
nnoremap <C-F3> :call FindWordNoFilter()<CR>

nnoremap <F4> :wa<CR> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
inoremap <F4> <Esc> <F4>
vnoremap <F4> <Esc> <F4>

nnoremap F :wa<CR>:call FindPrompt()<CR>
nnoremap E :wa<CR>:call FindPromptNoFilter()<CR>
nnoremap T :CtrlPTag<CR>

:map <F2> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
"nnoremap <leader>d :set modifiable<CR>:call DeleteAllLinesWithThisWord()<CR>:set nomodifiable<CR>
nnoremap <leader>e :e `=expand('%:p:h')`<CR>
nnoremap <leader>D :cd `=expand('%:p:h')`<CR>:pwd<CR>
" set foldmethod=indent
" set foldminlines=10
" set foldnestmax=5

let g:ctrlp_working_path_mode = 0
vmap <Tab> =
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

let g:ag_prg="ag --vimgrep"

:if $VIM_CRONTAB == "true"
:set nobackup
:set nowritebackup
:endif

nmap <F9> :set autowrite<CR>:cprev<CR>:set noautowrite<CR>zz
nmap <F10> :set autowrite<CR>:cnext<CR>:set noautowrite<CR>zz

nnoremap M :CtrlPMRUFiles<CR>

" turning syntax on tends to redraw the screen nicely
nnoremap <leader><space> :syn on<cr>:noh<cr>:match<cr>:set nopaste<CR>:set textwidth=100<CR>
nnoremap <leader>t viwy:tabnew<CR>:e ~/vim-todo.txt<CR>ggPa<CR><Esc>:wq<CR>
nnoremap <leader>T :tabnew<CR>:e ~/vim-todo.txt<CR>
nnoremap <leader>q :conf qa<CR>
nnoremap <leader>v <C-w>v<C-w>l<C-w>n<C-w>h

nnoremap <leader>90 :e ~/.vimrc<CR>
nnoremap <leader>91 :e ~/local.vimrc<CR>
nnoremap <leader>92 :e ~/.bashrc<CR>
nnoremap <leader>93 :e ~/local.bashrc<CR>
nnoremap <leader>9z :e ~/src/vim-zion/syntax/zion.vim<CR>
nnoremap <leader>d Odbg();<Esc>_
nnoremap <leader>i Oimport ipdb<CR>ipdb.set_trace()<Esc>j_
nnoremap <leader>p Oimport pdb<CR>pdb.set_trace()<Esc>j_
nnoremap <leader>r Ofrom celery.contrib import rdb<CR>rdb.set_trace()<Esc>j_

" F7 & F8 - incremental build
nmap <F7> :wa<CR> :!clear <CR><CR> :make<CR><CR>zz
imap <F7> <Esc> <F7>
vmap <F7> <Esc> <F7>

nmap <F8> :wa<CR> :!clear <CR><CR> :make<CR><CR>zz
imap <F8> <Esc> <F7>
vmap <F8> <Esc> <F7>

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

nmap c<Space> ct_

set tags+=tags;./tags

nnoremap s :exec "normal i".nr2char(getchar())."\el"<CR>
nnoremap S :exec "normal a".nr2char(getchar())."\el"<CR>


" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
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
autocmd FileType javascript setlocal sw=4 sts=4 ts=4 expandtab
autocmd FileType yaml setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType python setlocal sw=4 sts=4 ts=4 expandtab
autocmd FileType htmldjango setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType html setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType less setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType css setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType cpp setlocal sw=4 sts=4 ts=4
autocmd FileType haskell setlocal sw=2 sts=2 ts=8 expandtab shiftround
autocmd FileType haskell set makeprg=stack\ build

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

augroup myvimrc
	autocmd!
	autocmd BufWritePost local.vimrc,.vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC
augroup END

" set rtp+=$GOROOT/misc/vim
filetype plugin indent on
" autocmd BufRead,BufNewFile *.go set filetype=go
autocmd BufRead,BufNewFile *.eco set filetype=html

autocmd BufReadPost *.prepp set syntax=python

set ignorecase
set smartcase
set gdefault
set visualbell
set showmatch
" set list
" set listchars=tab:▸\ ,eol:¬

set gfn=Menlo\ Regular:h10
syn match Braces display '[<>{}()\[\]]'
set matchtime=0
colorscheme ir_black
set nowrap

silent! source ~/local.vimrc

augroup CursorLine
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END

" set cc=80
" hi ColorColumn cterm=NONE ctermbg=NONE ctermfg=NONE guibg=#111111 guifg=NONE

hi CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE guibg=#222222 guifg=NONE
hi CursorLineNR cterm=NONE ctermbg=NONE ctermfg=NONE guibg=#333333 guifg=NONE
set cursorline
nnoremap <silent> <Leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>

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

" Search for the ... arguments separated with whitespace (if no '!'),
" or with non-word characters (if '!' added to command).
function! SearchMultiLine(bang, ...)
  if a:0 > 0
    let sep = '\_.\{-}'
    let @/ = join(a:000, sep)
  endif
endfunction

let c_no_curly_error=1

" Tabber options
" set tabline=%!tabber#TabLine()
set guioptions-=e
let g:tabber_filename_style = 'filename'
let g:tabber_divider_style = 'fancy'

command! -bang -nargs=* -complete=tag S call SearchMultiLine(<bang>0, <f-args>)|normal! /<C-R>/<CR>
"runtime $VIMRUNTIME/macros/matchit.vim

" :match ErrorMsg '\%>80v.\+'
"
" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

