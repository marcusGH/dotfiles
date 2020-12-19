" ############################
" # Vim Plug package manager #
" ############################

call plug#begin('~/.vim/plugins')

" fzf, fuzzy file finder
Plug 'junegunn/fzf'
" startify, nicer splash screen
Plug 'mhinz/vim-startify'
" colour scheme
Plug 'arcticicestudio/nord-vim'

" seamless navigation between vim splits and awesomeWM clients
Plug 'intrntbrn/awesomewm-vim-tmux-navigator'

" vim snipmate, giving <tab> autocomplete functionality
Plug 'MarcWeber/vim-addon-mw-utils'	" \
Plug 'tomtom/tlib_vim'				" |-- Required
Plug 'garbas/vim-snipmate'			" /
Plug 'honza/vim-snippets'			" -- provides base snippets " vimtex, compile latex from within vim
Plug 'lervag/vimtex'

" delimmate, automatically end delimeters like (
Plug 'Raimondi/delimitMate'

" tcomment, comment lines and selections
Plug 'tomtom/tcomment_vim'

" gitgutter, see git changes as you edit
" Plug 'airblade/vim-gitgutter'

" ????, simple status screen
Plug 'vim-airline/vim-airline'

" vimwiki, create your own personal wiki pages

" repeat, gives nice dot commands to other plugins
Plug 'tpope/vim-repeat'

" easyclip, only modify clipboard with m and y
Plug 'svermeulen/vim-easyclip'
Plug 'svermeulen/vim-yoink'

" sneak, s<key1><key2>. Use cl for s and cc for S
Plug 'justinmk/vim-sneak'

" vimwiki, own personal wiki and todo lists
Plug 'vimwiki/vimwiki'

" easyescape, press jk and kj to exit insert mode
Plug 'zhou13/vim-easyescape'

call plug#end()


" #################### delimitMate #####################

let g:delimitMate_expand_cr = 1

" #################### easyescape ######################

let g:easyescape_chars = { "j": 1, "k": 1 }
let g:easyescape_timeout = 300
cnoremap jk <ESC>
cnoremap kj <ESC>

" ##################### latex ##########################

let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

" ##################### statusline ######################

let g:airline_detect_spell=0
let g:airline_detect_spelllang = 0


" ##################### search #########################

" ignore case when searching unless
" some characters are capitalised 
set ignorecase
set smartcase

" highlight search matches until space is pressed
set hlsearch
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
" pressing enter after search searches again with
" spaces replaced by arbitrary whitespace. This
" only happens in latex source files
autocmd BufRead,BufNewFile *.tex cnoremap <expr><Space> '/?' =~ getcmdtype() ? '\_s\+' : ' '

" ################# lines and cursor ###################

" show line numbers
set number

" highlight current line
set cursorline

" use relative line numbers (causes some lag?)
" set relativenumber

" #################### tabs ############################

set tabstop=4 softtabstop=0
set shiftwidth=4
set expandtab smarttab

set list listchars=tab:\>\ ,trail:%

" #################### gitgutter #######################


set updatetime=500
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

" ##################### easyclip #######################

" remap mark key
nnoremap gm m

" autoformat pastes and toggle with /cf
let g:yoinkAutoFormatPaste=1
nmap <leader>cf <plug>(YoinkPostPasteToggleFormat)
nmap M <Plug>MoveMotionEndOfLinePlug

" cycle through yanks after pasting
nmap <c-n> <plug>(YoinkPostPasteSwapBack)
nmap <c-p> <plug>(YoinkPostPasteSwapForward)

nmap p <plug>(YoinkPaste_p)
nmap P <plug>(YoinkPaste_P)

" use the + register by default for yanking
set clipboard=unnamedplus
let g:yoinkSyncSystemClipboardOnFocus=1

" ##################### sneak ##########################

map s <Plug>Sneak_s
map S <Plug>Sneak_S

" set highlight colours to nord
autocmd VimEnter * hi! link Sneak Search

" use smartcase
let g:sneak#use_ic_scs = 1

" ################## colour scheme #####################

" enable syntax highlighting
" syntax on

" make comments brighter
augroup nord-overrides
    autocmd!
    autocmd ColorScheme nord highlight Comment ctermfg=14
augroup END

" italic comments
set t_ZH=[3m
set t_ZR=[23m
autocmd VimEnter * highlight Comment cterm=italic

" set the colour scheme to nord
colorscheme nord

" remove underline from current line number
hi CursorLineNr NONE

" ##################### vimwiki #########################

" use markdown
let g:vimwiki_list = [{'path': '~/vimwiki/', 'index': 'README',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

" change indentation for markdown documents
autocmd FileType markdown setlocal shiftwidth=2 tabstop=2

" ##################### vimwiki #########################
nnoremap <Leader>o :FZF <CR>
let g:fzf_colors = 
            \ { 'fg':      ['fg', 'Normal'],
            \ 'bg':      ['bg', 'Normal'],
            \ 'hl':      ['fg', 'Comment'],
            \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
            \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
            \ 'hl+':     ['fg', 'Statement'],
            \ 'info':    ['fg', 'PreProc'],
            \ 'border':  ['fg', 'Ignore'],
            \ 'prompt':  ['fg', 'Conditional'],
            \ 'pointer': ['fg', 'Exception'],
            \ 'marker':  ['fg', 'Keyword'],
            \ 'spinner': ['fg', 'Label'],
            \ 'header':  ['fg', 'Comment'] }
" #################### miscellaneous ####################

" make vim auto-detect filetypes
filetype plugin indent on

" prerequisites for vimwiki
set nocompatible

" no idea what this does, but it fixes a bug causing
" strange "<4;2m" characters to appear
let &t_TI = ""
let &t_TE = ""

" fix backspace key
set backspace=indent,eol,start

" count number of words in latex documents or
" visual selection with :WC and :'<,'>WC
function! WC()
    let filename = expand("%")
    let cmd = "detex " . filename . " | wc -w | tr -d [:space:]"
    let result = system(cmd)
    echo result . " words"
endfunction
command! -range=% WC <line1>,<line2>w !detex | wc -w

" take a screenshot and paste result into latex at cursor
function! LatexScreenshot(name)
    if !(len(a:name) == 0)
        let wait = system('latexScreen ' . expand('%:p:h') . " " . a:name)
        normal p
    endif
endfunction
nnoremap <Leader>ls :call LatexScreenshot(input('Image name: '))<CR>

" spell checking, use z= in normal and <C-X>s
" (+ <C-N>, <C-p> to cycle) in insert mode
set spelllang=en_gb
set spell

" scrolloff, always show some stuff above/below cursor
set scrolloff=10
set sidescrolloff=30

" auto source .bash_profile to get caps-lock escape
set shell=bash\ -l

" speed up vim a bit
set lazyredraw
