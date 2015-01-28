#!/bin/bash
#设置忽略文件夹,默认git|repo|svn这三个文件夹忽略
IGNORE=".git/\|.repo/\|.svn/"

#查找当前文件夹的目录索引
function findfilelist()
{
    #TOPFILE=build/core/envsetup.mk
    local HERE=$PWD
    T=
    while [ \( $PWD != "/" \) ]; do
        T=$PWD
        if [ -f "$T/.filelist" ]; then
            #\cd
			filelist_path=$T
			cd $HERE
            return 
        fi
        \cd ..
    done
    \cd $HERE
    echo -e  "\033[1;31mcan't find filelist\033[0m"
}

#创建目录索引
function createfilelist()
{
	#记录程序开始运行时间
	startTime=`date +%s`
	echo `date`
	echo -n "Creating index..."
	#find . -wholename ./git -prune -o -wholename ./.repo -prune -o -wholename ./.git -prune -o -type f > filelist
	find . -type f | grep -v "$IGNORE" > .filelist
	echo -e  "\033[1;33m Done\033[0m"
	endTime=`date +%s`
	countTime=`echo "$endTime-$startTime" |bc`
	echo -e "耗时\033[1;31m$countTime\033[0m秒"
}

#更新目录索引文件
#\|.out/\|external/\|prebuilts
function updatefilelist()
{
    if [[ -z "$1" ]];then
		echo "Usage:Creatfilelist Ignore_file OR Ignore_dir!"
		return
	fi
	unset filelist_path
	findfilelist
	cat $filelist_path/.filelist | grep -v "$1" > $filelist_path/.filelist.new
	rm -rf $filelist_path/.filelist
	mv $filelist_path/.filelist.new $filelist_path/.filelist
	echo -e  "\033[31mupdate filelist for ignore $1 !\033[0m"
}

#查看目录索引文件
function catfilelist()
{
	findfilelist
	cat $filelist_path/.filelist
}

#前进到目标文件夹
function go () {
    if [[ -z "$1" ]]; then
        echo "Usage: go <regex>"
        return
    fi
	unset filelist_path
	findfilelist
    local lines
	#grep搜索关键字,sed切割最后/后面的文件名,sort排序,uniq去重
    lines=($(\grep "$1" $filelist_path/.filelist | sed -e 's/\/[^/]*$//' | sort | uniq))
    if [[ ${#lines[@]} = 0 ]]; then
        echo -e "Not found\033[31m $1\033[0m"
        return
    fi
    local pathname
    local choice
    if [[ ${#lines[@]} > 1 ]]; then
        while [[ -z "$pathname" ]]; do
            local index=1
            local line
			echo -e "\033[32m$filelist_path\033[0m"
            for line in ${lines[@]}; do
                printf "%6s %s\n" "[$index]" $line
                index=$(($index + 1))
            done
            echo
            echo -n "Select one: "
            unset choice
            read choice
            if [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
                echo -e "\033[1;31mInvalid choice\033[0m"
                continue
            fi
            pathname=${lines[$(($choice-1))]}
        done
    else
        pathname=${lines[0]}
    fi
	#echo -e "\033[34m$filelist_path/$pathname\033[0m"
    \cd $filelist_path/$pathname
}
