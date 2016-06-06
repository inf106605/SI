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

i:
	resd 1
j:
	resd 1

; Section with constants and program instructions
	section .text

; Constants
helloWorldMsg:
	db  30, 'Writting string: Hello, World!'
goodbyeWordlMsg:
	db  31, 'Writting: Goodbye, Cruel World!'
secondValLessMsg:
	db	29, 'Second value is less than 32.'
thirdValLessMsg:
	db	28, 'Third value is less than 32.'
thirdValNotLessMsg:
	db	32, 'Third value is not less than 32.'
msgWriteConstByte:
	db  33, 'Writting value from constant byte'
msgReadString:
	db  11, 'Read string'
msgReadByte:
	db  9, 'Read byte'
msgReadWord:
	db  9, 'Read word'
msgReadDouble:
	db  11, 'Read double'
msgWriteString:
	db  13, 'Write string:'
msgWriteByte:
	db  11, 'Write byte:'
msgWriteWord:
	db  11, 'Write word:'
msgWriteDouble:
	db  13, 'Write double:'
msgWriteSub0:
	db  15, 'Sub: word-byte:'
msgWriteSub:
	db  14, 'Sub: val word:'
msgWriteDec:
	db  14, 'Dec: val byte:'
msgLoop1:
	db  6, '3xLoop'
msgLoop2:
	db  6, '2xLoop'
msgLoop3:
	db  12, 'End of loops'
constByte:
	dd	14

_pWriteHelloWorld:
	push    helloWorldMsg
	call    _println_pascal_string
	add     esp, 4
	ret

_pRunLoops:
	;Write messages to screen
	push    msgLoop1
	call    _println_pascal_string
	add     esp, 4
	
	; Do a loopty loop (x3)
	mov		ecx, 1
	.outerLoopBegin:
	mov		[i], ecx
	; Write second messsage to console
	push    goodbyeWordlMsg
	call    _println_pascal_string
	add     esp, 4
	
	;Write messages to screen
	push    msgLoop2
	call    _println_pascal_string
	add     esp, 4
	; Do a backward loopty loop (x2)
	mov		ecx, 2
	.innerLoopBegin:
	mov		[j], ecx
	; Write loop counter to console
	push    dword [j]
	call    _println_uint32
	add     esp, 4
	; End of the inner loop
	mov		ecx, [j]
	dec		ecx
	cmp		ecx, 1
	jge		.innerLoopBegin
	; End of the outer loop
	mov		ecx, [i]
	inc		ecx
	cmp		ecx, 3
	jle		.outerLoopBegin
	
	;Write messages to screen
	push    msgLoop3
	call    _println_pascal_string
	add     esp, 4
	; Return
	ret

_pReadUserVariables:
	;Write messages to screen
	push    msgReadString
	call    _println_pascal_string
	add     esp, 4
	; Read user string
	push	str_var
	call	_read_pascal_string
	add		esp, 4
	
	;Write messages to screen
	push    msgReadByte
	call    _println_pascal_string
	add     esp, 4
	; Read user byte
	call	_read_uint8
	mov		[byte_var], al
	
	;Write messages to screen
	push    msgReadWord
	call    _println_pascal_string
	add     esp, 4
	; Read user word
	call	_read_uint16
	mov		[word_var], ax
	
	;Write messages to screen
	push    msgReadDouble
	call    _println_pascal_string
	add     esp, 4
	; Read user double
	call	_read_uint32
	mov		[double_var], eax
	; Return
	ret

_pWriteUserVariables:
    ;Write messages to screen
	push    msgWriteString
	call    _println_pascal_string
	add     esp, 4
	; Write user string
	push    str_var
	call    _println_pascal_string
	add     esp, 4
	
	;Write messages to screen
	push    msgWriteByte
	call    _println_pascal_string
	add     esp, 4
	; Write user byte
	push	dword [byte_var]
	call	_println_uint8
	add		esp, 4
	
	;Write messages to screen
	push    msgWriteWord
	call    _println_pascal_string
	add     esp, 4
	; Write user double
	push	dword [word_var]
	call	_println_uint16
	add		esp, 4
	
	;Write messages to screen
	push    msgWriteDouble
	call    _println_pascal_string
	add     esp, 4
	; Write user double
	push	dword [double_var]
	call	_println_uint32
	add		esp, 4
	; Return
	ret

_pDoMath:
	;;;SUB
	;Write messages to screen
	push    msgWriteSub0
	call    _println_pascal_string
	add     esp, 4
	push    msgWriteSub
	call    _println_pascal_string
	add     esp, 4
	push    dword [word_var]
	call    _println_uint16
	add     esp, 4
	
	; word_var -= byte_var
	mov		eax, [word_var]
	sub		al, [byte_var]
	mov		[word_var], eax
	
	;Write messages to screen
	push    msgWriteSub
	call    _println_pascal_string
	add     esp, 4
	push    dword [word_var]
	call    _println_uint16
	add     esp, 4
	
	;;;DEC
	;Write messages to screen
	push    msgWriteDec
	call    _println_pascal_string
	add     esp, 4
	push    dword [byte_var]
	call    _println_uint8
	add     esp, 4
	
	; --byte_var
	mov		eax, [byte_var]
	dec		eax
	mov		[byte_var], eax
	
	;Write messages to screen
	push    msgWriteDec
	call    _println_pascal_string
	add     esp, 4
	push    dword [byte_var]
	call    _println_uint8
	add     esp, 4
	; Return
	ret

_pWriteConstByte:
	;Write messages to screen
	push    msgWriteConstByte
	call    _print_pascal_string
	add     esp, 4
	
	; Write const byte
	push	dword [constByte]
	call	_println_uint8
	add		esp, 4	
	; Return
	ret

_pDoConditions:
	; Check if second user value is less than 32
	mov		al, [byte_var]
	cmp		al, 32
	jge		.endFirstIf
	push    secondValLessMsg
	call    _println_pascal_string
	add     esp, 4
	.endFirstIf:
	; Check if third user value is less than 32
	mov		ax, [word_var]
	cmp		ax, 32
	jge		.elseSecondIf
	push    thirdValLessMsg
	call    _println_pascal_string
	add     esp, 4
	jmp		.endSecondIf
	.elseSecondIf:
	push    thirdValNotLessMsg
	call    _println_pascal_string
	add     esp, 4
	.endSecondIf:
	; Return
	ret
	
_pDoFor:
	mov		ecx, [double_var]
	.outerLoopBegin:
	mov		[i], ecx
	mov		ecx, [i]
	inc		ecx
	cmp		ecx, [double_var]
	jle		.outerLoopBegin
	; Return
	ret
	
; Main function
_main:
	call 	_pWriteConstByte
	call	_pWriteHelloWorld
	call	_pReadUserVariables
	call	_pDoMath
	call	_pRunLoops
	call	_pWriteUserVariables
	call	_pDoConditions
	call	_pDoFor
	
	; Return
	ret
