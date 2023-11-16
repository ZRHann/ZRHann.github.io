#!/bin/bash

# 查找所有与 hexo 相关的进程
hexo_processes=$(ps -ef | grep 'hexo' | grep -v 'grep' | awk '{print $2}')

# 遍历所有找到的进程并结束它们
for pid in $hexo_processes
do
    echo "Killing process with PID $pid"
    kill -9 $pid
done

echo "All Hexo processes have been terminated."