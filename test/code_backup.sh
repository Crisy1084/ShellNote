#!/bin/bash

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
if [ "$1" = "" ]; then
	show_usage
elif [ "$1" = "a10" ] || [ "$1" = "a13" ] || [ "$1" = "a13" ]; then
    create_git_dir $@
elif [ "$1" = "a23" ]; then
	create_repo_dir a23an44
else
    create_repo_dir $@
fi

#create_repo_dir a3x
#create_repo_dir a20
#create_repo_dir a23an44

#create_git_dir a10
#create_git_dir a13
#create_git_dir a31s
