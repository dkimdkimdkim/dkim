"Add the following line to the beginning of your ~/.vimrc:
"source ~/git/dkim/vimrc

set showcmd

syntax on
filetype indent on
set autoindent
set lbr
set tabstop=4
set shiftwidth=4
set expandtab
set nu
"set mouse=a

set hlsearch

set shiftround

set title
set nobackup
set noswapfile

filetype plugin indent on
set pastetoggle=<F2>

set clipboard=unnamedplus

vnoremap <D-c> "*y

if !(&filetype == "txt")
  highlight WhiteSpaces ctermbg=green guibg=#55aa55
  match WhiteSpaces /\s\+$/
endif

nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

function! NumberToggle()
  if(&relativenumber == 1)
    set number
  else
    set relativenumber
  endif
endfunc

nnoremap <C-n> :call NumberToggle()<cr>
set backspace=indent,eol,start

"augroup CursorLine
"  au!
"  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
"  au WinLeave * setlocal nocursorline
"augroup END

if exists('+colorcolumn')
  set colorcolumn=80
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

let &colorcolumn="80,".join(range(120,999),",")

highlight ColorColumn ctermbg=8

set ignorecase
set smartcase
set incsearch
