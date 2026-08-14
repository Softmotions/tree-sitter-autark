#!/bin/sh
set -eu

repo_url=${TREE_SITTER_AUTARK_REPO:-https://github.com/Softmotions/tree-sitter-autark.git}
repo_branch=${TREE_SITTER_AUTARK_BRANCH:-main}
data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
work_root=${TREE_SITTER_AUTARK_DATA_DIR:-"$data_home/tree-sitter-autark-vscode"}
repo_dir="$work_root/repo"
extensions_dir=${VSCODE_EXTENSIONS_DIR:-"$HOME/.vscode/extensions"}

command -v git >/dev/null 2>&1 || {
  echo "error: git is required" >&2
  exit 1
}
command -v tree-sitter >/dev/null 2>&1 || {
  echo "error: tree-sitter CLI is required to build the WASM parser" >&2
  exit 1
}

mkdir -p "$work_root"

if [ -d "$repo_dir/.git" ]; then
  echo "Updating tree-sitter-autark from $repo_url ..."
  git -C "$repo_dir" fetch --depth 1 origin "$repo_branch"
  git -C "$repo_dir" checkout -B "$repo_branch" FETCH_HEAD
else
  echo "Cloning tree-sitter-autark from $repo_url ..."
  rm -rf "$repo_dir"
  git clone --depth 1 --branch "$repo_branch" "$repo_url" "$repo_dir"
fi

wasm="$work_root/tree-sitter-autark.wasm"
echo "Building Tree-sitter WASM parser ..."
tree-sitter build --wasm --output "$wasm" "$repo_dir"

pkg="$repo_dir/editors/vscode/package.json"
version=$(sed -n 's/^[[:space:]]*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$pkg" | head -n 1)
[ -n "$version" ] || {
  echo "error: cannot read VS Code extension version from $pkg" >&2
  exit 1
}

extension_dir="$extensions_dir/softmotions.autark-language-$version"
rm -rf "$extension_dir"
mkdir -p "$extension_dir/queries"

cp "$repo_dir/editors/vscode/package.json" "$extension_dir/"
cp "$repo_dir/editors/vscode/language-configuration.json" "$extension_dir/"
cp "$repo_dir/editors/vscode/extension.js" "$extension_dir/"
cp "$repo_dir/queries/highlights.scm" "$extension_dir/queries/"
cp "$repo_dir/queries/folds.scm" "$extension_dir/queries/"
cp "$wasm" "$extension_dir/tree-sitter-autark.wasm"

if command -v code >/dev/null 2>&1; then
  echo "Installing/updating AlecGhost.tree-sitter-vscode ..."
  code --install-extension AlecGhost.tree-sitter-vscode --force >/dev/null
else
  echo "warning: 'code' CLI not found; install AlecGhost.tree-sitter-vscode manually" >&2
fi

echo "Installed Autark VS Code integration to: $extension_dir"
echo "Parser source: $repo_url ($repo_branch)"
echo "Restart VS Code. No manual tree-sitter-vscode languageConfigs entry is required."
