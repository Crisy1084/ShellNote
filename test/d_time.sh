#!/bin/bash

current_time=`date +%s`

num=1
while [ $num -lt 999999 ]
do
	#echo $num
	#num=$(($num+1))
	#num=$[$num+1]
	((num++))
	#let num+=1
	#num=`expr $num + 1`
done


finish_time=`date +%s`

#d_time=`expr $(($finish_time-$current_time))`
d_time=`echo "$finish_time-$current_time" |bc`
echo 耗时$d_time秒
