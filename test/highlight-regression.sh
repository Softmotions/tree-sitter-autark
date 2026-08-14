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

# Both forms inside check are executable check-script names.
assert_capture function.call system.sh
assert_capture function.call test_blocks.sh
assert_not_capture string.special system.sh
assert_capture string.special IW_BLOCKS

# Supported directive modifiers.
for text in set '!set' '..set' '..!set' let '!let' '..let' '..!let' if '!if'; do
  assert_capture keyword "$text"
done

# Supported condition negation; spread is not supported.
assert_capture keyword.operator defined
assert_capture keyword.operator '!defined'
assert_not_capture keyword.operator '..defined'

# Supported helper modifiers.
for text in '$' '!$' '..$' '..!$' '@' '!@' C '!C'; do
  assert_capture function.builtin "$text"
done

# Unsupported modifier combinations remain generic/custom rule names.
for text in '!meta' '..meta' '..if' '..defined' '..@' '..!@' '..C' '!&'; do
  assert_capture function.call "$text"
  assert_not_capture keyword "$text"
  assert_not_capture keyword.operator "$text"
  assert_not_capture function.builtin "$text"
done

echo 'Highlight regression tests: OK'
