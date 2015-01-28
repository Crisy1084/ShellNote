#/bin/bash

function do_create_repo()
{
    mkdir lichee
    cd lichee


expect -c"
    set timeout 1200;

    spawn  repo init -u ssh://git@192.168.1.33/git_repo/$1/manifest.git -m lichee.xml

    expect {
                \"*Your*Name*\" {send \"caishaoyi\r\"; exp_continue}
                \"*Your*Email*\" {send \"caishaoyi@topwise3g.com\r\"; exp_continue}
                \"*is*this*correct*\" {send \"y\r\";}

    };"

	repo sync
    cd ../

    mkdir android
    cd android
expect -c"
    set timeout 1200;

    spawn  repo init -u ssh://git@192.168.1.33/git_repo/$1/manifest.git -m android.xml

    expect {
                \"*Your*Name*\" {send \"caishaoyi\r\"; exp_continue}
                \"*Your*Email*\" {send \"caishaoyi@topwise3g.com\r\"; exp_continue}
                \"*is*this*correct*\" {send \"y\r\";}

    };"
    repo sync
    cd ../
}

function do_create_git()
{
    git clone git@192.168.1.137:$1/android.git
    git clone git@192.168.1.137:$1/lichee.git
}

function create_repo_dir()
{
	if [ "$1" = "a23an44" ];then
		mkdir a23
		cd a23
	else
		mkdir $1
		cd $1
	fi
	do_create_repo $1
	cd ..
}

function create_git_dir()
{
	mkdir $1
	cd $1
	do_create_git $1
	cd ..
}

function show_usage()
{
    printf "
NAME
	本脚本适用于下载全志芯片平台代码
EXAMPLE
	$0 OPTIONS
OPTIONS
	a10		下载a10代码
	a13		下载a13代码
	a20		下载a20代码
	a23		下载a23代码
	a31s		下载a31s代码
	a3x		下载a3x代码
"
}
#if [ "$1" = "" ]; then
#	show_usage
#elif [ "$1" = "a10" ] || [ "$1" = "a13" ] || [ "$1" = "a13" ]; then
#    create_git_dir $@
#elif [ "$1" = "a23" ]; then
#	create_repo_dir a23an44
#else
#    create_repo_dir $@
#fi


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
function select_list_dir()
{
	dir=$(find . -maxdepth 1 -type d)
	#dir=`/bin/ls`
	#echo "$dir"
	echo "Which project world you select?"
	select project in $dir
	do
		if [ "$project" == "." ];then
			echo -e "\033[31m 全部文件查找更新！ \033[0m"
			for all in $dir
			do
				decide_project_code $all
			done
			break
		fi
		if [ "$project" == "" ];then
		#if [ -z "$project" ];then
			echo -e "\033[31m 警告，输入非法参数！ \033[0m"
		else
			decide_project_code $project
		fi
		break
		done	
}
function decide_project_code()
{
	android_dir=$1/android
	lichee_dir=$1/lichee
	if [ -e $android_dir ] && [ -e $lichee_dir ];then
		do_project_update $1
	else
		echo -e "\033[31m =======[$1]非代码文件夹======= \033[0m"
	fi

}
function do_project_update()
{
	echo -e "\033[31m =========[$1]========= \033[0m"
	Path=`pwd`	
	cd $1/lichee
		echo "=====准备更新$lichee_dir====="
		repo forall -c 'git checkout . ;git clean -fd ;git pull; pwd;'
	cd $Path
	cd $1/android
		echo "=====准备更新$android_dir====="
		repo forall -c 'git checkout . ;git clean -fd ;git pull; pwd;'
	cd $Path
	
}


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

#read_function
select_list_dir
