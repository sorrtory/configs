"" ------------------------------------
"" usefull tips
" :set <option>!             = disable option 
" >> / <<                    = change indents
" ctrl+x ctrl+f              = suggest file path
" Ctrl+o :norm 8ia Return    = Enter 8 "a"

"" My behaviour
" ctrl+shift + up/down       = swap lines
" ctrl+/                     = toggle comment
" brackets, quotes           = doubled after 1 press
" smart Tab                  = autocomplete (shift+Tab to choose back)
" F3                         = toggle numbers
" :w!!                       = prompt for sudo to save (type quick)
"" ------------------------------------
" Kitty support: https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim

if &term ==# "xterm-kitty"
    map <Esc>[13~ <F3>
endif

" Mouse support
set mouse=a
set ttymouse=sgr
set balloonevalterm
" Styled and colored underline support
let &t_AU = "\e[58:5:%dm"
let &t_8u = "\e[58:2:%lu:%lu:%lum"
let &t_Us = "\e[4:2m"
let &t_Cs = "\e[4:3m"
let &t_ds = "\e[4:4m"
let &t_Ds = "\e[4:5m"
let &t_Ce = "\e[4:0m"
" Strikethrough
let &t_Ts = "\e[9m"
let &t_Te = "\e[29m"
" Truecolor support
let &t_8f = "\e[38:2:%lu:%lu:%lum"
let &t_8b = "\e[48:2:%lu:%lu:%lum"
let &t_RF = "\e]10;?\e\\"
let &t_RB = "\e]11;?\e\\" " This is for color
" Bracketed paste
let &t_BE = "\e[?2004h"
let &t_BD = "\e[?2004l"
let &t_PS = "\e[200~"
let &t_PE = "\e[201~"
" Cursor control
let &t_RC = "\e[?12$p"
let &t_SH = "\e[%d q"
let &t_RS = "\eP$q q\e\\"
let &t_SI = "\e[5 q"
let &t_SR = "\e[3 q"
let &t_EI = "\e[1 q"
let &t_VS = "\e[?12L"
" Focus tracking
let &t_fe = "\e[?1004h"
let &t_fd = "\e[?1004l"
execute "set <FocusGained>=\<Esc>[I"
execute "set <FocusLost>=\<Esc>[O"
" Window title
let &t_ST = "\e[22;2t"
let &t_RT = "\e[23;2t"

" vim hardcodes background color erase even if the terminfo file does
" not contain bce. This causes incorrect background rendering when
" using a color theme with a background color in terminals such as
" kitty that do not support background color erase.
let &t_ut=''
"" ------------------------------------

"""" Basic settings
"" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

"" Trigger the following function after entering the specified mode
" Trigger NormalModeEnter() when entering Normal mode
augroup NormalModeCommands
  autocmd!
  autocmd ModeChanged *:n call NormalModeEnter()
augroup END

" Trigger InsertModeEnter() when entering Insert mode
augroup InsertModeCommands
  autocmd!
  autocmd ModeChanged *:i call InsertModeEnter()
augroup END

" Trigger VisualModeEnter() when entering Visual mode
augroup VisualModeCommands
  autocmd!
  autocmd ModeChanged *:v call VisualModeEnter()
augroup END

function! NormalModeEnter()
endfunction

function! InsertModeEnter()
endfunction

function! VisualModeEnter()
endfunction

" Enable w!! to save with sudo https://superuser.com/questions/694450/using-vim-to-force-edit-a-file-when-you-opened-without-permissions
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

"""" Appearance

"" LINENUMBERS
" Mouse copy without numbers with ctrl
set number
highlight LineNr ctermfg=grey
set cursorline
set cursorlineopt=number
highlight CursorLineNr ctermfg=white cterm=bold

" Toggle numbers by <F3> 
noremap <F3> :set number!<CR>
inoremap <F3> <C-o>:set number!<CR>
cnoremap <F3> <C-o>:set number!<CR>

""" SYNTAX
" Disable compatibility with vi which can cause unexpected issues.
set nocompatible
" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on
" Load an indent file for the detected file type.
filetype indent on
" Turn syntax highlighting on.
syntax on

"" Enable whitespace visualization
set list
" Customize how whitespace characters are shown
" ,eol:$ OR ↲
set listchars=tab:»·,trail:·,extends:›,precedes:‹,nbsp:␣
" ASCII option
" set listchars=tab:>-,trail:~

"" Lines
" Set shift width to 4 spaces.
set shiftwidth=4
" Set tab width to 4 columns.
set tabstop=4
" Use space characters instead of tabs.
set expandtab

"" Wrap lines
set textwidth=0
set wrapmargin=0
set wrap
set linebreak
"" Linebreak style
set cpo=n
" ↳
let &showbreak = '↪ '

"""" AUTOCOMPLETE
""" Tab for autocompleted
" Smart Tab in insert mode
inoremap <Tab> <C-R>=SmartTab()<CR>
inoremap <S-Tab> <C-R>=SmartS_Tab()<CR>

function! SmartTab()
    if pumvisible()
        return "\<C-n>"
    endif

    let l:col = col('.') - 1
    let l:line = getline('.')
    let l:before = l:col > 0 ? strpart(l:line, 0, l:col) : ''

    if l:before =~ '\v(\.\/|\.\.\/|\/|\w+\/)$'
        return "\<C-x>\<C-f>"
    elseif l:before =~ '\k$'
        return "\<C-n>"
    else
        return "\<Tab>"
    endif
endfunction

function! SmartS_Tab()
    if pumvisible()
        return "\<C-p>"
    else
        return "\<Tab>"
    endif
endfunction



"" BRACKETS
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

"" Backspace removes a pair
function! SmartBackspace()
  let line = getline('.')
  let col = col('.') - 1  " Current column, zero-based
  
  " Ensure we're not at the start or end of the line
  if col > 0 && col < len(line)
    let prev_char = line[col-1]  " Character before the cursor
    let next_char = line[col]    " Character at the cursor
    
    " Define valid opening and closing pairs
    let pairs = {
          \ '[' : ']',
          \ '{' : '}',
          \ '(' : ')',
          \ '<' : '>',
          \ "'" : "'",
          \ '"' : '"'
        \ }

    " Check if prev_char is an opening character and next_char is the matching closing character
    if has_key(pairs, prev_char) && next_char ==# pairs[prev_char]
      " Delete both characters if they form a valid pair
      return "\<BS>\<Del>"
    endif
  endif
  
  " If no valid pair is found, just return a normal backspace
  return "\<BS>"
endfunction

inoremap <expr> <BS> SmartBackspace()

""" COMMENTS
" ------------------------------
" ⌨️  Hotkeys (Insert, Normal, Visual)
" ------------------------------
" xterm-256color / alacritty
inoremap <C-_> <Esc>:call CommentToggleLine()<CR>gi
nnoremap <C-_> :call CommentToggleLine()<CR>
xnoremap <C-_> :<C-u>call CommentToggleBlock()<CR>

" xterm-kitty
inoremap <C-/> <Esc>:call CommentToggleLine()<CR>gi
nnoremap <C-/> :call CommentToggleLine()<CR>
xnoremap <C-/> :<C-u>call CommentToggleBlock()<CR>
" ------------------------------
" 💬 Comment String Map (can be extended in .vimrc)
" ------------------------------
let g:comment_strings = {
      \ 'python': '#',
      \ 'sh': '#',
      \ 'bash': '#',
      \ 'zsh': '#',
      \ 'yaml': '#',
      \ 'toml': '#',
      \ 'make': '#',
      \ 'dockerfile': '#',
      \ 'conf': '#',
      \ 'perl': '#',
      \ 'ruby': '#',
      \ 'vim': '"',
      \ 'lua': '--',
      \ 'sql': '--',
      \ 'c': '//',
      \ 'cpp': '//',
      \ 'objc': '//',
      \ 'java': '//',
      \ 'javascript': '//',
      \ 'typescript': '//',
      \ 'tsx': '//',
      \ 'jsx': '//',
      \ 'csharp': '//',
      \ 'rust': '//',
      \ 'go': '//',
      \ 'php': '//',
      \ 'json': '//',
      \ 'html': '<!--',
      \ 'xml': '<!--',
      \ 'css': '/*',
      \ 'scss': '/*',
      \ 'less': '/*'
      \ }

" ------------------------------
" 🔧 Get Comment String (fallback to "#")
" ------------------------------
function! GetCommentString()
    let l:ft = &filetype
    return get(g:comment_strings, l:ft, '#')
endfunction

" ------------------------------
" 🔁 Toggle Comment (Insert + Normal Mode)
" ------------------------------
function! CommentToggleLine()
    let l:comment = GetCommentString()
    let l:line = getline('.')
    let l:indent = matchstr(l:line, '^\s*')

    " HTML/XML
    if l:comment == '<!--'
        if l:line =~ '^\s*<!--'
            let l:new = substitute(l:line, '^\(\s*\)<!--\s*\(.*\)\s*-->\s*$', '\1\2', '')
        else
            let l:new = l:indent . '<!-- ' . substitute(l:line, '^\s*', '', '') . ' -->'
        endif
    " CSS-style block
    elseif l:comment == '/*'
        if l:line =~ '^\s*/\*'
            let l:new = substitute(l:line, '^\(\s*\)/\*\s*\(.*\)\s*\*/\s*$', '\1\2', '')
        else
            let l:new = l:indent . '/* ' . substitute(l:line, '^\s*', '', '') . ' */'
        endif
    " Line comment (//, #, --, etc)
    else
        let l:escaped = escape(l:comment, '/\*')
        if l:line =~ '^\s*' . l:escaped
            let l:new = substitute(l:line, '^\(\s*\)' . l:escaped . '\s*', '\1', '')
        else
            let l:new = l:indent . l:comment . ' ' . substitute(l:line, '^\s*', '', '')
        endif
    endif

    call setline('.', l:new)
endfunction

" ------------------------------
" 🔁 Toggle Comment (Visual Mode - Block)
" ------------------------------
function! CommentToggleBlock()
    let l:comment = GetCommentString()
    let l:start = line("'<")
    let l:end = line("'>")

    for l:lnum in range(l:start, l:end)
        let l:line = getline(l:lnum)
        let l:indent = matchstr(l:line, '^\s*')

        if l:comment == '<!--'
            if l:line =~ '^\s*<!--'
                let l:new = substitute(l:line, '^\(\s*\)<!--\s*\(.*\)\s*-->\s*$', '\1\2', '')
            else
                let l:new = l:indent . '<!-- ' . substitute(l:line, '^\s*', '', '') . ' -->'
            endif
        elseif l:comment == '/*'
            if l:line =~ '^\s*/\*'
                let l:new = substitute(l:line, '^\(\s*\)/\*\s*\(.*\)\s*\*/\s*$', '\1\2', '')
            else
                let l:new = l:indent . '/* ' . substitute(l:line, '^\s*', '', '') . ' */'
            endif
        else
            let l:escaped = escape(l:comment, '/\*')
            if l:line =~ '^\s*' . l:escaped
                let l:new = substitute(l:line, '^\(\s*\)' . l:escaped . '\s*', '\1', '')
            else
                let l:new = l:indent . l:comment . ' ' . substitute(l:line, '^\s*', '', '')
            endif
        endif

        call setline(l:lnum, l:new)
    endfor
endfunction


""" Move line with Ctrl+Shift+Up/Down
function! MoveToPrevLine()
    let l = line('.') - 1
    if l > 0
        let c = col('.') + 1
        execute ":m -2"
        call cursor(l, c)
    endif
endfunction

function! MoveToNextLine()
    let l = line('.') + 1
    if l <= line("$")
        let c = col('.') + 1
        execute ":m +1"
        call cursor(l, c)
    endif
endfunction

" Normal mode
nnoremap <C-S-Up> <Esc>:call MoveToPrevLine()<CR>i<Esc>
nnoremap <C-S-Down> <Esc>:call MoveToNextLine()<CR>i<Esc>

" Insert mode
inoremap <C-S-Up> <Esc>:call MoveToPrevLine()<CR>i
inoremap <C-S-Down> <Esc>:call MoveToNextLine()<CR>i


""" WILDMENU
" Enable auto completion menu after pressing TAB.
set wildmenu

set complete=.,w,b,u,t  " . = current buffer, w = buffers, b = keywords, u = unloaded, t = tags
set path+=**

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx,*.o,*.obj,*.bak,*.swp

set wildcharm=<C-Z>
" cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
" cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
" cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
" cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"

" Autosuggest file paths with arrows
cnoremap <expr> <Esc>[A wildmenumode() ? "\<left>" : "\<Up>"
cnoremap <expr> <Esc>[B wildmenumode() ? "\<right>" : "\<Down>"
cnoremap <expr> <Esc>[C wildmenumode() ? " \<bs>\<C-Z>" : "\<Right>"
cnoremap <expr> <Esc>[D wildmenumode() ? "\<up>" : "\<Left>"

"""" SEARCHING
" While searching though a file incrementally highlight matching characters as you type.
set incsearch
" Ignore capital letters during search.
set ignorecase
" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase
" Show partial command you type in the last line of the screen.
set showcmd
" Show the mode you are on the last line.
set showmode
" Show matching words during a search.
set showmatch
" Use highlighting when doing a search.
set hlsearch


"""" STATUSLINE
"" https://statusline.tomdaly.dev/
set laststatus=2
set statusline=
set statusline+=%2*
set statusline+=%{StatuslineMode()}
set statusline+=%1*
set statusline+=\ 
"set statusline+=<
"set statusline+=<
"set statusline+=\ 
"set statusline+=%f
"set statusline+=\ 
"set statusline+=>
"set statusline+=>
set statusline+=%=
set statusline+=%m
set statusline+=%h
set statusline+=%r
set statusline+=\ 
set statusline+=%3*
set statusline+=%{b:gitbranch}
set statusline+=%1*
set statusline+=\ 
set statusline+=%4*
set statusline+=%F
set statusline+=:
set statusline+=:
set statusline+=%5*
set statusline+=%l
set statusline+=/
set statusline+=%L
set statusline+=%1*
set statusline+=|
set statusline+=%y

hi StatusLine ctermbg=none ctermfg=none
hi User2 ctermbg=none ctermfg=gray
hi User1 ctermbg=none ctermfg=white
hi User3 ctermbg=none ctermfg=lightblue
hi User4 ctermbg=none ctermfg=lightgreen
hi User5 ctermbg=none ctermfg=magenta

function! StatuslineMode()
  let l:mode=mode()
  if l:mode==#"n"
    return "NORMAL"
  elseif l:mode==?"v"
    return "VISUAL"
  elseif l:mode==#"i"
    return "INSERT"
  elseif l:mode==#"R"
    return "REPLACE"
  elseif l:mode==?"s"
    return "SELECT"
  elseif l:mode==#"t"
    return "TERMINAL"
  elseif l:mode==#"c"
    return "COMMAND"
  elseif l:mode==#"!"
    return "SHELL"
  endif
endfunction

function! StatuslineGitBranch()
  let b:gitbranch=""
  if &modifiable
    try
      let l:dir=expand('%:p:h')
      let l:gitrevparse = system("git -C ".l:dir." rev-parse --abbrev-ref HEAD")
      if !v:shell_error
        let b:gitbranch="(".substitute(l:gitrevparse, '\n', '', 'g').") "
      endif
    catch
    endtry
  endif
endfunction

augroup GetGitBranch
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter * call StatuslineGitBranch()
augroup END

