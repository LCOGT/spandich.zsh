set nocompatible

set history=100

set paste

" color
set t_Co=256
"set t_AB=^[[48;5;%dm
"set t_AF=^[[38;5;%dm

syntax on 
filetype on
filetype plugin on 
filetype indent on 

" set number

" Search
set ignorecase
set smartcase
set hlsearch
set incsearch
set wrapscan

set isfname-==

"indent stuff 
set tabstop=2
set shiftwidth=2
set expandtab
set cindent
set smartindent
set autoindent
set softtabstop=2

set showmatch
set showcmd
set showmode

set visualbell
set backspace=indent,eol,start

"Cmd and status line stuff
set cmdheight=2
"set statusline=%f\ %m\ %r\ Line:%l/%L[%p%%]\ Col:%c\ Buf:%n\ [%b][0x%B]
set statusline=%f\ [%M%R]\ %y\%=Line:%l/%L[%p%%]\ Col:%c\ 
set laststatus=2 " Always show status line

"gui options
set mousehide
set guioptions=acegr
"set guioptions=ac
"set guioptions=egmrLtT

set cpoptions=aAcefFPs$
"set cpoptions=ces$
"set cpoptions=aABceFs

"fold options
set foldopen=block,insert,jump,mark,percent,quickfix,search,tag,undo

"invisibles 
"set listchars=eol:¬,tab:›\  
"set list

set scrolloff=8
""set textwidth=120

set fillchars=

" disable encryption
set key=

"completion
set wildmenu
set wildmode=longest:full,full
set complete=.,w,b,t,i,k
set showfulltag

set diffopt+=iwhite
set path+=~/dev/working/**

abbreviate teh the

set path=$PWD/**

let NERDTreeIgnore=['.*\.iml'] 
 
" Show the bookmarks table on startup
let NERDTreeShowBookmarks=1


nmap <silent> <Char-92> :silent nohls<CR>
map  <silent> ,nt :NERDTreeToggle<CR>

nmap <silent> ,ev :e $MYVIMRC<CR>
nmap <silent> ,sv :so $MYVIMRC<CR>

nnoremap ,ff :FufFile <cr>
nnoremap ,fd :FufDir <cr>
nnoremap ,fw :FufFile **/<cr>



colorscheme phd
highlight SpecialKey  term=bold ctermfg=7 guifg=grey30
highlight NonText     term=bold ctermfg=7 guifg=grey30 guibg=NONE

if &term=="xterm" || &term=="xterm-color"
     set t_Co=8
     set t_Sb=^[4%dm
     set t_Sf=^[3%dm
     :imap <Esc>Oq 1
     :imap <Esc>Or 2
     :imap <Esc>Os 3
     :imap <Esc>Ot 4
     :imap <Esc>Ou 5
     :imap <Esc>Ov 6
     :imap <Esc>Ow 7
     :imap <Esc>Ox 8
     :imap <Esc>Oy 9
     :imap <Esc>Op 0
     :imap <Esc>On .
     :imap <Esc>OQ /
     :imap <Esc>OR *
     :imap <Esc>Ol +
     :imap <Esc>OS -
endif

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
