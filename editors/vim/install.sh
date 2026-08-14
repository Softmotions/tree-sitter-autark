#!/bin/sh
set -eu

repo=${TREE_SITTER_AUTARK_REPO:-https://github.com/Softmotions/tree-sitter-autark.git}
branch=${TREE_SITTER_AUTARK_BRANCH:-main}
dest=${VIM_AUTARK_INSTALL_DIR:-${HOME}/.vim/pack/autark/start/tree-sitter-autark}

if ! command -v git >/dev/null 2>&1; then
  echo 'error: git is required' >&2
  exit 1
fi

if [ -d "$dest/.git" ]; then
  git -C "$dest" fetch --depth 1 origin "$branch"
  git -C "$dest" checkout -q "$branch" 2>/dev/null || git -C "$dest" checkout -q -B "$branch" "origin/$branch"
  git -C "$dest" reset --hard "origin/$branch"
elif [ -e "$dest" ]; then
  echo "error: $dest exists and is not a Git checkout" >&2
  exit 1
else
  mkdir -p "$(dirname "$dest")"
  git clone --depth 1 --branch "$branch" "$repo" "$dest"
fi

printf '%s\n' "Autark Vim support installed in: $dest"
printf '%s\n' 'Restart Vim, then open an Autark or *.autark file.'
