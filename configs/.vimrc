set noerrorbells 
set nocompatible
set backspace=indent,eol,start

set laststatus=2 " always show the status line
set statusline=%20F%m%r%h%w\ [t:%Y]\ [c:=\%03.3b]\ [p:=%l:%v][%02p%%]\ [l:%L]

set history=400
set ruler
set showcmd
set incsearch


"set cpoptions+=I

set ts=4
set sw=4
"set expandtab
set number

syntax on

filetype plugin indent on


set autoindent


set copyindent
set preserveindent
set smarttab

if $LANG =~ 'KOI'
    set langmap=�q,�a,�z,�w,�s,�x,�e,�d,�c,�r,�f,�v,�t,�g,�b,�y,�h,�n,�u,�j,�m,�i,�k,�\,,�o,�l,�.,�p
elseif $LANG =~ 'UTF'
map ё `
map й q
map ц w
map у e
map к r
map е t
map н y
map г u
map ш i
map щ o
map з p
map х [
map ъ ]
map ф a
map ы s
map в d
map а f
map п g
map р h
map о j
map л k
map д l
map ж ;
map э '
map я z
map ч x
map с c
map м v
map и b
map т n
map ь m
map б ,
map ю .
map Ё ~
map Й Q
map Ц W
map У E
map К R
map Е T
map Н Y
map Г U
map Ш I
map Щ O
map З P
map Х {
map Ъ }
map Ф A
map Ы S
map В D
map А F
map П G
map Р H
map О J
map Л K
map Д L
map Ж :
map Э "
map Я Z
map Ч X
map С C
map М V
map И B
map Т N
map Ь M
map Б <
map Ю >
endif

set mouse=a
set showbreak=>>>
set shiftround
set nowrap

colorscheme delek


" Use the dictionary completion
"
set complete-=k complete+=k

filetype on

"set cf " enable error files and error jumping

set clipboard+=unnamed " turns out I do like is sharing windows clipboard
set viminfo+=! " make sure it can save viminfo
set isk+=_,$,@,%,#,- " none of these should be word dividers, so make them not be

set backup 
set backupdir=~/.vim/b-cups
set directory=~/.vim/temp

set lsp=0 " space it out a little more (easier to read)
set ruler " Always show current positions along the bottom 
set lazyredraw " do not redraw while running macros (much faster)
set hid " you can change buffer without saving
set backspace=2 " make backspace work normal
set whichwrap+=<,>,h,l  " backspace and cursor keys wrap to
set shortmess=atI " shortens messages to avoid 'press a key' prompt 
set report=0 " tell us when anything is changed via :...
" make the splitters between windows be blank
set fillchars=vert:\ ,stl:\ ,stlnc:\

set showmatch " show matching brackets
set mat=5 " how many tenths of a second to blink matching brackets for
set nohlsearch " do not highlight searched for phrases
set incsearch " BUT do highlight as you type you search phrase
"set listchars=tab:\|\ ,trail:.,extends:>,precedes:<,eol:$ " what to show when I hit :set list
set so=3 " Keep 10 lines (top/bottom) for scope

"set fo=tcrqn " See Help (complex)
set ai " autoindent
set si " smartindent 
"set cindent " do c-style indenting

set wildmenu
set wildcharm=<Tab>

menu Encoding.koi8-r   :e ++enc=koi8-r<CR>
menu Encoding.windows-1251 :e ++enc=cp1251<CR>
menu Encoding.ibm-866      :e ++enc=ibm866<CR>
menu Encoding.utf-8                :e ++enc=utf-8 <CR>
map <silent><F1> :emenu Encoding.<TAB>

menu Swapping.enable	:set backup
menu Swapping.disable   :set nobackup
map <silent><F11> :emenu Swapping.<TAB>


nmap @t :set listchars=tab:>-,trail:~<CR>:set list!<CR>

nmap <Space> <C-d>
"nmap <F10> :qa<cr>
nmap <F4> :q<cr>

nmap <F2> :update<CR>
vmap <F2> <ESC><F2>gv
imap <F2> <C-o><F2>

nmap <F3> :set paste!<cr>:set paste?<cr>

nmap <C-Left>  g-
nmap <C-Right> g+
nmap <C-Down> j<C-E>
nmap <C-Up> k<C-Y>
nmap <C-j> j<C-E>
nmap <C-k> k<C-Y>

map gf :tabe <cfile><CR>

imap <silent><c-f> <c-o>w
imap <silent><c-b> <c-o>b
imap <silent><c-h> <c-o>h
imap <silent><c-j> <c-o>j
imap <silent><c-k> <c-o>k
imap <silent><c-l> <c-o>l

function My_next_file()
        tabn
endfunction

function My_prev_file()
        tabp
endfunction


nmap <silent><C-h> :call My_prev_file()<cr>
nmap <silent><C-l> :call My_next_file()<cr>

function SmartReturn()
    let col = col('.') - 1
    let line = getline('.')
    let char_before = line[col-1]
    let char_current = line[col]
    if (char_before == '(' && char_current == ')') || (char_before == '{' && char_current == '}')
        return "\<CR>\<ESC>ko"
    else
        return "\<CR>"
    endif
endfunction

inoremap <silent><CR> <c-r>=SmartReturn()<cr>


function Compile()
	let cmd=''
endfunction

function CheckSyntax()
	if &filetype != ''
		let cmd=''
		if &filetype == 'perl'
			let cmd='perl -w -MO=Lint,no-context '
		elseif &filetype == 'c'
			let cmd='gcc -fsyntax-only -pedantic '
		elseif &filetype == 'sh'
			let cmd='bash -n '
		elseif &filetype == 'cpp'
			let cmd='gcc -fsyntax-only -pedantic '
		endif

		if cmd != ''
			let output = system(cmd.expand('%'))
			echo strpart(output, 0, strlen(output)-1)
		else
			echo 'Have no idea how to check syntax for filetype '.&ft
		endif
	else
		echo 'unknown file type or filetype plugin not loaded'
	endif
endfunction

map  <silent><F9> :call CheckSyntax()<CR>
imap <silent><F9> :call CheckSyntax()<CR>
vmap <silent><F9> :call CheckSyntax()<CR>

function SvnDiff()
	let output = system("svn diff " . expand('%'))
	tabe 
	set ft=diff
	set buftype=nofile
	call append(0,split(output, '\n'))
	call setpos('.', [ 0, 1, 1, 0 ])
endfunction

map  <silent><F5> :call SvnDiff()<CR>
imap <silent><F5> <c-o>:call SvnDiff()<CR>


map  <silent><F7> :! sudo build_deb > /tmp/1 2>&1 &<CR><CR>
imap <silent><F7> :! sudo build_deb > /tmp/1 2>&1 &<CR><CR>
vmap <silent><F7> :! sudo build_deb > /tmp/1 2>&1 &<CR><CR>

map <silent><F8> :MRU <CR>

function StyleCheck()
	let output = system("/home/bolshakoff/yabs/trunk/t/perl_style_check.pl " . expand('%'))
	split_f
	set buftype=nofile
	call append(0,split(output, '\n'))
	call setpos('.', [ 0, 1, 1, 0 ])
endfunction

map  <silent><F10> :call StyleCheck()<CR>
imap <silent><F10> <c-o>:call StyleCheck()<CR>

map <silent><F12> :vsplit<CR> 

highlight MatchParen ctermbg=blue guibg=lightblue

nnoremap <silent> <F6> :let b:show_spaces=!b:show_spaces<CR>:call UpdateSpacesSettings()<CR>:echo b:show_spaces<cr>

autocmd BufNewFile,BufRead *.p? compiler perl

set foldmethod=indent
set foldlevel=100


:syntax keyword MyGroup cout
:highlight MyGroup ctermfg=green
