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
	
str_var:
	resb 256
byte_var:
	resb 1
word_var:
	resw 1
double_var:
	resd 1

; Section with constants and program instructions
	section .text

; Constants
msg1:
	db  14, 'Hello, World!', 10
msg2:
	db  22, 'Goodbye, Cruel World!', 10
constByte:
	dd	14

; Main function
_main:
	;mov		eax, [constByte]
	;dec		eax
	;mov		[byte_var], eax
	
	; Write const byte
	push	dword [constByte]
	call	_println_uint8
	add		esp, 4
	
	; Write first messsage to console
	push    msg1
	call    _print_pascal_string
	add     esp, 4
	
	; Read user string
	push	str_var
	call	_read_pascal_string
	add		esp, 4
	; Read user byte
	call	_read_uint8
	mov		[byte_var], al
	; Read user word
	call	_read_uint16
	mov		[word_var], ax
	; Read user double
	call	_read_uint32
	mov		[double_var], eax
	
	; A few arithmetical stuff on user input
	mov		eax, [word_var]
	sub		al, [byte_var]
	mov		[word_var], eax
	mov		eax, [byte_var]
	dec		eax
	mov		[byte_var], eax
	
	; Write second messsage to console
	push    msg2
	call    _print_pascal_string
	add     esp, 4
	
	; Write user string
	push    str_var
	call    _println_pascal_string
	add     esp, 4
	; Write user byte
	push	dword [byte_var]
	call	_println_uint8
	add		esp, 4
	; Write user double
	push	dword [word_var]
	call	_println_uint16
	add		esp, 4
	; Write user double
	push	dword [double_var]
	call	_println_uint32
	add		esp, 4
	
	; Return
	ret
