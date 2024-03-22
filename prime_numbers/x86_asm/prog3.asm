; x86 Assembly Program
;   Replacing chars on string
;   String Length macro
;
; ----------------------------------------------------
; nasm -f elf32 prog.asm -o prog1.o
; gcc -o prog.elf -m32 prog.o -nostdlib -static
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


; Find length of NULL terminated string
;   strlen(string_address) -> eax
; Returns:
;   eax: length of string
;   OPTIONAL esp+0: length of string 
%macro strlen 1
    mov eax, 0
.loop:
    cmp [%1 + eax], byte 0
    je .end

    inc eax
    jmp .loop

.end:
    sub esp, 4
    mov [esp], dword eax
    
%endmacro


%macro sys_exit 1
    mov ebx, %1     ; exit status
    mov eax, 1      ; sys_exit
    int 0x80
%endmacro

; ----------------------------------------------------
global _start

section .text
_start:
    print_msg title,len2

    mov [msg], byte 'Z'
    mov [msg+3], byte 'm'

    strlen msg
    mov ebx, eax    ; strlen -> eax
    sub ebx, 1      ; ebx = len - 1 (NULL)
    mov ecx, 0      ; ecx = loop counter
loop_str:
    mov [msg+ecx], byte '-'     ; isto pode!
    inc ecx

    cmp ecx, ebx    
    jl loop_str     ; if ecx < len-1

    mov ecx, 5      ; number of strings to print
loop:
    push ecx
    print_msg msg,len
    pop ecx

    dec ecx
    cmp ecx, 0
    jg loop

    ; exit
    strlen msg
    ;mov eax, dword [esp]
    sys_exit eax    ; return string len to system at program exit (echo $?)

section .data
    msg db "Loop", 0x0a, 0 ; \n
    len equ $ - msg

    title db "PROGRAM TO REPLACE AND PRINT STRINGS", 0x0a, 0 ; \n
    len2 equ $ - title