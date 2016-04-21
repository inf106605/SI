.PHONY: all
all: prog_asm.exe prog_pas.exe

translator.exe: translator.pl
	swipl --traditional -o translator.exe -c translator.pl --goal=main 2>/dev/null

prog.pas: prog.asm translator.exe
	translator.exe <prog.asm >prog.pas

prog_asm.exe: prog_asm.obj printers.obj
	gcc prog_asm.obj printers.obj -o prog_asm.exe

prog_asm.obj: prog.asm
	nasm -fwin32 prog.asm
	mv prog.obj prog_asm.obj

printers.obj: printers.c
	gcc -c printers.c -o printers.obj

prog_pas.exe: prog.pas
	fpc prog.pas >/dev/null
	rm -f prog.o
	mv prog.exe prog_pas.exe

.PHONY: clean
clean:
	rm -f *.o *.obj *.exe
