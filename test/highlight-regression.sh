#!/bin/sh
set -eu

TREE_SITTER=${TREE_SITTER:-tree-sitter}
QUERY_OUT=$(mktemp)
HTML_OUT=$(mktemp)
ERR=$(mktemp)
trap 'rm -f "$QUERY_OUT" "$HTML_OUT" "$ERR"' EXIT HUP INT TERM

"$TREE_SITTER" query -c queries/highlights.scm test/highlight-regression.autark >"$QUERY_OUT" 2>"$ERR"
"$TREE_SITTER" highlight -H --css-classes test/highlight-regression.autark >"$HTML_OUT" 2>>"$ERR"

assert_capture() {
  capture=$1
  text=$2
  if ! grep -F " - $capture," "$QUERY_OUT" | grep -F 'text: `'"$text"'`' >/dev/null; then
    echo "Missing capture @$capture for '$text'" >&2
    cat "$QUERY_OUT" >&2
    exit 1
  fi
}

assert_not_capture() {
  capture=$1
  text=$2
  if grep -F " - $capture," "$QUERY_OUT" | grep -F 'text: `'"$text"'`' >/dev/null; then
    echo "Unexpected capture @$capture for '$text'" >&2
    cat "$QUERY_OUT" >&2
    exit 1
  fi
}

assert_html_class() {
  class=$1
  text=$2
  if ! grep -F "class='$class'>$text</span>" "$HTML_OUT" >/dev/null; then
    echo "Missing rendered highlight class '$class' for '$text'" >&2
    exit 1
  fi
}

# Primary aliases, including shared aliases such as cxx -> cc,
# run-on-install -> run and install-sources -> install.
for text in meta cc cxx run run-on-install echo check set let env option macro foreach library call include install-sources; do
  assert_capture keyword "$text"
done

for text in if '!if' else; do
  assert_capture keyword.conditional "$text"
done

# Contextual fields. Multiple properties in the same parent must all survive
# the actual highlighter, not merely appear in raw query matches.
for text in objects consumes produces exec shell always; do
  assert_capture property "$text"
  assert_html_class property "$text"
done

for text in name vendor init setup build parent root; do
  assert_capture property "$text"
done
assert_not_capture property post-build

# Conditions under if and under nested and/or groups.
for text in and '!eq' defined or prefix eq; do
  assert_capture property "$text"
  assert_html_class property "$text"
done

# Positional arguments and executable names.
for text in SET_PARENT LET_NAME ENV_NAME OPT_NAME MACRO_NAME ITEM LIB_ROOT; do
  assert_capture keyword.modifier "$text"
done
assert_capture function.call system.sh
assert_capture function.call test_blocks.sh
assert_capture function.call MACRO_NAME

# Symbolic helpers use @function.builtin according to the current query.
for text in '$' '!@' '..@' '..@@' '!C' '&'; do
  assert_capture function.builtin "$text"
done

# The current query intentionally leaves generic rule names and ordinary bare
# values uncaptured.
assert_not_capture function.call custom-rule
assert_not_capture string.special bare-value

assert_capture comment '# Highlight regression fixture for the current query model.'
assert_capture string '"Enable option"'
assert_capture punctuation.bracket '{'

echo 'Highlight regression tests: OK'
