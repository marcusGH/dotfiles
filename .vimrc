call plug#begin('~/.vim/plugins')

" AwesomeWM navigation
Plug 'intrntbrn/awesomewm-vim-tmux-navigator'

" Custom snippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'

" Optional:
Plug 'honza/vim-snippets'

"latex plugin
Plug 'lervag/vimtex'
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

" Plug 'brennier/quicktex'
Plug 'Raimondi/delimitMate'

" A Vim Plugin for Lively Previewing LaTeX PDF Output
" Plug 'xuhdev/vim-latex-live-preview', { 'for': 'tex' }
" let g:livepreview_previewer = 'zathura'

"nice color scheme
Plug 'arcticicestudio/nord-vim'
let g:nord_cursor_line_number_background = 1

"Nice plugins
Plug 'tomtom/tcomment_vim'
"Plug 'airblade/vim-gitgutter'

"Indent guide (doesn't work for some reason)
" Plug 'nathanaelkane/vim-indent-guides'
"let g:indent_guides_guide_size = 1
"let g:indent_guides_color_change_percent = 3
"let g:indent_guides_enable_on_vim_startup = 1

" Messes up with the latex plugins, so not using it
"Plug 'Valloric/YouCompleteMe'
"let g:ycm_global_ycm_extra_conf = '~/.vim/plugins/YouCompleteMe/cpp/ycm/.ycm_extra_conf.py'

"Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'}


call plug#end()

"count words in latex documents
function! WC()
    let filename = expand("%")
    let cmd = "detex " . filename . " | wc -w | tr -d [:space:]"
    let result = system(cmd)
    echo result . " words"
endfunction

" for entire file and a range, respectively
" command WC call WC()
command! -range=% WC <line1>,<line2>w !detex | wc -w

" set up spell checking
set spelllang=en_gb
set spell

" line numbers
set number

" case search
set ignorecase
set smartcase

"Nord theme stuff
augroup nord-overrides
  autocmd!
  autocmd ColorScheme nord highlight Comment ctermfg=14
augroup END

"set colorscheme to nord
colorscheme nord

"tab length
set tabstop=4
set shiftwidth=4
