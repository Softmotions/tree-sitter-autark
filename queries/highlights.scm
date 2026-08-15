; Tree-sitter highlights for Autark.

(comment) @comment

(single_quoted_string) @string
(double_quoted_string) @string

["{" "}"] @punctuation.bracket

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

((rule
   name: (rule_name [
                     (meta)
                     (include)
                     (cc) 
                     (env) 
                     (set) 
                     (echo)
                     (echo)
                     (check)
                     (configure)
                     (if)
                     (run) 
                     (in_sources) 
                     (foreach) 
                     (library) 
                     (install) 
                     (macro) 
                     (call) 
                     (option)
                     ]) @keyword))

((rule
   name: (rule_name [
                     (if) 
                     (else) 
                     ]) @keyword.conditional))


((rule
   name: (rule_name (cc))
   body: (rule name: (rule_name) @property))
 (#any-of? @property
   "consumes"
   "produces"
   "objects"))
   
((rule
   name: (rule_name (run))
   body: (rule name: (rule_name) @property))
 (#any-of? @property
  "consumes"
  "produces"
  "exec"
  "shell"))
  
((rule
   name: (rule_name (run))
   body: (literal) @property)
 (#any-of? @property "always"))

((rule
   name: (rule_name (echo))
   body: (rule
           name: (rule_name) @property))
 (#any-of? @property
  "build"
  "setup"
  "init"))

((rule
   name: (rule_name (meta))
   body: (rule
           name: (rule_name) @property))
 (#any-of? @property
  "name"
  "version"
  "version_major"
  "version_minor"
  "version_patch"
  "description"
  "website"
  "author"
  "sources"
  "license"))

((rule 
   name: (rule_name (check))
   body: (literal) @function.call))

((rule 
   name: (rule_name (check))
   body: (rule name: (rule_name) @function.call)))

((rule
   name: (rule_name [(set)
                     (library)])
   body: (rule
           name: (rule_name) @property
           .
           body: (literal) @keyword.modifier))
 (#any-of? @property
  "parent"
  "root"))

((rule 
   name: (rule_name [(set)
                     (option)
                     (macro)
                     (foreach)])
   .
   body: (literal) @keyword.modifier))


((rule 
   name: (rule_name (call))
   .
   body: (literal) @function.call))
