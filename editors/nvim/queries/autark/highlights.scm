; Tree-sitter highlights for Autark.
; Capture names are compatible with Neovim and tree-sitter-vscode.
;
; Built-in names are matched with #any-of? rather than #match? so Neovim does
; not reinterpret Autark punctuation through Vim's regexp engine.

(comment) @comment

(single_quoted_string) @string
(double_quoted_string) @string

["{" "}"] @punctuation.bracket

; A direct bare child of `check` is a check-script invocation without
; arguments. A rule child such as `test.sh { ARG }` is already classified as
; @function.call by the generic rule-name query below, so both forms get the
; same semantic role.
((rule
   name: (rule_name) @_parent
   body: (literal) @function.call)
 (#eq? @_parent "check"))

; Ordinary bare values. Values that have context-specific meaning are excluded
; and classified by the queries below.
((rule
   name: (rule_name) @_parent
   body: (literal) @string.special)
 (#not-eq? @_parent "check")
 (#not-eq? @string.special "always"))

; A literal named `always` outside run/run-on-install is an ordinary value.
((rule
   name: (rule_name) @_parent
   body: (literal) @string.special)
 (#eq? @string.special "always")
 (#not-any-of? @_parent "run" "run-on-install"))

; `always` is a bare value in a run block, not a rule name in the AST.
((rule
   name: (rule_name) @_parent
   body: (literal) @keyword.modifier)
 (#any-of? @_parent "run" "run-on-install")
 (#eq? @keyword.modifier "always"))

; Generic/custom rules. Only actually supported built-in spellings are
; excluded. Unsupported modifier combinations therefore remain generic rather
; than being highlighted as valid Autark built-ins.
((rule
   name: (rule_name) @function.call)
 (#not-any-of? @function.call
   "meta" "option" "check"
   "set" "!set" "..set" "..!set"
   "let" "!let" "..let" "..!let"
   "env"
   "if" "!if" "else"
   "error" "echo" "configure"
   "run" "run-on-install"
   "in-sources" "foreach"
   "cc" "cxx"
   "library" "install" "install-sources"
   "macro" "call" "include" "fetch-url"
   "defined" "!defined"
   "eq" "!eq"
   "prefix" "!prefix"
   "contains" "!contains"
   "or" "!or"
   "and" "!and"
   "name" "description" "version"
   "parent" "root" "objects" "consumes" "produces" "exec" "shell"
   "init" "setup" "build" "post-build" "post_build"
   "$" "!$" "..$"
   "@" "!@" "..@@"
   "@@" "!@@" "..@@"
   "^" "!^"
   "%" "!%"
   "S" "!S"
   "SS" "!SS"
   "C" "!C"
   "CC" "!CC"
   "&"))

; Primary Autark directives.
; Negation is supported only by set, let and if here; spread (`..`) only by
; set and let. `..!set` / `..!let` combine the two supported modifiers.
((rule
   name: (rule_name) @keyword)
 (#any-of? @keyword
   "meta" "option" "check"
   "set" "!set" "..set"
   "let" "!let" "..let"
   "env"
   "if" "!if" "else"
   "error" "echo" "configure"
   "run" "run-on-install"
   "in-sources" "foreach"
   "cc" "cxx"
   "library" "install" "install-sources"
   "macro" "call" "include" "fetch-url"))

; Built-in conditions. Conditions may be negated, but are not spread rules.
((rule
   name: (rule_name) @keyword.operator)
 (#any-of? @keyword.operator
   "defined" "!defined"
   "eq" "!eq"
   "prefix" "!prefix"
   "contains" "!contains"
   "or" "!or"
   "and" "!and"))

; Named fields/subsections of built-in blocks.
((rule
   name: (rule_name) @property)
 (#any-of? @property
   "name" "description" "version"
   "parent" "root"
   "objects" "consumes" "produces" "exec" "shell"))

; Build phases are language-defined block names.
((rule
   name: (rule_name) @keyword)
 (#any-of? @keyword
   "init" "setup" "build" "post-build" "post_build"))

; Substitution/evaluation/path helper rules.
; `!` is valid for $, @, @@, ^, %, S, SS, C and CC.
; `..` is valid only for `$` in this group. `&` has no modifier.
((rule
   name: (rule_name) @function.builtin)
 (#any-of? @function.builtin
   "$" "!$" "..$"
   "@" "!@" "..@"
   "@@" "!@@" "..@@"
   "^" "!^"
   "%" "!%"
   "S" "!S"
   "SS" "!SS"
   "C" "!C"
   "CC" "!CC"
   "&"))
