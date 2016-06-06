; ----------------------------------------------------------------------------
; helloworld.asm
;
; This is a Win32 console program that writes "Hello, World" on one line and
; then exits.  It needs to be linked with a C library.
; ----------------------------------------------------------------------------

	global  _main
	extern  _print_pascal_string
	extern  _println_pascal_string
	extern  _print_int8
	extern  _println_int8
	extern  _print_uint8
	extern  _println_uint8
	extern  _print_int16
	extern  _println_int16
	extern  _print_uint16
	extern  _println_uint16
	extern  _print_int32
	extern  _println_int32
	extern  _print_uint32
	extern  _println_uint32
	extern  _read_pascal_string
	extern  _read_int8
	extern  _read_uint8
	extern  _read_int16
	extern  _read_uint16
	extern  _read_int32
	extern  _read_uint32
	
; Section with 0-initialized variables
	section .bss
	
double_var:
	resd 1
double_varN:
	resd 1
i:
	resd 1
	
; Section with constants and program instructions
	section .text

; Constants
msgWriteFactorial:
	db  20, 'Podaj podstawe silni'
msgWriteFactorial2:
	db  7, 'Wynik: '
msgWriteFactorial3:
	db  10, 'Silnia z: '
msgWriteFactorial4:
	db  9, ' wynosi: '
	
_pfactorial:
	;Write question to user
	push    msgWriteFactorial
	call    _println_pascal_string
	add     esp, 4
	;Read user number
	call	_read_uint32
	mov		[double_var], eax
	;Print writed number
	push    dword [double_var]
	call    _println_uint32
	add     esp, 4
	
	mov		dword [double_varN], 1
	
	; Do a loop 
	mov		ecx, 1
	.outerLoopBegin:
	mov		[i], ecx ; number of loop iteration
	
	;calculate
	mov		eax, [double_varN]
	mov		edx, [i]
	mul		edx
	mov		[double_varN], eax
	
	push    msgWriteFactorial3
	call    _print_pascal_string
	add     esp, 4
	push    dword [i]
	call    _print_uint32
	add     esp, 4
	push    msgWriteFactorial4
	call    _print_pascal_string
	add     esp, 4
	push    dword [double_varN]
	call    _println_uint32
	add     esp, 4
	
	; End of the outer loop
	mov		ecx, [i]
	inc		ecx
	cmp		ecx, [double_var]
	jle		.outerLoopBegin
	
	;Write messages to screen
	push    msgWriteFactorial2
	call    _println_pascal_string
	add     esp, 4
	
	;Print value of factoru
	push    dword [double_varN]
	call    _println_uint32
	add     esp, 4
	
	; Return
	ret
; Main function
_main:
	call 	_pfactorial
	
	
	; Return
	ret
