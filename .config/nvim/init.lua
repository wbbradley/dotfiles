-- [[
-- Lazy package manager
-- luacheck: globals vim
-- ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load global variables from lua/config/globals.lua
local globals = require('config.globals')

-- packages
local lazy_plugins = {
  "easymotion/vim-easymotion",
  "folke/trouble.nvim",
  "lewis6991/gitsigns.nvim",
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" }
    },
    opts = {
      -- Your setup opts here
    }
  },
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" }
    },
    opts = {
      -- Your setup opts here
    }
  },
  "folke/which-key.nvim",
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false }
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
  {
    "MysticalDevil/inlay-hints.nvim",
    event = "LspAttach",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function() require("inlay-hints").setup() end
  },
  "jremmen/vim-ripgrep",
  {
    "ibhagwan/fzf-lua",
    config = function()
      -- calling `setup` is optional for customization
      local actions = require("fzf-lua.actions")
      require("fzf-lua").setup({
        -- preview_opts = "hidden", -- NB: Toggle the preview with <F4>.
        fzf_opts = { ["--layout"] = "default" },
        actions = {
          files = {
            ["enter"] = function(selected, opts)
              local retval = actions.file_edit_or_qf(selected, opts)
              if vim.fn.win_gettype() == "quickfix" then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>",
                                                                     true, true,
                                                                     true), "n",
                                      false)
              end
              return retval
            end
          }
        }
        -- cmd = "git grep --line-number --column --color=always",
      })
      require("fzf-lua").register_ui_select()
    end
  }, -- "nvimtools/none-ls.nvim",
  {
    "neovim/nvim-lspconfig",
    dependencies = { { "j-hui/fidget.nvim", opts = {} } },
    opts = { inlay_hints = { enabled = false } },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach",
                                            { clear = true }),
        callback = function(_)
          -- local capabilities = vim.lsp.protocol.make_client_capabilities()
          -- vim.tbl_deep_extend("force", capabilities, {
          --   workspace = { didChangeWatchedFiles = { dynamicRegistration = true } }
          -- })
          -- require('lspconfig').rust_analyzer
          --     .setup { capabilities = capabilities }
        end
      })
    end
  },
  "modocache/move.vim",
  {
    "saecki/crates.nvim",
    tag = "stable",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup {
        completion = {
          cmp = { enabled = false },
          crates = { enabled = true, max_results = 8, min_chars = 3 }
        },
        lsp = { enabled = true, actions = true, completion = true, hover = true }
      }
    end
  },
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = 'rafamadriz/friendly-snippets',

    -- use a release tag to download pre-built binaries
    version = 'v0.13.1',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- Defaults are at https://cmp.saghen.dev/configuration/reference.html#completion-keyword
      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'select_and_accept', 'fallback' },
        ['<F1>'] = { 'show_documentation', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' }
      },

      cmdline = {
        completion = {
          list = { selection = { preselect = false, auto_insert = true } },
          menu = { auto_show = false }
        }
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        trigger = { prefetch_on_insert = true }
      },
      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer', 'cmdline' } }
      -- cmdline = { sources = {} }
    },
    opts_extend = { "sources.default" }
  },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   event = "InsertEnter",
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-buffer",
  --     "hrsh7th/cmp-path",
  --     "hrsh7th/cmp-cmdline"
  --   },
  --   config = function()
  --     local cmp = require("cmp")
  --     cmp.setup({
  --       completion = { completeopt = "menu,menuone,noinsert" },
  --       mapping = cmp.mapping.preset.insert({
  --         ["<C-j>"] = cmp.mapping.select_next_item(),
  --         ["<C-k>"] = cmp.mapping.select_prev_item(),
  --         ["<Tab>"] = cmp.mapping.confirm({ select = true })
  --         --[[["<C-l>"] = cmp.mapping(function(fallback)
  --           vim.api.nvim_feedkeys(
  --             vim.fn["copilot#Accept"](vim.api.nvim_replace_termcodes("<Tab>", true, true, true)),
  --             "n",
  --             true
  --           )
  --         end),]]
  --       }),
  --       experimental = { ghost_text = false },
  --       sources = {
  --         { name = "lazydev", group_index = 0 },
  --         { name = "nvim_lsp" },
  --         { name = "path" },
  --         { name = "buffer" }
  --       }
  --     })
  --   end
  -- },
  "nvim-lua/plenary.nvim",
  "nvim-treesitter/nvim-treesitter",
  "nvim-treesitter/nvim-treesitter-context",
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } }
      }
    }
  },
  { "Bilal2453/luvit-meta", lazy = true },
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
  "rust-lang/rust.vim",
  { "mrcjkb/rustaceanvim", ft = { "rust" } },
  "andersevenrud/nvim_context_vt"
}

if globals.allow_copilot then
  lazy_plugins[#lazy_plugins + 1] = {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",

    config = function()
      require("copilot").setup({
        suggestion = {
          auto_trigger = true,
          hide_during_completion = false,
          keymap = { accept = "<C-l>" }
        },
        -- panel = { enabled = true, auto_refresh = true },
        filetypes = {
          markdown = true,
          text = false -- prevent copilot while password-store editing
        }
      })
      vim.cmd([[
        imap <expr> <Plug>(vimrc:copilot-dummy-map) copilot#Accept("\<Tab>")
      ]])
    end
  }
end

-- if vim.loop.cwd() == os.getenv("HOME") .. "/src/walrus" then
--   vim.print("Walrus detected")
--           local capabilities = vim.lsp.protocol.make_client_capabilities()
--           vim.tbl_deep_extend("force", capabilities, {
--             workspace = { didChangeWatchedFiles = { dynamicRegistration = true } }
--           })
--   vim.g.rustaceanvim = {
--     server = {
--       default_settings = {
--         ['rust-analyzer'] = {
--           diagnostics = { disabled = { "inactive-code" } },
--           rustfmt = {
--             extraArgs = {
--               "--config",
--               "group_imports=StdExternalCrate,imports_granularity=Crate,imports_layout=HorizontalVertical"
--             }
--           },
--           -- cargo = { features = { "walrus-service/backup" } }
--           cargo = { profile = "dev", features = "all" }
--         }
--       }
--     }
--   }
-- elseif vim.loop.cwd() ~= os.getenv("HOME") .. "/src/sui" then
--   vim.g.rustaceanvim = {
--     server = {
--       default_settings = {
--         ['rust-analyzer'] = {
--           rustfmt = {
--             extraArgs = {
--               "--config",
--               "group_imports=StdExternalCrate,imports_granularity=Crate,imports_layout=HorizontalVertical"
--             }
--           }
--         }
--       }
--     }
--   }
-- end

-- Lazy doesn't support hot reloading, so we need to check if it's already been loaded
if vim.g.lazy_loaded == nil then
  require("lazy").setup(lazy_plugins, {})
  vim.g.lazy_loaded = true
end
require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_opts = { virt_text_pos = "right_align" }
})
vim.cmd("Gitsigns toggle_current_line_blame")
-- local _ = require("cmp")

require("lspconfig").gopls.setup({})
require("lspconfig").terraformls.setup({})
require("lspconfig").clangd.setup({})
require('lspconfig').ts_ls.setup({})
require('lspconfig').move_analyzer.setup({})

vim.cmd("colorscheme gruvbox")
require("nvim_context_vt").setup({
  min_rows = 30,
  disable_ft = { "markdown", "lua" },
  -- Disable display of virtual text below blocks for indentation based languages like Python
  -- Default: false
  disable_virtual_lines = false
})

--[[ require("lint").linters.cargo = require("cargo")
require("lint").linters_by_ft = {
  python = { "ruff" }, -- , "mypy" },
  sh = { "shellcheck" },
  yaml = { "yamllint" },
  toml = { "tomllint" },
  lua = { "luacheck" },
  sql = { "pgsanity" },
  -- go = { "golangci-lint" },
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
  group = vim.api.nvim_create_augroup("lint-on-save", { clear = true }),
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
]]
local function keymap(mode, shortcut, command)
  vim.keymap.set(mode, shortcut, command, { noremap = true, silent = true })
end

local function nmap(shortcut, command) keymap("n", shortcut, command) end
nmap("<F6>", ":SymbolsOutline<CR>")
nmap("M", ":FzfLua oldfiles<CR>")
nmap("<C-p>", ":FzfLua git_files<CR>")
nmap("<leader>[", ":InlayHintsToggle<CR>")
nmap("E", ':lua require("fzf-lua").live_grep()')
nmap("vv", "viw")
nmap(",", "<Plug>(easymotion-s)")

-- Treesitter
require("treesitter-context").setup({
  mode = "cursor",
  -- mode = 'topline',
  max_lines = 5,
  min_window_height = 20,
  multiline_threshold = 4
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
    "yaml"
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
    end
  }
})
vim.g.laststatus = 2

vim.keymap.set("n", "F", function()
  require("fzf-lua").live_grep({
    no_esc = true,
    search = "",
    cmd = "git grep --line-number --column --color=always"
  })
end)
vim.keymap.set("n", "<F3>", function()
  require("fzf-lua").grep_cword({
    cmd = "git grep --line-number --column --color=always"
  })
end)

nmap("g]",
     "<cmd>lua require('fzf-lua').tags({ fzf_opts = { ['--query'] = vim.fn.expand('<cword>') } })<CR>")

vim.keymap.set('n', '<leader>a', function() vim.lsp.buf.code_action() end)

vim.keymap.set('v', '<leader>a', function() vim.lsp.buf.code_action() end)

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
nnoremap <Leader>1 :e ~/README.md<CR>Go<Esc>:r!date<CR>
nnoremap <Leader>2 :e ~/github.txt<CR>Go<Esc>:r!date<CR>
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

nnoremap <F2> :mksession!<CR>
nnoremap <F14> :source Session.vim<CR>

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set nolazyredraw
set history=50 " keep 50 lines of command line history
set ruler      " show the cursor position all the time
set showcmd    " display incomplete commands
set incsearch  " do incremental searching

" Don't use Ex mode, use Q for formatting
vmap Q gq
nmap Q VQ

nmap <Leader><Leader> va}=
" nnoremap <expr> <C-p> (len(system('git -C ' . expand('%:p:h') . ' rev-parse' )) ? (':Files ' . expand('%:p:h')) : ':GFiles')."\<cr>"
" nmap M :History<CR>

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

nnoremap <leader>` :!build-ctags<CR>

" :execute 'grep! ' . expand('<cword>') . ' *'<CR>

nnoremap <F4> :call FindWordUnderCursorNoUI()<CR>

nnoremap B :FzfLua buffers<CR>
nnoremap <F7> :FzfLua lsp_workspace_diagnostics async=true<CR>
nnoremap <leader>C :FzfLua lsp_incoming_calls async=true<CR>
nnoremap <F12> :FzfLua lsp_incoming_calls async=true<CR>
nnoremap <leader>R :FzfLua lsp_references async=true<CR>
nnoremap <leader>T :FzfLua lsp_workspace_symbols async=true<CR>
nnoremap <leader>f :call FindPromptRaw()<CR>
nnoremap <leader>g :w<CR>:!git add %<CR>
nnoremap E :call FindPromptDirect()<CR>
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
vnoremap <leader>q :conf qa<CR>
nnoremap <leader>t mTviwy:e ~/vim-todo.txt<CR>ggPa<CR><Esc>:w<CR>'T
nnoremap <leader>v <C-w>v<C-w>l<C-w>n<C-w>h
nnoremap <leader>w :wa<CR>

nnoremap <leader>90 :e ~/.config/nvim/init.lua<CR>
nnoremap <leader>92 :e ~/.bashrc<CR>
nnoremap <leader>93 :e ~/local.bashrc<CR>
nnoremap <leader>9a :e ~/.config/alacritty/alacritty.toml<CR>
nnoremap <leader>9b :e ~/.bashrc<CR>
nnoremap <leader>9d :e ~/.config/dmypyls/dmypyls.yaml<CR>
nnoremap <leader>9k :e ~/Library/Application Support/k9s/screen-dumps/<CR>
nnoremap <leader>9l :e ~/local.bashrc<CR>
nnoremap <leader>9n :e ~/notes.md<CR>G
nnoremap <leader>9p :e ~/.config/pickls/pickls.yaml<CR>

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
" nmap <F7> :wa<CR> :!clear <CR><CR> :lmake<CR><CR>
" imap <F7> <Esc> <F7>
" vmap <F7> <Esc> <F7>

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
  autocmd FileType python setlocal textwidth=100
  autocmd FileType python setlocal colorcolumn=100,101,102,103
augroup END

autocmd BufRead *.ai setlocal ft=markdown
autocmd BufRead *.tf setlocal ft=terraform

augroup RustCore
  autocmd FileType rust nmap <F19> :wa<CR>:pclose<CR>:compiler cargo<CR>:setlocal makeprg=cargo\ check<CR>:make<CR><CR>
  autocmd FileType rust nmap <F20> :wa<CR>:pclose<CR>:compiler cargo<CR>:setlocal makeprg=cargo\ test\ --no-run<CR>:make<CR><CR>
  autocmd FileType rust nmap <F21> :wa<CR>:pclose<CR>:compiler cargo<CR>:setlocal makeprg=cargo\ simtest\ simtest\ build\ --profile\ simtest<CR>:make<CR><CR>
  autocmd FileType rust setlocal colorcolumn=100,101,102,103
  autocmd FileType rust nnoremap <leader>d Owalrus_utils::crumb!();<Esc>_
augroup END

hi ColorColumn ctermfg=blue ctermbg=darkgray guibg=#333333 guifg=#1111bb cterm=NONE

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

augroup bash
  autocmd FileType bash setlocal textwidth=100
  autocmd FileType bash setlocal colorcolumn=100,101,102,103
augroup END

" hi! MatchParen cterm=NONE,bold gui=NONE,bold guibg=#eee8d5 guifg=NONE
" syn match Braces display '[<>{}\[\]()]'

let c_no_curly_error=1

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

vim.api.nvim_set_var("copilot_status", "")

require("lualine").setup({
  extensions = { "fzf", "lazy", "quickfix" },
  sections = {
    lualine_c = { { "filename", path = 1 } },
    lualine_x = {
      "encoding", -- "fileformat",
      "searchcount",
      "filetype",
      function()
        local copilot_status = vim.api.nvim_get_var("copilot_status")

        if copilot_status == "Normal" then
          return "Copilot(Normal)"
        elseif copilot_status == "InProgress" then
          return "Copilot(InProgress)"
        elseif copilot_status == "Error" then
          return "Copilot(Error)"
        else
          return ""
        end
      end
    }
  }
})

local function is_home_directory(path)
  local home_dir = os.getenv("HOME")
  return path == home_dir
end

local function file_age_in_seconds(filename)
  local uv = vim.loop
  local stat = uv.fs_stat(filename)
  if stat and stat.mtime then
    -- Get the current time in seconds since the epoch
    local current_time = os.time()
    -- Calculate the age by subtracting the modification time from the current time
    return current_time - stat.mtime.sec
  else
    return nil
  end
end

local ctagsAfterSave = os.getenv("CTAGS_ON_SAVE") -- Get the environment variable
if ctagsAfterSave then
  -- Execute code for when CTAGS_ON_SAVE is set
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPre" }, {
    group = vim.api.nvim_create_augroup("ctags-on-save", { clear = true }),
    callback = function(_)
      local root_dir = vim.fs.root(0, { ".git" })

      if root_dir then
        if is_home_directory(root_dir) then
          return
        end
        local tags_filename = root_dir .. "/tags"
        local success, age_in_seconds =
            pcall(file_age_in_seconds, tags_filename)
        if not success or age_in_seconds == nil or (age_in_seconds > 5 * 60) then
          local cmd = 'sh -c "cd ' .. root_dir .. '; build-ctags &"'
          -- vim.notify(cmd)
          vim.fn.system(cmd)
        end
      end
    end
  })
end

vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename,
               { silent = true, desc = "Rename symbol" })
vim.api.nvim_create_autocmd({ "BufRead" }, {
  group = vim.api.nvim_create_augroup("pickls-bufread", { clear = true }),
  callback = function(_)
    if vim.fn.executable("pickls") ~= 0 then
      -- We found an executable for pickls.
      vim.lsp.set_log_level(vim.log.levels.INFO)
      vim.lsp.start({
        name = "pickls",
        cmd = { "pickls", vim.api.nvim_buf_get_name(0) },
        root_dir = vim.fs.root(0, {
          ".git",
          "pyproject.toml",
          "setup.py",
          "go.mod"
        })
      }, { bufnr = 0, reuse_client = function(_, _) return false end })
    end
  end
})

vim.api.nvim_create_autocmd("BufWritePre",
                            { callback = function() vim.lsp.buf.format() end })

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = { "*.py" },
  group = vim.api.nvim_create_augroup("dmypyls-bufread", { clear = true }),
  callback = function(_)
    if vim.fn.executable("dmypyls") ~= 0 then
      -- We found an executable for dmypyls.
      vim.lsp.set_log_level(vim.log.levels.INFO)
      vim.lsp.start({
        name = "dmypyls",
        cmd = { "dmypyls", vim.api.nvim_buf_get_name(0) },
        root_dir = vim.fs.root(0, {
          ".git",
          "pyproject.toml",
          "setup.py",
          "mypy.ini"
        })
      }, { bufnr = 0 })
      vim.cmd("nmap <buffer> K :lua vim.lsp.buf.hover()<CR>")
    end
  end
})

vim.diagnostic.config({ float = { source = 'always' } })

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

  vim.notify(string.format(
                 "ai running [insert_inline=%s, insertion_point=%s]...",
                 insert_inline, state.insertion_point), vim.log.levels.INFO)
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
        vim.api.nvim_buf_set_lines(0, state.insertion_point,
                                   state.insertion_point, true, lines)
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
        if return_val == 0 then
          vim.notify("ai completed successfully", vim.log.levels.INFO)
        else
          vim.notify("ai failed with code: " .. return_val, vim.log.levels.ERROR)
        end
      end)
    end
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
  local content = string.format("> user\n\nPlease review this:\n```%s\n%s\n```",
                                filetype, selected_text)

  -- Open a new buffer
  vim.cmd("split")
  vim.cmd("enew")
  vim.cmd("setlocal ft=markdown")

  -- Insert the content
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, "\n"))
end

_G.gather_and_send = function()
  vim.cmd("setlocal ft=markdown")
  local buf_contents = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  _G.send_contents(buf_contents)
end

if globals.allow_copilot then
  vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("password-store-copilot-disable",
                                        { clear = true }),
    callback = function(_)
      -- Check whether the current buffer's filename contains the string "pass"
      -- and if so, disable copilot suggestions.
      if string.find(vim.api.nvim_buf_get_name(0), "/pass.") then
        vim.b.copilot_suggestion_auto_trigger = false
      elseif string.find(vim.api.nvim_buf_get_name(0), ".md") then
        vim.b.copilot_suggestion_auto_trigger = false
      end
    end
  })
end

local function jump_to_rust_module()
  local current_dir = vim.fn.expand('%:p:h')
  local parent_dir = vim.fn.fnamemodify(current_dir, ':h')
  local dir_name = vim.fn.fnamemodify(current_dir, ':t')

  -- Define the potential module file names
  local potential_modules = {
    current_dir .. '/lib.rs',
    parent_dir .. '/' .. dir_name .. '.rs'
  }

  -- Check each potential module file and jump if it exists
  for _, module in ipairs(potential_modules) do
    if vim.fn.filereadable(module) == 1 then
      vim.cmd('edit ' .. module)
      return
    end
  end

  print("Module declaration not found")
end

-- Create a Vim command to easily access the function
vim.api.nvim_create_user_command('RustJumpToModule', jump_to_rust_module, {})
nmap("<leader>E", ":RustJumpToModule<CR>")

nmap("<leader>P", ":PopulateQuickFixFromClipboard<CR>")
vim.api.nvim_create_user_command("PopulateQuickFixFromClipboard", function()
  -- Grab the contents of the system clipboard
  local clipboard_contents = vim.fn.system("pbpaste")
  local clipboard_lines = vim.split(clipboard_contents, "\n",
                                    { plain = true, trimempty = true })

  -- Define the possible formats for locations (adjust as needed)
  local location_patterns = {
    -- Rust cargo build output
    {
      pattern = ".* ([^: ]+):(%d+):(.*)",
      filename_group = 1,
      lnum_group = 2,
      description_group = "line_before"
    }, -- File paths (relative or absolute)
    {
      pattern = "^([^0-9][^ :]*):(%d+):(.*)",
      filename_group = 1,
      lnum_group = 2,
      description_group = 3
    }, -- Python stack trace lines
    {
      pattern = 'File (%b""), line (%d+), in (%w+)',
      filename_group = 1,
      lnum_group = 2,
      description_group = 3
    }
  }
  -- Find all the locations that match any of the patterns, and record them in a table of tables.
  local locations = {}
  for _, line in ipairs(clipboard_lines) do
    if not string.find(line, "was not used in the crate graph", 1, true) then
      for _, pattern_info in ipairs(location_patterns) do
        local p1, p2, p3 = line:match(pattern_info.pattern)
        if p1 then
          local captures = { p1, p2, p3 }
          local filename = captures[pattern_info.filename_group]:gsub(
                               '^"(.*)"$', "%1")
          if string.len(filename) > 1 and
              not string.find(filename, "site-packages", 1, true) and
              not string.find(filename, "Python.framework", 1, true) and
              not string.find(filename, "/.cargo/", 1, true) and
              not string.find(filename, "importlib", 1, true) and
              not string.find(filename, "/rustc/", 1, true) then
            if filename:sub(1, 5) == "/app/" then
              filename = filename:sub(6)
            end
            local lnum = tonumber(captures[pattern_info.lnum_group]) or 0
            local description = captures[pattern_info.description_group]
            table.insert(locations, {
              filename = filename,
              lnum = lnum,
              text = description
            })
          end
        end
      end
    end
  end

  if #locations > 0 then
    -- Populate the location list window
    vim.fn.setqflist({}, "r",
                     { title = "Clipboard Locations", items = locations })
    vim.cmd("copen") -- Open the location list window
    vim.cmd.cfirst()
  else
    vim.notify("No locations found in clipboard.", vim.log.levels.INFO)
  end
end, {})

nmap("<leader>=", ":OpenNearestCargoToml<CR>")
vim.api.nvim_create_user_command("OpenNearestCargoToml", function()
  local path = vim.fn.expand('%:p')
  local dir = vim.fn.fnamemodify(path, ':h')
  while dir ~= "/" do
    local cargo_toml = dir .. "/Cargo.toml"
    if vim.fn.filereadable(cargo_toml) == 1 then
      vim.cmd('edit ' .. cargo_toml)
      return
    end
    dir = vim.fn.fnamemodify(dir, ':h')
  end
  print("No Cargo.toml found.")
end, {})
