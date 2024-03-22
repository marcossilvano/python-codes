# x86 Assembly Tutorial 01
# ----------------------------------------------------
# as helloworld64.asm -o helloworld.o
# gcc -o helloworld64.elf helloworld.o -nostdlib -static


.global _start
.intel_syntax noprefix
.section .text

_start:
    # sys_write
    mov rax, 1
    mov rdi, 1 # STDOUT
    lea rsi, [message]
    mov rdx, 13
    syscall

    # sys_exit
    mov rax, 60
    mov rdi, 69
    syscall

#.section .data
message:
    .ascii "Hello World!\n"
