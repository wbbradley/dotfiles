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
	"easymotion/vim-easymotion",
	"folke/trouble.nvim",
	"lewis6991/gitsigns.nvim",
	"nvim-lualine/lualine.nvim",
	{
		"wbbradley/conform.nvim",
		opts = {},
	},
	"mfussenegger/nvim-lint",
	"jremmen/vim-ripgrep",
	{
		"ibhagwan/fzf-lua",
		config = function()
			-- calling `setup` is optional for customization
			local actions = require("fzf-lua.actions")
			require("fzf-lua").setup({
				preview_opts = "hidden", -- NB: Toggle the preview with <F4>.
				fzf_opts = {
					["--layout"] = "default",
				},
				actions = {
					files = {
						["enter"] = function(selected, opts)
							local retval = actions.file_edit_or_qf(selected, opts)
							if vim.fn.win_gettype() == "quickfix" then
								vim.api.nvim_feedkeys(
									vim.api.nvim_replace_termcodes("<CR>", true, true, true),
									"n",
									false
								)
							end
							return retval
						end,
					},
				},
				-- cmd = "git grep --line-number --column --color=always",
			})
		end,
	},
	-- "nvimtools/none-ls.nvim",
	"neovim/nvim-lspconfig",
	"nvim-lua/plenary.nvim",
	"nvim-treesitter/nvim-treesitter",
	"nvim-treesitter/nvim-treesitter-context",
	"hrsh7th/nvim-cmp",
	{ "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
	"rust-lang/rust.vim",
	{
		"mrcjkb/rustaceanvim",
		ft = { "rust" },
	},
	"andersevenrud/nvim_context_vt",
}

-- Lazy doesn't support hot reloading, so we need to check if it's already been loaded
if vim.g.lazy_loaded == nil then
	require("lazy").setup(lazy_plugins, {})
	vim.g.lazy_loaded = true
end
require("gitsigns").setup({
	current_line_blame = true,
	current_line_blame_opts = {
		virt_text_pos = "right_align",
	},
})
vim.cmd("Gitsigns toggle_current_line_blame")
local _ = require("cmp")

require("lspconfig").gopls.setup({})
require("lspconfig").terraformls.setup({})
-- require("lspconfig").rust_analyzer.setup({})
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		local params = vim.lsp.util.make_range_params()
		params.context = { only = { "source.organizeImports" } }
		-- buf_request_sync defaults to a 1000ms timeout. Depending on your
		-- machine and codebase, you may want longer. Add an additional
		-- argument after params if you find that you have to write the file
		-- twice for changes to be saved.
		-- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
		for cid, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
					vim.lsp.util.apply_workspace_edit(r.edit, enc)
				end
			end
		end
		vim.lsp.buf.format({ async = false })
	end,
})
vim.cmd("colorscheme gruvbox")
require("nvim_context_vt").setup({
	min_rows = 30,
	disable_ft = { "markdown", "lua" },
	-- Disable display of virtual text below blocks for indentation based languages like Python
	-- Default: false
	disable_virtual_lines = false,
})

-- :help conform
require("conform").setup({
	notify_on_error = false,
	formatters = {
		autoimport = {
			command = "autoimport",
			args = { "-" },
			stdin = true,
			-- A function that calculates the directory to run the command in
			cwd = require("conform.util").root_file({ ".git" }),
			require_cwd = false,
			exit_codes = { 0 },
			-- Set to false to disable merging the config with the base definition
			inherit = false,
		},
		mdformat = {
			args = { "--number", "--wrap", "100", "-" },
		},
	},
	format_on_save = {
		lsp_format = "never",
		timeout_ms = 1500,
	},
	formatters_by_ft = {
		lua = { "stylua" },
		markdown = { "mdformat" },
		python = { "autoimport", "isort", "ruff_fix", "ruff_format" },
		rust = { "rustfmt" },
		terraform = { "terraform_fmt" },
	},
})
-- vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*", callback = function(args) require("conform").format({ bufnr = args.buf }) end, })
-- require("lint").linters.cargo = require("cargo")
require("lint").linters_by_ft = {
	python = { "ruff", "mypy" },
	sh = { "shellcheck" },
	yaml = { "yamllint" },
	toml = { "tomllint" },
	lua = { "luacheck" },
	sql = { "pgsanity" },
	-- rust = { "cargo" },
}
local mypy_linter = require("lint").linters.mypy
mypy_linter.args = {
	"--show-column-numbers",
	"--show-error-end",
	"--hide-error-codes",
	"--hide-error-context",
	"--no-color-output",
	"--no-error-summary",
	"--no-pretty",
}
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	pattern = "*",
	callback = function()
		require("lint").try_lint()
	end,
})
local function parse_pgsanity_output(output, bufnr, _linter_cwd)
	local diagnostics = {}
	for line in output:gmatch("[^\r\n]+") do
		local lnum, description = line:match("line (%d+): ERROR: (.+)")
		if lnum and description then
			table.insert(diagnostics, {
				bufnr = bufnr,
				lnum = tonumber(lnum) - 1,
				col = 0,
				end_lnum = tonumber(lnum) - 1,
				end_col = -1,
				severity = vim.diagnostic.severity.ERROR,
				message = description,
			})
		end
	end
	return diagnostics
end

require("lint").linters.pgsanity = {
	cmd = "pgsanity",
	stdin = true, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
	append_fname = true, -- Automatically append the file name to `args` if `stdin = false` (default: true)
	args = { "--add-semicolon" }, -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
	stream = nil, -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
	ignore_exitcode = false, -- set this to true if the linter exits with a code != 0 and that's considered normal.
	env = nil, -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
	parser = parse_pgsanity_output,
}
local function parse_tomllint_output(output, bufnr, _linter_cwd)
	local diagnostics = {}
	for line in output:gmatch("[^\r\n]+") do
		local _, lnum, col, description = line:match("(.+):(%d+):(%d+): error: (.+)")
		if lnum and description then
			table.insert(diagnostics, {
				bufnr = bufnr,
				lnum = tonumber(lnum) - 1,
				col = tonumber(col) - 1,
				end_lnum = tonumber(lnum) - 1,
				end_col = tonumber(col),
				severity = vim.diagnostic.severity.ERROR,
				message = description,
			})
		end
	end
	return diagnostics
end
require("lint").linters.tomllint = {
	cmd = "tomllint",
	stdin = true, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
	append_fname = false, -- Automatically append the file name to `args` if `stdin = false` (default: true)
	args = { "-" }, -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
	stream = "stderr", -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
	ignore_exitcode = false, -- set this to true if the linter exits with a code != 0 and that's considered normal.
	env = nil, -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
	parser = parse_tomllint_output,
}
local function keymap(mode, shortcut, command)
	vim.keymap.set(mode, shortcut, command, { noremap = true, silent = true })
end

local function nmap(shortcut, command)
	keymap("n", shortcut, command)
end

local function vmap(shortcut, command)
	keymap("v", shortcut, command)
end

nmap("M", ":FzfLua oldfiles<CR>")
nmap("<C-p>", ":FzfLua git_files<CR>")
nmap("E", ':lua require("fzf-lua").live_grep()')
nmap("vv", "viw")
nmap(",", "<Plug>(easymotion-s)")

-- Treesitter
require("treesitter-context").setup({
	mode = "cursor",
	-- mode = 'topline',
	-- max_lines = 5,
	multiline_threshold = 4,
})
vim.cmd([[
  hi TreesitterContextBottom gui=underline guisp=Grey
  hi TreesitterContextLineNumberBottom gui=underline guisp=Grey
]])
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

vim.keymap.set("n", "F", function()
	require("fzf-lua").live_grep({
		cmd = "git grep --line-number --column --color=always",
	})
end)
vim.keymap.set("n", "<F3>", function()
	require("fzf-lua").grep_cword({
		cmd = "git grep --line-number --column --color=always",
	})
end)

nmap("g]", "<cmd>lua require('fzf-lua').tags({ fzf_opts = { ['--query'] = vim.fn.expand('<cword>') } })<CR>")

vim.cmd([[
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
set cursorline

:autocmd VimResized * wincmd =

augroup go
  autocmd FileType go inoremap <C-n> <C-x><C-o>
augroup END
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

function! s:trim_trailing_whitespace() abort
  let l:view = winsaveview()
  keeppatterns %substitute/\m\s\+$//e
  call winrestview(l:view)
endfunction
augroup trim_spaces
  autocmd!
  autocmd BufWritePre *.md call <SID>trim_trailing_whitespace()
  autocmd BufWritePre *.rs call <SID>trim_trailing_whitespace()
  autocmd BufWritePre *.py call <SID>trim_trailing_whitespace()
  autocmd BufWritePre *.cpp call <SID>trim_trailing_whitespace()
  autocmd BufWritePre *.c call <SID>trim_trailing_whitespace()
  autocmd BufWritePre *.h call <SID>trim_trailing_whitespace()
augroup END

autocmd FileType gitcommit setlocal textwidth=71
autocmd FileType config setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
autocmd FileType sql setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab

augroup ProtoBuf
  autocmd!
  autocmd FileType proto nmap <buffer> <Leader>n :!protonum %<CR>L
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

nnoremap <leader><C-v> :r!pbpaste<CR>
nnoremap <leader><space> :noh<cr>:match<cr>:set nopaste<CR>:redraw!<CR>
nnoremap <leader>T :tabnew<CR>:e ~/vim-todo.txt<CR>
nnoremap <leader>d :set makeprg=dangle<CR>:make<CR>
nnoremap <leader>q :conf qa<CR>
nnoremap <leader>t mTviwy:e ~/vim-todo.txt<CR>ggPa<CR><Esc>:w<CR>'T
nnoremap <leader>v <C-w>v<C-w>l<C-w>n<C-w>h
nnoremap <leader>w :wa<CR>

nnoremap <leader>90 :e ~/.config/nvim/init.lua<CR>
nnoremap <leader>9a :e ~/.config/alacritty/alacritty.toml<CR>
nnoremap <leader>92 :e ~/.bashrc<CR>
nnoremap <leader>9b :e ~/.bashrc<CR>
nnoremap <leader>93 :e ~/local.bashrc<CR>
nnoremap <leader>9l :e ~/local.bashrc<CR>
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
autocmd FileType markdown setlocal textwidth=100 expandtab nocindent autoindent nosmartindent ts=2 sw=2 sts=2 cino= spell
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
  " autocmd BufWritePre *.py lua vim.lsp.buf.format()
augroup END

autocmd BufRead *.ai setlocal ft=markdown
autocmd BufRead *.tf setlocal ft=terraform
augroup RustCore
  autocmd FileType rust nmap <F7> :pclose<CR>:setlocal makeprg=cargo\ clippy<CR>:lmake<CR><CR>
  autocmd FileType rust setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi,tags
  autocmd BufRead *.rs setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi,tags
  " autocmd BufWritePre *.rs lua vim.lsp.buf.format()
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

syntax on
filetype plugin on
filetype indent on

" hi ColorColumn ctermfg=blue ctermbg=darkgray guibg=#333333 guifg=#1111bb cterm=NONE
augroup python
  autocmd FileType python setlocal textwidth=100
  " autocmd FileType python setlocal colorcolumn=110,111,112,113
augroup END

" hi! MatchParen cterm=NONE,bold gui=NONE,bold guibg=#eee8d5 guifg=NONE
" syn match Braces display '[<>{}\[\]()]'

let c_no_curly_error=1

if resolve(expand("~/.vimrc")) != resolve(expand("$PWD/.vimrc"))
  silent! source .vimrc
endif
silent! source local.vimrc

nnoremap - _
nnoremap L :lua vim.diagnostic.goto_next()<CR>
nnoremap H :lua vim.diagnostic.goto_prev()<CR>
nnoremap <F9> :cprev<CR>
nnoremap <F10> :cnext<CR>
" Make sure % works normally.
ounmap %
vunmap %
nunmap %
if &diff
  syntax on
endif
]])

require("lualine").setup({
	extensions = { "fzf", "lazy", "quickfix" },
	sections = {
		lualine_c = {
			{ "filename", path = 1 },
		},
		lualine_x = {
			"encoding", -- "fileformat",
			"searchcount",
			"filetype",
		},
	},
})

local Job = require("plenary.job")

_G.get_visual_selection_end_line = function()
	local _, le, _ = unpack(vim.fn.getpos("'>"))
	return le
end

_G.get_next_insertion_line = function()
	local mode = vim.fn.mode()
	local end_line

	if mode == "v" or mode == "V" or mode == "\22" then -- visual, visual-line, visual-block
		return _G.get_visual_selection_end_line()
	else
		local current_line = vim.api.nvim_win_get_cursor(0)[1]
		end_line = current_line
	end

	local insert_position = end_line
	return insert_position
end

_G.send_contents = function(buf_contents, extra_args, insert_inline)
	local state
	if insert_inline then
		state = { insertion_point = _G.get_next_insertion_line() }
	else
		state = { insertion_point = -1 }
	end

	vim.notify(
		string.format("ai running [insert_inline=%s, insertion_point=%s]...", insert_inline, state.insertion_point),
		vim.log.levels.INFO
	)
	local args = { "--embedded" }
	if type(extra_args) == "table" then
		for i = 1, #extra_args do
			table.insert(args, extra_args[i])
		end
	end
	Job:new({
		command = "ai",
		args = args,
		writer = buf_contents,
		on_stdout = function(_, stdout_data)
			vim.schedule(function()
				local lines = vim.split(stdout_data, "\n", true)
				vim.api.nvim_buf_set_lines(0, state.insertion_point, state.insertion_point, true, lines)
				-- Go to the end of the inserted text.
				if state.insertion_point == -1 then
					vim.api.nvim_command("normal! G")
				else
					state.insertion_point = state.insertion_point + #lines
					vim.api.nvim_command(tostring(state.insertion_point))
				end
			end)
		end,
		on_stderr = function(_, stderr_data)
			vim.schedule(function()
				for _, line in ipairs(stderr_data) do
					vim.notify(line, vim.log.levels.ERROR)
				end
			end)
		end,
		on_exit = function(_j, return_val)
			vim.schedule(function()
				require("conform").format()
				if return_val == 0 then
					vim.notify("ai completed successfully", vim.log.levels.INFO)
				else
					vim.notify("ai failed with code: " .. return_val, vim.log.levels.ERROR)
				end
			end)
		end,
	}):start()
end

_G.gather_visual_selection = function()
	local _, lnum1, col1, _ = unpack(vim.fn.getpos("'<"))
	local _, lnum2, col2, _ = unpack(vim.fn.getpos("'>"))
	local lines = vim.fn.getline(lnum1, lnum2)
	if #lines == 0 then
		return ""
	end
	lines[#lines] = string.sub(lines[#lines], 1, col2)
	lines[1] = string.sub(lines[1], col1)
	return table.concat(lines, "\n")
end

_G.create_review_visual_selection_buffer = function()
	-- Get current filetype
	local filetype = vim.bo.filetype

	local selected_text = _G.gather_visual_selection()

	-- Create the content to insert in new buffer
	local content = string.format("> user\n\nPlease review this:\n```%s\n%s\n```", filetype, selected_text)

	-- Open a new buffer
	vim.cmd("split")
	vim.cmd("enew")
	vim.cmd("setlocal ft=markdown")

	-- Insert the content
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n"))
end

_G.gather_and_send = function()
	vim.cmd("setlocal ft=markdown")
	require("conform").format()
	local buf_contents = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	_G.send_contents(buf_contents)
end

-- nmap("<leader>a", ":lua gather_and_send()<CR>")
vmap("<leader>a", ":lua create_review_visual_selection_buffer()<CR>:lua gather_and_send()<CR>")

nmap("<leader>P", ":PopulateQuickFixFromClipboard<CR>")
vim.api.nvim_create_user_command("PopulateQuickFixFromClipboard", function()
	-- Grab the contents of the system clipboard
	local clipboard_contents = vim.fn.system("pbpaste")
	local clipboard_lines = vim.split(clipboard_contents, "\n", { plain = true, trimempty = true })

	-- Define the possible formats for locations (adjust as needed)
	local location_patterns = {
		-- File paths (relative or absolute)
		{ pattern = "^(.*):(%d+):(.*)", filename_group = 1, lnum_group = 2, description_group = 3 },

		-- Python stack trace lines
		{ pattern = 'File (%b""), line (%d+), in (%w+)', filename_group = 1, lnum_group = 2, description_group = 3 },
	}

	-- Find all the locations that match any of the patterns, and record them in a table of tables.
	local locations = {}
	for _, line in ipairs(clipboard_lines) do
		for _, pattern_info in ipairs(location_patterns) do
			local p1, p2, p3 = line:match(pattern_info.pattern)
			if p1 then
				local captures = { p1, p2, p3 }
				local filename = captures[pattern_info.filename_group]:gsub('^"(.*)"$', "%1")
				if
					not string.find(filename, "site-packages", 1, true)
					and not string.find(filename, "Python.framework", 1, true)
				then
					local lnum = tonumber(captures[pattern_info.lnum_group]) or 0
					local description = captures[pattern_info.description_group]
					table.insert(locations, {
						filename = filename,
						lnum = lnum,
						text = description,
					})
				end
			end
		end
	end

	if #locations > 0 then
		-- Populate the location list window
		vim.fn.setqflist({}, "r", { title = "Clipboard Locations", items = locations })
		vim.cmd("copen") -- Open the location list window
		vim.cmd.cfirst()
	else
		vim.notify("No locations found in clipboard.", vim.log.levels.INFO)
	end
end, {})
