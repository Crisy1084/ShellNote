count=0  
while [ "$count" -lt 1000 ]; do  
	echo "$count"  
	adb shell input keyevent "$count"  
	count=$(($count+1))  
done  
