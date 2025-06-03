-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Normal Mode
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "j", "jzz")
vim.keymap.set("n", "k", "kzz")
vim.keymap.set("n", "o", "zzo")
vim.keymap.set("n", "O", "zzO")
vim.keymap.set("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>")
vim.keymap.set("n", "<leader>ss", "<cmd>write<CR>", { desc = "[S][a]ve the current file" })

vim.keymap.set({ "n", "i" }, "<M-l>", "<cmd>ToggleCheckbox<CR>")

vim.keymap.set(
	"n",
	"<leader>fr",
	"<cmd>FunctionReference<CR>",
	{ desc = "Show the call stack of a certain method or function" }
)

local copilot_on = false
vim.keymap.set("n", "<leader>ct", function()
	if copilot_on then
		vim.cmd("Copilot disable")
		print("Copilot OFF")
	else
		vim.cmd("Copilot enable")
		print("Copilot ON")
	end
	copilot_on = not copilot_on
end, { desc = "Toggle Copilot" })

local spell_check_on = false
vim.keymap.set("n", "<leader>sl", function()
	if spell_check_on then
		vim.cmd("set nospell")
		spell_check_on = false
		print("Spell check OFF")
	else
		local lang = vim.fn.input("Choose language (it/en): ")
		if lang == "it" or lang == "en" then
			vim.cmd("set spell")
			vim.cmd("set spelllang=" .. lang)
			spell_check_on = true
			print("Spell check " .. lang .. " ON")
		else
			print("Unsupported language: " .. lang)
		end
	end
end, { desc = "Toggle italian spell checker" })

vim.keymap.set("n", "<leader>sc", "<cmd>Scratch<CR>", { desc = "Open a temporary buffer to take temprary notes" })

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>w", "gqap", { desc = "Format Paragraph" })

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>qq", "<cmd>BufferClose<CR>")
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Debugger keymaps
vim.keymap.set("n", "<F5>", function()
	require("dap").continue()
end)
vim.keymap.set("n", "<F10>", function()
	require("dap").step_over()
end)
vim.keymap.set("n", "<F11>", function()
	require("dap").step_into()
end)
vim.keymap.set("n", "<F12>", function()
	require("dap").step_out()
end)
vim.keymap.set("n", "<Leader>b", function()
	require("dap").toggle_breakpoint()
end)
vim.keymap.set("n", "<Leader>B", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end)
vim.keymap.set("n", "<Leader>dr", function()
	require("dap").repl.open()
end)
vim.keymap.set("n", "<Leader>dh", function()
	require("dap.ui.widgets").hover()
end)
vim.keymap.set("n", "<Leader>dl", function()
	require("dap").run_last()
end)

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>t", "<cmd>split | terminal<cr>", { desc = "Open Terminal Buffer" })

-- vim.keymap.set("n", "<leader>t", "<cmd>NvimTreeFindFileToggle<cr>", { desc = "Toggle FileTree" })
vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open Oil for in the current buffer" })
vim.keymap.set(
	"n",
	"<leader>co",
	"<cmd>NvimTreeCollapseKeepBuffers<cr>",
	{ desc = "FileTree Collapse Keeping Buffers" }
)

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows

--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<C-1>", "<Cmd>BufferGoto 1<CR>")
vim.keymap.set("n", "<C-2>", "<Cmd>BufferGoto 2<CR>")
vim.keymap.set("n", "<C-3>", "<Cmd>BufferGoto 3<CR>")
vim.keymap.set("n", "<C-4>", "<Cmd>BufferGoto 4<CR>")
vim.keymap.set("n", "<C-5>", "<Cmd>BufferGoto 5<CR>")
vim.keymap.set("n", "<C-6>", "<Cmd>BufferGoto 6<CR>")
vim.keymap.set("n", "<C-7>", "<Cmd>BufferGoto 7<CR>")
vim.keymap.set("n", "<C-8>", "<Cmd>BufferGoto 8<CR>")
vim.keymap.set("n", "<C-9>", "<Cmd>BufferGoto 9<CR>")
vim.keymap.set("n", "<C-0>", "<cmd>Dashboard<CR>", { desc = "Open DashBoard" })

-- Visual Mode
-- Visual mode mappings to move lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Indentation
vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")

vim.keymap.set("n", "<Tab>", ">>")
vim.keymap.set("n", "<S-Tab>", "<<")
