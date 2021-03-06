" Use Vim settings, rather then Vi settings (much better!).
set laststatus=2
set encoding=utf-8
set ttyfast
" set undofile
set undodir=~/.vim/undodir
set noshowmode
set exrc
set number

if has('win32')
elseif has('mac')
	set clipboard=unnamed
else
	set clipboard=unnamedplus
endif

" set t_Co=256
set cpoptions+=n
set splitbelow
set splitright
set modeline
set modelines=2
set noesckeys
set sw=2 sts=2 noexpandtab
set timeoutlen=1000 ttimeoutlen=0

set wildignore+=*.o
set wildignore+=*.a
set wildignore+=experimental
set wildignore+=toolchains

let g:EditorConfig_max_line_indicator = 'none'
let g:ruby_indent_assignment_style = 'variable'
" Turn on case-insensitive feature for EasyMotion
let g:EasyMotion_smartcase = 1
nmap ] <Plug>(easymotion-prefix)
nmap , <Plug>(easymotion-overwin-f)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

let g:vim_markdown_folding_disabled = 1

set wildchar=<Tab> wildmenu wildmode=full
set tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab

" set rtp+=~/src/vim-zion

let g:hindent_on_save = 0
" let g:hdevtools_stack = 1
let g:python_pep8_indent_hang_indent = 4

let g:lightline = get(g:, 'lightline', {})
let g:lightline.component_expand = get(g:lightline, 'component_expand', {})
let g:lightline.component_expand.linter_checking = 'lightline#ale#checking'
let g:lightline.component_expand.linter_warnings = 'lightline#ale#warnings'
let g:lightline.component_expand.linter_errors = 'lightline#ale#errors'
let g:lightline.component_expand.linter_ok = 'lightline#ale#ok'

let g:lightline.component_type = {
      \     'tabs': 'tabsel',
      \     'close': 'raw',
      \     'linter_checking': 'left',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'left',
      \ }

let g:lightline.component_function = get(g:lightline, 'component_function', {})
let g:lightline.component_function.filename = 'LightlineFilename'

function! LightlineFilename()
  return expand('%')
endfunction

let g:lightline.active = get(g:lightline, 'active', {})
let g:lightline.active.right = [
      \   [ 'lineinfo' ],
		  \   [ 'fileformat', 'fileencoding', 'filetype' ],
      \   [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ]
      \ ]
let g:ale_markdown_markdownlint_executable = './node_modules/.bin/markdownlint'
let g:ale_ruby_rubocop_executable = 'rubocop'

" ln -s "$HOME/src/dotfiles/bin/bin/lint" "$HOME/bin/lint"
let g:ale_python_pylint_executable = 'lint'
let g:ale_python_pylint_change_directory = 0
let g:ale_python_pylint_use_global = 1

let g:ale_linters = {
      \ 'markdown': ['markdownlint'],
      \ 'python': ['pylint'],
      \ 'haskell': ['stack-build'],
      \ 'cpp': ['clang'],
      \ 'c': ['clang'],
      \ 'zion': ['zion'],
      \ 'ruby': ['rubocop'],
      \ }

let g:multi_cursor_exit_from_insert_mode=1
let g:multi_cursor_exit_from_visual_mode=1

augroup Haskell
  autocmd!
  autocmd FileType haskell nnoremap <buffer> <leader>? :call ale#cursor#ShowCursorDetail()<cr>
  " autocmd FileType haskell nnoremap <buffer> <Leader>ht :GhcModType<cr>
  " autocmd FileType haskell nnoremap <buffer> <Leader>htc :GhcModTypeClear<cr>
augroup END

let g:multi_cursor_exit_from_visual_mode=1
let g:multi_cursor_exit_from_insert_mode=1
let g:gitgutter_max_signs = 2000

let g:airline#extensions#ale#enabled = 1
let g:airline_powerline_fonts = 0
" let g:airline_section_z = ''
" let g:airline_section_warning = ''

let g:gitgutter_escape_grep = 1
let g:gitgutter_eager = 0

let g:pyindent_open_paren = '&sw'
let g:pyindent_continue = '&sw'

" let g:go_version_warning = 0
" let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"
let g:go_def_mode='gopls'
" let g:go_info_mode='gopls'
" let g:go_fmt_fail_silently = 0

let g:go_decls_mode = 'fzf'
" let g:go_def_mapping_enabled = 1
" let g:go_doc_keywordprg_enabled = 0
" let g:go_fmt_command = 'goimports'
" let g:go_fmt_fail_silently = 1
" let g:go_code_completion_enabled = 1
let g:go_list_type = 'quickfix'
" let g:go_highlight_build_constraints = 1
" let g:go_highlight_generate_tags = 1
" let g:go_highlight_functions = 1
" let g:go_highlight_function_calls = 1
" let g:go_highlight_operators = 1
" let g:go_statusline_duration = 10000

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

augroup Ruby
  au!
  autocmd FileType ruby,eruby setlocal expandtab shiftwidth=2 tabstop=2
  autocmd FileType ruby setlocal commentstring=#\ %s
  autocmd FileType ruby setlocal iskeyword+=!
  autocmd FileType ruby,eruby setlocal iskeyword+=?
  autocmd FileType ruby nnoremap <leader>d Odebugger<Esc>_
  autocmd FileType eruby nnoremap <leader>d O<% debugger %><Esc>_
augroup END

autocmd FileType gitcommit setlocal textwidth=71
autocmd FileType config setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
autocmd FileType sql setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab

augroup Golang
  autocmd!
  autocmd FileType go setlocal tabstop=4 shiftwidth=4
  autocmd FileType go nmap <buffer> <Leader>s <Plug>(go-implements)
  autocmd FileType go nmap <buffer> <Leader>i <Plug>(go-info)
  autocmd FileType go nmap <buffer> <Leader>gd <Plug>(go-doc)
  autocmd FileType go nmap <buffer> <Leader>gv <Plug>(go-doc-vertical)
  autocmd FileType go nmap <buffer> <Leader>gb <Plug>(go-doc-browser)
  autocmd FileType go nmap <buffer> <leader>r <Plug>(go-run)
  autocmd FileType go nmap <buffer> <leader>b <Plug>(go-build)
  autocmd FileType go nmap <buffer> <leader>t <Plug>(go-test)
  " autocmd FileType go nmap <leader>c <Plug>(go-coverage)
  autocmd FileType go nmap <buffer> <Leader>ds <Plug>(go-def-split)
  autocmd FileType go nmap <buffer> <Leader>dv <Plug>(go-def-vertical)
  autocmd FileType go nmap <buffer> <Leader>dt <Plug>(go-def-tab)
  autocmd FileType go nmap <buffer> <Leader>e <Plug>(go-rename)
  autocmd FileType go nmap <buffer> <C-]> :GoDef<CR>zz
  autocmd FileType go nmap <buffer> <F7> :GoBuild<CR>
augroup END

augroup Haskell
  autocmd FileType haskell setlocal sw=2 sts=2 ts=8 expandtab shiftround
  autocmd FileType haskell setlocal makeprg=stack\ build\ --fast
  " autocmd FileType haskell nnoremap <buffer> <F1> :HdevtoolsInfo<CR>
  " autocmd FileType haskell nnoremap <buffer> <F2> :HdevtoolsType<CR>
  autocmd FileType haskell nnoremap <buffer> <Leader>` :!stack exec -- hasktags -c src<CR>
augroup END

nnoremap ; :
nnoremap <C-]> <C-]>zz
nnoremap <C-o> <C-o>zz
nnoremap <C-i> <C-i>zz
nnoremap <leader>+ viwyo"""<Esc>pA."""<Esc>_wvU<Esc>V:s/_/ /<CR>:noh<CR>:match<CR>
nnoremap <Leader>! :view ~/README.txt<CR>
nnoremap <Leader>1 :e ~/README.txt<CR>Go<Esc>:r!date<CR>:set paste<CR>o
nnoremap <Leader>2 :e ~/github.txt<CR>Go<Esc>:r!date<CR>o
nnoremap <Leader>c :%s/\<<C-r><C-w>\>/
vnoremap <Leader>c "hy:%s/<C-r>h/
vnoremap <Leader>/ :Commentary<CR>
nnoremap <C-b> <C-w>
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz

hi Comment          guifg=#7C7C7C     guibg=NONE        gui=NONE      ctermfg=darkgray    ctermbg=NONE        cterm=NONE
autocmd Syntax cpp call EnhanceCppSyntax()
autocmd FileType c nnoremap <buffer> <F4> :wa<CR> :e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>
autocmd FileType c inoremap <buffer> <F4> <Esc> <F4>
autocmd FileType c vnoremap <buffer> <F4> <Esc> <F4>

function SetCOptions()
  nmap <buffer> <Leader><Leader> va}:ClangFormat<CR>
  nmap <buffer> == V:ClangFormat<CR>
  vmap <buffer> = :'<,'>ClangFormat<CR>
  nmap <buffer> Q :ClangFormat<CR>
endfunction

augroup cstuff
  autocmd!
  autocmd FileType c,cpp call SetCOptions()
  autocmd FileType c,cpp nnoremap <leader>d Odbg();<Esc>_
augroup END

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set lazyredraw
set history=50 " keep 50 lines of command line history
set ruler      " show the cursor position all the time
set showcmd    " display incomplete commands
set incsearch  " do incremental searching

" Don't use Ex mode, use Q for formatting
vmap Q gq
nmap Q VQ

nmap <C-p> :Files<CR>
nmap <Leader>z :Files ~/src/zion<CR>
nmap B :Buffers<CR>
nmap M :History<CR>
nmap <CR><CR> :!<CR>

" map home row to exit Insert mode
imap jk <Esc>
vnoremap . :norm.<CR>

function! Peg()
	let filename = expand('%:p')
	execute "!peg " . filename
endfunction

nmap <leader>P :call Peg()<CR><CR>
nmap <leader>9P :e ~/pegged.txt<CR>
nmap <leader>N :let @a=1<Bar>%s/\<\d\+\>/\=(@a+setreg('a',@a+1))/<CR>

function! FindPrompt()
  let i = input("Search: ", "")
  let j = substitute(i, "_", ".", "g")
	let str = substitute(j, "test_", ".*", "g")
	if str == ""
		return
	endif

	execute "Rg " . str
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

" nnoremap <leader>` :!ctags -R .<CR>

nnoremap <F3> :call FindWordUnderCursor()<CR>

nnoremap F :wa<CR>:call FindPrompt()<CR>
nnoremap T :Tags<CR>
nnoremap g] :call FindTagUnderCursor()<CR>

map <F5> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
nnoremap <leader>e :e `=expand('%:p:h')`<CR>
nnoremap <leader>D :cd `=expand('%:p:h')`<CR>:pwd<CR>

vmap <Tab> =
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

:if $VIM_CRONTAB == "true"
:set nobackup
:set nowritebackup
:endif

" turning syntax on tends to redraw the screen nicely
nnoremap <leader><space> :syn on<cr>:noh<cr>:match<cr>:set nopaste<CR>:set colorcolumn=0<CR>:set iskeyword=@,48-57,_,192-255<CR>
nnoremap <leader>t viwy:tabnew<CR>:e ~/vim-todo.txt<CR>ggPa<CR><Esc>:wq<CR>
nnoremap <leader>T :tabnew<CR>:e ~/vim-todo.txt<CR>
nnoremap <leader>q :conf qa<CR>
nnoremap <leader>v <C-w>v<C-w>l<C-w>n<C-w>h

nnoremap <leader>9t :e tests/test_basic.zion<CR>:make<CR>
nnoremap <leader>90 :e ~/.vimrc<CR>
nnoremap <leader>91 :e ~/local.vimrc<CR>
nnoremap <leader>92 :e ~/.bashrc<CR>
nnoremap <leader>93 :e ~/local.bashrc<CR>
nnoremap <leader>9x :e ~/.xmonad/xmonad.hs<CR>:vsplit<CR>:e ~/.config/xmobar/xmobar.config<CR>:set ft=haskell<CR>
nnoremap <leader>9z :e ~/src/vim-zion/syntax/zion.vim<CR>
nnoremap <leader>i Oimport ipdb<CR>ipdb.set_trace()<Esc>j_
nnoremap <leader>p Oimport pdb<CR>pdb.set_trace()<Esc>j_

function! CleanupPaste()
  set nopaste
endfunction

augroup nopasty
  autocmd InsertLeave * call CleanupPaste()
augroup END

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

nnoremap <silent> "" :registers "0123456789abcdefghijklmnopqrstuvwxyz*+.<CR>

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.

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
autocmd FileType txt setlocal smartindent
autocmd FileType javascript setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType yaml setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType python setlocal sw=4 sts=4 ts=4 expandtab
autocmd FileType htmldjango setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType html setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType less setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType css setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType markdown setlocal textwidth=80 expandtab nocindent noautoindent nosmartindent cino=
autocmd FileType conf setlocal expandtab sw=2 sts=2 smartindent
autocmd FileType sh setlocal expandtab sw=2 sts=2 ts=2 expandtab smartindent

augroup filetypedetect
    au! BufRead,BufNewFile *.bashrc setfiletype sh
augroup END

set ignorecase
set smartcase
set gdefault
set visualbell
set showmatch
set nowrap
set guifont=Meslo\ LG\ M\ for\ Powerline
set matchtime=0
set hlsearch
set signcolumn=yes

syntax on
filetype plugin on
filetype indent on

colorscheme zion

syn match Braces display '[<>{}()\[\]]'

let c_no_curly_error=1

silent! source ~/local.vimrc
silent! source .vimrc
silent! source local.vimrc

nnoremap <silent><F9> :silent! call <SID>qfnext(v:false)<CR>
nnoremap <silent><F10> :silent! call <SID>qfnext(v:true)<CR>

function! s:qfnext(next) abort
  " find all 'quickfix'-type windows on the current tab
  let qfwin = filter(getwininfo(), {_, v -> v.quickfix && v.tabnr == tabpagenr()})
  if !empty(qfwin)
    " using the first one found
    if qfwin[0].winid == getqflist({'nr': 0, 'winid': 0}).winid
      " it's quickfix
      execute a:next ? 'cnext' : 'cprev'
      return
    else
      " assume it's loclist
      " must execute it in the host window or in loclist itself
      call win_execute(qfwin[0].winid, a:next ? 'lnext' : 'lprev', '')
      return
    endif
  endif
  execute a:next ? 'lnext' : 'lprev'
endfunction
