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

set t_Co=256
set cpoptions+=n
set splitbelow
set splitright
set modeline
set modelines=2
set scrolloff=3
" set noesckeys
set sw=2 sts=2
set timeoutlen=1000 ttimeoutlen=0

set wildignore+=*.o
set wildignore+=*.a
set hidden
set confirm
set nocursorline

:autocmd VimResized * wincmd =

augroup sql
  autocmd FileType sql setlocal makeprg=pgsanity\ %
augroup END

augroup python
  autocmd FileType python nmap <buffer> <F8> :Autoformat<CR>
  autocmd FileType python setlocal textwidth=100
  autocmd FileType python vmap <buffer> <leader>r creveal_type(<Esc>pa)<Esc>
augroup END


" let g:autoformat_verbosemode=1
" let g:autoformat_autoindent = 0
" let g:autoformat_retab = 0
" let g:autoformat_remove_trailing_spaces = 1

let g:EditorConfig_max_line_indicator = 'none'
let g:ruby_indent_assignment_style = 'variable'
" Turn on case-insensitive feature for EasyMotion
let g:EasyMotion_smartcase = 1
nmap ] <Plug>(easymotion-prefix)
nmap , <Plug>(easymotion-overwin-f)
nmap <Space> :let @+=@0<CR>
nmap gd #
" nnoremap <Esc> :helpclose<CR>:cclose<CR>:pclose<CR>:lclose<CR><Esc>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-w>\ :vsplit<CR>
nnoremap <C-w>- :split<CR>
set grepprg=git\ grep\ -ERn
nmap <F1> :grep<CR>:cw<CR><CR>
let g:vim_markdown_folding_disabled = 1

set wildchar=<Tab> wildmenu wildmode=full
set tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab

" let g:qf_modifiable = 1
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
let g:vimsyn_noerror = 1
let g:ale_virtualenv_dir_names = ['.venv']
let g:ale_completion_enabled = 0
let g:ale_virtualtext_cursor = 2
let g:ale_python_autoflake_executable = $PWD . '/env/bin/autoflake'
let g:ale_python_autoflake_options = '--remove-all-unused-imports'
let g:ale_python_mypy_executable = $PWD . '/env/bin/mypy'
let b:ale_python_mypy_options = '--ignore-missing-imports'
" let g:ale_python_mypy_options = system('printf "%s" "$LOCAL_MYPY_FLAGS"')
let g:ale_python_isort_executable = $PWD . '/env/bin/isort'
let g:ale_python_isort_options = '-l 100 --skip __init__.py --skip ipython.py'
let g:ale_python_pylint_executable = $PWD . '/env/bin/pylint'
let g:ale_python_black_executable = $PWD . '/env/bin/autopep8'
let g:ale_python_autopep8_executable = $PWD . '/env/bin/autopep8'
let g:ale_python_autopep8_options = '--max-line-length 100 --experimental -a'
let g:ale_haskell_hls_executable = 'haskell-language-server-wrapper-1.7.0.0'
let g:ale_python_pylint_change_directory = 0
let g:ale_python_pylint_use_global = 0
"  " 'isort', 'autoflake', 'autopep8', 'trim_whitespace']
let g:ale_fixers = {
      \   'python': ['autoimport', 'isort', 'ruff_format', 'ruff', 'trim_whitespace']
      \ , 'cpp': ['clang-format']
      \ , 'c': ['clang-format']
      \ , 'proto': ['clang-format', 'protolint', 'buf-format']
      \ , 'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines']
      \ , 'haskell': ['hfmt']
      \ }
let g:ale_rust_cargo_use_clippy = 1
let g:ale_rust_rustfmt_options = '--edition 2021'
let g:ale_fix_on_save = 1
let g:ale_linters = {
      \   'haskell': ['hls']
      \ , 'python': ['ruff', 'mypy']
      \ , 'javascript': []
      \ , 'rust': ['cargo']
      \ }
" let g:ale_rust_rls_toolchain = 'nightly'

augroup dot
  autocmd!
  autocmd FileType dot set cindent cinkeys="
augroup END

augroup Haskell
  autocmd!
  autocmd FileType haskell nnoremap <buffer> <leader>? :call ale#cursor#ShowCursorDetail()<cr>
  autocmd FileType haskell nnoremap <buffer> <C-]> :ALEGoToDefinition<CR>
  " autocmd FileType haskell nnoremap <buffer> <Leader>ht :GhcModType<cr>
  " autocmd FileType haskell nnoremap <buffer> <Leader>htc :GhcModTypeClear<cr>
augroup END

" FZF UI version of search.
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>).' | grep -v -e dist/ -e static/ -e ".bundle:" -e "mobile/assets/.*\.js"', 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

let g:multi_cursor_exit_from_insert_mode=1
let g:multi_cursor_exit_from_visual_mode=1
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

let g:fzf_preview_window = ['up:50%', 'ctrl-/']
" imap <c-n> <plug>(fzf-complete-word)
imap <c-l> <plug>(fzf-complete-line)

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

" Make the quickfix window take up the entirety of the bottom of the window
" when it opens
autocmd FileType qf wincmd J

autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow

" autocmd BufNewFile,BufReadPost *.js set autoindent noexpandtab ts=2 sw=2
" autocmd BufNewFile,BufReadPost *.jsx set autoindent noexpandtab ts=2 sw=2

augroup Bash
  au!
  autocmd FileType bash,sh setlocal iskeyword+=45
augroup END

augroup Ruby
  au!
  autocmd FileType ruby,eruby setlocal expandtab shiftwidth=2 tabstop=2
  autocmd FileType ruby setlocal commentstring=#\ %s
  autocmd FileType ruby setlocal iskeyword+=!
  autocmd FileType ruby,eruby setlocal iskeyword+=?
  autocmd FileType ruby nnoremap <buffer> <leader>d Odebugger<Esc>_
  autocmd FileType eruby nnoremap <buffer> <leader>d O<% debugger %><Esc>_
augroup END

function! CloseCleanHiddenBuffers()
  " Store the buffer numbers of all buffers currently displayed in a window
  let l:visible = []
  for l:winnr in range(1, winnr('$'))
    call add(l:visible, winbufnr(l:winnr))
  endfor

  " Close all buffers that are not in 'visible' and not modified
  for l:buffer in range(1, bufnr('$'))
    if index(l:visible, l:buffer) == -1 && buflisted(l:buffer) && !getbufvar(l:buffer, '&mod')
      execute 'silent! bdelete' l:buffer
    endif
  endfor
endfunction

command! Bclosehidden call CloseCleanHiddenBuffers()
autocmd BufWritePost * :Bclosehidden

autocmd FileType gitcommit setlocal textwidth=71
autocmd FileType config setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
autocmd FileType sql setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab

augroup ProtoBuf
  autocmd!
  autocmd FileType proto nmap <buffer> <Leader>n :!protonum %<CR>L
augroup END

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
  autocmd FileType go nmap <buffer> <C-]> :GoDef<CR>
  autocmd FileType go nmap <buffer> <F7> :GoBuild<CR>
augroup END

augroup Haskell
  autocmd FileType haskell setlocal sw=2 sts=2 ts=8 expandtab shiftround
  " autocmd FileType haskell setlocal makeprg=stack\ build\ --fast
  " autocmd FileType haskell nnoremap <buffer> <F1> :HdevtoolsInfo<CR>
  " autocmd FileType haskell nnoremap <buffer> <F2> :HdevtoolsType<CR>
  " autocmd FileType haskell nnoremap <buffer> <Leader>` :!stack exec -- hasktags -c src<CR>
augroup END

nnoremap ; :
" nnoremap <C-]> <C-]>zz
" nnoremap <C-o> <C-o>zz
" nnoremap <C-i> <C-i>zz
nnoremap <leader>+ viwyo"""<Esc>pA."""<Esc>_wvU<Esc>V:s/_/ /<CR>:noh<CR>:match<CR>
nnoremap <Leader>! :view ~/README.md<CR>
nnoremap <Leader>1 :e ~/README.md<CR>Go<Esc>:r!date<CR>:set paste<CR>o
nnoremap <Leader>2 :e ~/github.txt<CR>Go<Esc>:r!date<CR>o
nnoremap <Leader>c :%s/\<<C-r><C-w>\>/
vnoremap <Leader>c "hy:%s/<C-r>h/
vnoremap <Leader>/ :Commentary<CR>
nnoremap <Leader>P :set paste<CR>p:set nopaste<CR>
vnoremap % :%s/
nnoremap <C-b> <C-w>

autocmd Syntax cpp call EnhanceCppSyntax()
autocmd FileType c nnoremap <buffer> <F2> :call FlipCHeader()<CR>
autocmd FileType cpp nnoremap <buffer> <F2> :call FlipHeader()<CR>

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

nnoremap <F2> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

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

nmap <Leader><Leader> va}=
nnoremap <expr> <C-p> (len(system('git -C ' . expand('%:p:h') . ' rev-parse' )) ? (':Files ' . expand('%:p:h')) : ':GFiles')."\<cr>"
nmap B :Buffers<CR>
nmap M :History<CR>
nmap <CR><CR> :!<CR>

" map home row to exit Insert mode
imap jk <Esc>
vnoremap . :norm.<CR>

nmap <C-w>1 :%bd\|e#<CR>
nmap <leader>N :let @a=1<Bar>%s/\<\d\+\>/\=(@a+setreg('a',@a+1))/<CR>
" nmap <leader>l /\%>100v.\+
nmap <leader>l iimport logging<CR>logger = logging.getLogger(__name__)<CR><Esc>
nmap <leader>a :ALEInfoToFile /var/tmp/ale.txt<CR>:e /var/tmp/ale.txt<CR>

function! FindPromptFzf()
  let i = input("Search: ", "")
  let j = substitute(i, "_", ".", "g")
	let str = substitute(j, "test_", ".*", "g")
	if str == ""
		return
	endif

	execute "GGrep " . str
endfunction

function! FindPromptDirect()
  let i = input("Search: ", "")
  let j = substitute(i, "_", ".", "g")
	let str = substitute(j, "test_", ".*", "g")
	if str == ""
		return
	endif

	execute "RipGrep '" . str . "'"
  cw
  redraw!
endfunction

function! FindPromptRaw()
  let str = input("" . $PWD . " $ grep -ERn ", "")
	if str == ""
		return
	endif

  setlocal grepprg=grep\ -ERn
	execute "grep '" . str . "'"
  cw
endfunction

function! FindPromptDirectGit()
  let i = input("Search: ", "")
  let j = substitute(i, "_", ".", "g")
	let str = substitute(j, "test_", ".*", "g")
	if str == ""
		return
	endif

	execute "Ggrep -q '" . str . "'"
  cw
  redraw!
endfunction

function! FindWordUnderCursor()
  let str = expand("<cword>")
  if str == ""
    return
  endif

  execute "GGrep " . str
endfunction

function! FindTagUnderCursor()
  let str = expand("<cword>")
  if str == ""
    return
  endif

  execute "Tags " . str
endfunction

function! FindWordUnderCursorNoUI()
  let str = expand("<cword>")
  if str == ""
    return
  endif

  execute "Ggrep -q '" . str . "'"
endfunction

" Add highlighting for function definition in C++
function! EnhanceCppSyntax()
  syn match cppFuncDef "::\~\?\zs\h\w*\ze([^)]*\()\s*\(const\)\?\)\?$"
  hi def link cppFuncDef Special
endfunction

function! FlipCHeader()
  :wa
  if expand('%:e') == 'c'
    :e %:r.h
  else
    if filereadable(expand('%:r') . '.c')
      :e %:r.c
    else
      :e %:r.c
    endif
  endif
endfunction

function! FlipHeader()
  if (&ft == 'c')
    if expand('%:e') == 'c'
      :e %:r.h
    else
      if filereadable(expand('%:r') . '.c')
        :e %:r.c
      else
        :e %:r.c
      endif
    endif
  else
    if expand('%:e') == 'hpp' || expand('%:e') == 'h'
      :e %:r.cpp
    else
      if filereadable(expand('%:r') . '.hpp')
        :e %:r.hpp
      else
        :e %:r.h
      endif
    endif
  endif
endfunction

nnoremap <leader>` :!ctags -R .<CR>

nnoremap <F3> :call FindWordUnderCursor()<CR>
" :execute 'grep! ' . expand('<cword>') . ' *'<CR>

nnoremap <F4> :call FindWordUnderCursorNoUI()<CR>

nnoremap <leader>f :call FindPromptRaw()<CR>
nnoremap F :call FindPromptFzf()<CR>
nnoremap E :call FindPromptDirect()<CR>
nnoremap <leader>g :w<CR>:!git add %<CR>
nnoremap T :Tags<CR>
nnoremap g] :call FindTagUnderCursor()<CR>

map <F5> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>e :e `=expand('%:p:h')`<CR>
" nnoremap <leader>D :cd `=expand('%:p:h')`<CR>:pwd<CR>

vmap <Tab> =
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

:if $VIM_CRONTAB == "true"
:set nobackup
:set nowritebackup
:endif

" turning syntax on tends to redraw the screen nicely
nnoremap <leader><space> :noh<cr>:match<cr>:set nopaste<CR>:redraw!<CR>
nnoremap <leader>t viwy:tabnew<CR>:e ~/vim-todo.txt<CR>ggPa<CR><Esc>:wq<CR>
nnoremap <leader>T :tabnew<CR>:e ~/vim-todo.txt<CR>
nnoremap <leader>q :conf qa<CR>
nnoremap <leader>w :wa<CR>
nnoremap <leader>v <C-w>v<C-w>l<C-w>n<C-w>h

nnoremap <leader>90 :e ~/.vimrc<CR>
nnoremap <leader>91 :e ~/local.vimrc<CR>
nnoremap <leader>92 :e ~/.bashrc<CR>
nnoremap <leader>93 :e ~/local.bashrc<CR>
nnoremap <leader>9x :e ~/.xmonad/xmonad.hs<CR>:vsplit<CR>:e ~/.config/xmobar/xmobar.config<CR>:set ft=haskell<CR>
nnoremap <leader>i Oimport ipdb<CR>ipdb.set_trace()<Esc>j_
nnoremap <leader>p Oimport pdb<CR>pdb.set_trace()<Esc>j_

function! CleanupPaste()
  set nopaste
endfunction

let g:markdown_recommended_style = 0

augroup nopasty
  autocmd InsertLeave * call CleanupPaste()
augroup END

" F7 & F8 - incremental build (build is so important it gets a two keys for
" redundancy).
nmap <F7> :wa<CR> :!clear <CR><CR> :lmake<CR><CR>
imap <F7> <Esc> <F7>
vmap <F7> <Esc> <F7>

nmap <F8> :wa<CR> :!clear <CR><CR> :lmake<CR><CR>
imap <F8> <Esc> <F7>
vmap <F8> <Esc> <F7>

" map Shift Tab to outdent
nmap <S-Tab> V<
vmap <S-Tab> <

" map Tab to indent
" nmap <Tab> V>
vmap <Tab> >

" C-F7 - clean build
nmap <C-F7> :!lmake clean <CR><CR> <F7>
imap <C-F7> <Esc> <C-F7>
vmap <C-F7> <Esc> <C-F7>

nmap c<Space> ct_

set tags=tags;./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi

nnoremap n nzz
nnoremap N Nzz
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

autocmd FileType ts setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType txt setlocal smartindent
autocmd FileType javascript setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType yaml setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType python setlocal sw=4 sts=4 ts=4 expandtab
autocmd FileType htmldjango setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType html setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType less setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType css setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType markdown setlocal textwidth=100 expandtab nocindent autoindent nosmartindent ts=2 sw=2 sts=2 cino=
autocmd BufRead,BufNewFile *.md setlocal textwidth=100 expandtab nocindent autoindent nosmartindent ts=2 sw=2 sts=2 cino=
autocmd FileType conf setlocal expandtab sw=2 sts=2 smartindent
autocmd FileType sh setlocal expandtab sw=2 sts=2 ts=2 expandtab smartindent
autocmd FileType qf nmap <buffer> <Esc> :close<CR>
autocmd FileType ale-preview nmap <buffer> <Esc> :close<CR>

augroup filetypedetect
    au! BufRead,BufNewFile *.pyi setfiletype python
    au! BufRead,BufNewFile *.bashrc setfiletype sh.bash
augroup END

augroup RustCore
  autocmd FileType rust nmap <F7> :pclose<CR>:setlocal makeprg=cargo\ clippy<CR>:lmake<CR><CR>
  autocmd FileType rust setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi,tags
  autocmd BufRead *.rs setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi,tags
  autocmd BufWritePost *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&"
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
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

let g:rainbow_active = 0

syntax on
filetype plugin on
filetype indent on

" hi ColorColumn ctermfg=blue ctermbg=darkgray guibg=#333333 guifg=#1111bb cterm=NONE
augroup python
  autocmd FileType python setlocal textwidth=100
  autocmd FileType python setlocal colorcolumn=100,101,102,103
  " autocmd FileType python nnoremap L :ALENextWrap<CR>:ALEDetail<CR><C-w><C-p>
  " autocmd FileType python nnoremap H :ALEPreviousWrap<CR>:ALEDetail<CR><C-w><C-p>
augroup END

" hi! MatchParen cterm=NONE,bold gui=NONE,bold guibg=#eee8d5 guifg=NONE
syn match Braces display '[<>{}()\[\]]'

let c_no_curly_error=1

silent! source ~/local.vimrc
if resolve(expand("~/.vimrc")) != resolve(expand("$PWD/.vimrc"))
  silent! source .vimrc
endif
silent! source local.vimrc

nnoremap - _
nnoremap L :lnext<CR>
nnoremap H :lprev<CR>
nnoremap <F9> :cprev<CR>
nnoremap <F10> :cnext<CR>

if &diff
  syntax on
  let g:ale_fixers = {}
  let g:ale_linters = {}
  let g:ale_fix_on_save = 0
endif

let g:context_add_mappings = 0

colorscheme slate
" colorscheme morning
hi clear SpellBad
hi clear SpellCap
hi CursorLine term=NONE cterm=NONE guibg=NONE
hi PreProc term=NONE cterm=NONE guibg=NONE guifg=NONE
hi Search guifg=#090819 guibg=#047943
hi SpellBad guifg=NONE guibg=#660a0a guisp=NONE gui=NONE cterm=NONE
hi SpellCap guibg=#a58545 guifg=NONE guisp=NONE gui=NONE cterm=NONE
hi MatchParen guifg=#ccccc1 guibg=#5555cc 
hi markdownItalic term=bold cterm=bold ctermfg=220 gui=bold guifg=#ffd700
hi rustCommentLine guifg=#555555

