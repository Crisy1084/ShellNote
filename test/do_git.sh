#!/bin/sh

HOME="/home/caishaoyi/project/msm8916_tw"
REMOTE="/home/msm8916_tw"

CONFIG_LIST=(
	"remote.origin.url"
	"remote.origin.fetch"
	"branch.master.remote"
	"branch.master.merge"
)
CONFIG_PARM=(
	"caishaoyi@10.20.31.53:"
	"+refs/heads/*:refs/remotes/origin/*"
	"origin"
	"refs/heads/master"
)

function git_config()
{
	for GIT in `cat $HOME/GIT_HOUSE.txt`
	do
		RootDir=`pwd`
		GIT_PATH=`dirname $GIT`
		#echo $GIT_PATH
		cd $GIT_PATH
		i=0
		while [ $i -lt ${#CONFIG_LIST[@]} ];do
			list=${CONFIG_LIST[$i]}
			parm=${CONFIG_PARM[$i]}
			config_test $list
			local result=$?
			if [ $result -ne 0 ];then
				git config --unset ${CONFIG_LIST[$i]}
				if [ "$list" == "remote.origin.url" ];then
					Project_path=${GIT_PATH//$HOME/}
					parm=$parm$REMOTE$Project_path
					echo $parm
					
				fi
				git config --add $list $parm
			fi
			((i++))
		done
		git_pull2
		cd $RootDir

	done
}
#不管有没有，全部unset，重新设置
function config_test()
{
	local result=
	git config --list | grep "$1"  > /dev/null
	result=$?
	if [ $result -eq 0 ];then
		return 1
	else
		return 1
	fi
		
	
}
function git_pull()
{
	expect -c"
	
	set timeout 1200;
	
	spawn  git pull 
	
	expect {
		\"*password*\" {send \"123456\r\"; exp_continue}

	
	};" 
}

function git_pull2()
{
	expect -c"	
	set timeout 1200;	
	spawn  git pull 
	expect \"*password*\"
	set timeout 300 
	send \"123456\r\" 
	

	expect eof
	" 
}

function git_find()
{
	find $HOME -name ".git" > $HOME/GIT_HOUSE.txt
	echo "find_git_finish"
}

function repo_forall()
{
	echo $@
	for GIT in `cat $HOME/GIT_HOUSE.txt`
	do
		RootDir=`pwd`
		GIT_PATH=`dirname $GIT`
		cd $GIT_PATH
		$@
		cd $RootDir
	done
	
	
}

#config_test $1
#git_find
#git_config
repo_forall $1 #2>/dev/null