#!/bin/bash
CURRENT_PID=$$
function download_code()
{
	svn co svn+ssh://10.20.30.18/msm8916/branches/LA1.1-CS-r113511.1 msm8916
}
function code_sync()
{
	#同步远程的代码:忽略.svn文件
	rsync -arvzP --progress  --exclude="*.svn" caishaoyi@10.20.31.114:project/encrypt_msm8916/* ./msm8916
}

function decode_code()
{
	sh ~/project/findfile_Decode.sh ./msm8916
}

function build_project()
{
	~/tmp/shell/cpproj/Cpproj.exe msm8916 p9388 m711
}

function compile_code()
{
	Root=`pwd`
	cd ~/project/msm8916/LINUX
	./compile.sh n M711_DZTX eng v1.0.0
	cd $Root
}
function stop_task()
{
	kill -SIGINT $CURRENT_PID
}
function main()
{
	#code_sync
	decode_code
	build_project
	compile_code
}

main