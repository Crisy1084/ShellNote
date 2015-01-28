#!/bin/bash

ENCRYPT_FILE_TYPE="\.xml$|\.java$|\.c$|\.cpp$|\.h$|\.hpp$|\.S$|\.cc$|\.s$"

decode_dir()
{
	local dst_dir=$1
	local file_list
	local file_item
	cd $dst_dir
	exit_on_error
	echo 解码路径:`pwd`
	file_list=`/bin/ls -1`
	#file_list=`ls`
	#echo $file_list
	IFS_OLD=$IFS
	IFS=$'\n'
	for file_item in ${file_list}; do
		#1重定向到里null，2重定向到了1
		decode ${file_item}
	done
	IFS=$IFS_OLD
	cd ..
}
decode()
{
	if [ -z $1 ];then
		show_usage
		exit 
	fi
	#file_name=`echo $1 | sed -r 's/^"|"$//g' `
	echo -e "\033[36m${1}\033[0m"
	if [ -f $1 ];then
		if [ "`echo ${1} | grep -E \"${ENCRYPT_FILE_TYPE}\"`" != "" ];then
			file_type=`file $1 | grep data$` 
			local result=$?
			if [ $result -eq 0 ];then
				echo -e "\033[34m解码\033[0m": ${1}
				echo "`cat ${1}`" > ${1}.decode
				exit_on_error
				rm ${1}
				mv ${1}.decode ${1}
			else
				echo -e "\033[34m${1}没有加密!!\033[0m"
			fi
		else
			echo -e "\033[32m${1} 不属于加密文件类型 ！\033[0m"
		fi
	elif [ -d ${1} ];then
		decode_dir ${1}
	else 
		echo -e "\033[31m${1} 文件错误 !\033[0m"
		show_usage
	fi

}
show_usage()
{
	printf "Usage:
	$0 [文件夹] || $0 [文件]

"
}
exit_on_error() {
	local error=$?
	if [ ${error} -ne 0 ]; then
		exit ${error}
		#continue
	fi
}

startTime=`date +%s`
echo `date`
decode "$1"
endTime=`date +%s`
countTime=`echo "$endTime-$startTime"|bc`
echo 耗时$countTime秒
