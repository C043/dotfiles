return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- UI for dap
			"jay-babu/mason-nvim-dap.nvim", -- Optional: Manages debuggers
			"williamboman/mason.nvim", -- If you use Mason for managing LSPs
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
	},
}
