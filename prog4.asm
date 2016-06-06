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
	extern  _println
	extern  _read_pascal_string
	extern  _read_int8
	extern  _read_uint8
	extern  _read_int16
	extern  _read_uint16
	extern  _read_int32
	extern  _read_uint32
	
; Section with 0-initialized variables
	section .bss
	
n:
	resd	1
x:
	resd	1
y:
	resd	1
i:
	resd	1

; Section with constants and program instructions
	section .text

; Main function
_main:
	; Read max i
	call	_read_uint32
	mov		[n], eax
	; Initialization
	mov		dword [x], 1
	; For begin
	mov		ecx, 0
	.loopBegin:
	mov		[i], ecx
	; Step
	xor		edx, edx
	mov		eax, [n]
	mov		ebx, [x]
	div		ebx
	mov		[y], eax
	mov		eax, [x]
	add		eax, [y]
	mov		[x], eax
	xor		edx, edx
	mov		eax, [x]
	mov		ebx, 2
	div		ebx
	mov		[x], eax
	; For end
	mov		ecx, [i]
	inc		ecx
	cmp		ecx, 10
	jle		.loopBegin
	; Write result
	push	dword [x]
	call	_println_uint32
	add		esp, 4
	; Return
	ret
