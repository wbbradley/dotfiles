local h = require("null-ls.helpers")
local u = require("null-ls.utils")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING
local RANGE_FORMATTING = methods.internal.RANGE_FORMATTING

return h.make_builtin({
    name = "autoimport",
    meta = {
        url = "https://github.com/lyz-code/autoimport",
        description = "Autoimport missing python libraries.",
    },
    method = { FORMATTING },
    filetypes = { "python" },
    generator_opts = {
        command = ".venv/bin/autoimport",
        args = function(params)
            assert(params.method == FORMATTING)
            return { "-" }
        end,
        to_stdin = true,
        cwd = h.cache.by_bufnr(function(params)
            return u.root_pattern(
                "pyproject.toml"
            )(params.bufname)
        end),
    },
    factory = h.formatter_factory,
})
