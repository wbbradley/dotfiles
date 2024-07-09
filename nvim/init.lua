-- Lazy package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- packages
local lazy_plugins = {
  "folke/trouble.nvim",
  "lewis6991/gitsigns.nvim",
  "nvim-lualine/lualine.nvim",
  "jremmen/vim-ripgrep",
  {
    "ibhagwan/fzf-lua",
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({
        preview_opts = 'hidden', -- NB: Toggle the preview with <F4>.
        fzf_opts = {
          ['--layout'] = 'default',
        }
        -- cmd = "git grep --line-number --column --color=always",
      })
    end
  },
  "nvimtools/none-ls.nvim",
  "neovim/nvim-lspconfig",
  "nvim-lua/plenary.nvim",
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-context",
  { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true},
}

-- Lazy doesn't support hot reloading, so we need to check if it's already been loaded
if vim.g.lazy_loaded == nil then
  require("lazy").setup(lazy_plugins, {})
  vim.g.lazy_loaded = true
end
require('gitsigns').setup {
  current_line_blame = trye,
  current_line_blame_opts = {
    virt_text_pos = 'right_align',
  }
}
vim.cmd "Gitsigns toggle_current_line_blame"
vim.cmd("colorscheme gruvbox")

local function keymap(mode, shortcut, command)
  vim.keymap.set(mode, shortcut, command, { noremap = true, silent = true })
end

local function nmap(shortcut, command)
  keymap("n", shortcut, command)
end

local function vmap(shortcut, command)
  keymap("v", shortcut, command)
end

local function imap(shortcut, command)
  keymap("i", shortcut, command)
end

nmap('M', ':FzfLua oldfiles<CR>')
nmap("<C-p>", ":FzfLua git_files<CR>")
nmap("E", ':lua require("fzf-lua").live_grep()')
nmap("vv", "viw")

-- AI setup
vim.g.vim_ai_debug = 1
vim.g.vim_ai_debug_log_file = "/tmp/vim-ai.log"
vim.g.vim_ai_model = "gpt-4-default"
nmap("<Leader>ai", ":set noautoindent<CR>:AIChat<CR>")
vmap("<Leader>ai", ":AI<CR>")
vmap("<M-k>", ":AI<CR>")

-- Treesitter
require("treesitter-context").setup {
  mode = 'cursor'
  -- mode = 'topline',
}
vim.cmd [[
  hi TreesitterContextBottom gui=underline guisp=Grey
  hi TreesitterContextLineNumberBottom gui=underline guisp=Grey
]]
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "c",
    "clojure",
    "cpp",
    "css",
    "dockerfile",
    "fennel",
    "go",
    "hcl",
    "html",
    "http",
    "java",
    "json",
    "kotlin",
    "lua",
    "markdown",
    "nix",
    "python",
    "ruby",
    "rust",
    "scala",
    "starlark",
    "sql",
    "terraform",
    "thrift",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
  },
  highlight = {
    enable = true,

    -- disable highlight for large files
    disable = function(_lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
  },
})
vim.g.laststatus = 2

local null_ls = require("null-ls")
null_ls.setup({
  autostart = true,
  sources = {
    require("autoimport"),
    require("shellcheck"),
    require("jsoncheck"),
    require("yamlcheck"),
    null_ls.builtins.diagnostics.mypy,
    null_ls.builtins.formatting.isort,
  }
})

-- Put ruff after isort and autoimport to ensure proper formatting.
local lspconfig = require('lspconfig')
lspconfig.ruff.setup {
  cmd = { "ruff", "server", "--preview" },
}
lspconfig.rust_analyzer.setup({})

vim.keymap.set('n', "F", function()
  require("fzf-lua").live_grep({
    cmd = "git grep --line-number --column --color=always"
  })
end)
vim.keymap.set('n', "<F3>", function()
  require("fzf-lua").grep_cword({
    cmd = "git grep --line-number --column --color=always"
  })
end)

local function search_tags_filtered()
  local current_word = vim.fn.expand("<cword>")
  require('fzf-lua').tags({ fzf_opts = { ['--query'] = current_word } })
end

nmap('g]', "<cmd>lua require('fzf-lua').tags({ fzf_opts = { ['--query'] = vim.fn.expand('<cword>') } })<CR>")

vim.cmd [[
set encoding=utf-8
" set undofile
set undodir=~/.local/share/nvim/undodir
set encoding=utf-8
set number
set noshowmode
set exrc
set number
set ttyfast

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
" set cursorline

:autocmd VimResized * wincmd =

augroup sql
  autocmd FileType sql setlocal makeprg=pgsanity\ %
augroup END

nmap <Space> :let @+=@0<CR>
" nmap gd #
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

let g:vimsyn_noerror = 1

augroup dot
  autocmd!
  autocmd FileType dot set cindent cinkeys="
augroup END

augroup Haskell
  autocmd!
  " autocmd FileType haskell nnoremap <buffer> <Leader>ht :GhcModType<cr>
  " autocmd FileType haskell nnoremap <buffer> <Leader>htc :GhcModTypeClear<cr>
augroup END

" FZF UI version of search.
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>).' | grep -v -e dist/ -e static/ -e ".bundle:" -e "mobile/assets/.*\.js"',
  \   0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

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

function! s:trim_trailing_whitespace() abort
  let l:view = winsaveview()
  keeppatterns %substitute/\m\s\+$//e
  call winrestview(l:view)
endfunction
augroup trim_spaces
  autocmd!
  autocmd BufWritePre * call <SID>trim_trailing_whitespace()
augroup END

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
vnoremap <Leader>x :!chmod +x %<CR>
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
" nnoremap <expr> <C-p> (len(system('git -C ' . expand('%:p:h') . ' rev-parse' )) ? (':Files ' . expand('%:p:h')) : ':GFiles')."\<cr>"
nmap B :FzfLua buffers<CR>
" nmap M :History<CR>
nmap <CR><CR> :!<CR>

" map home row to exit Insert mode
imap jk <Esc>
vnoremap . :norm.<CR>

nmap <C-w>1 :%bd\|e#<CR>
nmap <leader>N :let @a=1<Bar>%s/\<\d\+\>/\=(@a+setreg('a',@a+1))/<CR>
" nmap <leader>l /\%>100v.\+
nmap <leader>l iimport logging<CR>logger = logging.getLogger(__name__)<CR><Esc>

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

  execute "LiveGrep " . str
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

" nnoremap <F3> :call FindWordUnderCursor()<CR>
" :execute 'grep! ' . expand('<cword>') . ' *'<CR>

nnoremap <F4> :call FindWordUnderCursorNoUI()<CR>

nnoremap <leader>f :call FindPromptRaw()<CR>
nnoremap E :call FindPromptDirect()<CR>
nnoremap <leader>g :w<CR>:!git add %<CR>
nnoremap T :FzfLua tags<CR>

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

nnoremap <leader>90 :e ~/.config/nvim/init.lua<CR>
nnoremap <leader>92 :e ~/.bashrc<CR>
nnoremap <leader>93 :e ~/local.bashrc<CR>
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
autocmd FileType htmldjango setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType html setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType less setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType css setlocal sw=2 sts=2 ts=2 expandtab
autocmd FileType markdown setlocal textwidth=100 expandtab nocindent autoindent nosmartindent ts=2 sw=2 sts=2 cino=
autocmd BufRead,BufNewFile *.md setlocal textwidth=100 expandtab nocindent autoindent nosmartindent ts=2 sw=2 sts=2 cino=
autocmd FileType conf setlocal expandtab sw=2 sts=2 smartindent
autocmd FileType sh setlocal expandtab sw=2 sts=2 ts=2 expandtab smartindent
autocmd FileType qf nmap <buffer> <Esc> :close<CR>

augroup filetypedetect
    au! BufRead,BufNewFile *.pyi setfiletype python
    au! BufRead,BufNewFile *.bashrc setfiletype sh.bash
augroup END

augroup Python
  autocmd FileType python setlocal sw=4 sts=4 ts=4 expandtab
  autocmd FileType python setlocal sw=4 sts=4 ts=4 expandtab
  autocmd BufWritePre *.py lua vim.lsp.buf.format()
augroup END

augroup RustCore
  autocmd FileType rust nmap <F7> :pclose<CR>:setlocal makeprg=cargo\ clippy<CR>:lmake<CR><CR>
  autocmd FileType rust setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi,tags
  autocmd BufRead *.rs setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi,tags
  autocmd BufWritePre *.rs lua vim.lsp.buf.format()
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
  autocmd FileType python setlocal textwidth=110
  " autocmd FileType python setlocal colorcolumn=110,111,112,113
augroup END

" hi! MatchParen cterm=NONE,bold gui=NONE,bold guibg=#eee8d5 guifg=NONE
" syn match Braces display '[<>{}\[\]()]'

let c_no_curly_error=1

silent! source ~/local.vimrc
if resolve(expand("~/.vimrc")) != resolve(expand("$PWD/.vimrc"))
  silent! source .vimrc
endif
silent! source local.vimrc

nnoremap - _
nnoremap L :lua vim.diagnostic.goto_next()<CR>
nnoremap H :lua vim.diagnostic.goto_prev()<CR>
nnoremap <F9> :cprev<CR>
nnoremap <F10> :cnext<CR>

if &diff
  syntax on
endif

let g:context_add_mappings = 0

" colorscheme slate
" colorscheme morning
" hi clear SpellBad
" hi clear SpellCap
" hi CursorLine term=NONE cterm=NONE guibg=NONE
" hi PreProc term=NONE cterm=NONE guibg=NONE guifg=NONE
" hi Search guifg=#090819 guibg=#047943
" hi SpellBad guifg=NONE guibg=#660a0a guisp=NONE gui=NONE cterm=NONE
" hi SpellCap guibg=#a58545 guifg=NONE guisp=NONE gui=NONE cterm=NONE
" hi MatchParen guifg=#ccccc1 guibg=#5555cc
" hi markdownItalic term=bold cterm=bold ctermfg=220 gui=bold guifg=#ffd700
" hi rustCommentLine guifg=#555555
]]

require('lualine').setup({
  extenstion = { 'fzf', 'lazy', 'quickfix' }
})
