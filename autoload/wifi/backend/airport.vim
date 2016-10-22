
" airport -------------------------------------------------------------
" ref: https://raw.githubusercontent.com/b4b4r07/dotfiles/master/bin/wifi
let s:airport = {
      \ 'job': 0,
      \ 'data': [],
      \ 'rssi': -100,
      \ 'rate': 0,
      \ 'ssid': '',
      \ 'callback': 0,
      \}
let s:airport.executable = join([
      \ '/System',
      \ '/Library',
      \ '/PrivateFrameworks',
      \ '/Apple80211.framework',
      \ '/Versions',
      \ '/Current',
      \ '/Resources',
      \ '/airport',
      \], '')

function! s:airport.update() abort
  if wifi#job#is_alive(self.job)
    return
  endif
  let self.job = wifi#job#start(
        \ self.executable . ' --getinfo',
        \ self
        \)
endfunction

function! s:airport.on_stdout(job, data, event) abort
  call extend(self.data, a:data)
endfunction

function! s:airport.on_exit(...) abort
  let content = join(self.data, "\n")
  let self.data = []
  let self.rssi = str2nr(matchstr(content, '\<agrCtlRSSI: \zs.\+$'))
  let self.rate = str2nr(matchstr(content, '\<lastTxRate: \zs.\+$'))
  let self.ssid = matchstr(content, '\<SSID: \zs\w\+')
endfunction


function! wifi#backend#airport#define() abort
  return s:airport
endfunction
