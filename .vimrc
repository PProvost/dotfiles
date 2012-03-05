"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" .vimrc
" Author: Peter Provost <http://www.github.com/PProvost>
" Credits: Too many to list
" Usage: From your ~/.vimrc (unix/linux/mac) or your ~\_vimrc\_vimrc (Windows)
"        add the line "source $HOME/.vim/.vimrc"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use vim settings rather than vi settings (must be first line)
set nocompatible

" put my .vim first, then the vim install, then the after directory (for overrides)
set runtimepath=~/.vim,$VIMRUNTIME,~/.vim/after

" enable clipboard and other Win32 features
source $VIMRUNTIME/mswin.vim

" Use pathogen.vim to manage and load plugins
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" appearance options
set bg=dark
let g:zenburn_high_Contrast = 1
let g:liquidcarbon_high_contrast = 1
let g:molokai_original = 1
let g:Powerline_cache_file = expand('$TMP/Powerline.cache')
set t_Co=256
colorscheme slate

if has("gui_running")
   " set default size
   set columns=100
   set lines=45

   " No menus and no toolbar
   " set guioptions-=m
   set guioptions-=T
endif

" Platform specific stuff like fonts, temp dir, etc.
if has("win32") || has("win64")
  set guifont=Consolas:h11:cANSI,Lucida\ Console,Courier\ New,System
  set directory=$TMP
  if !has("gui_running")
    colorscheme slate
    let &guioptions = substitute(&guioptions, "t", "", "g")
  end
else
  set directory /tmp
endif

" Allow backspacing over everything
set backspace=indent,eol,start

" Misc vim configuration tweaks
set nobackup
set nowrap
set history=50
set number ruler
set incsearch
set autoindent
set hlsearch
set modeline
set tabstop=2 " tab size = 2
set shiftwidth=2 " soft space = 2
set smarttab
set expandtab " expand tabs
set wildchar=9 " tab as completion character
set showcmd
set showmatch " Show matching braces.

" Allow selections beyond EOL when in block mode
" (Since we load the mswin.vim file above, enter block mode with C-Q)
set virtualedit=block

" Use the windows clipboard for the unnamed register (default yanks, etc)
set clipboard+=unnamed

" Custom status line text
set laststatus=2 " Always show the status line
set statusline=
set statusline+=%-52F%h%m%r%w%y\ 
set statusline+=\ %{&ff}\ 
set statusline+=\ %{&fenc!=''?&fenc:&enc}\ 
set statusline+=\ %24{fugitive#statusline()}\ 
" set statusline=%<%F%h%m%r%h%w%y\ %{&ff}\ %{strftime(\"%c\",getftime(expand(\"%:p\")))}%=\ lin:%l\,%L\ col:%c%V\ pos:%o\ ascii:%b\ %P

"Use Q for formatting (no Ex mode)
map Q gq

"Disable middle mouse button pasting
map <MiddleMouse> <Nop>
map! <MiddleMouse> <Nop>

" Setup syntax highlighting
syntax on
syntax sync fromstart
filetype plugin indent on


