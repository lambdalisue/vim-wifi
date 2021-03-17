" Ref: https://wiki.termux.com/wiki/Termux-wifi-connectioninfo
let s:Job = vital#wifi#import('System.Job')

function! s:termux_update() abort dict
  if type(self.job) is# v:t_dict && self.job.status() ==# 'run'
    return
  endif
  let data = []
  let args = ['termux-wifi-connectioninfo']
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
  if json_decode(content).supplicant_state ==# 'COMPLETED'
    let a:backend.rssi = json_decode(content).rssi + 0
    let a:backend.rate = json_decode(content).link_speed_mbps + 0
    if json_decode(content).ssid_hidden ==# 'false'
      let a:backend.ssid = json_decode(content).ssid
    endif
  endif
endfunction

function! wifi#backend#termux#define() abort
  return {
        \ 'job': 0,
        \ 'rssi': -100,
        \ 'rate': 0,
        \ 'ssid': '',
        \ 'update': funcref('s:termux_update'),
        \}
endfunction

function! wifi#backend#termux#is_available() abort
  return executable('termux-wifi-connectioninfo')
endfunction
