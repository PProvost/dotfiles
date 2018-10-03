"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" .vimrc
" Author: Peter Provost <http://www.github.com/PProvost>
" Credits: Too many to list
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use vim settings rather than vi settings (must be first line)
set nocompatible

" put my .vim first, then the vim install, then the after directory (for overrides)
set runtimepath=~/.vim,$VIMRUNTIME,~/.vim/after

" enable clipboard and other Win32 features
" source $VIMRUNTIME/mswin.vim

" Use pathogen.vim to manage and load plugins
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" appearance options
let g:Powerline_cache_file = expand('$TMP/Powerline.cache')

if has("gui_running")
	set background=dark
	set t_Co=256	" enable 256 color mode for colorschemes that use them
	set columns=100
	set lines=45
	set guifont=Consolas:h11:cANSI,Lucida\ Console,Courier\ New,System
	set guioptions-=T " No toolbar
	" colorscheme solarized
	colorscheme slate
else
	set background=dark
	colorscheme slate
endif

" Platform specific stuff
if has("win32") || has("win64") || has("windows")
	set directory=$TMP
else
	set directory /tmp
endif

" Allow backspacing over everything
set backspace=indent,eol,start

" Misc vim configuration tweaks
set nobackup
set nowritebackup
set nowrap
set history=50
set number ruler
set incsearch
set autoindent
set hlsearch
set encoding=utf-8
set nomodeline " turn off file specific modeline instruction parsing
set tabstop=2 " tab size = 2
set shiftwidth=2 " soft space = 2
set smarttab
set wildchar=9 " tab as completion character
set showcmd
set showmatch " Show matching braces.
set visualbell

" Allow selections beyond EOL when in block mode
" (Since we load the mswin.vim file above, enter block mode with C-Q)
set virtualedit=block

" Use the windows clipboard for the unnamed register (default yanks, etc)
set clipboard+=unnamed

" Custom status line text
set laststatus=2 " Always show the status line

"Use Q for formatting (no Ex mode)
map Q gq

"Disable middle mouse button pasting
map <MiddleMouse> <Nop>
map! <MiddleMouse> <Nop>

" Setup syntax highlighting
syntax on
syntax sync fromstart
filetype plugin indent on

