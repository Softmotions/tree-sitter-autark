-- Neovim integration for tree-sitter-autark when this repository itself is
-- installed as a runtime plugin (vim-plug, native packages, lazy.nvim, etc.).
--
-- Plain Vim ignores *.lua files in plugin/, so the standard Vim
-- ftdetect/syntax/ftplugin integration remains independent of Neovim.

if vim.g.loaded_tree_sitter_autark == 1 then
  return
end
vim.g.loaded_tree_sitter_autark = 1

local script = debug.getinfo(1, 'S').source
if script:sub(1, 1) == '@' then
  script = script:sub(2)
end

local root = vim.fn.fnamemodify(script, ':p:h:h')
local nvim_runtime = root .. '/editors/nvim'

-- The canonical Tree-sitter queries are kept in queries/*.scm for the CLI and
-- current nvim-treesitter. The editors/nvim runtime directory contains the
-- queries/autark/*.scm layout expected by Neovim's runtime query lookup.
local rtp = vim.opt.runtimepath:get()
if not vim.tbl_contains(rtp, nvim_runtime) then
  vim.opt.runtimepath:append(nvim_runtime)
end

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
    return false
  end

  -- Frozen nvim-treesitter `master` (Neovim 0.10-0.11).
  if type(parsers.get_parser_configs) == 'function' then
    local parser_config = parsers.get_parser_configs()
    parser_config.autark = {
      install_info = {
        -- The legacy installer explicitly supports a local directory in `url`.
        -- Regenerate from grammar.js so Neovim 0.10/0.11 gets its own ABI
        -- instead of compiling the checked-in ABI 15 parser.c.
        url = root,
        files = { 'src/parser.c' },
        generate_requires_npm = false,
        requires_generate_from_grammar = true,
      },
      filetype = 'autark',
    }
  else
    -- Current nvim-treesitter `main` (Neovim 0.12+).
    parsers.autark = {
      install_info = {
        -- Use the checkout already installed by the plugin manager. This avoids
        -- downloading a second copy of tree-sitter-autark during :TSInstall.
        path = root,
        queries = 'queries',
      },
    }
  end

  return true
end

register_parser()

-- nvim-treesitter reloads its parser table before install/update operations on
-- current `main`, so register the custom parser again at that point.
vim.api.nvim_create_autocmd('User', {
  pattern = 'TSUpdate',
  callback = register_parser,
})

-- Test parser availability by asking Neovim to instantiate a parser. This is
-- more robust than checking a platform-specific shared-library suffix.
local function parser_available()
  return pcall(vim.treesitter.get_string_parser, '', 'autark')
end

local function install_parser_if_missing()
  -- Set this to 0 before plugin loading to keep parser installation manual.
  if vim.g.tree_sitter_autark_auto_install == 0 then
    return
  end

  -- nvim-treesitter may appear after this plugin in runtimepath. Re-register
  -- here so :TSInstall sees the custom parser on the first Neovim startup
  -- after :PlugInstall.
  if not register_parser() or parser_available() then
    return
  end

  if vim.fn.exists(':TSInstall') ~= 2 then
    return
  end

  -- Run after VimEnter has completed. Current nvim-treesitter installs
  -- asynchronously; the legacy branch accepts the same command.
  vim.schedule(function()
    -- Recheck in case another startup hook installed the parser first.
    if not parser_available() then
      vim.cmd('TSInstall autark')
    end
  end)
end

-- Retry registration after startup in case nvim-treesitter appears later in
-- runtimepath, and automatically install the parser on first use of this plugin.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    register_parser()
    install_parser_if_missing()
  end,
})

vim.treesitter.language.register('autark', 'autark')

-- Current nvim-treesitter no longer owns the highlighting module. Start the
-- built-in Neovim Tree-sitter highlighter when a parser is available. If the
-- parser has not been installed yet, pcall keeps the native Vim syntax fallback
-- working normally.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'autark',
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf, 'autark')
    if ok then
      -- Do not run Vim regex syntax and Tree-sitter highlighting together.
      vim.bo[args.buf].syntax = ''
    end
  end,
})
