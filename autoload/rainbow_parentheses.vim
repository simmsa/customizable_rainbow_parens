"==============================================================================
"  Description: Rainbow colors for parentheses, based on rainbow_parenthsis.vim
"               by Martin Krischik, June Gunn and others.
"==============================================================================

" let s:generation = 0

function! s:GetCurrentBufFileType()
    return getbufvar(bufnr(bufname('%')), '&filetype')
endfunction

function! s:GetCurrentBufFileExtension()
    return expand('%:e')
endfunction

function! s:ExcludeCurrentFileType ()
    let l:base_single_exclude_fts = get(g:, 'rainbow#base_exclude', [])
    return index(l:base_single_exclude_fts, s:GetCurrentBufFileType()) > -1
endfunction

function! s:colors_to_hi(colors)
  " vint: -ProhibitUnnecessaryDoubleQuote
  return
    \ join(
    \   values(
    \     map(
    \       filter({ 'ctermfg': a:colors[0], 'guifg': a:colors[1] },
    \              '!empty(v:val)'),
    \       'v:key . "=".v:val')), ' ')
endfunction

function! rainbow_parentheses#activate(...)
  let s:max_level = get(g:, 'rainbow#max_level', 16)
  let l:colors = map(copy(g:rainbow_colors[&background]), 's:colors_to_hi(v:val)')

  if s:ExcludeCurrentFileType()
      return
  else
      let l:single_color = g:rainbow_single_colors[&background][0]
      let l:single_ctermfg = l:single_color[0]
      let l:single_guifg = l:single_color[1]
      execute printf('hi rainbowSingle%d ctermfg=%s guifg=%s', 0, l:single_ctermfg, l:single_guifg)
  endif

  for l:level in range(1, s:max_level)
    let l:this_color = l:colors[(l:level - 1) % len(l:colors)]
    execute printf('hi rainbowParensShell%d %s', s:max_level - l:level + 1, l:this_color)
    execute printf('hi rainbowSingle%d %s', s:max_level - l:level + 1, l:this_color)
  endfor

  call s:regions(s:max_level)
endfunction

function! rainbow_parentheses#deactivate()
  " if exists('#rainbow_parentheses')
    for l:level in range(0, s:max_level)
      " FIXME How to cope with changes in rainbow#max_level?
      " silent! execute 'hi clear rainbowParensShell'.l:level
      " silent! execute 'hi clear rainbowSingle'.l:level
      " FIXME buffer-local
      silent! execute 'syntax clear rainbowParens'.l:level
      silent! execute 'syntax clear rainbowSingle'.l:level
    endfor
    " augroup rainbow_parentheses
    "   autocmd!
    " augroup END
    " augroup! rainbow_parentheses
    " delc RainbowParenthesesColors
  " endif
endfunction

function! rainbow_parentheses#toggle()
  if exists('#rainbow_parentheses')
    call rainbow_parentheses#deactivate()
  else
    call rainbow_parentheses#activate()
  endif
endfunction

function! s:GetRainbowPairs()
  let l:ft_pairs = get(g:rainbow_ft_pairs, s:GetCurrentBufFileType(), [])
  let l:ext_pairs = get(g:rainbow_ext_pairs, s:GetCurrentBufFileExtension(), [])
  return extend(copy(g:rainbow_pairs), extend(l:ft_pairs, l:ext_pairs))
endfunction

function! s:GetRainbowIncludes()
  let l:ft_include = get(g:rainbow_ft_include, s:GetCurrentBufFileType(), [])
  let l:ext_include = get(g:rainbow_ext_include, s:GetCurrentBufFileExtension(), [])
  " return join(extend(copy(g:rainbow_include), extend(l:ft_include, l:ext_include)), '\{1}\|') . '\{1}'
  return join(extend(copy(g:rainbow_include), extend(l:ft_include, l:ext_include)), '\|')
  " let l:include = join(extend(l:ext_include, copy(g:rainbow_include)), '\{1}\|')
  " let l:include = join(extend(g:rainbow_include, l:ext_include), '\{1}\|') . '\{1}'
  " let l:include = join(extend(l:ext_include, extend(l:ft_include, g:rainbow_include)), '\{1}\|')

  " let l:include = join(get(g:, 'rainbow#include', [';', ':', '=', ',']), '\{1}\|')
endfunction

function! GetCurrentBufferId()
  let l:buf_info = getbufinfo('%')[0]
  return l:buf_info['bufnr'] . ' ' . l:buf_info['name']
endfunction

function! ShouldTurnOnRainbowParens()
  if getfsize(expand('%')) > g:rainbow_max_file_size
    return v:false
  elseif index(g:rainbow_ignore_fts, s:GetCurrentBufFileType()) > -1
    return v:false
  endif

  return v:true
endfunction

function! s:debug(msg_type, buf_id)
    if a:msg_type ==# "init"
      let l:msg = printf("Init rainbow parens in buffer: %s", a:buf_id)
    elseif a:msg_type ==# "deactivate"
      let l:msg = printf("Deactivating rainbow parens in buffer: %s", a:buf_id)
    elseif a:msg_type ==# "skip"
      let l:msg = printf("Skipping rainbow parens in buffer: %s", a:buf_id)
    elseif a:msg_type ==# "remove_from_state"
      let l:msg = printf("Removing buffer from rainbow parens state: %s", a:buf_id)
    endif

    call insert(g:rainbow_debug_msg, l:msg, 0)
endfunction

function! s:regions(max)
  let l:buf_id = GetCurrentBufferId()
  let l:buffer_state = get(g:rainbow_state, l:buf_id, v:null)

  if l:buffer_state != v:null
    call s:debug("skip", l:buf_id)
    return
  else
    if ShouldTurnOnRainbowParens()
      let g:rainbow_state[l:buf_id] = v:true
      call s:debug("init", l:buf_id)
    else
      let g:rainbow_state[l:buf_id] = v:false
      call s:debug("deactivate", l:buf_id)
      return
    endif
  endif

  let l:pairs = s:GetRainbowPairs()
  let l:include = s:GetRainbowIncludes()

  " Match base includes
  let l:base_include_cmd = 'syntax match rainbowSingle%d /%s/'
  execute printf(l:base_include_cmd, 0, l:include)

  for l:level in range(1, a:max)
    let l:include_cmd = 'syntax match rainbowSingle%d /%s/ contained containedin=rainbowParens%d'
    execute printf(l:include_cmd, l:level, l:include, l:level)

    let l:cmd = 'syntax region rainbowParens%d matchgroup=rainbowParensShell%d start=/%s/ end=/%s/ contains=%s'

    " vint: -ProhibitUnnecessaryDoubleQuote
    let l:children = extend(['TOP'], map(range(l:level, a:max), '"rainbowParens".v:val'))
    for l:pair in l:pairs
      " vint: -ProhibitUnnecessaryDoubleQuote
      let [l:open, l:close] = map(copy(l:pair), 'escape(v:val, "[]/")')
      execute printf(l:cmd, l:level, l:level, l:open, l:close, join(l:children, ','))
    endfor
  endfor
endfunction

function! rainbow_parentheses#UpdateStateOnBufferDeleted()
    try
        let l:buf_id = GetCurrentBufferId()
        call remove(g:rainbow_state, l:buf_id)
        call s:debug("remove_from_state", l:buf_id)
    catch /E716/
        " pass
    endtry
endfunction

" vim: set sw=2
