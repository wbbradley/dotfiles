local M = {}

function M.open()
  vim.cmd.edit(vim.fn.fnameescape(vim.fn.expand("~/README.md")))
  vim.cmd.normal({ "Go# \27", bang = true })
  vim.cmd("read !date")
  vim.cmd.normal({ "kJo\r\27", bang = true })
end

return M
