#!/bin/bash
function build_custom(){
	a=
	b=
	c=
	#OPTIND 表示下一次运行getopts的时候将读取数组的第optind个
	OPTIND=1
    local OPTION
    while getopts a:b:c:d OPTION
    do
        case $OPTION in
            a) a=$OPTARG
			echo $a
            ;;
            b) b=$OPTARG
			echo $b
            ;;
            c) c=$OPTARG
			echo $c
            ;;
            d) d=1
			echo $d
            ;;
            *) echo "show_custom_helps"
            ;;
        esac
    done
    unset OPTION
	unset a b c 

}