set rtp+="$POWERLINE_PATH/bindings/vim"
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

" Always show vim
set laststatus=2

" Use the 256 colours
set t_Co=256

set hlsearch
map <F5> :set hlsearch!<CR>
map <F6> :set number!<CR>
