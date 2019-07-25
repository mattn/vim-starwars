scriptencoding utf-8

let s:dir = expand('<sfile>:h:h') . '/resources/'
let s:episodes = map(glob(s:dir . '/*.txt', 1, 1), 'fnamemodify(v:val, ":t:r")')

function! starwars#play(...) abort
  if a:0 == 0 && exists('*popup_create')
    call s:show_popup(s:episodes)
    return
  endif
  let l:ep = a:1
  echomsg 'Loading...'
  let l:height = 13
  let l:frames = []
  let l:lines = readfile(printf('%s/%s.txt', s:dir, l:ep))
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

function! s:popup_menu_update(wid, ctx) abort
  let l:buf = winbufnr(a:wid)
  let l:menu = map(copy(a:ctx.menu), '(v:key == a:ctx.select ? "→" : "  ") .. v:val')
  call setbufline(l:buf, 1, l:menu)
endfunction

function! s:popup_filter(ctx, wid, c) abort
  if a:c ==# 'j'
    let a:ctx.select += a:ctx.select ==# len(a:ctx.menu)-1 ? 0 : 1
    call s:popup_menu_update(s:wid, a:ctx)
  elseif a:c ==# 'k'
    let a:ctx.select -= a:ctx.select ==# 0 ? 0 : 1
    call s:popup_menu_update(s:wid, a:ctx)
  elseif a:c ==# "\n" || a:c ==# "\r" || a:c ==# ' '
    call popup_close(a:wid)
    call starwars#play(a:ctx.menu[a:ctx.select])
  elseif a:c ==# "\x1b"
    call popup_close(a:wid)
    return 0
  endif
  return 1
endfunction

function! s:show_popup(menu) abort
  let l:ctx = {'select': 0, 'menu': a:menu}
  let s:wid = popup_create(a:menu, {
        \ 'border': [1,1,1,1],
        \ 'filter': function('s:popup_filter', [l:ctx]),
        \})
  call s:popup_menu_update(s:wid, l:ctx)
endfunction

function! starwars#menu() abort
endfunction

function! starwars#complete(arglead, cmdline, cursorpos)
  return filter(copy(s:episodes), 'stridx(v:val, a:arglead)==0')
endfunction
