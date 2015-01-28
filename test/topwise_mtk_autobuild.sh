#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------
# add new sh file for first time, you should pull commond for the file in terminal. 
# eg: 
# chmod a+x autobuild.sh
# "BASE_DIR"：
# 这个取代码到本机的目录"BASE_DIR"路径可自己根据习惯来定；~ 表示是用户目录，注意不能加双引号，那样路径会不一样的。
# 如：
# 	local BASE_DIR=~/work
# 或
# 	local BASE_DIR=/media/work
# 注意：
# 　　如果要修改这个参数值，都要把本文件和涉及到的配置文件中，所有的参数都更改为一致的。
# ----------------------------------------------------------------------------------------------------------------------

function help()
{
	# ./autobuild.sh [项目版本号] [鼎智项目名] [客户项目名] [编译模式] [延时时间] [分支类型]
	cat help.txt
}

# 产生 svn_log.txt
function do_svn_log()
{
	local backup_cur_path=`pwd`
	local hsvnlogpath=${1}/`basename ${2}`
	cd ${hsvnlogpath}
	local svnlogfile=./svn_log.txt
	local svnr=`svn info | grep 版本:| head -n 1 | sed -e "s/版本: /r/g"`
	if [ "${svnr}" = "" ] ; then
		svnr=`LANG=en_US.UTF-8;svn info | grep Revision:|sed -e "s/Revision: /r/g"`
	fi
	echo "${hsvnlogpath}" > ${svnlogfile}
	echo "全取全编的日期:" >> ${svnlogfile}
	echo "    `date`" >> ${svnlogfile}
	echo "全取全编的svn号：" >> ${svnlogfile}
	echo "    ${svnr}" >> ${svnlogfile}
	echo "------------------------------------------------------" >> ${svnlogfile}
	echo "版本编译人员或开发人员在当前目录临时手动修改的内容点：" >> ${svnlogfile}
	echo "    " >> ${svnlogfile}
	echo "------------------------------------------------------" >> ${svnlogfile}
	echo "版本编译人员手动修改、删除、更新的svn号：" >> ${svnlogfile}
	cd "${backup_cur_path}"
}

function svn_co_dir()
{
	local svn_version=$1
	local svn_dir=$2
	local target_dir=$3
	local ignore_dir=$4
	for i in `ls $target_dir`; do 
		if [ -d "$target_dir/$i" ]; then
			if [ "$i" = "${ignore_dir}" ]; then 
				svn co -r $svn_version $svn_dir/$i $target_dir/$i --depth immediates
			else
				echo "need to svn co $target_dir/$i"
				svn co -r $svn_version $svn_dir/$i $target_dir/$i --depth infinity
			fi
		fi
	done
}

# 支持4个参数：项目名 目标目录 svn目录 [版本号]
function svn_co_prj()
{
	local prj=$1
	local target_dir=$2
	local svn_root=$3
	local svn_version=$4
	if [ "$svn_version" = "" ]; then
		svn_version=`svn info $svn_root| grep "^版本:" | awk -F":" '{print $2}'`
	fi
	echo "svn_co_prj: $svn_version"  | tee -a ./../autobuild.log

	test -d $target_dir && echo "$target_dir 已经存在，必须先删除它。确认删除？y/n" && read -n 1 -t 60
	if [ "$REPLY" = "n" -o "$REPLY" = "N" ]; then
		exit
	else
		rm -rf $target_dir
	fi

	svn co -r $svn_version $svn_root $target_dir --depth immediates
	svn_co_dir $svn_version $svn_root $target_dir "idh.code"
	svn_co_dir $svn_version $svn_root/idh.code $target_dir/idh.code "customize"
	svn_co_dir $svn_version $svn_root/idh.code/customize $target_dir/idh.code/customize "res"
	for i in `svn ls $svn_root/idh.code/customize/res | egrep -v "^p1|^p6"`; do 
		echo "need to svn co $svn_root/idh.code/customize/res/$i"
		local dirorfile=`echo $i | grep "\/"`
		if [ "" = "${dirorfile}" ];then
			if [ -f $target_dir/idh.code/customize/res/$i ];then 
				echo "$target_dir/idh.code/customize/res/$i this file is exist."
			else
				svn up -r $svn_version $svn_root/idh.code/customize/res/$i $target_dir/idh.code/customize/res/$i
			fi
		else
			svn co -r $svn_version $svn_root/idh.code/customize/res/$i $target_dir/idh.code/customize/res/$i --depth infinity
		fi
		if [ $? -ne 0 ]; then
			return 1
		fi
	done
	for i in `svn ls $svn_root/idh.code/customize/res | egrep "^p1|^p6"`; do 
		if [ -d "$target_dir/idh.code/customize/res/$i" ]; then
			rm -rf $target_dir/idh.code/customize/res/$i
		fi
		if [ "$i" = "$prj/" ]; then 
			svn co -r $svn_version $svn_root/idh.code/customize/res/$i $target_dir/idh.code/customize/res/$i --depth infinity
		else
			echo "need to svn ignore $svn_root/idh.code/customize/res/$i"
		fi
	done
}

function do_svn_co()
{
	local svn_co_dir=$1
	local svn_co_path=$2
	local svn_co_prj=$3
	# 重新创建log文件
	echo "${svn_co_dir} autobuild log start" > ./autobuild.log
	mkdir -p ./${svn_co_dir}
	echo "svn co start: `date`"  | tee -a ./autobuild.log
	cd ./${svn_co_dir}
	echo "正在从svn上取代码，大约需要半个小时左右。请稍候..."
	local tmdir=`basename ${svn_co_path}`
	svn_co_prj ${svn_co_prj} `pwd`/${tmdir} ${svn_co_path}
	cd ..
	# 产生 svn_log.txt
	do_svn_log ${svn_co_dir} ${svn_co_path}
	echo "svn co end: `date`"  | tee -a ./autobuild.log
}

function do_main()
{
	if [ "${1}" = "-h" -o "${1}" = "-help" -o "${6}" = "" ]; then
		help
		exit
	fi

	local CUSTOMIZE_VERSION=${1}
	local TOPWISE_PROJECT=${2}
	local TOPWISE_CUSTOMER=${3}
	local PROJ_OPT=${4}
	local SLEEP_TIME=${5}
	local SVN_TYPE=${6}
	# 这个BASE_DIR基础路径可自己根据习惯来定；~ 表示是用户目录，注意不能加双引号，那样路径会不一样的
	local BASE_DIR=~/1mtk
	local PROJ_DIR="${TOPWISE_CUSTOMER}_${PROJ_OPT}"
	local SVN_PATH=""

	# 外文版本编译选项特殊处理
	local PROJ_OPTS=(${PROJ_OPT//:/ })
	local PROJ_OPTS_NUM=${#PROJ_OPTS[@]} 
	if [ $PROJ_OPTS_NUM -eq 1 ]; then
		if [ ! "$PROJ_OPT" = "user" -a ! "$PROJ_OPT" = "usr" -a ! "$PROJ_OPT" = "userdebug" -a ! "$PROJ_OPT" = "eng" ]; then
			help
			exit
		fi
	elif [ $PROJ_OPTS_NUM -eq 2 ]; then
		if [ ! "${PROJ_OPTS[0]}" = "user" -a ! "${PROJ_OPTS[0]}" = "usr" -a ! "${PROJ_OPTS[0]}" = "userdebug" -a ! "${PROJ_OPTS[0]}" = "eng" ]; then
			help
			exit
		fi
		if ! [ "${PROJ_OPTS[1]}" = "multi" -o "${PROJ_OPTS[1]}" = "sign" ]; then
			help
			exit
		fi
		# 第2个编译选项中有“:”，但编译路径目录中不得有“:”，所以将“:”转换为“_”
		local tmp_opt=(${PROJ_OPT//:/_})
		PROJ_DIR="${TOPWISE_CUSTOMER}_${tmp_opt}"
	else
		help
		exit
	fi

	if [ ! "$SLEEP_TIME" = "now" ]; then
		if [[ ! "$SLEEP_TIME" =~ [0-9]+[s|m|h] ]]; then
			echo -e "\e[1;33m时间格式是：now或者5s或者5m或者5h\e[0m"
			exit
		fi
	fi

	# 判断是否支持此项目的编译
	case ${TOPWISE_PROJECT} in
		p1[0-9][0-9][0-9])
			echo "${TOPWISE_PROJECT} is mt6571 android project"
			;;
		p6[0-9][0-9][0-9])
			echo "${TOPWISE_PROJECT} is mt6582 android project"
			;;
		*)
			echo -e "\e[1;33m鼎智4.0.3项目名必须是这类格式的：p1XXX,p6XXX\e[0m"
			exit
			;;
	esac
	# 获得对应的svn路径
	case ${SVN_TYPE} in
		6571_aliyun_branch)
			SVN_PATH="svn+ssh://svn@10.20.30.20/mediatek/mt6571/branches/MT6571_YUNOS_V2.9"
			;;
		6571_aliyun_trunk)
			SVN_PATH="svn+ssh://svn@10.20.30.20/mediatek/mt6571/trunk/MT6571_YUNOS_V2.9"
			;;
		6571_branch)
			SVN_PATH="svn+ssh://svn@10.20.30.20/mediatek/mt6571/branches/MT6571.MP.V1.38_P13"
			;;
		6571_trunk)
			SVN_PATH="svn+ssh://svn@10.20.30.20/mediatek/mt6571/trunk/MT6571.MP.V1.38_P13"
			;;
		6582_branch)
			SVN_PATH="svn+ssh://svn@10.20.30.20/mediatek/mt6571/branches/MT6582.MP.V1.19"
			;;
		6582_trunk)
			SVN_PATH="svn+ssh://svn@10.20.30.20/mediatek/mt6571/trunk/MT6582.MP.V1.19"
			;;
		*)
			echo -e "\e[1;33m找不到对应的svn，请确认“分支类型”是否输入正确？\e[0m"
			exit
			;;
	esac

	# 输出信息以便版本编译人员核对
	echo "svn path: ${SVN_PATH}"
	echo "proj name: ${PROJ_DIR}"
	echo "build inputs: ${CUSTOMIZE_VERSION} ${TOPWISE_PROJECT} ${TOPWISE_CUSTOMER} ${PROJ_OPT}"
	echo "sleep time: ${SLEEP_TIME}"
	echo "注意：核对如上参数信息"

	# 延时操作
	if [ "${SLEEP_TIME}" = "now" ]; then
		sleep 1s
	else
		sleep ${SLEEP_TIME}
	fi

	# 代码目录创建和获取
	BASE_DIR=${BASE_DIR}/${SVN_TYPE}
	test -d ${BASE_DIR} || mkdir -p ${BASE_DIR}
	cd ${BASE_DIR}
	local CUR_DATE=`date +%Y%m%d`
	local CUR_TIME=`date +%H`
	do_svn_co ${CUR_DATE}_${CUR_TIME}_${PROJ_DIR} ${SVN_PATH} ${TOPWISE_PROJECT}
	echo "public path: ${BASE_DIR}" >> ./autobuild.log

	# 进入idh.code开始编译版本
	cd ${CUR_DATE}_${CUR_TIME}_${PROJ_DIR}/`basename ${SVN_PATH}`/idh.code
	test -f ../../../autobuild.log && echo "${TOPWISE_CUSTOMER} build start: `date`" >> ../../../autobuild.log
	test -f ../../autobuild.log && echo "${TOPWISE_CUSTOMER} build start: `date`" >> ../../autobuild.log
	./mk -o=${PROJ_OPT} ${TOPWISE_PROJECT} ${TOPWISE_CUSTOMER} pac ${CUSTOMIZE_VERSION}
	test -f ../../../autobuild.log && echo "${TOPWISE_CUSTOMER} build end: `date`" >> ../../../autobuild.log
	test -f ../../autobuild.log && echo "${TOPWISE_CUSTOMER} build end: `date`" >> ../../autobuild.log
}

do_main ${1} ${2} ${3} ${4} ${5} ${6}

