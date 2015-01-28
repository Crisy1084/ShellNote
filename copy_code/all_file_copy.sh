#!/bin/sh


function awk_file(){
	mkdir -p source/allFileList
i=0
for file in `cat source/file_view_code.txt`
do	
	FileSize=`echo $file | wc -L`
	if [ "$FileSize" -ne 0 ];then
		((i++))
		echo $i
		#mkdir $i
		OLD_IFS=$IFS
		#echo $OLD_IFS
		IFS=';'

		for list in $file
		do
			echo $list
			echo $list >> source/allFileList/$i.txt
			#cp -rfv /home/caishaoyi/project/msm8916_new/LINUX/$list $i
			#echo ::::::::::::::::::::::::::::

		done
		IFS=$OLD_IFS
	fi
	#echo $file
done
}
function search(){
i=0
while [ $i -lt 392 ]
do
	((i++))
	echo $i
	sh copy_file.sh -p ~/project/msm8916_new/LINUX/ -c /home/caishaoyi/tmp/shell/copy_code/source/$i -f /home/caishaoyi/tmp/shell/copy_code/source/allFileList/$i.txt 
done


}
function AwkFileQcom(){
i=0
while read line
do
	((i++))
	echo $i   
	    #echo $line
	name=`sed -n "$i"p source/file_view_name.txt`
	#echo $name
	mv source/$i"--"$name/qcom/android source/$i"--"$name/qcom_android
	mv source/$i"--"$name/qcom/$i.txt source/$i"--"$name/$i"_qcom.txt"
	rm -rf source/$i"--"$name/qcom
done < file_view_problem.txt
}
function AwkFileProblem(){
i=0
while read line
do
	((i++))
	#echo $line
	name=`sed -n "$i"p source/file_view_name.txt`
	#echo $name

	echo $line > source/$i"--"$name/$i"_problem.txt"
done < file_view_problem.txt
}
function readbyList()
{
	i=0
	for name in `cat source/file_view_name.txt`
	do
		((i++))
		sh copy_file.sh -p ~/project/msm8916_new/LINUX/ -c /home/caishaoyi/tmp/shell/copy_code/source/$i"--"$name -f /home/caishaoyi/tmp/shell/copy_code/source/allFileList/$i.txt 
	done
}

function qcom_readbyList()
{
	i=0
	for name in `cat source/file_view_name.txt`
	do
		((i++))
		sh copy_file.sh -p ~/project/msm8916_qcom/ -c /home/caishaoyi/tmp/shell/copy_code/source/$i"--"$name/qcom -f /home/caishaoyi/tmp/shell/copy_code/source/allFileList/$i.txt 
	done
}
awk_file
readbyList
qcom_readbyList
AwkFileQcom
AwkFileProblem