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
" This is the fallback for user-defined and otherwise unclassified rules.
syn match autarkRuleName /\%([^{}\\[:space:]]\|\\[{}\\nrt]\)\+\ze\_s*{/

" Named directive aliases from grammar.js. Keep the prefixed variants explicit:
" the grammar aliases !set/..set and !let/..let, but not combined ..! forms.
syn match autarkKeywordRule /\%(^\|[{}[:space:]]\)\zs\%(meta\|include\|option\|cc\|cxx\|env\|echo\|error\|check\|configure\|run\|run-on-install\|in-sources\|foreach\|library\|install\|install-sources\|macro\|call\)\ze\_s*{/
syn match autarkKeywordRule /\%(^\|[{}[:space:]]\)\zs\%(set\|!set\|\.\.set\|let\|!let\|\.\.let\)\ze\_s*{/

" Conditional aliases. if/!if share one grammar alias; else is separate.
syn match autarkConditionalRule /\%(^\|[{}[:space:]]\)\zs\%(if\|!if\|else\)\ze\_s*{/

" Logical condition groups are named condition_group nodes in the grammar.
syn match autarkConditionGroup /\%(^\|[{}[:space:]]\)\zs\%(and\|!and\|or\|!or\)\ze\_s*{/

" Condition predicates used by the current Tree-sitter highlighting rules. Vim
" syntax has no AST context, so classify these by name wherever they are rules.
syn match autarkConditionProperty /\%(^\|[{}[:space:]]\)\zs\%(defined\|!defined\|contains\|!contains\|eq\|!eq\|prefix\|!prefix\)\ze\_s*{/

" Symbolic built-ins from queries/highlights.scm. These are deliberately exact:
" spread and negation are not combined unless an exact form is listed here.
syn match autarkSpecialRule /\%(^\|[{}[:space:]]\)\zs\%(\$\|!\$\|\.\.\$\|@\|!@\|\.\.@\|@@\|!@@\|\.\.@@\)\ze\_s*{/
syn match autarkSpecialRule /\%(^\|[{}[:space:]]\)\zs\%(!\)\?\%(\^\|%\|SS\|S\|CC\|C\)\ze\_s*{/
syn match autarkSpecialRule /\%(^\|[{}[:space:]]\)\zs&\ze\_s*{/

" First literal arguments that have a name/key role in the current query.
" The atom is made atomic before the negative look-ahead so a nested rule name
" cannot be partially backtracked and misclassified as a modifier.
syn match autarkModifier /\%(\%(set\|!set\|\.\.set\|let\|!let\|\.\.let\|env\|option\|macro\|foreach\)\_s*{\_s*\)\@<=\%(\%([^{}\\[:space:]]\|\\[{}\\nrt]\)\+\)\@>\ze\%(\_s*{\)\@!/
syn match autarkModifier /\%(\%(parent\|root\)\_s*{\_s*\)\@<=\%(\%([^{}\\[:space:]]\|\\[{}\\nrt]\)\+\)\@>\ze\%(\_s*{\)\@!/

" The first literal in call { ... } is a macro/function target.
syn match autarkCallTarget /\%(call\_s*{\_s*\)\@<=\%(\%([^{}\\[:space:]]\|\\[{}\\nrt]\)\+\)\@>\ze\%(\_s*{\)\@!/

" The first bare check entry is executable rather than data. Nested check rules
" are already covered by autarkRuleName -> Function.
syn match autarkCheckTarget /\%(check\_s*{\_s*\)\@<=\%(\%([^{}\\[:space:]]\|\\[{}\\nrt]\)\+\)\@>\ze\%(\_s*{\)\@!/

" Named fields/subsections recognized by the current Tree-sitter highlighting
" policy. In plain Vim these are intentionally name-based approximations.
syn match autarkPropertyRule /\%(^\|[{}[:space:]]\)\zs\%(name\|version\|version_major\|version_minor\|version_patch\|description\|website\|author\|vendor\|maintainer\|sources\|license\|parent\|root\|objects\|consumes\|produces\|exec\|shell\|build\|setup\|init\)\ze\_s*{/

" `always` is a bare property-like value under run/run-on-install. Without AST
" context, plain Vim treats the standalone token consistently wherever it occurs.
syn match autarkPropertyValue /\%(^\|[{}[:space:]]\)\zsalways\ze\%($\|[{}[:space:]]\)/

syn match autarkDelimiter /[{}]/

" Quoted values may span lines. Autark does not define C-style escaping inside
" STRQ/STRQQ; the next matching quote terminates the value.
syn region autarkSingleQuotedString start=+'+ end=+'+ keepend
syn region autarkDoubleQuotedString start=+"+ end=+"+ keepend

" Autark removes a comment only when # is the first non-whitespace character
" on a source line. Define comments last so they win over the generic STRP
" matcher; an inline # remains an ordinary literal, matching Autark itself.
syn match autarkComment /^\s*#.*$/

" Give multi-line quoted values enough look-behind without forcing fromstart on
" large Autark files.
syn sync minlines=50

hi def link autarkComment Comment
hi def link autarkSingleQuotedString String
hi def link autarkDoubleQuotedString String
hi def link autarkLiteral String
hi def link autarkRuleName Function
hi def link autarkKeywordRule Keyword
hi def link autarkConditionalRule Conditional
hi def link autarkConditionGroup Operator
hi def link autarkConditionProperty Identifier
hi def link autarkPropertyRule Identifier
hi def link autarkPropertyValue Identifier
hi def link autarkModifier StorageClass
hi def link autarkCallTarget Function
hi def link autarkCheckTarget Function
hi def link autarkSpecialRule Special
hi def link autarkDelimiter Delimiter

let b:current_syntax = 'autark'
