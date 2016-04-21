#!/bin/sh

make && echo ; echo '----- ASM -----' ; ./prog_asm.exe ; echo ; echo '----- PAS -----' ; ./prog_pas.exe

exit $?
