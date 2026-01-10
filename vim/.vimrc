"IMPOSTAZIoni di base------------------------------{{{

"Imposta come registro predefinito quello di sistema
set clipboard=unnamedplus

" Disabilita la compatibilità con vi che può causare problemi inaspettati.
set nocompatible

" Abilita il rilevamento del tipo di file. 
filetype on

" Abilita i plugin e carica i plugin per il tipo di file rilevato.
filetype plugin on

" Carica il file di indentazione per il tipo di file rilevato.
filetype indent on
"Abilta l'evidenziazione della sintassi.
syntax on

"indentazione da 4 spazi
set tabstop=4
set shiftwidth=4

" Aggiungi i numeri a ciascuna riga nella parte sinistra.
set number

" Mostra la parte del comando che digiti nell'ultima riga dello schermo.
set showcmd

" Mostra la modalità nella quale ti trovi nell'ultima riga.
set showmode

" Mostra le parole corrispondenti durante una ricerca.
set showmatch

" Usa l'evidenziazione durante una ricerca.
set hlsearch

" Imposta il numero di comandi da salvare nella cronologia (default è 20).
set history=100

" Abilita il menu di auto completamento quando digiti TAB.
set wildmenu

colorscheme default

" Rende il comportamento di wildmenu simile a quello del completamento in Bash.
set wildmode=list:longest

" Ci sono alcuni file che non vogliamo mai editare in Vim.
" Wildmenu ignorerà i file con queste estensioni.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
"}}}

""PLUGINS--------------------------------{{{			
"call plug#begin('~/.vim/plugged') 
"  Plug 'vim-airline/vim-airline'
"  Plug 'vim-airline/vim-airline-themes'
"  Plug 'jasonccox/vim-wayland-clipboard'
"call plug#end()
""}}}

"VIMSCRIPT-----------------------------------------{{{
" Questo abilita la piegatura del codice.
" Usa il metodo di marcatura (marker) per la piegatura.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
"}}}

"MAPPINGS-----------------------------------------{{{

"mappa il tasto jj come <esc> in modalità insert
inoremap jj <Esc>

"quicksave command
noremap <C-s> :update<CR>
inoremap <C-s> <Esc>:update<CR>a

"quicksave command
noremap <C-s> :update<CR>
inoremap <C-s> <Esc>:update<CR>a

"delete highlighted search
noremap <C-n> :nohl<CR>

"rimane in modalità visual mentre indento blocchi di codice
vnoremap < <gv 
vnoremap > >gv

"}}}

"STATUSLINE--------------------------------------{{{
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%Y-%m-%d\ %H:%M:%S\ %Z\")}

"}}}
