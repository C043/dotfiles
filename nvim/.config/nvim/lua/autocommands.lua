local utils = require("utils")
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd("Copilot disable")
		local user = os.getenv("USER") or os.getenv("USERNAME")
		print("Welcome back, " .. user .. "!")
	end,
})

vim.api.nvim_create_autocmd("BufWinLeave", {
	callback = function()
		-- Schedule to run after the buffer fully loads
		vim.schedule(function()
			-- Check if we're in an empty [No Name] buffer and no listed buffers remain
			local bufname = vim.api.nvim_buf_get_name(0)
			local buftype = vim.bo.buftype

			local listed = vim.tbl_filter(function(buf)
				return vim.fn.buflisted(buf) == 1
			end, vim.api.nvim_list_bufs())

			-- Conditions: No buffers left, current is empty and not a special terminal/etc
			if #listed == 1 and bufname == "" and buftype == "" then
				vim.cmd("Dashboard")
			end
		end)
	end,
})

-- NOTE Running files inside NeoVim autocommand
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = function()
		local fileName = vim.api.nvim_buf_get_name(0)
		local filetype = vim.bo.filetype
		if filetype == "javascript" then
			vim.keymap.set("n", "<leader>rr", function()
				utils.TerminalOut("node " .. fileName)
			end, { desc = "Execute the current buffer script" })
		end

		if filetype == "lua" then
			vim.keymap.set("n", "<leader>rr", function()
				utils.TerminalOut("lua " .. fileName)
			end, { desc = "Execute the current buffer script" })
		end

		if filetype == "java" then
			vim.keymap.set("n", "<leader>rr", "<cmd>JavaRunnerRunMain<CR>", { desc = "Run Java Runner" })
		end

		if filetype == "cpp" then
			vim.keymap.set(
				"n",
				"<leader>rr",
				"<cmd>Piorun<CR>",
				{ desc = "Uploads the arduino sketch on the arduino board" }
			)
			vim.keymap.set("n", "<leader>rb", "<cmd>Piorun build<CR>", { desc = " Tests the arduino sketch" })
		end

		if filetype == "openscad" then
			vim.keymap.set("n", "<leader>rr", "<cmd>OpenscadExecFile<CR>", { desc = "Open openscad file in viewer" })
			vim.keymap.set("n", "<leader>ff", "magg=G'azz", { desc = "Format all openscad file" })
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "ejs",
	callback = function()
		vim.opt_local.indentexpr = ""
	end,
})

-- vim.cmd("autocmd BufNewFile,BufRead *.ejs set filetype=html")
-- vim.cmd("autocmd BufNewFile,BufRead *.ejs set filetype=ejs.html")

vim.filetype.add({ extension = { ejs = "ejs" } })
--vim.treesitter.language.register("html", "ejs")
-- vim.treesitter.language.register("javascript", "ejs")
-- vim.treesitter.language.register("embedded_template", "ejs")
