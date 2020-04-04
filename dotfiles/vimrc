set nocompatible              " be iMproved, required
filetype off                  " required
set number
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required

"Plugin 'maralla/completor.vim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'hzchirs/vim-material'
Plugin 'ryanoasis/vim-devicons'
Plugin 'kaicataldo/material.vim'
Plugin 'henrynewcomer/vim-theme-papaya'
Plugin 'luochen1990/rainbow'
Plugin 'VundleVim/Vundle.vim'
Plugin 'arcticicestudio/nord-vim'
Plugin 'Yggdroot/indentLine'
Plugin 'Matt-Deacalion/vim-systemd-syntax'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'bash-support.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
"Plugin 'shougo/deoplete.nvim'
"Plugin 'junegunn/rainbow_parentheses.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'mtdl9/vim-log-highlighting'
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}
" Vim
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

syntax on
set t_Co=256
set cursorline

"airline themes change status/tabline for vim

"let g:airline_theme='onehalfdark'
"let g:airline_theme='material'

"+++++++++++++++++++++++++++++++++++++++++++++++++++++++

""Vim-Material Theme settings

" Dark
"
"set background=dark
"colorscheme vim-material


" Palenight

"let g:material_style='palenight'
"set background=dark
"colorscheme vim-material

" Oceanic

"let g:material_style='oceanic'
"set background=dark
"colorscheme vim-material

"----------------------------------------------
"material theme settings

"let g:material_theme_style = 'default' | 'palenight' | 'ocean' | 'lighter' | 'darker'

let g:material_terminal_italics = 0
let g:material_theme_style = 'ocean'

"----------------------------------------------

"let g:rainbow#max_level = 16
"let g:rainbow#pairs = [['(', ')'], ['[', ']']]
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
let g:ycm_use_clangd = 0

"let g:deoplete#enable_at_startup = 1
" lightline
" let g:lightline.colorscheme='onehalfdark'
" All of your Plugins must be added before the following line
call vundle#end()            " required

"colorscheme papaya
"colorscheme onehalfdark
"colorscheme vim-material
colorscheme material

filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
	"filetype plugin on
	"
	" Brief help
	" :PluginList       - lists configured plugins
	" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
	" :PluginSearch foo - searches for foo; append `!` to refresh local cache
	" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
	"
	" see :h vundle for more details or wiki for FAQ
	" Put your non-Plugin stuff after this line


if (has('termguicolors'))
  set termguicolors
endif

"if exists('+termguicolors')
 " let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  "let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  "set termguicolors
"endif	" 
"if (has("termguicolors"))
 " set termguicolors
"endif

""This section refers to completer plugin
""Every line has double quotes is a code line 
"" Use TAB to complete when typing words, else inserts TABs as usual.  Uses
" dictionary, source files, and completor to find matching words to complete.

" Note: usual completion is on <C-n> but more trouble to press all the time.
" Never type the same word twice and maybe learn a new spellings!
" Use the Linux dictionary when spelling is in doubt.
""function! Tab_Or_Complete() abort
  " If completor is already open the `tab` cycles through suggested completions.
  ""if pumvisible()
    ""return "\<C-N>"
  " If completor is not open and we are in the middle of typing a word then
  " `tab` opens completor menu.
  ""elseif col('.')>1 && strpart( getline('.'), col('.')-2, 3 ) =~ '^[[:keyword:][:ident:]]'
    ""return "\<C-R>=completor#do('complete')\<CR>"
  ""else
    " If we aren't typing a word and we press `tab` simply do the normal `tab`
    " action.
    ""return "\<Tab>"
  ""endif
"endfunction

" Use `tab` key to select completions.  Default is arrow keys.
""inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
""inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Use tab to trigger auto completion.  Default suggests completions as you type.
""let g:completor_auto_trigger = 0
""inoremap <expr> <Tab> Tab_Or_Complete()

"------------------------------------------------

"NerdTree settings
"
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

"map a specific key or shortcut to open NERDTree
map <C-n> :NERDTreeToggle<CR>

"open a NERDTree automatically when vim starts up
autocmd vimenter * NERDTree


"close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')
