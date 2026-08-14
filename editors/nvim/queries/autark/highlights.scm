; Tree-sitter highlights for Autark.
; Capture names are chosen so they work in Neovim and with tree-sitter-vscode.

(comment) @comment

(single_quoted_string) @string
(double_quoted_string) @string
(literal) @string.special

["{" "}"] @punctuation.bracket

; Generic/custom rules. Built-ins are excluded to avoid overlapping captures.
((rule
   name: (rule_name) @function.call)
 (#not-match? @function.call "^(\\.\\.)!?(meta|option|check|set|let|env|if|else|error|echo|configure|run|run-on-install|in-sources|foreach|cc|cxx|library|install|install-sources|macro|call|include|fetch-url|defined|eq|prefix|contains|or|and|parent|root|objects|consumes|produces|exec|shell|init|setup|build|\\$|@|@@|\\^|%|S|SS|C|CC|&)$"))

; Primary Autark directives.
((rule
   name: (rule_name) @keyword)
 (#match? @keyword "^(\\.\\.)!?(meta|option|check|set|let|env|if|else|error|echo|configure|run|run-on-install|in-sources|foreach|cc|cxx|library|install|install-sources|macro|call|include|fetch-url)$"))

; Conditions and structurally significant child blocks.
((rule
   name: (rule_name) @keyword)
 (#match? @keyword "^(\\.\\.)!?(defined|eq|prefix|contains|or|and|parent|root|objects|consumes|produces|exec|shell|init|setup|build)$"))

; Substitution/evaluation/path helper rules.
((rule
   name: (rule_name) @function.builtin)
 (#match? @function.builtin "^(\\.\\.)!?(\\$|@|@@|\\^|%|S|SS|C|CC|&)$"))
