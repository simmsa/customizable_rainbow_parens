"==============================================================================
"  Description: Rainbow colors for parentheses, based on rainbow_parenthsis.vim
"               by Martin Krischik, June Gunn and others.
"==============================================================================

command! -bang -nargs=? -bar RainbowParentheses
  \  if empty('<bang>')
  \|   call rainbow_parentheses#activate()
  \| elseif <q-args> == '!'
  \|   call rainbow_parentheses#toggle()
  \| else
  \|   call rainbow_parentheses#deactivate()
  \| endif

let g:rainbow_state = {}
let g:rainbow_debug_msg = []

let g:rainbow_max_file_size = 100000

let g:rainbow_ignore_fts = [
    \ 'help',
\ ]

let g:rainbow_colors = {
    \ 'dark': [
        \ ['33', '#2979ff'],
        \ ['43', '#1de9b6'],
        \ ['165', '#d500f9'],
        \ ['45', '#00e5ff'],
        \ ['57', '#651fff'],
        \ ['39', '#00b0ff'],
        \ ['42', '#00e676'],
        \ ['33', '#2979ff'],
        \ ['43', '#1de9b6'],
        \ ['165', '#d500f9'],
        \ ['45', '#00e5ff'],
        \ ['57', '#651fff'],
        \ ['39', '#00b0ff'],
        \ ['42', '#00e676'],
    \ ],
    \ 'light': [
        \ ['33', '#2979ff'],
        \ ['43', '#1de9b6'],
        \ ['165', '#d500f9'],
        \ ['45', '#00e5ff'],
        \ ['57', '#651fff'],
        \ ['39', '#00b0ff'],
        \ ['42', '#00e676'],
        \ ['33', '#2979ff'],
        \ ['43', '#1de9b6'],
        \ ['165', '#d500f9'],
        \ ['45', '#00e5ff'],
        \ ['57', '#651fff'],
        \ ['39', '#00b0ff'],
        \ ['42', '#00e676'],
    \ ],
\}

let g:rainbow_single_colors = {
    \ 'dark': [
        \ ['123', '#18ffff'],
    \ ],
    \'light': [
        \ ['123', '#18ffff'],
    \]
\}

let g:rainbow_pairs = [
    \ ['(', ')'],
    \ ['[', ']'],
    \ ['{', '}'],
\ ]

        " \ ['^\s\+\(? \)\=<\w\+\(\s\|$\|\>\)\=', '</\w\+>\_$\|/>\_$'],
let g:rainbow_ext_pairs = {
    \ 'tsx': [
        \ ['\(\S\)\@=<\(\S\+\(, \)\=\)\{-}', '>'],
        \ ['^\s\+\(? \)\=\(: \)\=<\w\+\(\s\|\_$\|\>\)\=', '</\S\+>;\=,\=\_$\|/>;\='],
    \],
    \ 'ts': [
        \ ['\(\S\)\@=<\(\S\+\(, \)\=\)\{-}', '>'],
    \],
\ }

let g:rainbow_ft_pairs = {
    \ 'vim': [
        \ ['^function!', '^endfunction'],
        \ ['^augroup', '^augroup END'],
        \ ['^\s\+if', 'endif\_$'],
        \ ['^if', 'endif\_$'],
        \ ['for\s', 'endfor\_$'],
        \ ['while\s', 'endwhile\_$'],
    \ ],
    \ 'quarto': [
    \ [':::\s{.*}', ':::\_$'],
    \ [':::{.*}', ':::\_$'],
    \ ['::::\s{.*}', '::::\_$'],
    \ ['::::{.*}', '::::\_$'],
    \],
\}
    " \ [':::\s{#\a\+}', ':::\_$'],

let g:rainbow_ft_include = {
    \ 'vim': [
        \ '^\s\+let\s',
        \ '^\s\+execute\s',
        \ 'call\s',
        \ 'exe\s',
        \ 'elseif\s',
        \ 'else\_$',
        \ '\sin\s',
    \ ],
    \ 'go': [
        \ ' := ',
    \ ],
    \ 'typescript': [
        \ 'describe',
        \ 'test',
    \ ],
    \ 'cpp': [
        \ '::',
    \ ]
\}

" You can use one multi in these commands so use it wisely
let g:rainbow_ext_include = {
    \ 'tsx': [
        \ '\(\w\)\+=',
        \ 'this\.',
        \ 'this\.props',
        \ 'this\.state',
        \ 'props\.',
    \]
\ }

let g:rainbow_include = [
    \ '^\s\+case\s',
    \ '>\_$',
    \ ';\_$ ',
    \ ',\_$',
    \ ', ',
    \ '\w\+ = ',
    \ ' = ',
    \ ' \. ',
    \ ', ',
    \ ' < ',
    \ ' > ',
    \ ' ! ',
    \ ' & ',
    \ ' | ',
    \ ' + ',
    \ ' - ',
    \ ' += ',
    \ ' -= ',
    \ ' >= ',
    \ ' <= ',
    \ ' => ',
    \ ' =>\_$',
    \ ' \\ ',
    \ ';\n',
    \ '; ',
    \ ' \* ',
    \ '++',
    \ '\.',
    \ '->',
    \ ' != ',
    \ ' == ',
    \ ' && ',
    \ ' || ',
    \ ' << ',
    \ ' >> ',
    \ ' != ',
    \ ' \*= ',
    \ ' === ',
    \ ' !== ',
    \ ' ? ',
    \ '? ',
    \ '\w\+,\_$',
\ ]
    " \ ': ',
    " \ '\(\w\)\+: ',
    " \ '\(\w\)\+?: ',

augroup rainbow_parens
    au!
    au! VimEnter * let g:rainbow_state = {}
    au! BufReadPost,BufEnter,WinEnter * call rainbow_parentheses#activate()
    au BufDelete * call rainbow_parentheses#UpdateStateOnBufferDeleted()
augroup END

command! -bar RainbowParenthesesActivate call rainbow_parentheses#activate()
command! -bar RainbowParenthesesDeactivate call rainbow_parentheses#deactivate()
