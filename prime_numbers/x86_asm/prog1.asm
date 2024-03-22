; x86 Assembly Program
;   Print a string and do some basic math.
;
; ----------------------------------------------------
; nasm -f elf32 prog1.asm -o prog1.o
; gcc -o helloworld.elf -m32 helloworld.o -nostdlib -static
;
; echo $?    <- saida do ultimo programa

%macro print 0
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, len
    int 0x80
%endmacro

global _start
;intel_syntax noprefix
section .text

_start:
    print
    print

    ; do some math and put in exit code register
    mov ebx, 0  ; ebx = 0
    add ebx, 2  ; ebx += 2 (2)
    add ebx, 2  ; ebx += 2 (4)
    add ebx, 2  ; ebx += 2 (6)
    
    mov eax, 3  ; eax = 3
    mul ebx     ; eax *= ebx (18)

    mov ecx, 2  ; ecx = 2
    div ecx     ; exa /= ecx (9)
    mov ebx, eax; ebx = eax
    
    ; exit syscall
    mov eax, 1 ; exit
    int 0x80

section .data
    msg db "Hello World!", 0x0a ; \n
    len equ $ - msg
