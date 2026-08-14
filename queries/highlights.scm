; Tree-sitter highlights for Autark.
; Capture names are compatible with Neovim and tree-sitter-vscode.
;
; Built-in names are matched with #any-of? rather than #match? so Neovim does
; not have to reinterpret Autark punctuation through Vim's regexp engine.

(comment) @comment

(single_quoted_string) @string
(double_quoted_string) @string
((literal) @string.special
 (#not-eq? @string.special "always"))

["{" "}"] @punctuation.bracket

; Generic/custom rules. Known language constructs are excluded so every rule
; name receives one semantic role instead of overlapping captures.
((rule
   name: (rule_name) @function.call)
 (#not-any-of? @function.call
   "meta" "!meta" "..meta" "..!meta"
   "option" "!option" "..option" "..!option"
   "check" "!check" "..check" "..!check"
   "set" "!set" "..set" "..!set"
   "let" "!let" "..let" "..!let"
   "env" "!env" "..env" "..!env"
   "if" "!if" "..if" "..!if"
   "else" "!else" "..else" "..!else"
   "error" "!error" "..error" "..!error"
   "echo" "!echo" "..echo" "..!echo"
   "configure" "!configure" "..configure" "..!configure"
   "run" "!run" "..run" "..!run"
   "run-on-install" "!run-on-install" "..run-on-install" "..!run-on-install"
   "in-sources" "!in-sources" "..in-sources" "..!in-sources"
   "foreach" "!foreach" "..foreach" "..!foreach"
   "cc" "!cc" "..cc" "..!cc"
   "cxx" "!cxx" "..cxx" "..!cxx"
   "library" "!library" "..library" "..!library"
   "install" "!install" "..install" "..!install"
   "install-sources" "!install-sources" "..install-sources" "..!install-sources"
   "macro" "!macro" "..macro" "..!macro"
   "call" "!call" "..call" "..!call"
   "include" "!include" "..include" "..!include"
   "fetch-url" "!fetch-url" "..fetch-url" "..!fetch-url"
   "defined" "!defined" "..defined" "..!defined"
   "eq" "!eq" "..eq" "..!eq"
   "prefix" "!prefix" "..prefix" "..!prefix"
   "contains" "!contains" "..contains" "..!contains"
   "or" "!or" "..or" "..!or"
   "and" "!and" "..and" "..!and"
   "name" "description" "version"
   "parent" "root" "objects" "consumes" "produces" "exec" "shell"
   "init" "setup" "build" "post-build" "post_build"
   "always"
   "$" "!$" "..$" "..!$"
   "@" "!@" "..@" "..!@"
   "@@" "!@@" "..@@" "..!@@"
   "^" "!^" "..^" "..!^"
   "%" "!%" "..%" "..!%"
   "S" "!S" "..S" "..!S"
   "SS" "!SS" "..SS" "..!SS"
   "C" "!C" "..C" "..!C"
   "CC" "!CC" "..CC" "..!CC"
   "&" "!&" "..&" "..!&"))

; Primary Autark directives.
((rule
   name: (rule_name) @keyword)
 (#any-of? @keyword
   "meta" "!meta" "..meta" "..!meta"
   "option" "!option" "..option" "..!option"
   "check" "!check" "..check" "..!check"
   "set" "!set" "..set" "..!set"
   "let" "!let" "..let" "..!let"
   "env" "!env" "..env" "..!env"
   "if" "!if" "..if" "..!if"
   "else" "!else" "..else" "..!else"
   "error" "!error" "..error" "..!error"
   "echo" "!echo" "..echo" "..!echo"
   "configure" "!configure" "..configure" "..!configure"
   "run" "!run" "..run" "..!run"
   "run-on-install" "!run-on-install" "..run-on-install" "..!run-on-install"
   "in-sources" "!in-sources" "..in-sources" "..!in-sources"
   "foreach" "!foreach" "..foreach" "..!foreach"
   "cc" "!cc" "..cc" "..!cc"
   "cxx" "!cxx" "..cxx" "..!cxx"
   "library" "!library" "..library" "..!library"
   "install" "!install" "..install" "..!install"
   "install-sources" "!install-sources" "..install-sources" "..!install-sources"
   "macro" "!macro" "..macro" "..!macro"
   "call" "!call" "..call" "..!call"
   "include" "!include" "..include" "..!include"
   "fetch-url" "!fetch-url" "..fetch-url" "..!fetch-url"))

; Built-in condition/predicate rules behave like operators/functions rather
; than named fields of a record-like block.
((rule
   name: (rule_name) @keyword.operator)
 (#any-of? @keyword.operator
   "defined" "!defined" "..defined" "..!defined"
   "eq" "!eq" "..eq" "..!eq"
   "prefix" "!prefix" "..prefix" "..!prefix"
   "contains" "!contains" "..contains" "..!contains"
   "or" "!or" "..or" "..!or"
   "and" "!and" "..and" "..!and"))

; Named fields/subsections of built-in blocks.
; Include-tree selectors and phase blocks are language-defined names rather
; than user-defined calls.
((rule
   name: (rule_name) @property)
 (#any-of? @property
   "name" "description" "version"
   "parent" "root"
   "objects" "consumes" "produces" "exec" "shell"))

((rule
   name: (rule_name) @keyword)
 (#any-of? @keyword
   "init" "setup" "build" "post-build" "post_build"))

; A literal named `always` outside run/run-on-install is an ordinary value.
((rule
   name: (rule_name) @_parent
   body: (literal) @string.special)
 (#eq? @string.special "always")
 (#not-any-of? @_parent
   "run" "!run" "..run" "..!run"
   "run-on-install" "!run-on-install" "..run-on-install" "..!run-on-install"))

; `always` is a bare value in a run block, not a rule name in the AST.
((rule
   name: (rule_name) @_parent
   body: (literal) @keyword.modifier)
 (#any-of? @_parent
   "run" "!run" "..run" "..!run"
   "run-on-install" "!run-on-install" "..run-on-install" "..!run-on-install")
 (#eq? @keyword.modifier "always"))

; Substitution/evaluation/path helper rules.
((rule
   name: (rule_name) @function.builtin)
 (#any-of? @function.builtin
   "$" "!$" "..$" "..!$"
   "@" "!@" "..@" "..!@"
   "@@" "!@@" "..@@" "..!@@"
   "^" "!^" "..^" "..!^"
   "%" "!%" "..%" "..!%"
   "S" "!S" "..S" "..!S"
   "SS" "!SS" "..SS" "..!SS"
   "C" "!C" "..C" "..!C"
   "CC" "!CC" "..CC" "..!CC"
   "&" "!&" "..&" "..!&"))
