let s:dir = expand('<sfile>:h:h') . '/resources/'
function! s:play(...) abort
  let l:ep = get(a:000, 0, 1)
  echomsg 'Loading...'
  let l:height = 13
  let l:frames = []
  let l:lines = readfile(printf('%s/sw%d.txt', s:dir, l:ep))
  for l:i in range(0, len(l:lines)-1, l:height+1)
    if l:i%(l:height+1) == 0
      let l:duration = 0 + l:lines[i]
      call add(l:frames, {'lines': l:lines[l:i+1 : i+l:height], 'duration': l:duration})
    endif
  endfor
  unlet l:lines
  redraw
  echo ''
  new | only! | setlocal buftype=nofile bufhidden=wipe
  let l:speed = 15
  for l:frame in l:frames
    call setline(1, l:frame['lines'])
    redraw!
    let l:duration = max([l:frame['duration'] * 1000 / l:speed, 1])
    exe printf('sleep %dms', l:duration)
    let l:key = getchar(0)
    if l:key == 106
      if l:speed > 1
        let l:speed += 1
      endif
    elseif l:key == 107
      let l:speed -= 1
    elseif l:key != 0
      break
    endif
  endfor
  bw!
endfunction

command -nargs=? StarWars call s:play(<f-args>)
