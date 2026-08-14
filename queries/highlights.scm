; Tree-sitter highlights for Autark.
; Capture names are chosen so they work in Neovim and with tree-sitter-vscode.
;
; Do not use #match? for built-in rule-name lists here. Neovim implements
; #match? with a very-magic Vim regex, where characters used by Autark rule
; names (notably '@') have regexp meaning. #any-of? is both exact and faster
; for keyword lists, and avoids editor-specific regexp escaping.

(comment) @comment

(single_quoted_string) @string
(double_quoted_string) @string
(literal) @string.special

["{" "}"] @punctuation.bracket

; Generic/custom rules. Built-ins are excluded to avoid overlapping captures.
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
   "parent" "!parent" "..parent" "..!parent"
   "root" "!root" "..root" "..!root"
   "objects" "!objects" "..objects" "..!objects"
   "consumes" "!consumes" "..consumes" "..!consumes"
   "produces" "!produces" "..produces" "..!produces"
   "exec" "!exec" "..exec" "..!exec"
   "shell" "!shell" "..shell" "..!shell"
   "always" "!always" "..always" "..!always"
   "init" "!init" "..init" "..!init"
   "setup" "!setup" "..setup" "..!setup"
   "build" "!build" "..build" "..!build"
   "post-build" "!post-build" "..post-build" "..!post-build"
   "post_build" "!post_build" "..post_build" "..!post_build"
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

; Conditions and structurally significant child blocks.
((rule
   name: (rule_name) @keyword)
 (#any-of? @keyword
   "defined" "!defined" "..defined" "..!defined"
   "eq" "!eq" "..eq" "..!eq"
   "prefix" "!prefix" "..prefix" "..!prefix"
   "contains" "!contains" "..contains" "..!contains"
   "or" "!or" "..or" "..!or"
   "and" "!and" "..and" "..!and"
   "parent" "!parent" "..parent" "..!parent"
   "root" "!root" "..root" "..!root"
   "objects" "!objects" "..objects" "..!objects"
   "consumes" "!consumes" "..consumes" "..!consumes"
   "produces" "!produces" "..produces" "..!produces"
   "exec" "!exec" "..exec" "..!exec"
   "shell" "!shell" "..shell" "..!shell"
   "always" "!always" "..always" "..!always"
   "init" "!init" "..init" "..!init"
   "setup" "!setup" "..setup" "..!setup"
   "build" "!build" "..build" "..!build"
   "post-build" "!post-build" "..post-build" "..!post-build"
   "post_build" "!post_build" "..post_build" "..!post_build"))

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
