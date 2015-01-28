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
			echo -e "\033[31m$filelist_path\033[0m"
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
    lines=($(\grep -i "$1" $filelist_path/.filelist | sed -e 's/\/[^/]*$//' | sort | uniq))
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
#帮助
function filelist_show_help(){
	printf "
创建类：
	createfilelist	==>	创建当前文件夹下索引文件
	updatefilelist + 忽略文件	==>	忽略目标文件，更新索引文件
查找类：
	findfilelist	==>	查看当前目录的索引文件位置
	catfilelist	==>	查看索引文件内容
使用类：
	go + 文件名	==>	前进该文件目录

"
}


#############################################################################################
#搜索java文件
function jgrep()
{
    find . -name .repo -prune -o -name .git -prune -o  -type f -name "*\.java" -print0 | xargs -0 grep --color -n "$@"
}
#搜索c或h文件
function cgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' \) -print0 | xargs -0 grep --color -n "$@"
}
#搜索xml类型文件
function resgrep()
{
    #for dir in `find . -name .repo -prune -o -name .git -prune -o -name res -type d`; 
	#do 
	#	find $dir -type f -name '*\.xml' -print0 | xargs -0 grep --color -n "$@"; 
	#done;
    find . -name .repo -prune -o -name .git -prune -o -name '*\.xml' -print0 | xargs -0 grep --color -n "$@";
}
#搜索makefile或者
case `uname -s` in
    Darwin)
		#针对window类型系统
        function mgrep()
        {
            find -E . -name .repo -prune -o -name .git -prune -o -path ./out -prune -o -type f -iregex '.*/(Makefile|Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -print0 | xargs -0 grep --color -n "$@"
        }

        function treegrep()
        {
            find -E . -name .repo -prune -o -name .git -prune -o -type f -iregex '.*\.(c|h|cpp|S|java|xml)' -print0 | xargs -0 grep --color -n -i "$@"
        }

        ;;
    *)
        function mgrep()
        {
            find . -name .repo -prune -o -name .git -prune -o -path ./out -prune -o -regextype posix-egrep -iregex '(.*\/Makefile|.*\/Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -type f -print0 | xargs -0 grep --color -n "$@"
        }

        function treegrep()
        {
			#iregex的写法
            find . -name .repo -prune -o -name .git -prune -o -regextype posix-egrep -iregex '.*\.(c|h|cpp|S|java|xml)' -type f -print0 | xargs -0 grep --color -n -i "$@"
        }

        ;;
esac
#帮助
function grep_show_help(){
	printf "
jgrep	==>	只搜索java文件
cgrep	==>	只搜索c或h文件
resgrep	==>	只搜索xml类型文件

"
}
#############################################################################################
