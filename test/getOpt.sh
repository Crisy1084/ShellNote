#!/bin/bash
a=
b=
c=
while getopts a:b:c OPTION
do
	case $OPTION in
		a)a=$OPTARG
			;;
		b)b=$OPTARG
			;;
		c)c=1
			;;
		*)echo "help"
			;;
	esac
done
echo "a=$a"
echo "b=$b"
echo "c=$c"
unset OPTION
unset a b c 
