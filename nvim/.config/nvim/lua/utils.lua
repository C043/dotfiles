local M = {}

M.extra = " && echo . && echo . && echo Please Press ENTER to continue"

----------------------------------------------------------------------------------------
function M.TerminalOut(command)
	local width = vim.api.nvim_get_option_value("columns", {})
	local height = vim.api.nvim_get_option_value("lines", {})
	-- calculate our floating window size
	local win_height = math.ceil(height * 0.8 - 4)
	local win_width = math.ceil(width * 0.8)
	-- and its starting position
	local row = math.ceil((height - win_height) / 2.1 - 1)
	local col = math.ceil((width - win_width) / 2.1)
	local jobid
	--
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(bufnr, true, {
		relative = "win",
		border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
		width = win_width,
		style = "minimal",
		height = win_height,
		row = row,
		col = col,
	})
	--
	local chan = vim.api.nvim_open_term(bufnr, {
		on_input = function(_, _, _, data)
			if jobid then
				pcall(vim.api.nvim_chan_send, jobid, data)
			end
		end,
	})
	-- Echo the command to output termainal
	vim.api.nvim_chan_send(chan, vim.fn.getcwd() .. " > " .. command .. "\r\n\r\n\r\n")
	--
	local opts = {
		pty = true,
		-- stdin = "pipe",
		on_stdout = function(_, data)
			vim.api.nvim_chan_send(chan, table.concat(data, "\r\n"))
		end,
		on_exit = function(_, exit_code)
			vim.api.nvim_chan_send(chan, "\r\n\r\n[Process exited " .. tostring(exit_code) .. "]")
			vim.api.nvim_chan_send(chan, "\r\n\r\nPress <ENTER> to close this window.")
			vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "<cmd>bd!<CR>", { noremap = true, silent = true })
		end,
	}
	-- Send the command to terminal
	jobid = vim.fn.jobstart(command, opts)
end

return M
