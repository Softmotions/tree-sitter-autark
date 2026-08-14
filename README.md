# Tree-sitter based syntax highlighting for Autark scripts

Tree-sitter grammar for the [Autark](https://autark.dev) build-script DSL.

## Vim 8+

Vim 8+ can use this repository directly as a native package. Vim itself does
not provide a built-in API for arbitrary Tree-sitter parsers, so the Vim
integration uses standard `ftdetect/`, `syntax/` and `ftplugin/` runtime files.
It mirrors the Tree-sitter highlighting policy closely without requiring
Neovim, `nvim-treesitter`, Node.js or the Tree-sitter CLI.

### Install with Vim's native package support

Clone the repository directly into a Vim `pack/*/start/*` directory:

```sh
git clone --depth 1 \
  https://github.com/Softmotions/tree-sitter-autark.git \
  ~/.vim/pack/autark/start/tree-sitter-autark
```

Restart Vim. No additional configuration is required.

To update later:

```sh
git -C ~/.vim/pack/autark/start/tree-sitter-autark pull --ff-only
```

### Install with the provided script

The installer clones or updates the same GitHub repository under Vim's native
package directory:

```sh
curl -fsSL \
  https://raw.githubusercontent.com/Softmotions/tree-sitter-autark/main/editors/vim/install.sh \
  | sh
```

By default it installs into:

```text
~/.vim/pack/autark/start/tree-sitter-autark
```

The destination can be overridden with `VIM_AUTARK_INSTALL_DIR`; the repository
and branch can be overridden with `TREE_SITTER_AUTARK_REPO` and
`TREE_SITTER_AUTARK_BRANCH`.

### Install with vim-plug

The repository is a regular Vim runtime plugin, so the same vim-plug entry
works in both Vim and Neovim:

```vim
call plug#begin()
Plug 'Softmotions/tree-sitter-autark'
call plug#end()
```

Then run:

```vim
:PlugInstall
```

In plain Vim this enables the native `ftdetect/`, `syntax/` and `ftplugin/`
integration. No Tree-sitter runtime is required.

In Neovim, if `nvim-treesitter` is also installed, the repository additionally
registers its own vim-plug checkout as the `autark` parser source. See the
[vim-plug section under Neovim](#install-neovim-with-vim-plug) below.

Useful checks:

```vim
:set filetype?
:syntax list autarkKeywordRule
:syntax list autarkLiteral
```

## Neovim

### Install Neovim with vim-plug

If you use vim-plug, install `tree-sitter-autark` as a normal Neovim plugin
alongside `nvim-treesitter`:

```vim
call plug#begin()

" Use the nvim-treesitter branch appropriate for your Neovim version.
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'Softmotions/tree-sitter-autark'

call plug#end()
```

Then run:

```vim
:PlugInstall
```

Restart Neovim. No separate `:TSInstall autark` command is required: on the
first startup after installation, `plugin/tree-sitter-autark.lua` registers the
custom parser.

Automatic parser installation can be disabled before `plug#end()` if you want
to manage parsers manually:

```vim
let g:tree_sitter_autark_auto_install = 0
```

Then install it explicitly with `:TSInstall autark`.

After `:PlugUpdate`, update/rebuild the installed parser with:

```vim
:TSUpdate autark
```

Useful checks:

```vim
:set filetype?
:InspectTree
:checkhealth nvim-treesitter
```

### Install Neovim without vim-plug

The parser source can also be installed directly from:

```text
https://github.com/Softmotions/tree-sitter-autark
```

A separate local checkout of the grammar is not required.

#### Current nvim-treesitter `main` (Neovim 0.12+)

Install the provided configuration into your Neovim config, for example:

```sh
mkdir -p ~/.config/nvim/plugin
curl -fLo ~/.config/nvim/plugin/tree-sitter-autark.lua \
  https://raw.githubusercontent.com/Softmotions/tree-sitter-autark/main/editors/nvim/autark-main.lua
```

Then restart Neovim and install the parser:

```vim
:TSInstall autark
```

The configuration registers `Softmotions/tree-sitter-autark` as a custom
`nvim-treesitter` parser source:

```lua
require('nvim-treesitter.parsers').autark = {
  install_info = {
    url = 'https://github.com/Softmotions/tree-sitter-autark',
    branch = 'main',
    queries = 'queries',
  },
}
```

`src/parser.c` is checked into this repository, so installation does not need to
regenerate the parser from `grammar.js`. `nvim-treesitter` clones the repository,
compiles the parser and installs the query files from `queries/`.

The configuration also detects:

```text
Autark      -> filetype: autark
*.autark    -> filetype: autark
```

and starts Tree-sitter highlighting automatically for the `autark` filetype.

To update the installed parser and queries later:

```vim
:TSUpdate autark
```

#### Frozen nvim-treesitter `master` (Neovim 0.10-0.11)

Use the legacy configuration instead:

```sh
mkdir -p ~/.config/nvim/plugin
curl -fLo ~/.config/nvim/plugin/tree-sitter-autark.lua \
  https://raw.githubusercontent.com/Softmotions/tree-sitter-autark/main/editors/nvim/autark-master.lua
```

Then restart Neovim and run:

```vim
:TSInstall autark
```

For this legacy path, keep `tree-sitter` CLI and Node.js available. The parser
is regenerated from `grammar.js` with the ABI supported by that Neovim version,
which avoids trying to load the repository's checked-in ABI 15 `src/parser.c`
on older Neovim releases. The source still comes directly from the GitHub
repository:

```lua
install_info = {
  url = 'https://github.com/Softmotions/tree-sitter-autark',
  branch = 'main',
  files = { 'src/parser.c' },
  generate_requires_npm = false,
  requires_generate_from_grammar = true,
}
```

The frozen `nvim-treesitter` branch does not copy custom queries from grammar
repositories. `autark-master.lua` therefore automatically maintains a shallow
checkout of this same repository under:

```text
stdpath('data')/tree-sitter-autark-runtime
```

and adds its `editors/nvim` directory to `runtimepath` so `queries/autark/*.scm` can be found.
To update that query checkout explicitly:

```vim
:AutarkTSUpdateQueries
```

Useful checks for either Neovim setup:

```vim
:set filetype?
:InspectTree
:checkhealth nvim-treesitter
```

## VS Code

VS Code does not expose arbitrary Tree-sitter grammars through the normal
`contributes.grammars` extension point; that extension point is for TextMate
grammars. The integration in this repository uses
`AlecGhost.tree-sitter-vscode`, which loads a Tree-sitter WASM parser and maps
Tree-sitter query captures to VS Code semantic tokens.

The provided installer is self-contained: it clones or updates
`Softmotions/tree-sitter-autark` from GitHub, builds `tree-sitter-autark.wasm`,
installs the small Autark language-registration extension, copies the queries,
and configures `tree-sitter-vscode` automatically. No manually maintained local
grammar checkout or `tree-sitter-vscode.languageConfigs` entry is required.

### Requirements

- `git`;
- Tree-sitter CLI 0.26.x;
- VS Code 1.110+;
- network access for cloning the grammar and, on the first WASM build, for the
  WASI SDK if it is not already installed/cached.

### Install

Run directly from the repository:

```sh
curl -fsSL \
  https://raw.githubusercontent.com/Softmotions/tree-sitter-autark/main/editors/vscode/install-language-extension.sh \
  | sh
```

Or, from an existing checkout:

```sh
./editors/vscode/install-language-extension.sh
```

By default the installer keeps its managed source checkout under:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/tree-sitter-autark-vscode/repo
```

and installs the VS Code language extension under:

```text
$HOME/.vscode/extensions/softmotions.autark-language-<version>
```

The source checkout is managed by the installer and always originates from:

```text
https://github.com/Softmotions/tree-sitter-autark.git
```

If the `code` command is available, the installer also installs or updates:

```text
AlecGhost.tree-sitter-vscode
```

Otherwise install that extension manually from VS Code.

Restart VS Code after installation. The Autark extension registers:

```text
Autark      -> language id: autark
*.autark    -> language id: autark
```

On activation it automatically adds an `autark` entry to
`tree-sitter-vscode.languageConfigs`, using the WASM parser and queries copied
into the installed extension directory, and asks `tree-sitter-vscode` to reload.

To update the grammar later, simply run the same installer again. It fetches the
latest `main` branch and rebuilds the WASM parser.

### Installer overrides

The installer supports these environment variables:

```text
TREE_SITTER_AUTARK_REPO       Git repository URL
TREE_SITTER_AUTARK_BRANCH     Git branch, default: main
TREE_SITTER_AUTARK_DATA_DIR   Managed checkout/build directory
VSCODE_EXTENSIONS_DIR         VS Code extensions directory
```

For example, for Code - OSS or VSCodium:

```sh
VSCODE_EXTENSIONS_DIR="$HOME/.vscode-oss/extensions" \
  ./editors/vscode/install-language-extension.sh
```

`editors/vscode/settings.example.json` remains only as a manual fallback and is
not needed when the installer is used.

## Highlighting policy

`queries/highlights.scm` uses these categories:

| Syntax | Capture |
|---|---|
| primary directives (`set`, `if`, `run`, `cc`, ...) | `@keyword` |
| conditions / structural child blocks | `@keyword` |
| special forms (`$`, `@`, `@@`, `^`, `%`, `S`, ...) | `@function.builtin` |
| other rule names | `@function.call` |
| quoted literals | `@string` |
| bare literals | `@string.special` |
| whole-line comments | `@comment` |
| braces | `@punctuation.bracket` |

## Notes on compatibility with Autark

The original parser is intentionally very small. The core syntax is:

```text
RULE  = STRP _ '{' _ (VALR (__ VALR)*)? _ '}'
VALR  = STRQ | STRQQ | RULE | STRP
```

This grammar therefore does not hard-code the full set of allowed rule names.
Unknown/custom rule names still parse as normal `rule` nodes and are highlighted
as generic function-like calls. Built-in names are a highlighting concern, not
a syntactic restriction. This is important for Autark's extensibility and for
nested bag-style blocks.

The Autark preprocessor removes only lines whose first non-whitespace character
is `#`. Consequently, this is a comment:

```text
  # comment
```

but `#x` in the middle of a rule body line remains an ordinary literal.

One pathological edge case is intentionally documented rather than hidden: Autark removes whole-line comments before PEG parsing without checking whether the line is inside a multi-line quoted string. The Tree-sitter grammar keeps quoted strings lexically intact, so a line beginning with `#` inside a multi-line quoted literal is represented as string content rather than preprocessed away. Normal single-line quoted literals are identical to Autark.

## License

MIT.

