nnoremap <silent> <Plug>(CasingToSnakeCase) :set operatorfunc=SnakeCaseOperator<CR>g@
nnoremap <silent> <Plug>(CasingToPascalCase) :set operatorfunc=PascalCaseOperator<CR>g@
nnoremap <silent> <Plug>(CasingToCamelCase) :set operatorfunc=CamelCaseOperator<CR>g@

function! SnakeCaseOperator(type)
  let l:state = s:push_state()
  call s:select_region(a:type)
  call s:snake_case_transformer()
  call s:pop_state(l:state)
endfunction

function! s:snake_case_transformer()
  keepjumps '<,'>s/\v%V(\l)(\u)/\1_\2/ge  " HttpRequest -> Http_Request
  keepjumps '<,'>s/\v%V(\u+)(\u\l)/\1_\2/ge " HTTPRequest -> HTTP_Request
  execute "normal! `<gu`>"
endfunction

function! PascalCaseOperator(type)
  let l:state = s:push_state()
  call s:select_region(a:type)
  call s:snake_case_transformer()
  keepjumps '<,'>s/\v%V\w+_/\u\0/ge  " http_request -> Http_request
  keepjumps '<,'>s/\v%V_\l/\U\0/ge  " Http_request -> Http_Request
  keepjumps '<,'>s/\v%V_//ge  " Http_Request -> HttpRequest
  call s:pop_state(l:state)
endfunction

function! CamelCaseOperator(type)
  let l:state = s:push_state()
  call s:select_region(a:type)
  call s:snake_case_transformer()
  keepjumps '<,'>s/\v%V_\l/\U\0/ge  " http_request -> http_Request
  keepjumps '<,'>s/\v%V_//ge  " http_Request -> httpRequest
  call s:pop_state(l:state)
endfunction

function! s:push_state()
  return {
  \ 'saved_v_start': getpos("'<"),
  \ 'saved_v_end': getpos("'>"),
  \ 'saved_cursor': getcurpos(),
  \ 'saved_search': @/,
  \ }
endfunction

function! s:pop_state(state)
  let @/ = a:state.saved_search
  call setpos(".", a:state.saved_cursor)
  call setpos("'>", a:state.saved_v_end)
  call setpos("'<", a:state.saved_v_start)
endfunction

function! s:select_region(type)
  if a:type ==# 'char'
    execute "normal! `[v`]\<esc>"
  elseif a:type ==# 'line'
    execute "normal! '[V']\<esc>"
  endif
endfunction
