#!/bin/sh

if [ \( -e ./prog3.asm \) -o \( -e ./input3.txt \) ] ; then
	echo ERROR!
	exit 1
fi

mv ./prog.asm ./prog3.asm
mv ./prog2.asm ./prog.asm
mv ./prog3.asm ./prog2.asm

mv ./input.txt ./input3.txt
mv ./input2.txt ./input.txt
mv ./input3.txt ./input2.txt

exit 0
