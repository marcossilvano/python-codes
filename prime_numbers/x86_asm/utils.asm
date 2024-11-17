; Print string
; ----------------------------------------------
; Stack Paramaters:
;   %1 string address
;   %2 string length in bytes
fun_print:
    params .str, .n
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
    params .num

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


; Print an array of positive integers of 8 bits
; ----------------------------------------------
; Stack Paramaters:
;   %1 Array address
;   %2 Array length (in bytes)
fun_print_array_byte:
    params .vec, .len

    %define .idx ebx
    %define .adr ecx

    push_ebp
    ; push_locals
    push_regs ebx, ecx, edx
   
    mov .adr, .vec
    mov .idx, 0
    xor edx, edx         ; clear edx
.loop:
    mov dl, [.adr+.idx]
    print_intsp edx
    inc .idx

    cmp .idx, .len
    jl .loop
    ; end loop

    println

    pop_regs ebx, ecx, edx
    ; pop_locals
    pop_ebp
    ret

; Print an array of positive integers of 32 bits
; ----------------------------------------------
; Stack Paramaters:
;   %1 Array address
;   %2 Array length (in bytes)
fun_print_array_dword:
    params .vecd, .lend

    %define .idx ebx
    %define .adr ecx

    push_ebp
    ; push_locals
    push_regs ebx, ecx
   
    mov .adr, .vecd
    mov .idx, 0
.loop:
    print_intsp dword [.adr+.idx]
    add .idx, 4

    cmp .idx, .lend
    jl .loop
    ; end loop

    println

    pop_regs ebx, ecx
    ; pop_locals
    pop_ebp
    ret
