require("noice").setup({
  messages = {
    enabled = false,
  },
  notify = {
    enabled = false,
  },
  lsp = {
    progress = {
      enabled = false,
    },
  },
})

-- Force Neovim to use its default notification handler instead of Noice's UI
if vim.notify_original then
  vim.notify = vim.notify_original

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      vim.notify = vim.notify_original
    end,
  })
end
