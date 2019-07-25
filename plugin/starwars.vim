command! -nargs=? -complete=customlist,starwars#complete StarWars call starwars#play(<f-args>)
