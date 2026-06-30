# COMPLETED

## Go language development support

Brought Go editing to Rust parity in the nvim config:

- Added a `vim.lsp.config('gopls', ...)` settings block (gofumpt, staticcheck,
  usePlaceholders, unusedparams/unusedwrite/nilness analyses, inlay hints off)
  before `vim.lsp.enable('gopls')` in `.config/nvim/init.lua`.
- Organize-imports-on-save: registered a gopls-gated `source.organizeImports`
  `BufWritePre` callback inside `LspAttach`, ordered before the existing
  gofmt format-on-save so a single save organizes imports then formats.
- New `.config/nvim/after/ftplugin/go.lua` setting hard tabs
  (`noexpandtab`, `tabstop/shiftwidth/softtabstop = 4`).
- Added `gomod`, `gosum`, `gowork`, `gotmpl` treesitter parsers.
- Removed the stale `<C-n>` → `<C-x><C-o>` Go omni-complete mapping (cmp now
  handles completion).
- `install.sh` now bootstraps `gopls` via `go install` (guarded on the `go`
  toolchain being present, since Linux may lack it).

Verified end-to-end: nvim starts clean, the four new parsers install, a `.go`
buffer shows `noexpandtab`/`ts=4`/`sw=4`, and saving a file with an unused
import + missing import + bad formatting both organizes imports and gofmt-formats
in one write.
