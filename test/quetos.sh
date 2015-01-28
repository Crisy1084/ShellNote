#!/bin/bash
SHELL=hello,shell1
echo $SHELL
echo "$SHELL"
echo '$SHELL'


echo *.zip\n
echo "zi\tp"
echo '*.zip'
echo '*.zi\n p'


zip=*.zip

echo $zip
echo "$zip"
echo '$zip'
echo '$z'i'p'
echo '$z\n ip'

LOGNAME=yeexun
test=ok

echo "who am i:$LOGNAME"	
#结果：who am i:yeexun	
echo "who am i:'$LOGNAME'"	
#结果：who am i:'yeexun'	''被当成普通字符串了；
echo "who am i:"$LOGNAME""	
#结果：who am i:yeexun

echo 'who am i:$LOGNAME'	
#结果：who am i:$LOGNAME	
echo 'who am i:"$LOGNAME"'	
#结果：who am i:"$LOGNAME"	
echo 'who am $test i:'$LOGNAME''
#结果：who am i:yeexun
