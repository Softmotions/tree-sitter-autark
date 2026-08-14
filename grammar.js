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

    rule_name: $ => $._atom,
    literal: $ => $._atom,

    // STRQ / STRQQ contain everything up to the matching quote; Autark does
    // not define C-style escapes inside quoted strings.
    single_quoted_string: _ => token(prec(2, /'[^']*'/)),
    double_quoted_string: _ => token(prec(2, /"[^"]*"/)),
  },
});
