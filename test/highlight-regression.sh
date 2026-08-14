#!/bin/sh
set -eu

TREE_SITTER=${TREE_SITTER:-tree-sitter}
OUT=$(mktemp)
ERR=$(mktemp)
trap 'rm -f "$OUT" "$ERR"' EXIT HUP INT TERM

"$TREE_SITTER" query -c queries/highlights.scm test/highlight-regression.autark >"$OUT" 2>"$ERR"

assert_capture() {
  capture=$1
  text=$2
  if ! grep -F " - $capture," "$OUT" | grep -F 'text: `'"$text"'`' >/dev/null; then
    echo "Missing capture @$capture for '$text'" >&2
    cat "$OUT" >&2
    exit 1
  fi
}

assert_not_capture() {
  capture=$1
  text=$2
  if grep -F " - $capture," "$OUT" | grep -F 'text: `'"$text"'`' >/dev/null; then
    echo "Unexpected capture @$capture for '$text'" >&2
    cat "$OUT" >&2
    exit 1
  fi
}

# Long set value list: the variable name is special, every later bare value is not.
assert_capture keyword.modifier CFLAGS
for text in \
  '-std=gnu11' '-fsigned-char' '-Wall' '-Wextra' '-Wfatal-errors' \
  '-Wno-implicit-fallthrough' '-Wno-missing-braces' \
  '-Wno-missing-field-initializers' '-Wno-sign-compare' \
  '-Wno-unknown-pragmas' '-Wno-unused-function' '-Wno-unused-parameter' \
  '-Wno-overlength-strings' '-fPIC'; do
  assert_capture string.special "$text"
done

# Both forms inside check are executable check-script names.
assert_capture function.call system.sh
assert_capture function.call test_blocks.sh
assert_not_capture string.special system.sh
assert_capture string.special IW_BLOCKS

# Representative built-ins from the user-priority query baseline.
for text in set '!set' '..set' let '!let' '..let' if '!if'; do
  assert_capture keyword "$text"
done

assert_capture keyword.operator defined
assert_capture keyword.operator '!defined'

for text in '$' '!$' '..$' '@' '!@' C '!C'; do
  assert_capture function.builtin "$text"
done

echo 'Highlight regression tests: OK'
