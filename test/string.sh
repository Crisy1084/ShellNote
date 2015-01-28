#!/bin/bash
function ArrayTest()
{
	if [ -z "$1" ];then
		echo "Null-z"
	else
		echo "$1-z"
	fi

	if [ -n "$1" ];then
		echo "$1-n"
	else
		echo "Null-n"
	fi

	if [ "$1" ];then
		echo "$1"
	else
		echo "Null"
	fi

}

ArrayTest $1
