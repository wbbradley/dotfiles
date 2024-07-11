-- A linter for nvim-lint
local function find_file_in_parent_dirs(filename, start_dir)
	local current_dir = start_dir or "." -- Start in current directory if not provided
	local path_sep = package.config:sub(1, 1) -- Get path separator (either '/' or '\')

	while true do
		-- Check if the file exists in the current directory
		local file_path = current_dir .. path_sep .. filename
		local file = io.open(file_path, "r")
		if file then
			file:close()
			return file_path
		end

		-- Move up one directory
		local parent_dir = current_dir:match("(.*)" .. path_sep .. "[^" .. path_sep .. "]+")
		if not parent_dir or parent_dir == current_dir then -- Reached root or current dir
			return nil -- File not found in any parent directory
		end
		current_dir = parent_dir
	end
end

return {
	cmd = "cargo",
	args = {
		"clippy",
		"--message-format=json",
		function()
			local filename = vim.api.nvim_buf_get_name(0)
			local related_cargo_toml = find_file_in_parent_dirs(filename, "Cargo.toml")
			return { "--manifest-path", related_cargo_toml } -- Get the current buffer's filename
		end,
	},
	stream = "stdout",
	ignore_exitcode = true, -- Clippy can exit with non-zero even with warnings
	parser = function(output)
		local diagnostics = {}
		for line in output:gmatch("[^\r\n]+") do
			if string.sub(line, 0, 1) == "{" then
				local json = vim.json.decode(line)
				if json.reason == "compiler-message" then
					table.insert(diagnostics, {
						lnum = json.spans[1].line_start,
						col = json.spans[1].column_start,
						message = json.message,
						severity = ({
							note = vim.diagnostic.severity.INFO,
							help = vim.diagnostic.severity.HINT,
							warning = vim.diagnostic.severity.WARN,
							error = vim.diagnostic.severity.ERROR,
						})[json.level] or vim.diagnostic.severity.WARN,
					})
				end
			end
		end
		return diagnostics
	end,
}
