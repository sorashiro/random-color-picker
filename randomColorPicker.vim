function! GetOS()
    if has('unix')
        return 'linux'
    elseif has('win16') || has('win32') || has('win64')
        return 'win'
    endif
endfunction

function! GetRAND()
    if g:os == 'linux'
        return system("echo $RANDOM")
    elseif g:os == 'win'
        return system("echo %RANDOM%")
    endif
endfunction

let g:os=GetOS()

if g:os == 'linux'
    let g:plugin_path=$HOME.'/.vim/plugin'
    let g:slash='/'
    let g:love_path=g:plugin_path.'/.love'
    let g:like_path=g:plugin_path.'/.like'
    let g:hate_path=g:plugin_path.'/.hate'
elseif g:os == 'win'
    let g:plugin_path=$HOME.'/vimfiles/plugin'
    let g:slash='\'
    let g:love_path=g:plugin_path.'\love.txt'
    let g:like_path=g:plugin_path.'\like.txt'
    let g:hate_path=g:plugin_path.'\hate.txt'
endif

let g:colorscheme_file_path=''
let g:colorscheme_file=''
let g:totla_colorschemes = 0

function! Picker()
    if g:os == 'linux'
        let colorscheme_dirs=[$VIMRUNTIME.'/colors', '~/.vim/colors', '~/.vim/bundle/vim-colors/colors', '~/.vim/bundle/vim-colorschemes/colors']
    elseif g:os == 'win'
	let colorscheme_dirs=[$VIMRUNTIME.'/colors', $HOME.'/vimfiles/colors']
    endif
    let arr=[]
    for colorsheme_dir in colorscheme_dirs
        let colorschemes=glob(colorsheme_dir.'/*.vim')
        let arr+=split(colorschemes, '\n')
    endfor
    let g:total_colorschemes = len(arr)
    let hates=[]
    let r=findfile(g:hate_path)
    if r != ''
        let hates=readfile(g:hate_path)
    endif
    let r=findfile(g:love_path)
    if r != ''
        let loves=readfile(g:love_path)
        if len(loves) > 0
            let g:colorscheme_file=loves[0]
            call ApplyCS()
            return
        endif
    endif
    while 1
        let rand=GetRAND()
        let rand=rand%len(arr)
        let g:colorscheme_file_path=arr[rand]
        if index(hates, g:colorscheme_file_path) == -1
            break
        endif
    endwhile
    " colorscheme is /path/to/colorscheme_file.vim
    " convert to colorscheme_file
    let g:colorscheme_file=split(g:colorscheme_file_path, g:slash)[-1][:-5]
    call ApplyCS()
endfunction

function! ApplyCS()
    let cmd='colorscheme '.g:colorscheme_file
    execute cmd
endfunction

function! LoveCS()
    execute writefile([g:colorscheme_file], g:love_path)
endfunction

function! LikeCS()
    execute writefile([g:colorscheme_file], g:like_path)
endfunction

function! HateCS()
    call delete(g:love_path)
    let r=findfile(g:hate_path)
    if r != ''
        let hates=readfile(g:hate_path)
    else
        let hates=[]
    endif
    if len(hates) + 1 == g:total_colorschemes
        redrawstatus
	echo "She is the last one you got, Can't hate it anymore, or :Back first."
    else
        call add(hates, g:colorscheme_file_path)
        call writefile(hates, g:hate_path)
        call Picker()
        redrawstatus
        call ShowCS()
    endif
endfunction

function! BackCS()
    execute writefile([], g:hate_path)
    redrawstatus
    echo "you've got all the previously hated colorschemes back"
endfunction

function! ShowCS()
    echo 'using colorscheme: '.g:colorscheme_file
endfunction

call Picker()
autocmd VimEnter * echo 'using colorscheme: '.g:colorscheme_file
command! Love call LoveCS()
command! Hate call HateCS()
command! Like call Picker()
command! CS call ShowCS()
command! Back call BackCS()
command! Csn call Picker()
