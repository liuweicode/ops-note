+++
title = ".vimrc 配置"
slug = "vimrc-config"
author = "liuwei"
date = "2022-10-14"
tags = [
    "编辑器",
    "IDE",
]
categories = [
    "vim",
]
+++

Vim (/vɪm/;[5] a contraction of Vi IMproved) is a free and open-source, screen-based text editor program.

Vim 是最好的编辑器，没有之一！

这里用于记录我的`.vimrc`文件的变更过程；

![my vim config file](https://static.liuwei.co/202210/1665724052.png)



## 通用配置 

### 公共配置

```
" --------------------------------------------------------------------------------------------
"  公共配置
" --------------------------------------------------------------------------------------------
let mapleader = "\<space>"
set encoding=UTF-8
set nocompatible
inoremap jj <esc>
set ts=4
" 解决backspace按键失效问题
set backspace=2
" 把所有数字当10进制
set nrformats=
set number
"set relativenumber
" 折叠
set foldmethod=indent
set nofoldenable
```

### 窗口设置

```
" --------------------------窗口设置----------------------------
" 设置命令行高度
set cmdheight=2
set ruler " 打开状态栏标尺
set shiftwidth=4 " 设定 << 和 >> 命令移动时的宽度为 4
```

### 复制粘贴

```
" --------------------------复制粘贴----------------------------
set clipboard=unnamed
"粘贴时保持格式
set paste
```

### 常用快捷键

```
" --------------------------常用快捷键----------------------------
" reselect pasted text
nnoremap gp `[v`]
vnoremap cp "0p
```

### 搜索相关

```
" --------------------------搜索相关开始----------------------------
" 搜索关键词高亮
set hlsearch
"在搜索的时候忽略大小写
set ignorecase
" 如果有一个大写字母，则切换到大小写敏感查找
set smartcase
" 指定 Search 结果的前景色（foreground）为黑色，背景色（background）为灰色； 渐进搜索的前景色为黑色，背景色为黄色；光标处的字符加下划线
highlight Search ctermbg=yellow ctermfg=black
highlight IncSearch ctermbg=black ctermfg=yellow
highlight MatchParen cterm=underline ctermbg=NONE ctermfg=NONE
```

### 其他

```
" 允许鼠标点击定位 坚决不允许！！
"set mouse=a
```

## 相关链接

- 项目代码: https://github.com/liuweicode/vimrc
- 官网: https://www.vim.org


