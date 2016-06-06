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
	
x:
	resd	1
y:
	resd	1
z:
	resd	1
i:
	resd	1
maxI:
	resd	1

; Section with constants and program instructions
	section .text

separator:
	db		2, ')', 9

; Main function
_main:
	; Read max i
	call	_read_uint32
	mov		[maxI], eax
	; Initialization
	mov		dword [x], 0
	mov		dword [y], 1
	; For begin
	mov		ecx, 0
	.loopBegin:
	mov		[i], ecx
	; Write result
	push	dword [i]
	call	_print_uint32
	add		esp, 4
	push	separator
	call	_print_pascal_string
	add		esp, 4
	push	dword [x]
	call	_println_uint32
	add		esp, 4
	; Fibonnaci step
	mov		eax, [x]
	add		eax, [y]
	mov		[z], eax
	mov		eax, [y]
	mov		[x], eax
	mov		eax, [z]
	mov		[y], eax
	; For end
	mov		ecx, [i]
	inc		ecx
	cmp		ecx, [maxI]
	jle		.loopBegin
	; Return
	ret
