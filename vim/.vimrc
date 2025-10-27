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

"imposta colonna colorata a riga 80
set colorcolumn=80

"imposta i numeri realivi
"set relativenumber

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

set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%Y-%m-%d\ %H:%M:%S\ %Z\")}

"}}}

"PLUGINS--------------------------------{{{
call plug#begin('~/.vim/plugged') 

  Plug 'jceb/vim-orgmode'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

" Code completion
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
" file system navigation 
  Plug 'preservim/nerdtree'
" nerdtree filetype highliting
  Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
 
" plug per l'integrazione dei comandi di gradle in vim
  Plug 'hdiniz/vim-gradle'

"plug per il copia e incolla su wayland
  Plug 'jasonccox/vim-wayland-clipboard'

" plug per facilitare l'uso di snippets predefiniti
" in questo momento usato per generare javadoc
Plug 'SirVer/ultisnips'
" Dipendenza consigliata per autocompletamento (se vuoi)
Plug 'honza/vim-snippets' " Questo include snippet predefiniti per vari linguaggi, incluso Java

" plug per l'interfaccia di debugging 
" da studiare bene ancora
  Plug 'puremourning/vimspector'

call plug#end()

"}}}

"impostazioni coc ---------------------------{{{

" May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
" utf-8 byte sequence
set encoding=utf-8

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" *** Spostiamo CheckBackspace() qui, prima della mappatura del TAB ***
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

" Mappatura per <TAB>:
" 1.Se la finestra di completamento (PUM) è visibile, usa <Tab> per navigare al suggerimento successivo.
" 2.Altrimenti, se siamo all'inizio della riga o dopo uno spazio, inserisci un TAB normale (per indentazione).
" 3.Altrimenti (se hai appena digitato un carattere), ricarica i suggerimenti di CoC.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

" Mappatura per <CR> (Invio):
" 1. Se la finestra di completamento (PUM) è visibile, conferma il suggerimento corrente.
" 2. Altrimenti, inserisci un normale Invio (newline).
inoremap <expr><cr> pumvisible() ? coc#_select_confirm() : "\<CR>"

" Mappatura per <S-Tab>:
" 1. Se la finestra di completamento (PUM) è visibile, naviga al suggerimento precedente.
" 2. Altrimenti, se c'è un placeholder precedente nello snippet, salta indietro.
" 3. Altrimenti, esegui un backspace (comportamento predefinito per S-Tab se non gestito).
inoremap <silent><expr> <S-TAB>
      \ coc#pum#visible() ? coc#pum#prev(1) :
      \ "\<C-h>" " <--- Questo è un backspace

" Funzione ShowDocumentation (spostata qui per completezza del blocco CoC)
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent><nowait> [g <Plug>(coc-diagnostic-prev)
nmap <silent><nowait> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent><nowait> gd <Plug>(coc-definition)
nmap <silent><nowait> gy <Plug>(coc-type-definition)
nmap <silent><nowait> gi <Plug>(coc-implementation)
nmap <silent><nowait> gr <Plug>(coc-references)
"
" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

"}}}

"impostazioni nerdtree ------{{{

" Open when no files were speficied on vim launch
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Chiudi Vim se l'unica finestra rimasta è NerdTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.is_visible()) | q | endif
"}}}

"impostazione ultisnips-----{{{

" Tasto per espandere lo snippet (es. Ctrl + Spazio)
let g:UltiSnipsExpandTrigger = '<c-space>'

" Tasto per saltare avanti tra i placeholder (es. Ctrl + f)
let g:UltiSnipsJumpForwardTrigger = '<c-f>'

" Tasto per saltare indietro tra i placeholder (es. Ctrl + b)
let g:UltiSnipsJumpBackwardTrigger = '<c-b>'

" Se vuoi un nome autore predefinito nei tuoi snippet
let g:snips_author_name = "steppasecca"

"}}}

"VIMSCRIPT-----------------------------------------{{{
" Questo abilita la piegatura del codice.
" Usa il metodo di marcatura (marker) per la piegatura.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" Se la versione di Vim è maggiore/uguale a 7.3 abilita undofile.
" Questo ti consente di ripristinare le modifiche a un file anche dopo averlo salvato.
if version >= 703
    set undodir=~/.vim/backup
    set undofile
    set undoreload=10000
endif

"}}}

"MAPPINGS-----------------------------------------{{{

"mappa il tasto jj come <esc> in modalità insert
inoremap jj <Esc>

" Mappa il tasto F5 per eseguire uno script Python all'interno di Vim.
" Qui mappo F5 a una catena di comandi.
" :w salva il file.
" <CR> (carriage return) è come premere ENTER.
" !clear esegue il comando esterno clear screen per pulire lo schermo.
" !python3 % esegue con Python il file corrente.
nnoremap <f5> :w <CR>:!clear <CR>:!python3 % <CR>

"quicksave command
noremap <C-s> :update<CR>
inoremap <C-s> <Esc>:update<CR>a

"delete highlighted search
noremap <C-n> :nohl<CR>

"tasti per muoversi fra le finestre
map <leader>j  <C-w>j
map <leader>k <C-w>k
map <leader>l <C-w>l
map <leader>h <C-w>h

"tasti per fare il resize delle window
map <leader>+ <C-w>+
map <leader>- <C-w>-
map <leader>< <C-w><
map <leader>> <C-w>>
"map tab navigation 
map <C-l> gt
map <C-h> gT

"rimane in modalità visual mentre indento blocchi di codice
vnoremap < <gv 
vnoremap > >gv

"Digrafi personalizzati per la Logica del Primo Ordine
"Formato digraphs XX CODICE_ESADECIMALE

" Negazione (¬) - Unicode: 00AC
imap <C-v>NG ¬

" Congiunzione (∧) - Unicode: 2227
imap <C-v>AN ∧

" Disgiunzione (∨) - Unicode: 2228
imap <C-v>OR ∨

" Implicazione (→) - Unicode: 2192
imap <C-v>IM →

" Doppia implicazione (↔) - Unicode: 2194
imap <C-v>BI ↔

" Per ogni (∀) - Unicode: 2200
imap <C-v>FA ∀

" Esiste (∃) - Unicode: 2203
imap <C-v>EX ∃

" Appartiene a (∈) - Unicode: 2208
imap <C-v>AP ∈

" Insieme vuoto (∅) - Unicode: 2205
imap <C-v>ES ∅

"<C-t>" to open nerdtree
map <C-t> :NERDTreeToggle<CR>

"mappatura tasti vimspector
nmap <leader>D <Plug>VimspectorLaunch
nmap <leader>t <Plug>VimspectorToggleBreakpoint
nmap <leader>c <Plug>VimspectorContinue
nmap <leader>s <Plug>VimspectorStepOver
nmap <leader>i <Plug>VimspectorStepInto
nmap <leader>o <Plug>VimspectorStepOut
nmap <leader>S <Plug>VimspectorStop

"}}}

"STATUSLINE--------------------------------------{{{
set laststatus=2
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%]\ %{strftime(\"%Y-%m-%d\ %H:%M:%S\ %Z\")}

"}}}
