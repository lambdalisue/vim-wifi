if exists('g:loaded_wifi')
  finish
endif
let g:loaded_wifi = 1


if get(g:, 'wifi_watch_on_startup', 1)
  call wifi#watch()
endif
