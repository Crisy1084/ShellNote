#!/bin/bash
# count the line of the file.
function Count()
{
	MYDIR="decode/"
	DIRLIST=`ls ${MYDIR}`
	SF=()
	MF=()
	LF=()
	for i in ${DIRLIST}
	do
		LINE=`cat ${MYDIR}/$i | wc -l`
		if ((${LINE}<10))
		then
			SF=({SF[*]} $i)
		elif ((${LINE}>=10)) && ((${LINE}<=100))
		then
			MF=(${MF[*]} $i)
		elif ((${LINE}>100))
		then
			LF=(${LF[*]} $i)
		fi
	done
	echo Small files: ${SF[*]}
	echo Medium files: ${MF[*]}
	echo Large files: ${LF[*]}
}

function Learn()
{
	DIRLIST=`ls $1`
	SF=()
	MF=()
	LF=()
	for file in $DIRLIST
	do
		LINE=`cat $1/$file | wc -l`
		if (( $LINE < 10 ));then
			SF=(${SF[*]} $file)
		elif (( $LINE >= 10 )) && (( $LINE <= 100 ));then
			MF=(${MF[*]} $file)
		elif (( $LINE > 100 ));then
			LF=(${LF[*]} $file)
		fi
	done
	echo Small file : "${SF[*]}"
	echo Medium file : "${MF[*]}"
	echo Large file : "${LF[*]}"
}

Learn $1
