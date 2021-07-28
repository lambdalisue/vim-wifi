let s:Job = vital#wifi#import('System.Job')
if filereadable('/proc/net/wireless')
  let s:wifi_if = trim(get(split(matchstr(readfile('/proc/net/wireless'), ':'), ':'), 0))
endif

function! s:linux_update() abort dict
  if type(self.job) is# v:t_dict && self.job.status() ==# 'run'
    return
  endif
  let data = []
  let args = ['iw', 'dev', s:wifi_if, 'link']
  let self.job = s:Job.start(args, {
        \ 'on_stdout': funcref('s:on_stdout', [data]),
        \ 'on_exit': funcref('s:on_exit', [self, data]),
        \})
endfunction

function! s:on_stdout(buffer, data) abort
  call extend(a:buffer, a:data)
endfunction

function! s:on_exit(backend, buffer, exitval) abort
  let content = join(a:buffer, '')
  let a:backend.rssi = matchstr(content, 'signal: \zs\S\+')
  let a:backend.rate = matchstr(content, 'tx bitrate: \zs\S\+')
  let a:backend.ssid = matchstr(content, 'SSID: \zs.\{-}\ze\t')
endfunction

function! wifi#backend#linux#define() abort
  return {
        \ 'job': 0,
        \ 'rssi': -100,
        \ 'rate': 0,
        \ 'ssid': '',
        \ 'update': funcref('s:linux_update'),
        \}
endfunction

function! wifi#backend#linux#is_available() abort
  return !empty(get(s:, 'wifi_if')) && executable('iw')
endfunction
