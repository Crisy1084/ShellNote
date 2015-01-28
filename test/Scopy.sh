#!/bin/bash
echo "start!"
expect -c "
spawn scp caishaoyi@10.20.31.114:$1 $2
expect 
{
	\"*password*\" {send \"caishaoyi\r\";}	
};"

echo "sucessful!"
