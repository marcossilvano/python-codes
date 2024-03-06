; x86 Assembly Program
;   Counting loop
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

%macro sys_exit 1
    mov ebx, %1    ; exit status
    mov eax, 1    ; sys_exit
    int 0x80
%endmacro

; ----------------------------------------------------
global _start

section .text
_start:
    mov [msg_loop], byte 'Z'
    mov [msg_loop+3], byte 'm'

    mov ecx, 0
loop_str:
    mov [msg_loop+ecx], byte '-'
    inc ecx

    cmp ecx, len_loop
    jl loop_str    ; if ecx < len_loop

    mov ecx, 1
loop:
    push ecx
    print_msg msg_loop,len_loop
    pop ecx

    dec ecx
    cmp ecx, 0
    jg loop

end:
    sys_exit 0

section .data
    msg_loop db "Loop", 0x0a
    len_loop equ $ - msg_loop