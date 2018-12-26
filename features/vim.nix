# inspired by https://www.mpscholten.de/nixos/2016/04/11/setting-up-vim-on-nixos.html
  
with import <nixpkgs> {};

vim_configurable.customize {
    name = "vim";
    vimrcConfig.customRC = ''
        " Sets how many lines of history VIM has to remember
        set history=500

        " Enable filetype plugins
        filetype plugin on
        filetype indent on

        " Set to auto read when a file is changed from the outside
        set autoread

        " :W sudo saves the file 
        " (useful for handling the permission-denied error)
        command W w !sudo tee % > /dev/null

        "Always show current position
        set ruler

        " Height of the command bar
        set cmdheight=2

        " A buffer becomes hidden when it is abandoned
        set hid

        " Configure backspace so it acts as it should act
        set backspace=eol,start,indent
        set whichwrap+=<,>,h,l

        " Ignore case when searching
        set ignorecase

        " When searching try to be smart about cases 
        set smartcase

        " Highlight search results
        set hlsearch

        " Makes search act like search in modern browsers
        set incsearch 

        " Show matching brackets when text indicator is over them
        set showmatch 
        " How many tenths of a second to blink when matching brackets
        set mat=2

        " No annoying sound on errors
        set novisualbell

        " Enable syntax highlighting
        syntax enable 

        " Set utf8 as standard encoding and en_US as the standard language
        set encoding=utf8

        " Use Unix as the standard file type
        set ffs=unix,dos,mac

        " Turn backup off, since most stuff is in SVN, git et.c anyway...
        set nobackup
        set nowb
        set noswapfile


        " Use spaces instead of tabs
        set expandtab

        " Be smart when using tabs ;)
        set smarttab

        " 1 tab == 2 spaces
        set shiftwidth=2
        set tabstop=2

        " Linebreak on 500 characters
        set lbr
        set tw=500

        set ai "Auto indent
        set si "Smart indent
        set wrap "Wrap lines

        " Always show the status line
        set laststatus=2

        " Format the status line
        set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
    '';
}
