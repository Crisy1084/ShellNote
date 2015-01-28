#!/bin/sh
read -p "Please enter 1 or 2. " var
case $var in
1) echo "OK" ;;
2) echo "Error" ;;
*) echo "Wrong" ;;
esac
