; x86 Assembly Program
;   Allocating and iterating over array
;
; ----------------------------------------------------
; nasm -f elf32 prog.asm -o prog1.o
; gcc -o prog.elf -m32 prog.o -nostdlib -static
; echo $?    <- show last program output
;
; registers: https://en.wikibooks.org/wiki/X86_Assembly/X86_Architecture 

; ========================================
; MACROS
; ========================================
%include "macros.asm"

%macro summation 1-*
    mov edi, 0
    %rep %0
        add edi, %1
        %rotate 1
    %endrep

    print_intln edi
%endmacro

section .text

; ========================================
; SUBROUTINES
; ========================================

; Testing paramaters access
; ----------------------------------------------
; Stack Parameters:
;   %1 number 1
;   %2 number 2
;   %3 number 3
fun_test:
    stack_params .num1, .num2, .num3
    ;push_stack .a, .b, .c, eax, ebx, ecx
    push_ebp
    push_vars .a, .b, .c
    push_regs eax, ebx, ecx

    mov eax, .num1
    mov .a, eax

    mov eax, .num2
    mov .b, eax

    mov eax, .num3
    mov .c, eax
    add .c, dword 5
    sub .c, dword 10

    print_intsp dword .a
    print_intsp dword .b
    print_intsp dword .c
    println

    is_reg ax
    mov edi, result         ; symbol for macro return
    print_intln edi

    pop_regs eax, ebx, ecx
    pop_vars 3
    pop_ebp

    ret

; Print string
; ----------------------------------------------
; Stack Paramaters:
;   %1 string address
;   %2 string length in bytes
fun_print:
    stack_params .str, .n

    push_ebp
    ; push_locals
    push_regs eax, ebx, ecx, edx  
    
    mov     ecx, .str
    mov     edx, .n
    mov     ebx, 1
    mov     eax, 4
    int     0x80

    mov edi, .n
    
    pop_regs eax, ebx, ecx, edx
    ; pop_locals
    pop_ebp

    ret

; Convert int to str
; ----------------------------------------------
; Stack params:
;   %1 int number
fun_int_to_str:
    stack_params .num

    push_ebp
    ;push_locals
    push_regs eax, ebx, edx, esi, ecx

    ; find int number length
    
    mov ecx, 0      ; counter
    mov ebx, 10     ; divisor
    mov eax, .num
.loop_count:
    mov edx, 0      ; reset remainder
    div ebx         ; eax: quotient,  edx: remainder
    
    inc ecx         ; counter++
    cmp eax, 0
    jne .loop_count

    ; convert number to string

    mov ebx, 10     ; divisor
    ;mov ecx, buffer.len   ; ecx = last string index
    mov esi, ecx   ; ecx = last number index
    dec esi

    mov eax, .num
.loop_extract:
    mov edx, 0      ; reset remainder
    div ebx         ; eax /= ebx; edx = eax mod ebx

    add edx, byte '0'
    mov [buffer+esi], dl
    mov [buffer+esi], dl
    dec esi         ; index--
    
    ; print each digit
    ;mov [sum], dl  
    ;call_ fun_print, sum, 1

    cmp eax, 0      ; if eax == 0: end
    jg .loop_extract
    ; end loop

    ; reset remainder of buffer to zero
;.loop_spaces:
;    mov [buffer+esi], byte '0'  
;    dec esi;

;    cmp esi, 0
;    jg .loop_spaces       ; if index != 0: loop
    ; end loop

    call_ fun_print, buffer, ecx

    pop_regs eax, ebx, edx, esi, ecx
    ;pop_locals
    pop_ebp
    ret

; Print an array of positive integers
; ----------------------------------------------
; Stack Paramaters:
fun_print_array:
    %define .idx ebx

    push_ebp
    ; push_locals
    push_regs ebx
    
    mov .idx, 0
.loop:
    print_int dword [vec+.idx]
    print_str sep
    add .idx, 4

    cmp .idx, vec.len
    jl .loop
    ; end loop

    println

    pop_regs ebx
    ; pop_locals
    pop_ebp
    ret


; ----------------------------------------------
; START
; ----------------------------------------------

global _start

_start:  
    call_ fun_print_array

    summation 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

    push msg
    push msg.len
    call fun_print
    add esp, 4*2
    println

    print_strln msg

    print_intln 12
    print_intln 1234
    print_intln 123456
    
    print_strln msg

    ; put result in edi
    call_ fun_test, 1, 10, 100

    mov eax, 1
    mov ebx, edi  ; exit status
    int 0x80

section .data
    def_str msg, "Printing a string!"

    vec dd 1,2,3,4,5,6,7
    vec.len equ $ - vec         ; size in bytes
    vec.n equ vec.len/4         ; numbers of dword elements

    def_str buffer, "000000000000"

    def_str char, "0"
    def_str sep, ", "

segment .bss
    sum resb 1