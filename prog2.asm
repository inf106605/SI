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
	
user_name:
	resb 256
born_year:
	resd 1
age:
	resd 1

i:
	resd 1

; Section with constants and program instructions
	section .text

; Constants
whatIsYourNameMsg:
	db  18, 'What is your name?'
helloMsg:
	db  6, 'Hello '
exclamationMsg:
	db  1, '!'

letCountMsg:
	db  21, 'Let', 39, 's count a little!'
whatYearMsg:
	db	27, 'What year were you born in?'
wowMsg:
	db	14, 'WOW, you have '
yearsMsg:
	db	7, ' years!'
bigBoyMsg:
	db	31, 'You are such a big, smart boy, '

letCountMoreMsg:
	db  26, 'Let', 39, 's count a little more!'
tenAndFingers:
	db	60, 'Yeah, ten! That', 39, 's as much as you have fingers on both hands.'

currentYear:
	dd	2016

_pGetUserName:
	; Ask about name
	push	whatIsYourNameMsg
	call	_println_pascal_string
	add		esp, 4
	; Get name
	push	user_name
	call	_read_pascal_string
	add		esp, 4
	; Say hello
	push	helloMsg
	call	_print_pascal_string
	add		esp, 4
	push	user_name
	call	_print_pascal_string
	add		esp, 4
	push	exclamationMsg
	call	_println_pascal_string
	add		esp, 4
	; Write empty line
	call	_println
	; Return
	ret

_pShowBigBoyMessage:
	push	bigBoyMsg
	call	_print_pascal_string
	add		esp, 4
	push	user_name
	call	_print_pascal_string
	add		esp, 4
	push	exclamationMsg
	call	_println_pascal_string
	add		esp, 4
	ret

_pCountALittle:
	; Say that it is time to count a little
	push	letCountMsg
	call	_println_pascal_string
	add		esp, 4
	; Ask about born year
	push	whatYearMsg
	call	_println_pascal_string
	add		esp, 4
	; Get born year
	call	_read_uint32
	mov		[born_year], eax
	; Count age
	mov		eax, [currentYear]
	sub		eax, [born_year]
	mov		[age], eax
	; Say age
	push	wowMsg
	call	_print_pascal_string
	add		esp, 4
	push	dword [age]
	call	_print_uint32
	add		esp, 4
	push	yearsMsg
	call	_println_pascal_string
	add		esp, 4
	; Say user is big boy
	call	_pShowBigBoyMessage
	; Write empty line
	call	_println
	; Return
	ret

_pCountALittleMore:
	; Say that it is time to count a little more
	push	letCountMoreMsg
	call	_println_pascal_string
	add		esp, 4
	; Count from 1 to 10
	mov		ecx, 1
	.outerLoopBegin:
	mov		[i], ecx
	push    dword [i]
	call    _println_uint32
	add     esp, 4
	mov		ecx, [i]
	inc		ecx
	cmp		ecx, 10
	jle		.outerLoopBegin
	; Say about fingers
	push	tenAndFingers
	call	_println_pascal_string
	add		esp, 4
	; Return
	ret

; Main function
_main:
	call	_pGetUserName
	call	_pCountALittle
	call	_pCountALittleMore
	ret
