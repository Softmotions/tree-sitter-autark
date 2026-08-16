# tree-sitter-autark

Tree-sitter grammar for the [Autark](https://autark.dev) build-script DSL.

The grammar follows Autark's PEG grammar in `scriptx.leg` and the comment
preprocessing performed by Autark itself. It recognizes:

Highlight queries distinguish primary directives, contextual built-in fields and
conditions, special forms, quoted strings and comments. Generic rule names and
ordinary bare values are intentionally left uncaptured.

## Build and test

Requirements:

- Tree-sitter CLI 0.26.x;
- Node.js on `PATH` for `tree-sitter generate` (or `--js-runtime native` with Tree-sitter 0.26+);
- a C/C++ compiler for parser builds and tests.

```sh
tree-sitter generate
tree-sitter test
tree-sitter highlight examples/Autark
```

Or:

```sh
make test
make highlight
```

### Verified toolchain

The checked-in generated parser was produced and validated with Tree-sitter CLI
`0.26.12` using ABI 15. The following checks pass:

```sh
tree-sitter generate --abi 15
tree-sitter test
tree-sitter build
tree-sitter parse examples/Autark
tree-sitter highlight examples/Autark
```

The corpus currently covers nested rules, quoted and bare literals, Autark
escapes, special forms, negation/spread prefixes, exact whole-line comment
semantics, adjacent top-level rules, and whitespace/comment edge cases.

### Build the WASM parser

VS Code integration below uses a WASM parser with ABI 15:

```sh
tree-sitter generate --abi 15
tree-sitter build --wasm
```

With recent Tree-sitter CLI versions, `build --wasm` downloads the required
WASI SDK automatically on first use.

The result is normally `tree-sitter-autark.wasm` in the project root.

## Highlighting model

The bundled Tree-sitter query is deliberately context-sensitive:

- primary directives such as `meta`, `set`, `let`, `cc`, `cxx`, `run`,
  `run-on-install`, `include` and `install-sources` use `@keyword`;
- `if`, `!if` and `else` use `@keyword.conditional`;
- built-in child fields use `@property` only in the contexts where they are
  meaningful: metadata fields under `meta`, build inputs/outputs under `cc` and
  `run`, phases under `echo`, and conditions under `if` / `and` / `or` groups;
- `always` inside `run` / `run-on-install` is also `@property`;
- positional names such as the first argument of `set`, `let`, `env`, `option`,
  `macro` and `foreach` use `@keyword.modifier`;
- check-script names and the first argument of `call` use `@function.call`;
- symbolic helpers such as `$`, `@`, `@@`, `^`, `%`, `S`, `SS`, `C`, `CC`
  and `&` use `@function.builtin`;
- quoted values use `@string`, comments use `@comment`, and braces use
  `@punctuation.bracket`.

Generic/custom rule names and ordinary bare values are intentionally left
uncaptured by the current query.

## Vim

Vim 8+ can use this repository directly as a native package. Vim itself does
not provide a built-in API for arbitrary Tree-sitter parsers, so the Vim
integration uses standard `ftdetect/`, `syntax/` and `ftplugin/` runtime files.
It mirrors the Tree-sitter highlighting policy closely without requiring
Neovim, `nvim-treesitter`, Node.js or the Tree-sitter CLI.

The Vim integration provides:

- filetype detection for `Autark` and `*.autark`;
- highlighting for primary directives and helper rules;
- highlighting for symbolic forms such as `${...}`, `@{...}`, `^{...}` and
  `S{...}`;
- quoted and bare literals;
- Autark's whole-line `#` comment semantics;
- brace delimiters and basic `commentstring`/`comments` settings.

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

`queries/highlights.scm` and `queries/folds.scm` are the single canonical query
files for all integrations. Current `nvim-treesitter` installs them into its
Neovim runtime layout automatically.

### Install Neovim with vim-plug

If you use vim-plug, install `tree-sitter-autark` as a normal Neovim plugin
alongside `nvim-treesitter`:

```vim
call plug#begin()

Plug 'nvim-treesitter/nvim-treesitter'
Plug 'Softmotions/tree-sitter-autark', { 'do': ':TSUpdate autark' }

call plug#end()
```

Then run:

```vim
:PlugInstall
```

Restart Neovim. No separate `:TSInstall autark` command is required: on the
first startup after installation, `plugin/tree-sitter-autark.lua` registers the
custom parser and automatically invokes:

```vim
:TSInstall autark
```

only when the Autark parser is not already installed. No extra Autark Lua
configuration and no manually specified checkout path are required. The runtime
plugin:

- registers `Autark` and `*.autark` as the `autark` filetype;
- registers the **existing vim-plug checkout** as the parser source, avoiding a
  second clone of `tree-sitter-autark`;
- uses the canonical `queries/*.scm` files directly, without a duplicated Neovim query tree;
- automatically runs `:TSInstall autark` on the first startup when the parser
  is missing;
- starts Neovim's Tree-sitter highlighter when the parser is available;
- keeps the native Vim syntax files as a fallback until parser installation
  completes.

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

#### nvim-treesitter `main` (Neovim 0.12+)

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

Useful checks:

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

`queries/highlights.scm` currently uses these captures:

| Syntax / context | Capture |
|---|---|
| primary directives (`meta`, `include`, `cc`/`cxx`, `env`, `set`/`let`, `echo`, `check`, `configure`, `run`/`run-on-install`, `in-sources`, `foreach`, `library`, `install`/`install-sources`, `macro`, `call`, `option`) | `@keyword` |
| `if`, `!if`, `else` | `@keyword.conditional` |
| `objects`, `consumes`, `produces` inside `cc` / `cxx` | `@property` |
| `exec`, `shell`, `consumes`, `produces`, and bare `always` inside `run` / `run-on-install` | `@property` |
| `init`, `setup`, `build` inside `echo` | `@property` |
| `name`, `version`, `version_major`, `version_minor`, `version_patch`, `description`, `website`, `author`, `vendor`, `maintainer`, `sources`, `license` inside `meta` | `@property` |
| `parent` / `root` blocks under `set` / `let` or `library` | `@property` |
| `defined`, `!defined`, `eq`, `!eq`, `prefix`, `!prefix`, `and`, `or` when used directly under `if` or inside an `and` / `or` condition group | `@property` |
| first direct literal of `set` / `let`, `env`, `option`, `macro`, `foreach`; first literal inside `parent` / `root` blocks | `@keyword.modifier` |
| direct check-script names and rule-form check scripts inside `check`; first literal of `call` | `@function.call` |
| symbolic helpers (`$`, `!$`, `..$`, `@`, `!@`, `..@`, `@@`, `!@@`, `..@@`, `^`, `!^`, `%`, `!%`, `S`, `!S`, `SS`, `!SS`, `C`, `!C`, `CC`, `!CC`, `&`) | `@function.builtin` |
| single- and double-quoted values | `@string` |
| whole-line comments | `@comment` |
| braces | `@punctuation.bracket` |

The current query deliberately has no generic fallback capture for arbitrary
rule names or ordinary bare literals. They remain unhighlighted unless one of
the contextual rules above applies.

## Notes on compatibility with Autark

The original parser is intentionally very small. The core syntax is:

```text
RULE  = STRP _ '{' _ (VALR (__ VALR)*)? _ '}'
VALR  = STRQ | STRQQ | RULE | STRP
```

This grammar therefore does not restrict the set of allowed rule names. Selected
built-ins receive named aliases so context-sensitive queries can recognize them,
while unknown/custom names still parse as normal `rule` nodes. The current
highlight query leaves those generic rule names uncaptured. This preserves
Autark's extensibility and nested bag-style blocks.

The Autark preprocessor removes only lines whose first non-whitespace character
is `#`. Consequently, this is a comment:

```text
  # comment
```

but `#x` in the middle of a rule body line remains an ordinary literal.

One pathological edge case is intentionally documented rather than hidden: Autark removes whole-line comments before PEG parsing without checking whether the line is inside a multi-line quoted string. The Tree-sitter grammar keeps quoted strings lexically intact, so a line beginning with `#` inside a multi-line quoted literal is represented as string content rather than preprocessed away. Normal single-line quoted literals are identical to Autark.

## License

MIT.
