#!/bin/bash
function cycle()
{
	base=$1
	top=$2
	number=99999
	while [ "$number" -ge "$top" ] || [ "$number" -le "$base" ]
	do
		number=$RANDOM
	done
	print $base $top $num
}

function division()
{
	min=$1
	max=$2-$1
	echo max=$max
	num=`date +%s%N`
	((return=num%max+min))
	print $min $max $return
}

function print()
{
	local base=$1
	local top=$2
	local number=$3
	echo "Random number $base ~ $top --- $number"#
	
}

division $1 $2
