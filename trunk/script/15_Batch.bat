﻿
::##################################################
::#     合并多个文本文件
::##################################################
linux:  cat * > ouput.q
windows:    copy * output.q
::##################################################
::#     命令行输出到文件, 重命名执行文件
::##################################################
dir > K:\cmd.q
::print the error message into one file
python python.py 2> output.q 
rename "[阳光电影www.ygdy8.com]冰与火之歌：权力的游戏.第五季第10集.1024x576.中英双字幕.rmvb" "ThenSongofIceandFireSession5Chapter10.rmvb"
::change the filename to xxx.bat then double click this file
::##################################################
::#     进入远程共享目录
::##################################################
click "Start" button / input "\\10.240.170.50"