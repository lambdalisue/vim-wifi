function! wifi#backend() abort
  if exists('s:backend')
    return s:backend
  endif
  let s:backend = wifi#backend#get(g:wifi#backend)
  let s:backend.callback = function('s:update_callback')
  return s:backend
endfunction

function! wifi#update() abort
  let backend = wifi#backend()
  return backend.update()
endfunction

function! wifi#rssi() abort
  let backend = wifi#backend()
  return backend.rssi
endfunction

function! wifi#rate() abort
  let backend = wifi#backend()
  return backend.rate
endfunction

function! wifi#ssid() abort
  let backend = wifi#backend()
  return backend.ssid
endfunction

function! wifi#graph() abort
  let backend = wifi#backend()
  if backend.rssi > -50
    return '▂▅▇'
  elseif backend.rssi > -80
    return '▂▅ '
  elseif backend.rssi > -100
    return '▂  '
  endif
endfunction

function! wifi#watch() abort
  if exists('s:timer')
    call timer_stop(s:timer)
  endif
  let s:timer = timer_start(0, function('s:watch_callback'))
endfunction

function! wifi#unwatch() abort
  if exists('s:timer')
    call timer_stop(s:timer)
    unlet s:timer
  endif
endfunction

function! wifi#component() abort
  let backend = wifi#backend()
  if backend.rate == 0
    return ''
  endif
  let format = g:wifi#component_format
  let format = substitute(format, '%s', backend.ssid, 'g')
  let format = substitute(format, '%r', backend.rate, 'g')
  let format = substitute(format, '%i', backend.rssi, 'g')
  let format = substitute(format, '%g', wifi#graph(), 'g')
  let format = substitute(format, '%\([^%]\)', '\1', 'g')
  let format = substitute(format, '%%', '%', 'g')
  return format
endfunction

function! s:update_callback() abort
  if g:wifi#update_tabline
    let &tabline = &tabline
  endif
  if g:wifi#update_statusline
    let &statusline = &statusline
  endif
endfunction

function! s:watch_callback(...) abort
  call wifi#update()
  let s:timer = timer_start(
        \ g:wifi#update_interval,
        \ function('s:watch_callback')
        \)
endfunction

function! s:get_available_backend() abort
  if has('mac')
    return 'airport'
  endif
  return 'dummy'
endfunction

function! s:define(prefix, default) abort
  let prefix = a:prefix =~# '^g:' ? a:prefix : 'g:' . a:prefix
  for [key, Value] in items(a:default)
    let name = prefix . '#' . key
    if !exists(name)
      execute 'let ' . name . ' = ' . string(Value)
    endif
    unlet Value
  endfor
endfunction

call s:define('g:wifi', {
      \ 'backend': s:get_available_backend(),
      \ 'update_interval': 30000,
      \ 'update_tabline': 0,
      \ 'update_statusline': 0,
      \ 'component_format': '%s %r Mbs %g',
      \})
