set term=xterm
set noai "filetype plugin indent off
set ts=4
set sw=4
match ErrorMsg /\s\+$\| \+\ze\t/
set expandtab
set nocp "nocompatible关闭vi兼容
set bs=2 "在insert模式下用退格键删除
set enc=utf-8
"set number "显示行号
"filetype plugin on "文件类型
"set history=500 "历史命令
"syntax on "语法高亮
"set autoindent "ai 自动缩进
"set smartindent "智能缩进
"set showmatch "括号匹配
set ruler "右下角显示光标状态行
"set nohls "关闭匹配的高亮显示
set incsearch "设置快速搜索
"set foldenable "开启代码折叠
"set fdm=manual "手动折叠
"set foldmethod=syntax "自动语法折叠
set modeline "自动载入模式行
"自动插入modeline
func! AppendModeline()
let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d :",
\ &tabstop, &shiftwidth, &textwidth)
let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
call append(line("$"), l:modeline)
endfunc
"按\ml,自动插入modeline
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>
"空格展开折叠
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
"colorscheme desert
hi MatchParen ctermbg=Yellow guibg=lightblue
