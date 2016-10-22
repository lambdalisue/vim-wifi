function! wifi#backend#get(name) abort
  if exists('s:' . a:name)
    return s:{a:name}
  endif
  try
    let s:{a:name} = wifi#backend#{a:name}#define()
  catch /^Vim\%((\a\+)\)\=:E117/  " Unknown functino
    let s:{a:name} = wifi#backend#dummy#define()
  endtry
  return s:{a:name}
endfunction
