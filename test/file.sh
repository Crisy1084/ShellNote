#!/bin/bash

#查找机密文件类型（只支持文本类型）PS：加密也只是针对文本类型加密
ENCRYPT_FILE_TYPE=".*\.xml$\|.*\.java$\|.*\.[cC]$\|.*\.cpp$\|.*\.h$\|.*\.hpp$\|.*\.[sS]$\|.*\.cc$"

#解密函数
function decode(){
	echo -n " ==>\033[32m解密文件\033[0m"
	echo "`cat "$1"`" > "$1".decode
	rm -rf $1
	mv $1.decode $1
	decide_type $1
	if [ $? -ne 0 ];then
		echo -e " ==>\033[31m解密失败\033[0m"
		#解密失败，保存LOG
		echo $1 >> decode.log
	fi
	echo 
	#cp $1 test/
}
#加密文件类型判断
function decide_type()
{
	type=`file "$1" | grep "data$"`
	if [ $? -ne 0 ];then
	#查找data类型为结果1，则属于未加密文件，返回0
		return 0
	else
	#查找data类型为结果0，则属于加密文件，返回1
		return 1
	fi
}
#文件查找
function file_find()
{
	echo "解密开始"
	rm -rf decode.log
	IFS=$'\n'
	#查找相应文件类型
	for FILE in `find $1 -regex "$ENCRYPT_FILE_TYPE"`
	do
		decide_type $FILE
		Path=`dirname $FILE`
		Name=`basename $FILE`
		if [ $? -ne 0 ];then
			echo -n -e "$FILE ==>\033[34m加密文件\033[0m"
			decode $FILE
		else
			#echo -e "\033[35m$Path/\033[32m$Name ==>\033[34m非加密文件\033[0m"
			echo -e "$FILE ==>\033[36m非加密文件\033[0m"
		fi
	done
}

file_find $1

#decode $1
#decode_tee $1
