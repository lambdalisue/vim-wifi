" Ref: https://raw.githubusercontent.com/b4b4r07/dotfiles/master/bin/wifi
let s:Job = vital#wifi#import('System.Job')
let s:EXE = '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'

function! s:update() abort dict
  if type(self.job) is# v:t_dict && self.job.status() ==# 'run'
    return
  endif
  let buffer = ['']
  let self.job = s:Job.start([s:EXE, '--getinfo'], {
        \ 'on_stdout': funcref('s:on_stdout', [buffer]),
        \ 'on_exit': funcref('s:on_exit', [buffer], self),
        \})
endfunction

function! s:on_stdout(buffer, data) abort
  call extend(a:buffer, a:data)
endfunction

function! s:on_exit(buffer, exitval) abort dict
  let content = join(a:buffer, "\n")
  let self.rssi = str2nr(matchstr(content, '\<agrCtlRSSI: \zs.\+$'))
  let self.rate = str2nr(matchstr(content, '\<lastTxRate: \zs.\+$'))
  let self.ssid = matchstr(content, '\<SSID: \zs[^\r\n]\+')
  if type(self.callback) is# v:t_func
    call self.callback()
  endif
endfunction

function! wifi#backend#airport#define() abort
  return {
        \ 'job': 0,
        \ 'rssi': -100,
        \ 'rate': 0,
        \ 'ssid': '',
        \ 'callback': 0,
        \ 'update': funcref('s:update'),
        \}
endfunction
