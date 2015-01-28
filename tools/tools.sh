#/bin/bash

function do_create_repo()
{
	_do_create_repo $1 lichee
	_do_create_repo $1 android
}

function _do_create_repo()
{
	local project=$1
	local codeDir=$2
	mkdir $codeDir
    cd $codeDir
expect -c"
    set timeout 1200;
    spawn  repo init -u ssh://git@192.168.1.33/git_repo/$project/manifest.git -m $codeDir.xml
    expect {
                \"*Your*Name*\" {send \"caishaoyi\r\"; exp_continue}
                \"*Your*Email*\" {send \"caishaoyi@topwise3g.com\r\"; exp_continue}
                \"*is*this*correct*\" {send \"y\r\";}
    };"
    repo sync
	repo start master --all
    cd ../
}

function do_create_git()
{
    git clone git@192.168.1.137:$1/android.git
    git clone git@192.168.1.137:$1/lichee.git
}

function show_down_usage()
{
    printf "
NAME :
	本脚本适用于下载全志芯片平台代码
EXAMPLE :
	$0 OPTIONS
OPTIONS :
	a10		下载a10代码
	a13		下载a13代码
	a20		下载a20代码
	a23		下载a23代码
	a31s		下载a31s代码
	a33		下载a33代码
"
}

function down_aw_code()
{
	if [ "$1" = "" ]; then
		show_down_usage
		exit 0
	fi
	rootDir=`pwd`
	mkdir $1
	cd $1
	if [ "$1" = "a10" ] || [ "$1" = "a13" ] || [ "$1" = "a13" ]; then
		do_create_git $1
	elif [ "$1" = "a23" ]; then
		do_create_repo a23an44
	elif [ "$1" = "a31s" ];then
		do_create_repo a3x
	else
		do_create_repo $1
	fi	
	cd $rootDir
}


declare -a sourcePath
function isSourcePath()
{
	allDir=$(find . -maxdepth 1 -type d)
	i=0
	for dir in $allDir
	do
		if [ -d $dir/lichee ] && [ -d $dir/android ];then
			sourcePath[$i]=$dir	
			let "i+=1"
		fi
	done
	#echo  "${sourcePath[@]}" 
}
function select_list_dir()
{
	echo "Which project world you select?"
	isSourcePath
	sourceNum=${#sourcePath[@]}
	sourcePath[$sourceNum+1]="all"
	select project in  ${sourcePath[@]}
	do
		if [ "$project" == "all" ];then
			echo -e "\033[31m 全部文件查找更新！ \033[0m"
			for all in $dir
			do
				do_project_update $all
			done
			break
		fi
		if [ "$project" == "" ];then
		#if [ -z "$project" ];then
			echo -e "\033[31m 警告，输入非法参数！ \033[0m"
		else
			parm=$@
			do_project_update $project $parm
		fi
		break
	done	
}

function do_project_update()
{
	echo -e "\033[31m =========[$1]========= \033[0m"
	array=($@)
	array[0]="repo forall -c"
	Path=`pwd`	
	cd $1/lichee
		echo "=====准备更新$1/lichee====="
		${array[@]}
	cd $Path
	cd $1/android
		echo "=====准备更新$1/android====="
		${array[@]}
	cd $Path
	
}


function read_function()
{
	echo -e "May you do something! \n" 
	read function
	case $function in
		1) echo "function 1";;
		2) echo "function 2" ;;
		*) echo "there is nothing to do" ;;
	esac	
}
function getOpt()
{
	while getopts a:b:c OPTION
	do
		case $OPTION in
			c) IS_CLEAN_ANDROID=1
			;;
			b) MY_BUILD_BOARD=$OPTARG
			;;
			*) show_usage
			;;
		esac
	done

}
#read_function
function main()
{
	local project=$1
	down_aw_code $project	
	#select_list_dir $@
}



main $1 $2 $3 $4 $5 