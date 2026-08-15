-- Frozen nvim-treesitter `master` branch / Neovim 0.10-0.11.
-- The parser is installed directly from GitHub.
--
-- Unlike current nvim-treesitter `main`, the frozen branch does not install
-- custom query files from grammar repositories. This script therefore keeps a
-- shallow Git checkout under stdpath('data') and loads the repository's canonical
-- queries/*.scm files directly through Neovim's Tree-sitter query API.
local repo = 'https://github.com/Softmotions/tree-sitter-autark'
local query_checkout = vim.fn.stdpath('data') .. '/tree-sitter-autark-runtime'

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

  local parser_config = parsers.get_parser_configs()
  parser_config.autark = {
    install_info = {
      url = repo,
      branch = 'main',
      files = { 'src/parser.c' },
      generate_requires_npm = false,
      requires_generate_from_grammar = true,
    },
    filetype = 'autark',
  }
end

local function read_file(path)
  local file = io.open(path, 'rb')
  if not file then
    return nil
  end
  local text = file:read('*a')
  file:close()
  return text
end

local function load_queries()
  local ok_parser = pcall(vim.treesitter.get_string_parser, '', 'autark')
  if not ok_parser then
    return false
  end

  for _, name in ipairs({ 'highlights', 'folds' }) do
    local text = read_file(query_checkout .. '/queries/' .. name .. '.scm')
    if not text then
      return false
    end
    local ok, err = pcall(vim.treesitter.query.set, 'autark', name, text)
    if not ok then
      vim.schedule(function()
        vim.notify(
          'tree-sitter-autark: failed to load ' .. name .. ' query: ' .. tostring(err),
          vim.log.levels.ERROR
        )
      end)
      return false
    end
  end

  return true
end

local function ensure_query_checkout(update)
  if vim.fn.executable('git') ~= 1 then
    vim.schedule(function()
      vim.notify('tree-sitter-autark: git is required to install query files', vim.log.levels.ERROR)
    end)
    return false
  end

  if vim.fn.isdirectory(query_checkout .. '/.git') == 0 then
    vim.fn.mkdir(vim.fn.fnamemodify(query_checkout, ':h'), 'p')
    vim.fn.system({
      'git', 'clone', '--depth', '1', '--branch', 'main', repo, query_checkout,
    })
  elseif update then
    vim.fn.system({ 'git', '-C', query_checkout, 'fetch', '--depth', '1', 'origin', 'main' })
    if vim.v.shell_error == 0 then
      vim.fn.system({ 'git', '-C', query_checkout, 'reset', '--hard', 'FETCH_HEAD' })
    end
  end

  if vim.v.shell_error ~= 0 then
    vim.schedule(function()
      vim.notify('tree-sitter-autark: failed to clone/update query files from GitHub', vim.log.levels.ERROR)
    end)
    return false
  end

  load_queries()
  return true
end

register_parser()
ensure_query_checkout(false)

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    register_parser()
    load_queries()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'autark',
  callback = function()
    load_queries()
  end,
})

vim.api.nvim_create_user_command('AutarkTSUpdateQueries', function()
  if ensure_query_checkout(true) then
    vim.notify('tree-sitter-autark: query files updated')
  end
end, {})

vim.treesitter.language.register('autark', 'autark')
