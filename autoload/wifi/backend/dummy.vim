let s:dummy = {
      \ 'job': 0,
      \ 'rssi': -100,
      \ 'rate': 0,
      \ 'ssid': '',
      \ 'callback': 0,
      \}

function! s:dummy.update() abort
endfunction

function! s:dummy.on_stdout(job, data, event) abort
endfunction

function! s:dummy.on_exit(...) abort
endfunction

function! wifi#backend#dummy#define() abort
  return s:dummy
endfunction
