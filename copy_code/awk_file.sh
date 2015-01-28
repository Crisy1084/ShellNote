#!/bin/sh


function awk_file(){
#cat proble.xml | awk '/<Cell/,/<\/Cell>/'
#cat view.txt | awk -F "END" '{print $1} > '
#cat view.txt |   sed -nr 's/BEGIN(.*)/END/p'
#	IFS='END'
#	i=0
#IFS='\n'
#for file in `cat filetest.txt | perl -nle 'print  while m/(BEGIN.*?END)/g;'  `
#for file in `cat view.txt  `
#	do
#
#		((i++))
#		echo $i
#		echo $file
#		echo =============
#
#	done
#for k in `cat view.txt`
#do
#if [ "${k:0:5}" == "BEGIN" ]; then
#    echo "${k#*BEGIN}" | awk -F"END" '{ print $1 }'
#fi
#done

while read line
do
	((i++))
	echo $i   
	    echo $line
	name=`sed -n "$i"p source/file_view_name.txt`
	echo $name
	 source/$i"--"$name/qcom/android source/$i"--"$name/qcom_android
	#mv source/$i"--"$name/qcom/$i.txt source/$i"--"$name/$i"_qcom.txt"
done < file_view_problem.txt
}

awk_file

