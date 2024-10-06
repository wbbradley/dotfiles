local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

return h.make_builtin({
  name = "yamlcheck",
  method = DIAGNOSTICS,
  filetypes = { "yaml" },
  generator_opts = {
    command = "yamlcheck",
    args = { "--stdin-filename", "$FILENAME", "-" },
    to_stdin = true,
    from_stderr = true,
    format = "line",
    check_exit_code = function(code)
      return code == 0
    end,
    on_output = h.diagnostics.from_patterns({
        {
          pattern = [[.*:(%d+):(%d+): (.*)]],
          groups = { "row", "col", "message" },
        }
    }),
  },
  factory = h.generator_factory,
})
