%ifndef MACROS_MAC
%define MACROS_MAC

; Macro: Signalize program termination
;   %1 Exit status
%macro sys_exit 1
    mov ebx, %1    ; exit status
    mov eax, 1    ; sys_exit
    int 0x80
%endmacro

; ---------------------------------------------------------
; DATA DEFINITION HELPERS
; ---------------------------------------------------------

; Macro: Define String
;   %1 symbol name
;   %2 string
%macro def_str 2
    %1 db  %2
    %1.len equ $ - %1
%endmacro

; ---------------------------------------------------------
; OLD PRINT STRING UTILITIES
; ---------------------------------------------------------

; Macro: Initialize array with number
; Stack paramaters:
;   %1 char
;   %2 string address
;   %3 string length
%macro fstring_init 3
    push %1
    push %2
    push %3
    call fun_string_init 
    add esp, 4*3
%endmacro

; Macro: Print \n
%macro fprintln 0
    push newline
    push 1
    call fun_print
    add esp, 8
%endmacro

; Macro: Print string
; paramaters:
;   %1 string address
;   %2 string length
%macro fprint 2
    push %1
    push %2
    call fun_print
    add esp, 8
%endmacro

; ---------------------------------------------------------
; PRINT FUNCION UTILITIES
; ---------------------------------------------------------

; Macro: Print line break
%macro println 0
    mov [char], byte 0x0a
    call_ fun_print, char, 1
%endmacro

; Macro: Print int
;   %1 int to print
%macro print_int 1
    call_ fun_int_to_str, %1
    ;call_ fun_print, buffer, buffer.len
%endmacro

; Macro: Print int with trailing space
;   %1 int to print
%macro print_intsp 1
    call_ fun_int_to_str, %1
    print_char byte ' '
%endmacro

; Macro: Print int and break line
;   %1 int to print
%macro print_intln 1
    print_int %1
    println
%endmacro

; Macro: Print String
;   %1 string address
%macro print_str 1
    call_ fun_print, %1, %1.len
%endmacro

; Macro: Print String and break line
;   %1 string address
%macro print_strln 1
    print_str %1
    println
%endmacro

; Macro: Print char
;   %1 char to print
%macro print_char 1
    mov [char], byte %1
    print_str char
%endmacro

; ---------------------------------------------------------
; TYPEOF MACRO
; ---------------------------------------------------------

%define IMMEDIATE_TYPE   0
%define REGISTER_TYPE    1
%define OTHER_TYPE       2
%define INTEGER_TYPE_ID  3
%define FLOAT_TYPE_ID    4
%define STRING_TYPE_ID   5
%define FUNCTION_TYPE_ID 6

%define TypeOf.eax      REGISTER_TYPE
%define TypeOf.ebx      REGISTER_TYPE
%define TypeOf.ecx      REGISTER_TYPE
%define TypeOf.edx      REGISTER_TYPE
%define TypeOf.edi      REGISTER_TYPE
%define TypeOf.esi      REGISTER_TYPE

%macro is_reg 1
    %ifndef TypeOf.%1
        %define result IMMEDIATE_TYPE
    %elif TypeOf.%1 = REGISTER_TYPE
        %define result REGISTER_TYPE
    %else
        %define result OTHER_TYPE
    %endif
%endmacro

; ---------------------------------------------------------
; PUSH / POP UTILITIES FOR SUBROUTINES
; ---------------------------------------------------------

%macro push_ebp 0
    push ebp
    mov ebp, esp
%endmacro

%macro pop_ebp 0
    pop ebp
%endmacro

%macro push_regs 1-*
%rep %0
    push %1
    %rotate 1       ; rotate macro params to left
%endrep
%endmacro

%macro pop_regs 1-*
%rep %0
    %rotate -1      ; rotate macro params to right
    pop %1
%endrep
%endmacro

; ---------------------------------------------------------
; SUBROUTINE CALL AND PARAMETERS
; ---------------------------------------------------------
; reg
; reg
; local     -8
; local     -4
; ebp       <
; @return
; param     +8
; param     +12

%macro call_ 1-*
    %rep %0-1       ; push args
        %rotate 1   ; rotate left
        push %1
    %endrep
    %rotate 1
    call %1
    %if %0 > 1
        add esp, 4*(%0-1)
    %endif
%endmacro

%macro params_ 1-*    ; DOESN'T WORK...
    %assign i 8
    %rep %0
        %rotate -1          ; rotate macro params right
        %define %1 [ebp+i]
        %assign i i+4       ; assign must written before using it
    %endrep
%endmacro

%macro params 1
    %define %1 [ebp+8]
%endmacro

%macro params 2
    %define %1 [ebp+12]
    %define %2 [ebp+8]
%endmacro

%macro params 3
    %define %1 [ebp+16]
    %define %2 [ebp+12]
    %define %3 [ebp+8]
%endmacro

%macro params 4
    %define %1 [ebp+20]
    %define %2 [ebp+16]
    %define %3 [ebp+12]
    %define %4 [ebp+8]
%endmacro

%macro params 5
    %define %1 [ebp+24]
    %define %2 [ebp+20]
    %define %3 [ebp+16]
    %define %4 [ebp+12]
    %define %5 [ebp+8]
%endmacro

; ---------------------------------------------------------
; LOCAL STACK VARS UTILITIES FOR SUBROUTINES
; ---------------------------------------------------------

; local2    -8
; local1    -4
; ebp   <
; @return
; param1    +8
; param2    +12

%macro push_vars_ 1-*
    %assign i 0
    %rep %0
        %assign i i+4
        %define %1 [ebp-i]
        %rotate 1           ; rotate macro params left
    %endrep
    sub esp, 4*%0           ; allocate space in stack
%endmacro

%macro push_vars 1
    %define %1 [ebp-4]
    sub esp, 4*%0           ; allocate space in stack
%endmacro

%macro push_vars 2
    %define %1 [ebp-4]
    %define %2 [ebp-8]
    sub esp, 4*%0           ; allocate space in stack
%endmacro

%macro push_vars 3
    %define %1 [ebp-4]
    %define %2 [ebp-8]
    %define %3 [ebp-12]
    sub esp, 4*%0           ; allocate space in stack
%endmacro

%macro push_vars 4
    %define %1 [ebp-4]
    %define %2 [ebp-8]
    %define %3 [ebp-12]
    %define %4 [ebp-16]
    sub esp, 4*%0           ; allocate space in stack
%endmacro

%macro pop_vars 1
    add esp, 4*%1      ; free locals in stack
%endmacro

%endif