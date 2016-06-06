#!/bin/sh

max_val=3

if [ \( -e ./prog$(expr $max_val + 1).asm \) -o \( -e ./input$(expr $max_val + 1).txt \) ] ; then
	echo ERROR!
	exit 1
fi

make clean

mv ./prog1.asm ./prog$(expr $max_val + 1).asm
mv ./input1.txt ./input$(expr $max_val + 1).txt
for i in $(seq 1 $max_val) ; do
	mv ./prog$(expr $i + 1).asm ./prog${i}.asm
	mv ./input$(expr $i + 1).txt ./input${i}.txt
done

exit 0
