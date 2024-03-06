; x86 Assembly Program
;   Print if number is equal, smaller or greater than other.
;
; ----------------------------------------------------
; nasm -f elf32 prog1.asm -o prog1.o
; gcc -o helloworld.elf -m32 helloworld.o -nostdlib -static
;
; echo $?    <- show last program output


; ----------------------------------------------------
; Print string
;   %1 string adress
;   %2 string length
%macro print_msg 2    
    mov eax, 4  ; sys_write
    mov ebx, 1  ; stdout
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

; ----------------------------------------------------
global _start

section .text
_start:
    mov ecx, 101

    cmp ecx, 100
    jl less_than
    je equal
    
    print_msg msg_greater,len_greater
    jmp end

equal:
    print_msg msg_equal,len_equal
    jmp end

less_than:
    print_msg msg_smaller,len_smaller
    jmp end

end:

    ; exit
    mov ebx, 0    ; exit status
    mov eax, 1    ; sys_exit
    int 0x80


section .data
    msg_equal db "Equal", 0x0a
    len_equal equ $ - msg_equal

    msg_smaller db "Smaller", 0x0a
    len_smaller equ $ - msg_smaller

    msg_greater db "Greater", 0x0a
    len_greater equ $ - msg_greater
