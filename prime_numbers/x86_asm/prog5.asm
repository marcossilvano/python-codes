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

; generate prime numbers up to N
%define numbers.n 10

%macro generate_primes 0
    ; zero array to zero
    mov ebx, 0
.loop_zero:
    mov [numbers+ebx], byte 1
    inc ebx

    cmp ebx, numbers.n
    jl .loop_zero

    call_ fun_print_array, numbers, numbers.n+1, 1

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
    mul .multi

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

    call_ fun_print_array, numbers, numbers.n+1, 1
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
    ;generate_primes
    mov ebx, 0
.loop:
    call_ fun_print_array, vecb, vecb.len, 1

    ; general tests
    ;call_ fun_print_array, vec, vec.len, 4
    ;print_intln 123456
    ;print_strln msg
    ;call_ fun_test, 1, 2, 3

    mov eax, 1
    mov ebx, edi  ; exit status
    int 0x80

section .data
    def_str msg, "Printing a string!"

    vec     dd  1,2,3,4,5,6,7,8,9,10
    vec.len equ $ - vec

    vecb    db  1,2,3,4,5,6,7,8,9,10
    vecb.len equ $ - vecb

    ; needed for printing functions
    def_str buffer, "000000000000"
    def_str sep, ", "
    def_str char, "0"

segment .bss
    vecc    resb 10
    numbers resb numbers.n+1