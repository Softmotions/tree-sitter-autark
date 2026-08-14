-- Current nvim-treesitter `main` branch / Neovim 0.12+.
-- The parser and queries are installed directly from GitHub.
local repo = 'https://github.com/Softmotions/tree-sitter-autark'

vim.filetype.add({
  filename = {
    Autark = 'autark',
  },
  extension = {
    autark = 'autark',
  },
})

local function register_parser()
  local ok, parsers = pcall(require, 'nvim-treesitter.parsers')
  if not ok then
    return
  end

  parsers.autark = {
    install_info = {
      url = repo,
      branch = 'main',
      -- src/parser.c is checked in, so generation is not required.
      queries = 'queries',
    },
  }
end

-- Register immediately when nvim-treesitter is already loaded, and register
-- again for parser update/install operations as recommended by nvim-treesitter.
register_parser()
vim.api.nvim_create_autocmd('User', {
  pattern = 'TSUpdate',
  callback = register_parser,
})
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = register_parser,
})

vim.treesitter.language.register('autark', { 'autark' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'autark',
  callback = function()
    vim.treesitter.start()
  end,
})
