#!/bin/bash

ENCRYPT_FILE_TYPE="\.xml$|\.java$|\.c$|\.cpp$|\.h$|\.hpp$|\.S$|\.cc$"

decode_dir()
{
	local dst_dir=$1
	local file_list
	local file_item
	file $dst_dir 2>/dev/null
	local error=$?
	if [ ${error} -ne 0 ];then
		echo -e "\033[31m ${dst_dir} 错误的文件夹类型 !\033[0m"
		return
	fi
	cd $dst_dir
	exit_on_error
	echo 解码路径:`pwd`
	#file_list=`ls -Q`
	file_list=`ls`
	echo $file_list
	for file_item in ${file_list}; do
		file $file_item >/dev/null 2>&1
		if [ ${error} -ne 0 ];then
			echo -e "\033[31m ${dst_dir} 错误的文件夹类型 !\033[0m"
			continue
		fi
		decode ${file_item}
	done
	cd ..
}
decode()
{
	if [ -z $1 ];then
		show_usage
		exit 
	fi
	echo -e "\033[36m${1}\033[0m"
	if [ -f $1 ];then
		if [ "`echo ${1} | grep -E \"${ENCRYPT_FILE_TYPE}\"`" != "" ];then
			file_type=`file ${1} | cut -d ' ' -f 2`
			if [ "$file_type" == "data" ];then
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
	
decode $1 
