" Vim syntax file
" Language: Autark build-script DSL
" Maintainer: Softmotions Ltd
" Repository: https://github.com/Softmotions/tree-sitter-autark

if exists('b:current_syntax')
  finish
endif

syn case match

" STRP from scriptx.leg: any non-space/non-brace/non-backslash character, or
" one of the six accepted backslash escapes: { } \\ n r t.
syn match autarkLiteral /\%([^{}\\[:space:]]\|\\[{}\\nrt]\)\+/

" Any STRP immediately followed by optional whitespace and { is a rule name.
" Define this after autarkLiteral so rule names win when both start together.
syn match autarkRuleName /\%([^{}\\[:space:]]\|\\[{}\\nrt]\)\+\ze\_s*{/

" Primary Autark directives. Optional '..' and '!' prefixes are part of the
" rule name and have the same highlighting as the directive itself.
syn match autarkKeywordRule /\%(^\|[{}[:space:]]\)\zs\%((\.\.)\)\?\(!\)\?\%(meta\|option\|check\|set\|let\|env\|if\|else\|error\|echo\|configure\|run\|run-on-install\|in-sources\|foreach\|cc\|cxx\|library\|include\|install\|install-sources\|macro\|call\|fetch-url\)\ze\_s*{/

" Structural/helper child rules used by built-in directives.
syn match autarkControlRule /\%(^\|[{}[:space:]]\)\zs\%((\.\.)\)\?\(!\)\?\%(defined\|eq\|prefix\|contains\|or\|and\|parent\|root\|objects\|consumes\|produces\|exec\|shell\|always\|init\|setup\|build\|post-build\|post_build\)\ze\_s*{/

" Symbolic substitutions/helpers and source/path helpers.
syn match autarkSpecialRule /\%(^\|[{}[:space:]]\)\zs\%((\.\.)\)\?\(!\)\?\%(\$\|@\|@@\|\^\|%\|S\|SS\|C\|CC\|&\)\ze\_s*{/

syn match autarkDelimiter /[{}]/

" Quoted values may span lines. Autark does not define C-style escaping inside
" STRQ/STRQQ; the next matching quote terminates the value. These regions are
" defined after bare literals so quote characters are treated as string bounds.
syn region autarkSingleQuotedString start=+'+ end=+'+ keepend
syn region autarkDoubleQuotedString start=+"+ end=+"+ keepend

" Autark removes a comment only when # is the first non-whitespace character
" on a source line. Define comments last so a whole comment line wins over the
" generic STRP matcher, while an inline # remains an ordinary literal.
syn match autarkComment /^\s*#.*$/

hi def link autarkComment Comment
hi def link autarkSingleQuotedString String
hi def link autarkDoubleQuotedString String
hi def link autarkLiteral String
hi def link autarkRuleName Function
hi def link autarkKeywordRule Keyword
hi def link autarkControlRule Keyword
hi def link autarkSpecialRule Special
hi def link autarkDelimiter Delimiter

let b:current_syntax = 'autark'
