; ----------------------------------------------------------------------------
; helloworld.asm
;
; This is a Win32 console program that writes "Hello, World" on one line and
; then exits.  It needs to be linked with a C library.
; ----------------------------------------------------------------------------

    global  _main
    extern  _print_pascal_string
    extern  _print_int8
    extern  _print_uint8
    extern  _print_int16
    extern  _print_uint16
    extern  _print_int32
    extern  _print_uint32

    section .text
_main:
    push    message
    call    _print_pascal_string
    add     esp, 4
	push	0xFFFFFF9A
	call	_print_int8
	call	_print_uint8
	call	_print_int16
	call	_print_uint16
	call	_print_int32
	call	_print_uint32
	add		esp, 4
    ret
message:
    db  14, 'Hello, World!', 10
