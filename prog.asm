; ----------------------------------------------------------------------------
; helloworld.asm
;
; This is a Win32 console program that writes "Hello, World" on one line and
; then exits.  It needs to be linked with a C library.
; ----------------------------------------------------------------------------

    global  _main
    extern  _print_pascal_string

    section .text
_main:
    push    message
    call    _print_pascal_string
    add     esp, 4
    ret
message:
    db  14, 'Hello, World!', 10
