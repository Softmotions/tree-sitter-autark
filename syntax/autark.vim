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

" Primary Autark directives. Only set/let support both `!` and `..`; if
" supports `!`; other directive names have no prefix modifier.
syn match autarkKeywordRule /\%(^\|[{}[:space:]]\)\zs\%(meta\|option\|check\|env\|else\|error\|echo\|configure\|run\|run-on-install\|in-sources\|foreach\|cc\|cxx\|library\|include\|install\|install-sources\|macro\|call\|fetch-url\)\ze\_s*{/
syn match autarkKeywordRule /\%(^\|[{}[:space:]]\)\zs\%(!\)\?if\ze\_s*{/
syn match autarkKeywordRule /\%(^\|[{}[:space:]]\)\zs\%(\.\.\)\?\%(!\)\?\%(set\|let\)\ze\_s*{/

" Built-in predicates/operators may be negated but not spread.
syn match autarkControlRule /\%(^\|[{}[:space:]]\)\zs\%(!\)\?\%(defined\|eq\|prefix\|contains\|or\|and\)\ze\_s*{/

" Named fields/subsections of built-in blocks.
syn match autarkPropertyRule /\%(^\|[{}[:space:]]\)\zs\%(name\|description\|version\|parent\|root\|objects\|consumes\|produces\|exec\|shell\)\ze\_s*{/

" Build phases are language-defined block names.
syn match autarkPhaseRule /\%(^\|[{}[:space:]]\)\zs\%(init\|setup\|build\|post-build\|post_build\)\ze\_s*{/

" `always` is a bare run modifier rather than a rule name.
syn match autarkRunModifier /\<always\>/

" Symbolic substitutions/helpers and source/path helpers. Negation is valid
" for $, @, @@, ^, %, S, SS, C and CC; spread is valid only for `$`.
syn match autarkSpecialRule /\%(^\|[{}[:space:]]\)\zs\%(\.\.\)\?\%(!\)\?\$\ze\_s*{/
syn match autarkSpecialRule /\%(^\|[{}[:space:]]\)\zs\%(!\)\?\%(@@\|@\|\^\|%\|SS\|S\|CC\|C\)\ze\_s*{/
syn match autarkSpecialRule /\%(^\|[{}[:space:]]\)\zs&\ze\_s*{/

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
hi def link autarkControlRule Operator
hi def link autarkPropertyRule Identifier
hi def link autarkPhaseRule Keyword
hi def link autarkRunModifier Keyword
hi def link autarkSpecialRule Special
hi def link autarkDelimiter Delimiter

let b:current_syntax = 'autark'
