#!/bin/bash
cp -rfv decode.log decode.tmp
sed -i 's/decode_msm8916/project\/msm8916_topwise/g' decode.tmp
i=0
for File in `cat decode.tmp`
do
	((i++))
	j=0
	for Dest_file in `cat decode.log`
	do
		((j++))
		if [ $j -eq $i ];then
			echo $Dest_file
			echo $File
			expect -c "
			spawn scp caishaoyi@10.20.31.114:$Dest_file $File 
			expect {
				{\"*password*\" send \"caishaoyi\r\"}	
			};
			"
			break
		else
			continue
		fi
	done
done

