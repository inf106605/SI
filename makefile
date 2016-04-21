prog.exe: prog.obj c_printers.obj
	gcc prog.obj c_printers.obj -o prog.exe

prog.obj: prog.asm
	nasm -fwin32 prog.asm

c_printers.obj: c_printers.c
	gcc -c c_printers.c -o c_printers.obj
