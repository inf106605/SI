prog.exe: prog.obj printers.obj
	gcc prog.obj printers.obj -o prog.exe

prog.obj: prog.asm
	nasm -fwin32 prog.asm

printers.obj: printers.c
	gcc -c printers.c -o printers.obj

clean:
	rm -r -f *.obj *.exe
