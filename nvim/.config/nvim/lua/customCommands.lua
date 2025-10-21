-- Scratch buffer creation custom command
vim.api.nvim_create_user_command("Scratch", function()
	vim.cmd("enew")
	vim.bo.buftype = "nofile"
	vim.bo.bufhidden = "hide"
	vim.bo.swapfile = false
	vim.bo.filetype = "markdown"
end, {})

vim.api.nvim_create_user_command("ToggleCheckbox", function()
	-- Toggle Checkbox custom command
	local checked_character = "x"
	local checked_checkbox = "%[" .. checked_character .. "%]"
	local unchecked_checkbox = "%[ %]"

	local line_contains_unchecked = function(line)
		return line:find(unchecked_checkbox)
	end

	local line_contains_checked = function(line)
		return line:find(checked_checkbox)
	end

	local line_with_checkbox = function(line)
		-- return not line_contains_a_checked_checkbox(line) and not line_contains_an_unchecked_checkbox(line)
		return line:find("^%s*- " .. checked_checkbox)
			or line:find("^%s*- " .. unchecked_checkbox)
			or line:find("^%s*%d%. " .. checked_checkbox)
			or line:find("^%s*%d%. " .. unchecked_checkbox)
	end

	local get_indent = function(line)
		return line:match("^(%s*)") or ""
	end

	local checkbox = {
		check = function(line)
			return line:gsub(unchecked_checkbox, checked_checkbox, 1)
		end,

		uncheck = function(line)
			return line:gsub(checked_checkbox, unchecked_checkbox, 1)
		end,

		make_checkbox = function(line)
			local indent = get_indent(line)
			if line:match("^%s*$") then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
				return indent .. "- [ ] "
			end
		end,
	}
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local start_line = cursor[1] - 1
	local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

	-- If the line contains a checked checkbox then uncheck it.
	-- Otherwise, if it contains an unchecked checkbox, check it.
	local new_line = ""

	if not line_with_checkbox(current_line) then
		new_line = checkbox.make_checkbox(current_line)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>A", true, false, true), "n", true)
	elseif line_contains_unchecked(current_line) then
		new_line = checkbox.check(current_line)
	elseif line_contains_checked(current_line) then
		new_line = checkbox.uncheck(current_line)
	end

	vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, { new_line })
	vim.api.nvim_win_set_cursor(0, cursor)
end, {})
