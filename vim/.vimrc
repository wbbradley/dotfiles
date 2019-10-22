" Use Vim settings, rather then Vi settings (much better!).
set laststatus=2
set encoding=utf-8
set ttyfast
set undofile
set undodir=~/.vim/undodir
" set path=src,$HOME/src

if has('win32')
elseif has('mac')
	set clipboard=unnamed
elseif has('unix')
	set clipboard=unnamedplus
endif

set t_Co=256
set nonumber
set cpoptions+=n
set splitbelow
set splitright
set modeline
set modelines=1
set noesckeys

set wildignore+=*.o
set wildignore+=*.a
set wildignore+=experimental
set wildignore+=toolchains

let g:EditorConfig_max_line_indicator = 'none'

set wildchar=<Tab> wildmenu wildmode=full

filetype off

set rtp+=~/.vim/bundle/Vundle.vim
set rtp+=~/src/vim-zion

call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plugin 'junegunn/fzf.vim'

Plugin 'editorconfig/editorconfig-vim'
" Plugin 'mileszs/ack.vim'
" Plugin 'tpope/vim-fireplace'
" Plugin 'othree/html5.vim'
" Plugin 'vim-scripts/YankRing.vim'
" Plugin 'maxbrunsfeld/vim-yankstack'
" Plugin 'jmcantrell/vim-virtualenv'
" Plugin 'vim-scripts/django.vim'
Plugin 'nvie/vim-flake8'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
" Plugin 'tpope/vim-dispatch'
" Plugin 'tpope/vim-unimpaired'
" Plugin 'kchmck/vim-coffee-script.git'
" Plugin 'jimmyhchan/dustjs.vim.git'
" Plugin 'juvenn/mustache.vim.git'
" Plugin 'Lokaltog/vim-easymotion'
" Plugin 'groenewege/vim-less'
" Plugin 'rking/ag.vim'
" Plugin 'fweep/vim-tabber'
" Plugin 'pangloss/vim-javascript'
" Plugin 'mxw/vim-jsx'
Plugin 'scrooloose/syntastic'

Plugin 'prabirshrestha/vim-lsp'

Plugin 'bitc/vim-hdevtools'
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
" Plugin 'IN3D/vim-raml'
" Plugin 'elzr/vim-json'
" Plugin 'Superbil/llvm.vim'
" Plugin 'flowtype/vim-flow'
" Plugin 'leafgarden/typescript-vim'
call vundle#end()


let g:hdevtools_stack = 1
let g:airline#extensions#ale#enabled = 1

nnoremap <Leader>ht :GhcModType<cr>
nnoremap <Leader>htc :GhcModTypeClear<cr>
autocmd FileType haskell nnoremap <buffer> <leader>? :call ale#cursor#ShowCursorDetail()<CR>

let g:gitgutter_max_signs = 2000
" let g:airline_powerline_fonts = 1
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
let g:go_version_warning = 0
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"
let g:vim_json_syntax_conceal = 0
let g:jsx_ext_required = 0

augroup filetypedetect
    au BufRead,BufNewFile *.pyi setfiletype python
augroup END

" Make the quickfix window take up the entirety of the bottom of the window
" when it opens
autocmd FileType qf wincmd J

autocmd BufNewFile,BufReadPost *.coffee setl shiftwidth=2 expandtab
" autocmd BufNewFile,BufReadPost *.js set autoindent noexpandtab ts=2 sw=2
" autocmd BufNewFile,BufReadPost *.jsx set autoindent noexpandtab ts=2 sw=2

autocmd FileType gitcommit setlocal textwidth=71
autocmd FileType go setlocal tabstop=4 shiftwidth=4
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
autocmd FileType config setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab

augroup Haskell
  autocmd FileType haskell nnoremap <buffer> <F1> :HdevtoolsType<CR>
  autocmd FileType haskell nnoremap <buffer> <F2> :HdevtoolsInfo<CR>
  autocmd FileType haskell nnoremap <buffer> <F3> :HdevtoolsClear<CR>
augroup END

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
vmap Q gq
nmap Q VQ

nmap <C-p> :Files<CR>
nmap M :History<CR>
nmap <CR><CR> :!<CR>

" map home row to exit Insert mode
inoremap jk <Esc>
nmap <leader>' i'<CR>'<Esc>gqj
nmap <leader>" i"<CR>"<Esc>gqj
vnoremap . :norm.<CR>

function! Peg()
	let filename = expand('%:p')
	execute "!peg " . filename
endfunction

nmap <leader>P :call Peg()<CR>
nmap <leader>9P :e ~/pegged.txt<CR>

function! FindPrompt()
	let str = input("Search: ", "")
	if str == ""
		return
	endif

	execute "Rg " . str
endfunction

function! DeleteAllLinesWithThisWord()
	let str = expand("<cword>")
	if str == ""
		return
	endif
	:silent! execute "g/" . str . "/d"
endfunction

function! FindWordUnderCursor()
	let str = expand("<cword>")
	if str == ""
		return
	endif

	execute "Rg " . str
endfunction

function! FindTagUnderCursor()
	let str = expand("<cword>")
	if str == ""
		return
	endif

	execute "Tags " . str
endfunction

" Add highlighting for function definition in C++
function! EnhanceCppSyntax()
  syn match cppFuncDef "::\~\?\zs\h\w*\ze([^)]*\()\s*\(const\)\?\)\?$"
  hi def link cppFuncDef Special
endfunction

nnoremap <leader>~ :!build-ctags<CR>
nnoremap <leader>` :!build-ctags<CR>

nnoremap <F3> :call FindWordUnderCursor()<CR>

nmap <F4> :wa<CR> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
inoremap <F4> <Esc> <F4>
vnoremap <F4> <Esc> <F4>

nnoremap F :wa<CR>:call FindPrompt()<CR>
nnoremap T :Tags<CR>
nnoremap g] :call FindTagUnderCursor()<CR>

map <F5> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
"nnoremap <leader>d :set modifiable<CR>:call DeleteAllLinesWithThisWord()<CR>:set nomodifiable<CR>
nnoremap <leader>e :e `=expand('%:p:h')`<CR>
nnoremap <leader>D :cd `=expand('%:p:h')`<CR>:pwd<CR>

vmap <Tab> =
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

:if $VIM_CRONTAB == "true"
:set nobackup
:set nowritebackup
:endif

nmap <F9> :setlocal autowrite<CR>:cprev<CR>:setlocal noautowrite<CR>zz
nmap <F10> :setlocal autowrite<CR>:cnext<CR>:setlocal noautowrite<CR>zz

" turning syntax on tends to redraw the screen nicely
nnoremap <leader><space> :syn on<cr>:noh<cr>:match<cr>:set nopaste<CR>:set colorcolumn=0<CR>:HdevtoolsClear<CR>
nnoremap <leader>t viwy:tabnew<CR>:e ~/vim-todo.txt<CR>ggPa<CR><Esc>:wq<CR>
nnoremap <leader>T :tabnew<CR>:e ~/vim-todo.txt<CR>
nnoremap <leader>q :conf qa<CR>
nnoremap <leader>v <C-w>v<C-w>l<C-w>n<C-w>h

nnoremap <leader>9t :e tests/test_basic.zion<CR>:make<CR>
" nnoremap <leader>9w :cexpr system('wmake ' . shellescape(expand('%:r')))
nnoremap <leader>9w :e .wmake<CR>
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

set tags=tags

nnoremap s :exec "normal i".nr2char(getchar())."\el"<CR>
nnoremap S :exec "normal a".nr2char(getchar())."\el"<CR>


" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

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

autocmd FileType * setlocal colorcolumn=0
autocmd FileType ts setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType javascript setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType yaml setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType python setlocal sw=4 sts=4 ts=4 expandtab
autocmd FileType htmldjango setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType html setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType less setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType css setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType haskell setlocal sw=2 sts=2 ts=8 expandtab shiftround
autocmd FileType haskell setlocal makeprg=stack\ build
autocmd FileType markdown setlocal textwidth=80 expandtab nocindent noautoindent nosmartindent cino=
autocmd FileType conf setlocal expandtab sw=2 sts=2 smartindent
" autocmd FileType sh setlocal expandtab sw=2 sts=2 ts=2 expandtab smartindent

augroup myvimrc
	autocmd!
	autocmd BufWritePost local.vimrc,.vimrc so $MYVIMRC
augroup END

augroup filetypedetect
    au! BufRead,BufNewFile *.bashrc setfiletype sh
augroup END

set ignorecase
set smartcase
set gdefault
set visualbell
set showmatch
set nowrap
set guifont=Menlo\ Regular:h10
set matchtime=0
set hlsearch
syntax on
colorscheme ir_black

syn match Braces display '[<>{}()\[\]]'

let c_no_curly_error=1

silent! source ~/local.vimrc

