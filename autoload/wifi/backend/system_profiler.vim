" Backend for modern macOS (macOS 15+) using system_profiler
" This backend is used when the airport command is not available
"
" Note: Due to macOS privacy changes introduced in macOS 14 (Sonoma),
" SSID access requires Location Services permission. CLI tools cannot
" request this permission, so SSID will always be unavailable.
" See: https://developer.apple.com/forums/thread/732431
"
" RSSI and transmission rate are still available as they are not
" considered privacy-sensitive information.
let s:Job = vital#wifi#import('System.Job')
let s:EXE = 'system_profiler'

function! s:update() abort dict
  if type(self.job) is# v:t_dict && self.job.status() ==# 'run'
    return
  endif
  let buffer = ['']
  let self.job = s:Job.start([s:EXE, 'SPAirPortDataType'], {
        \ 'on_stdout': funcref('s:on_stdout', [buffer]),
        \ 'on_exit': funcref('s:on_exit', [buffer], self),
        \})
endfunction

function! s:on_stdout(buffer, data) abort
  call extend(a:buffer, a:data)
endfunction

function! s:on_exit(buffer, exitval) abort dict
  let content = join(a:buffer, "\n")
  " Parse system_profiler output format:
  " Signal / Noise: -51 dBm / -90 dBm
  " Transmit Rate: 229
  " The SSID is in the line before "PHY Mode" in Current Network Information section

  " Extract RSSI (Signal strength in dBm)
  let rssi_match = matchstr(content, 'Signal / Noise:\s*\zs-\?\d\+')
  let self.rssi = empty(rssi_match) ? -100 : str2nr(rssi_match)

  " Extract transmit rate
  let rate_match = matchstr(content, 'Transmit Rate:\s*\zs\d\+')
  let self.rate = empty(rate_match) ? 0 : str2nr(rate_match)

  " Extract SSID from Current Network Information section
  " The SSID appears as the network name (indented) before PHY Mode
  " Note: macOS 14+ shows '<redacted>' due to Location Services requirement
  let current_network_section = matchstr(content, 'Current Network Information:\_.\{-}\n\s\+\zs\S\+\ze:\_.\{-}PHY Mode:')
  if empty(current_network_section) || current_network_section ==# '<redacted>'
    let self.ssid = ''
  else
    let self.ssid = current_network_section
  endif

  if type(self.callback) is# v:t_func
    call self.callback()
  endif
endfunction

function! wifi#backend#system_profiler#is_available() abort
  " system_profiler is available on all macOS versions
  " This backend is used when airport command is not available
  return executable('system_profiler')
endfunction

function! wifi#backend#system_profiler#define() abort
  return {
        \ 'job': 0,
        \ 'rssi': -100,
        \ 'rate': 0,
        \ 'ssid': '',
        \ 'callback': 0,
        \ 'update': funcref('s:update'),
        \}
endfunction
