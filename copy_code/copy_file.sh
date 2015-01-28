#!/bin/sh
#	parm1:源码路径
#  	parm2:拷贝路径
#	parm3:需拷贝文件

#
#	采用绝对路径::
#	√全局引用脚本:
#	流程 : 判断参数->判断目标文件是否存在->格式化文件列表->当前路径创建目录->查找目标->破解文件->拷贝文件到目标
#	1.目标为路径:拷贝到目标
#	2.目标为文件夹名:拷贝到脚本路径
#	×当前引用:
#	1.目标为路径
#	2.目标为文件夹名
#

function copy_file(){
	#1.判断参数
	if [ $# -lt 2 ];then
		show_help
		return
	fi

	SrcDir=$1
	DestDir=$2
	ShellPath=$(cd "$(dirname "$0")"; pwd)

	#2.判断目标文件是否存在;
	#支持保存重复命名文件夹
	if [ -d $DestDir ];then
		mv $DestDir $DestDir"_bak"
	fi

	#3.支持文件列表可配置;不指定的话默认脚本路径下的filelist.txt文件
	if [ -z $FileList ];then
		FileList="$ShellPath/filelist.txt"
	else
		FileList=$3
	fi
	#4.格式化文件列表,确保能被正确读取
	fromdos $FileList


	#5.创建目录(如果-c 参数为路径?)
	CopyName=`basename $DestDir`
	CopyDir=`dirname $DestDir`
	mkdir -p $CopyName

	#6.查找目标
	echo "Copy file..."
	RootDir=`pwd`
	cd $SrcDir
	oldIFS=$IFS
	IFS=$'\n'
	for file in `cat $FileList`
	do
		echo "----->>>"$file
		if [ "$file" == "\r" ];then
			echo 跳过空行!
		else
			cp -rf --parents $file $RootDir/$CopyName
		fi
		file=
	done
	IFS=$oldIFS
	cd $RootDir
	echo "Finish !!!"

	#7.破解文件
	sh ~/tmp/shell/decode/findfile_Decode.sh $CopyName

	#8.拷贝文件到目标
	cp -rvf $FileList $RootDir/$CopyName

	#9.如果-c参数是路径移动到相应路径;否则默认放到脚本所在位置;
	if [ "$CopyDir" != "." ];then
		mv -vf $RootDir/$CopyName $CopyDir
	else
		mv -vf $RootDir/$CopyName $ShellPath
	fi
}
#脚本帮助
function show_help(){
	printf "Usage:
$0 -p SrcDir -c DestDir -f FileList

"
}
#采用直接引用脚本方式;不采用source的方式;
#参数指定分配;不采用$1 $2 $3
#function main(){
	OPTIND=1
	#local OPTION
	OPTION=
	SrcDir=
	DestDir=
	FileList=
	while getopts p:c:f: OPTION
	do
		case $OPTION in
			p)SrcDir=$OPTARG
			;;
			c)DestDir=$OPTARG
			;;
			f)FileList=$OPTARG
			;;
			*)show_help
			;;
		esac
	done
	unset OPTION
	echo $SrcDir $DestDir $FileList
	copy_file $SrcDir $DestDir $FileList
#}

#copy_file $1 $2 $3





















