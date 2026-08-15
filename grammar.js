/**
 * @file Tree-sitter grammar for the Autark build-script DSL
 * @author Softmotions Ltd
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

// scriptx.leg accepts an unquoted literal as one or more characters except
// {, }, backslash, space, tab and EOL. A backslash may only escape
// {, }, backslash, n, r or t.
const BARE_ATOM = /([^{}\\ \t\r\n]|\\[{}\\nrt])+/;

module.exports = grammar({
  name: 'autark',

  // Whitespace is deliberately explicit. In the original PEG grammar,
  // values inside a rule body MUST be separated by at least one whitespace
  // character, while whitespace before/after braces is optional.
  extras: _ => [],

  // An atom followed by whitespace can be either a literal value or a rule
  // name whose opening brace appears after that whitespace. The original PEG
  // resolves this with ordered parsing; Tree-sitter keeps both paths until the
  // following token makes the choice unambiguous.
  conflicts: $ => [
    [$.rule_name, $.literal],
    [$.rule_name, $._aliased_name_atom],
  ],

  rules: {
    source_file: $ => seq(
      optional($._leading_spacing),
      repeat(seq(
        $.rule,
        optional($._spacing),
      )),
    ),

    // Autark preprocesses comments before feeding scriptx.leg: a line is a
    // comment only when '#' is the first non-whitespace character on it.
    // A special leading branch handles a comment on the first source line;
    // subsequent comments are attached to the line-break that precedes them.
    _leading_spacing: $ => choice(
      seq(
        $.comment,
        optional($._spacing),
      ),
      seq(
        $._line_break,
        optional($._spacing),
      ),
      seq(
        $._hspace,
        optional(choice(
          seq($.comment, optional($._spacing)),
          seq($._line_break, optional($._spacing)),
        )),
      ),
    ),

    _spacing: $ => repeat1($._space_unit),

    _space_unit: $ => choice(
      $._hspace,
      $._line_break,
    ),

    _line_break: $ => prec.right(seq(
      $._newline,
      optional($._hspace),
      optional($.comment),
    )),

    _hspace: _ => token(/[ \t]+/),
    _newline: _ => token(/\r\n|\n|\r/),

    comment: _ => token(prec(3, /#[^\r\n]*/)),

    // scriptx.leg:
    // RULE = STRP _ '{' _ (VALR (__ VALR)*)? _ '}'
    rule: $ => seq(
      field('name', $.rule_name),
      optional($._spacing),
      '{',
      optional($._spacing),
      optional($._rule_body),
      '}',
    ),

    // Right-recursive factoring is intentional: after a value, one whitespace
    // sequence is consumed first and only then do we decide whether another
    // value follows or the block ends. This preserves PEG's mandatory `__`
    // separator without introducing a trailing-whitespace ambiguity.
    _rule_body: $ => seq(
      field('body', $._value),
      optional(seq(
        $._spacing,
        optional($._rule_body),
      )),
    ),

    // scriptx.leg:
    // VALR = STRQ | STRQQ | RULE | STRP
    _value: $ => choice(
      $.single_quoted_string,
      $.double_quoted_string,
      $.rule,
      $.literal,
    ),

    // Both rule names and unquoted values are STRP in the PEG grammar. They
    // intentionally share one hidden lexical token so the parser can decide
    // from lookahead whether an atom is a plain literal or the start of a rule.
    _atom: _ => token(prec(1, BARE_ATOM)),

    // Selected directive names get a named alias when they occur in the
    // `rule_name` position. The same exact tokens are also accepted by
    // `literal`, so values such as `${CC cc}` remain plain literals.
    rule_name: $ => choice(
      alias($._name_meta, $.meta),
      alias($._name_include, $.include),
      alias($._name_option, $.option),
      alias($._name_cc, $.cc),
      alias($._name_cxx, $.cc),
      alias($._name_env, $.env),
      alias($._name_set, $.set),
      alias($._name_bang_set, $.set),
      alias($._name_spread_set, $.set),
      alias($._name_let, $.set),
      alias($._name_bang_let, $.set),
      alias($._name_spread_let, $.set),
      alias($._name_echo, $.echo),
      alias($._name_check, $.check),
      alias($._name_configure, $.configure),
      alias($._name_if, $.if),
      alias($._name_bang_if, $.if),
      alias($._name_else, $.else),
      alias($._name_and, $.condition_group),
      alias($._name_bang_and, $.condition_group),
      alias($._name_or, $.condition_group),
      alias($._name_bang_or, $.condition_group),
      alias($._name_run, $.run),
      alias($._name_run_on_install, $.run),
      alias($._name_in_sources, $.in_sources),
      alias($._name_foreach, $.foreach),
      alias($._name_library, $.library),
      alias($._name_install, $.install),
      alias($._name_install_sources, $.install),
      alias($._name_macro, $.macro),
      alias($._name_call, $.call),
      $._atom,
    ),

    literal: $ => choice(
      $._aliased_name_atom,
      $._atom,
    ),

    _aliased_name_atom: $ => choice(
      $._name_meta,
      $._name_include,
      $._name_option,
      $._name_cc,
      $._name_cxx,
      $._name_env,
      $._name_set,
      $._name_bang_set,
      $._name_spread_set,
      $._name_let,
      $._name_bang_let,
      $._name_spread_let,
      $._name_echo,
      $._name_check,
      $._name_configure,
      $._name_if,
      $._name_bang_if,
      $._name_and,
      $._name_bang_and,
      $._name_or,
      $._name_bang_or,
      $._name_else,
      $._name_run,
      $._name_run_on_install,
      $._name_in_sources,
      $._name_foreach,
      $._name_library,
      $._name_install,
      $._name_install_sources,
      $._name_macro,
      $._name_call,
    ),

    _name_meta: _ => token(prec(1, 'meta')),
    _name_include: _ => token(prec(1, 'include')),
    _name_option: _ => token(prec(1, 'option')),
    _name_cc: _ => token(prec(1, 'cc')),
    _name_cxx: _ => token(prec(1, 'cxx')),
    _name_env: _ => token(prec(1, 'env')),
    _name_set: _ => token(prec(1, 'set')),
    _name_bang_set: _ => token(prec(1, '!set')),
    _name_spread_set: _ => token(prec(1, '..set')),
    _name_let: _ => token(prec(1, 'let')),
    _name_bang_let: _ => token(prec(1, '!let')),
    _name_spread_let: _ => token(prec(1, '..let')),
    _name_echo: _ => token(prec(1, 'echo')),
    _name_check: _ => token(prec(1, 'check')),
    _name_configure: _ => token(prec(1, 'configure')),
    _name_if: _ => token(prec(1, 'if')),
    _name_bang_if: _ => token(prec(1, '!if')),
    _name_and: _ => token(prec(1, 'and')),
    _name_bang_and: _ => token(prec(1, '!and')),
    _name_or: _ => token(prec(1, 'or')),
    _name_bang_or: _ => token(prec(1, '!or')),
    _name_else: _ => token(prec(1, 'else')),
    _name_run: _ => token(prec(1, 'run')),
    _name_run_on_install: _ => token(prec(1, 'run-on-install')),
    _name_in_sources: _ => token(prec(1, 'in-sources')),
    _name_foreach: _ => token(prec(1, 'foreach')),
    _name_library: _ => token(prec(1, 'library')),
    _name_install: _ => token(prec(1, 'install')),
    _name_install_sources: _ => token(prec(1, 'install-sources')),
    _name_macro: _ => token(prec(1, 'macro')),
    _name_call: _ => token(prec(1, 'call')),

    // STRQ / STRQQ contain everything up to the matching quote; Autark does
    // not define C-style escapes inside quoted strings.
    single_quoted_string: _ => token(prec(2, /'[^']*'/)),
    double_quoted_string: _ => token(prec(2, /"[^"]*"/)),
  },
});
