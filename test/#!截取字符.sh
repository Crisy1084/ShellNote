#!/bin/bash 

var=http://www.linuxidc.com/test.htm


# NO.1   "#" 号截取，删除左边字符，保留右边字符。
#   其中 var 是变量名，# 号是运算符，*// 表示从左边开始删除第一个 // 号及左边的所有字符
#   即删除 http://
#   结果是 ：www.linuxidc.com/test.htm
#echo ${var#*//}


# NO.2  "##" 号截取，删除左边字符，保留右边字符。
#   ##*/ 表示从左边开始删除最后（最右边）一个 / 号及左边的所有字符
#   即删除 http://www.linuxidc.com/         
#   结果是 test.htm
#echo ${var##*/}


# NO.3  % 号截取，删除右边字符，保留左边字符
#   %/* 表示从右边开始，删除第一个 / 号及右边的字符
#   结果是：http://www.linuxidc.com
#echo ${var%/*}


# NO.4  %% 号截取，删除右边字符，保留左边字符
#   %%/* 表示从右边开始，删除最后（最左边）一个 / 号及右边的字符
#   结果是：http:
#echo ${var%%/*}


# NO.5  从左边第几个字符开始，及字符的个数
#   其中的 0 表示左边第一个字符开始，5 表示字符的总个数。
#   结果是：http:
#echo ${var:0:5}



#var=http://www.linuxidc.com/test.htm

# NO.6  从左边第几个字符开始，一直到结束。
#   其中的 7 表示左边第8个字符开始，一直到结束。
#   结果是 ：www.linuxidc.com/test.htm
#echo ${var:7}


# NO.7  从右边第几个字符开始，及字符的个数
#   其中的 0-7 表示右边算起第七个字符开始，3 表示字符的个数。
#   结果是：test
#echo ${var:0-8:3}



# NO.8  从右边第几个字符开始，一直到结束。
#   表示从右边第七个字符开始，一直到结束。
#   结果是：test.htm
#echo ${var:0-8}













