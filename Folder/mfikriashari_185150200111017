#!/bin/bash

usage()
{
    echo "usage: ./ape.sh JumlahDirektori"
}

if [  $# -le 0 ] 
	then 
		usage
		exit 1
fi

if [ "$1" == "0" ]; then
	echo "Tidak dapat membuat 0 folder!"
	echo "Nilai parameter harus lebih besar dari 0!"
else
	for (( i=1; i<="$1"; i++ ))
	do
		mkdir "$i"
	done
fi

echo "Sukses membuat $1 folder!"