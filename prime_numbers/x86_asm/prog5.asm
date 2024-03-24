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

; ----------------------------------------
; GENERATE PRIMES
; ----------------------------------------

; generate prime numbers up to N
%define numbers.n 5000000

; SET ARRAY TO ZERO
%macro reset_primes_map 0
    ; zero array to zero
    mov ebx, 0
.loop_zero:
    mov [numbers+ebx], byte 0
    inc ebx

    cmp ebx, numbers.n+1
    jl .loop_zero
%endmacro

; PRINT PRIMES BY ARRAY INDEXES
%macro print_primes 0
    print_str text_primes
    
    mov ebx, 2
.loop_print:
    xor ecx, ecx
    mov cl, [numbers+ebx]
    
    cmp cl, 0
    jne .loop_print_end
    print_intsp ebx

.loop_print_end:
    inc ebx
    
    cmp ebx, numbers.n+1
    jl .loop_print

    println
%endmacro

; GENERATE PRIME NUMBERS
%macro generate_primes 0
    reset_primes_map
    ;print_str text_map
    ;call_ fun_print_array_byte, numbers, numbers.n+1

.sieve:
    ; Sieve of Eratosthenes
    %define .half   numbers.n/2

    %define .num ebx
    %define .multi eax

    mov .num, 2
.loop:
    cmp .num, .half
    jge .end

    cmp [numbers+.num], byte 0
    jne .loop_inc

    mov .multi, .num
    ;mul .multi
    add .multi, .multi

    .loop2:
        cmp .multi, numbers.n
        jg .loop_inc

        mov [numbers+.multi], byte 1
        add .multi, .num

        jmp .loop2

    .loop_inc:
        inc .num

    jmp .loop
.end:

    ;print_str text_map
    ;call_ fun_print_array_byte, numbers, numbers.n+1
    ;print_primes
%endmacro

section .text

%include "utils.asm"

; ========================================
; SUBROUTINES
; ========================================

; Subroutine: Testing paramaters access
; ----------------------------------------------
; Stack Parameters:
;   %1 number 1
;   %2 number 2
;   %3 number 3
fun_test:
    params .num1, .num2, .num3
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
    sub .c, dword 3

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

; ----------------------------------------------
; START
; ----------------------------------------------
global _start

_start:  
    ;print_strln text_primes
    generate_primes
    
    ;print_str text_byte
    ;print_intln byte 127
    
    ;call_ fun_print_array_byte, vecb, vecb.len
    ;call_ fun_print_array_dword, vecd, vecd.len

    ; general tests
    ;call_ fun_print_array, vec, vec.len, 4
    ;print_intln 123456
    ;print_strln msg
    ;call_ fun_test, 1, 2, 3

    mov eax, 1
    mov ebx, edi  ; exit status
    int 0x80

section .data
    def_str text_byte,   "Byte: "
    def_str text_primes, "Primes: "
    def_str text_map,    "Map:    "
    def_str msg, "Printing a string!"

    vecd     dd  1,2,3,4,5,6,7,8,9,10
    vecd.len equ $ - vecd

    vecb    db  1,2,3,4,5,6,7,8,9,10
    vecb.len equ $ - vecb

    ; needed for printing functions
    def_str buffer, "000000000000"
    def_str sep, ", "
    def_str char, "0"

segment .bss
    vecc    resb 10
    numbers resb numbers.n+1