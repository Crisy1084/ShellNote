#/bin/bash

function scopy()
{
	srcPath=$1
	if [ -z $2 ];then
		destPath="tmp/release"	
	else
		destPath=$2
	fi
	
	expect -c "
	set timeout 1200
	spawn scp -r $srcPath caishaoyi@192.168.1.108:$destPath
	expect \"*password*\"
	set timeout 300
	send \"123456\r\"
	expect eof
	"
}

function getOpts()
{
	srcPath=$1
	destPath=$2


	OPTIND=1
	local OPTION=
	while getopts r OPTION
	do
		case $OPTION in
			r)destPath="tmp/release"
				;;
			*)echo "nothings"
				;;
		esac
	done
	echo $destPath
	scopy $srcPath $destPath
	
}
