#!/bin/bash

#查找机密文件类型（只支持文本类型）PS：加密也只是针对文本类型加密
ENCRYPT_FILE_TYPE=".*\.xml$\|.*\.java$\|.*\.[cC]$\|.*\.cpp$\|.*\.h$\|.*\.hpp$\|.*\.[sS]$\|.*\.cc$"

SUMCOUNT=0
ENCRYPTCOUNT=0
DECODECOUNT=0
ABANDONCOUNT=0

#解密函数
function decodeFile(){
	echo -n -e "$1 ==>\033[34m加密类型\033[0m"
	echo -n -e " ==>\033[32m解密文件\033[0m"
	#解密程序关键点；
	#必须通过脚本的echo转接cat指令;（加密程序会直接识别bash/cat的重定向）
	#再重定向到加密系统不加密的文件类型；
	#删除原文件；
	#再把解密后文件恢复回来；
	#！可能会改变文件属性；
	#echo "`cat "$1"`" | tee "$1".decode
	/bin/cat "$1" | tee "$1".decode > /dev/null
	#重新检测文件类型，判断解密是否成功
	decideType "$1".decode
	local result=$?
	if [ $result -ne 0 ];then
		echo -e " ==>\033[31m解密失败\033[0m"
		#解密失败，保存LOG
		echo $1 >> DecodeLog/decode.log
		cp -rvf --parents $1 DecodeLog/AbandonFile/
	else
		((DECODECOUNT++))	
		#echo -e " ==>\033[1;37m解密成功\033[0m"
		echo -e " ==>\033[35m解密成功\033[0m"
	fi
	#保存原文件权限
	fileParm=`stat $1 -c %a`
	#删除加密文件rm -rfv $1
	rm -rf $1
	#还原文件
	mv $1.decode $1
	#还原文件权限
	/bin/chmod $fileParm $1	
}
#加密文件类型判断
function decideType()
{
	#加密后的文件，文件类型变为2进制data类型；
	type=`file "$1" | grep "data$"`
	local result=$?
	if [ $result -ne 0 ];then
	#查找data类型为结果1，则属于未加密文件，返回0
		return 0
	else
	#查找data类型为结果0，则属于加密文件，返回1
		return 1
	fi
}
#文件查找
function findFind()
{
	echo -e "\033[35m解密开始,正在查找加密文件,文件较多请耐心等待...\033[0m"
	echo -e "\033[35m检测加密文件类型为：\033[0m" $ENCRYPT_FILE_TYPE | sed 's/[.\/*|$]/ /g'
	echo 

	#以换行符为for切割标准
	IFS_OLD=$IFS
	IFS=$'\n'
	#查找相应文件类型
	for FILE in `find $1 -regex "$ENCRYPT_FILE_TYPE"`
	do
		((SUMCOUNT++))
		#判断文件类型
		decideType $FILE
		local result=$?
		#返回非0，即加密文件
		if [ $result -ne 0 ];then
			#echo -n -e "$FILE ==>\033[34m加密类型\033[0m"
			((ENCRYPTCOUNT++))
			decodeFile $FILE
		else
			#echo -e "\033[35m$Path/\033[32m$Name ==>\033[34m非加密文件\033[0m"
			echo -e "$FILE ==>\033[36m非加密文件\033[0m"
		fi
	done
	IFS=$IFS_OLD
}
#重复检测函数
function reDecode()
{
	if [ $reDecodeCount -lt 10 ];then 
		#如果存在LOG的文件则再次解密；
		if [ -f DecodeLog/decode.log ];then
			encrypt_file=`cat DecodeLog/decode.log`
			abandon_file=$encrypt_file
			if [ "$encrypt_file" ];then
				echo -e "\033[1;31m再次解码未成功解密文件:\033[0m"
				#再次解密开始，删除LOG文件；
				rm -rfv DecodeLog/decode.log	
				IFS_OLD=$IFS
				IFS=$'\n'
				for refile in $encrypt_file
				do
					decodeFile $refile
				done
				unset encrypt_file
				IFS=$IFS_OLD
				((reDecodeCount++))
				#递归调用；再次检查是否仍有未解密文件；
				reDecode
			fi
		else
			echo -n -e "\033[1;31m全部解密完成！\033[0m"
		fi
		
	else
		echo -e "\033[1;31m解码失败文件列表：\033[0m"
		echo "$abandon_file"
		ABANDONCOUNT=`cat DecodeLog/decode.log | wc -l`
		reDecodeFail=`echo "10-$reDecodeCount"| bc`
		echo -e "重复解密\033[1;31m$reDecodeCount次\033[0m失败，该文件可能包含了特殊字符导致文件类型错误，退出脚本!！"
		unset reDecodeCount
	fi
}
function initFile(){
	#删除可能之前残留的LOG文件
	rm -rf DecodeLog
	mkdir -p DecodeLog/AbandonFile
	touch DecodeLog/decode.log
}
function showTime(){
	currentTime=`date +%s`
	echo `date`
	return $currentTime
}
function showUsage()
{
	printf "Usage:
	. $0  [Path] Or [File]

Description:
	破解文本类加密文件脚本，支持直接输入路径，或文件名进行破解；
	decode.log为解密失败的log文件；程序运行结束，检测该文件，确保完全解密成功；

Warning:
	该解码采用删除原文件，重定向文件内容，可能会改变文件属性，导致编译问题；

Another:
	如果只想单独解密decode.log里的文件
	source $0 && i=次数 && reDecode\n
"
}
function main()
{
	if [ -z $1 ];then
		showUsage 
	else
		#记录程序开始运行时间
		showTime
		startTime=$?
		initFile
		findFind $1
		#取消重复解密
		#reDecodeCount=0
		#reDecode
		#程序运行结束时间
		showTime
		endTime=$?
		countTime=`echo "$endTime-$startTime" |bc`
		ABANDONCOUNT=`cat DecodeLog/decode.log | wc -l`
		echo -ne "总文件：\033[1;31m$SUMCOUNT\033[0m ; "
		echo -ne "加密文件：\033[1;31m$ENCRYPTCOUNT\033[0m ; "
		echo -ne "顽固文件：\033[1;31m$ABANDONCOUNT\033[0m ; "
		echo -e "破解文件：\033[1;31m$DECODECOUNT\033[0m ;"
		echo -e "耗时\033[1;31m$countTime\033[0m秒"
	fi
}
main $1

