#!/bin/bash
combine_apk_certs()
{
	local src=$1
	local dst=$2
	local line_content

	cat ${src} | while read line_content
	do
		#读取目标文件,如果目标行为空或者属于#注释的,则跳过
		if [ "${line_content}" = "" ] || [ "${line_content:0:1}" = "#" ]; then
			continue
		fi
		key=`echo ${line_content} | cut -d ' ' -f 1`
		echo "    ${key}"
		cat ${dst} | grep "^${key}" -v > ${dst}.new
		cp ${dst}.new ${dst}.new_bak
		rm ${dst}
		mv ${dst}.new ${dst}
		echo ${line_content} 
		echo ${line_content} >> ${dst}
	done
}

combine_apk_certs $1 $2