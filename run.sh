#!/bin/sh

make
result=$?
if [ $result -ne 0 ] ; then
	exit $result
fi
echo

echo '----- ASM -----'
./prog_asm.exe <./input.txt | tee ./output_asm.txt
result=$?
if [ $result -ne 0 ] ; then
	exit $result
fi
echo
echo '----- PAS -----'
./prog_pas.exe <./input.txt | tee ./output_pas.txt
result=$?
if [ $result -ne 0 ] ; then
	exit $result
fi
echo

if diff ./output_*.txt ; then
	echo 'Outputs are identical!'
fi

exit 0
