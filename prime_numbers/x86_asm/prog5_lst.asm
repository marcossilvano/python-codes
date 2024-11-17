     1                                  ; ========================================
     2                                  ; MACROS
     3                                  ; ========================================
     4                                  %include "macros.asm"
     5                              <1> %ifndef MACROS_MAC
     6                              <1> %define MACROS_MAC
     7                              <1> 
     8                              <1> ; Macro: Signalize program termination
     9                              <1> ;   %1 Exit status
    10                              <1> %macro sys_exit 1
    11                              <1>     mov ebx, %1    ; exit status
    12                              <1>     mov eax, 1    ; sys_exit
    13                              <1>     int 0x80
    14                              <1> %endmacro
    15                              <1> 
    16                              <1> ; ---------------------------------------------------------
    17                              <1> ; DATA DEFINITION HELPERS
    18                              <1> ; ---------------------------------------------------------
    19                              <1> 
    20                              <1> ; Macro: Define String
    21                              <1> ;   %1 symbol name
    22                              <1> ;   %2 string
    23                              <1> %macro def_str 2
    24                              <1>     %1 db  %2
    25                              <1>     %1.len equ $ - %1
    26                              <1> %endmacro
    27                              <1> 
    28                              <1> ; ---------------------------------------------------------
    29                              <1> ; OLD PRINT STRING UTILITIES
    30                              <1> ; ---------------------------------------------------------
    31                              <1> 
    32                              <1> ; Macro: Initialize array with number
    33                              <1> ; Stack paramaters:
    34                              <1> ;   %1 char
    35                              <1> ;   %2 string address
    36                              <1> ;   %3 string length
    37                              <1> %macro fstring_init 3
    38                              <1>     push %1
    39                              <1>     push %2
    40                              <1>     push %3
    41                              <1>     call fun_string_init 
    42                              <1>     add esp, 4*3
    43                              <1> %endmacro
    44                              <1> 
    45                              <1> ; Macro: Print \n
    46                              <1> %macro fprintln 0
    47                              <1>     push newline
    48                              <1>     push 1
    49                              <1>     call fun_print
    50                              <1>     add esp, 8
    51                              <1> %endmacro
    52                              <1> 
    53                              <1> ; Macro: Print string
    54                              <1> ; paramaters:
    55                              <1> ;   %1 string address
    56                              <1> ;   %2 string length
    57                              <1> %macro fprint 2
    58                              <1>     push %1
    59                              <1>     push %2
    60                              <1>     call fun_print
    61                              <1>     add esp, 8
    62                              <1> %endmacro
    63                              <1> 
    64                              <1> ; ---------------------------------------------------------
    65                              <1> ; PRINT FUNCION UTILITIES
    66                              <1> ; ---------------------------------------------------------
    67                              <1> 
    68                              <1> ; Macro: Print line break
    69                              <1> %macro println 0
    70                              <1>     mov [char], byte 0x0a
    71                              <1>     call_ fun_print, char, 1
    72                              <1> %endmacro
    73                              <1> 
    74                              <1> ; Macro: Print int
    75                              <1> ;   %1 int to print
    76                              <1> %macro print_int 1
    77                              <1>     call_ fun_int_to_str, %1
    78                              <1>     ;call_ fun_print, buffer, buffer.len
    79                              <1> %endmacro
    80                              <1> 
    81                              <1> ; Macro: Print int with trailing space
    82                              <1> ;   %1 int to print
    83                              <1> %macro print_intsp 1
    84                              <1>     call_ fun_int_to_str, %1
    85                              <1>     print_char byte ' '
    86                              <1> %endmacro
    87                              <1> 
    88                              <1> ; Macro: Print int and break line
    89                              <1> ;   %1 int to print
    90                              <1> %macro print_intln 1
    91                              <1>     print_int %1
    92                              <1>     println
    93                              <1> %endmacro
    94                              <1> 
    95                              <1> ; Macro: Print String
    96                              <1> ;   %1 string address
    97                              <1> %macro print_str 1
    98                              <1>     call_ fun_print, %1, %1.len
    99                              <1> %endmacro
   100                              <1> 
   101                              <1> ; Macro: Print String and break line
   102                              <1> ;   %1 string address
   103                              <1> %macro print_strln 1
   104                              <1>     print_str %1
   105                              <1>     println
   106                              <1> %endmacro
   107                              <1> 
   108                              <1> ; Macro: Print char
   109                              <1> ;   %1 char to print
   110                              <1> %macro print_char 1
   111                              <1>     mov [char], byte %1
   112                              <1>     print_str char
   113                              <1> %endmacro
   114                              <1> 
   115                              <1> ; ---------------------------------------------------------
   116                              <1> ; TYPEOF MACRO
   117                              <1> ; ---------------------------------------------------------
   118                              <1> 
   119                              <1> %define IMMEDIATE_TYPE   0
   120                              <1> %define REGISTER_TYPE    1
   121                              <1> %define OTHER_TYPE       2
   122                              <1> %define INTEGER_TYPE_ID  3
   123                              <1> %define FLOAT_TYPE_ID    4
   124                              <1> %define STRING_TYPE_ID   5
   125                              <1> %define FUNCTION_TYPE_ID 6
   126                              <1> 
   127                              <1> %define TypeOf.eax      REGISTER_TYPE
   128                              <1> %define TypeOf.ebx      REGISTER_TYPE
   129                              <1> %define TypeOf.ecx      REGISTER_TYPE
   130                              <1> %define TypeOf.edx      REGISTER_TYPE
   131                              <1> %define TypeOf.edi      REGISTER_TYPE
   132                              <1> %define TypeOf.esi      REGISTER_TYPE
   133                              <1> 
   134                              <1> %macro is_reg 1
   135                              <1>     %ifndef TypeOf.%1
   136                              <1>         %define result IMMEDIATE_TYPE
   137                              <1>     %elif TypeOf.%1 = REGISTER_TYPE
   138                              <1>         %define result REGISTER_TYPE
   139                              <1>     %else
   140                              <1>         %define result OTHER_TYPE
   141                              <1>     %endif
   142                              <1> %endmacro
   143                              <1> 
   144                              <1> ; ---------------------------------------------------------
   145                              <1> ; PUSH / POP UTILITIES FOR SUBROUTINES
   146                              <1> ; ---------------------------------------------------------
   147                              <1> 
   148                              <1> %macro push_ebp 0
   149                              <1>     push ebp
   150                              <1>     mov ebp, esp
   151                              <1> %endmacro
   152                              <1> 
   153                              <1> %macro pop_ebp 0
   154                              <1>     pop ebp
   155                              <1> %endmacro
   156                              <1> 
   157                              <1> %macro push_regs 1-*
   158                              <1> %rep %0
   159                              <1>     push %1
   160                              <1>     %rotate 1       ; rotate macro params to left
   161                              <1> %endrep
   162                              <1> %endmacro
   163                              <1> 
   164                              <1> %macro pop_regs 1-*
   165                              <1> %rep %0
   166                              <1>     %rotate -1      ; rotate macro params to right
   167                              <1>     pop %1
   168                              <1> %endrep
   169                              <1> %endmacro
   170                              <1> 
   171                              <1> ; ---------------------------------------------------------
   172                              <1> ; SUBROUTINE CALL AND PARAMETERS
   173                              <1> ; ---------------------------------------------------------
   174                              <1> ; reg
   175                              <1> ; reg
   176                              <1> ; local     -8
   177                              <1> ; local     -4
   178                              <1> ; ebp       <
   179                              <1> ; @return
   180                              <1> ; param     +8
   181                              <1> ; param     +12
   182                              <1> 
   183                              <1> %macro call_ 1-*
   184                              <1>     %rep %0-1       ; push args
   185                              <1>         %rotate 1   ; rotate left
   186                              <1>         push %1
   187                              <1>     %endrep
   188                              <1>     %rotate 1
   189                              <1>     call %1
   190                              <1>     %if %0 > 1
   191                              <1>         add esp, 4*(%0-1)
   192                              <1>     %endif
   193                              <1> %endmacro
   194                              <1> 
   195                              <1> %macro params_ 1-*    ; DOESN'T WORK...
   196                              <1>     %assign i 8
   197                              <1>     %rep %0
   198                              <1>         %rotate -1          ; rotate macro params right
   199                              <1>         %define %1 [ebp+i]
   200                              <1>         %assign i i+4       ; assign must written before using it
   201                              <1>     %endrep
   202                              <1> %endmacro
   203                              <1> 
   204                              <1> %macro params 1
   205                              <1>     %define %1 [ebp+8]
   206                              <1> %endmacro
   207                              <1> 
   208                              <1> %macro params 2
   209                              <1>     %define %1 [ebp+12]
   210                              <1>     %define %2 [ebp+8]
   211                              <1> %endmacro
   212                              <1> 
   213                              <1> %macro params 3
   214                              <1>     %define %1 [ebp+16]
   215                              <1>     %define %2 [ebp+12]
   216                              <1>     %define %3 [ebp+8]
   217                              <1> %endmacro
   218                              <1> 
   219                              <1> %macro params 4
   220                              <1>     %define %1 [ebp+20]
   221                              <1>     %define %2 [ebp+16]
   222                              <1>     %define %3 [ebp+12]
   223                              <1>     %define %4 [ebp+8]
   224                              <1> %endmacro
   225                              <1> 
   226                              <1> %macro params 5
   227                              <1>     %define %1 [ebp+24]
   228                              <1>     %define %2 [ebp+20]
   229                              <1>     %define %3 [ebp+16]
   230                              <1>     %define %4 [ebp+12]
   231                              <1>     %define %5 [ebp+8]
   232                              <1> %endmacro
   233                              <1> 
   234                              <1> ; ---------------------------------------------------------
   235                              <1> ; LOCAL STACK VARS UTILITIES FOR SUBROUTINES
   236                              <1> ; ---------------------------------------------------------
   237                              <1> 
   238                              <1> ; local2    -8
   239                              <1> ; local1    -4
   240                              <1> ; ebp   <
   241                              <1> ; @return
   242                              <1> ; param1    +8
   243                              <1> ; param2    +12
   244                              <1> 
   245                              <1> %macro push_vars_ 1-*
   246                              <1>     %assign i 0
   247                              <1>     %rep %0
   248                              <1>         %assign i i+4
   249                              <1>         %define %1 [ebp-i]
   250                              <1>         %rotate 1           ; rotate macro params left
   251                              <1>     %endrep
   252                              <1>     sub esp, 4*%0           ; allocate space in stack
   253                              <1> %endmacro
   254                              <1> 
   255                              <1> %macro push_vars 1
   256                              <1>     %define %1 [ebp-4]
   257                              <1>     sub esp, 4*%0           ; allocate space in stack
   258                              <1> %endmacro
   259                              <1> 
   260                              <1> %macro push_vars 2
   261                              <1>     %define %1 [ebp-4]
   262                              <1>     %define %2 [ebp-8]
   263                              <1>     sub esp, 4*%0           ; allocate space in stack
   264                              <1> %endmacro
   265                              <1> 
   266                              <1> %macro push_vars 3
   267                              <1>     %define %1 [ebp-4]
   268                              <1>     %define %2 [ebp-8]
   269                              <1>     %define %3 [ebp-12]
   270                              <1>     sub esp, 4*%0           ; allocate space in stack
   271                              <1> %endmacro
   272                              <1> 
   273                              <1> %macro push_vars 4
   274                              <1>     %define %1 [ebp-4]
   275                              <1>     %define %2 [ebp-8]
   276                              <1>     %define %3 [ebp-12]
   277                              <1>     %define %4 [ebp-16]
   278                              <1>     sub esp, 4*%0           ; allocate space in stack
   279                              <1> %endmacro
   280                              <1> 
   281                              <1> %macro pop_vars 1
   282                              <1>     add esp, 4*%1      ; free locals in stack
   283                              <1> %endmacro
   284                              <1> 
   285                              <1> %endif
     5                                  
     6                                  %macro summation 1-*
     7                                      mov edi, 0
     8                                      %rep %0
     9                                          add edi, %1
    10                                          %rotate 1
    11                                      %endrep
    12                                  
    13                                      print_intln edi
    14                                  %endmacro
    15                                  
    16                                  ; ----------------------------------------
    17                                  ; GENERATE PRIMES
    18                                  ; ----------------------------------------
    19                                  
    20                                  ; generate prime numbers up to N
    21                                  %define numbers.n 5000000
    22                                  
    23                                  ; SET ARRAY TO ZERO
    24                                  %macro reset_primes_map 0
    25                                      ; zero array to zero
    26                                      mov ebx, 0
    27                                  .loop_zero:
    28                                      mov [numbers+ebx], byte 0
    29                                      inc ebx
    30                                  
    31                                      cmp ebx, numbers.n+1
    32                                      jl .loop_zero
    33                                  %endmacro
    34                                  
    35                                  ; PRINT PRIMES BY ARRAY INDEXES
    36                                  %macro print_primes 0
    37                                      print_str text_primes
    38                                      
    39                                      mov ebx, 2
    40                                  .loop_print:
    41                                      xor ecx, ecx
    42                                      mov cl, [numbers+ebx]
    43                                      
    44                                      cmp cl, 0
    45                                      jne .loop_print_end
    46                                      print_intsp ebx
    47                                  
    48                                  .loop_print_end:
    49                                      inc ebx
    50                                      
    51                                      cmp ebx, numbers.n+1
    52                                      jl .loop_print
    53                                  
    54                                      println
    55                                  %endmacro
    56                                  
    57                                  ; GENERATE PRIME NUMBERS
    58                                  %macro generate_primes 0
    59                                      reset_primes_map
    60                                      ;print_str text_map
    61                                      ;call_ fun_print_array_byte, numbers, numbers.n+1
    62                                  
    63                                  .sieve:
    64                                      ; Sieve of Eratosthenes
    65                                      %define .half   numbers.n/2
    66                                  
    67                                      %define .num ebx
    68                                      %define .multi eax
    69                                  
    70                                      mov .num, 2
    71                                  .loop:
    72                                      cmp .num, .half
    73                                      jge .end
    74                                  
    75                                      cmp [numbers+.num], byte 0
    76                                      jne .loop_inc
    77                                  
    78                                      mov .multi, .num
    79                                      ;mul .multi
    80                                      add .multi, .multi
    81                                  
    82                                      .loop2:
    83                                          cmp .multi, numbers.n
    84                                          jg .loop_inc
    85                                  
    86                                          mov [numbers+.multi], byte 1
    87                                          add .multi, .num
    88                                  
    89                                          jmp .loop2
    90                                  
    91                                      .loop_inc:
    92                                          inc .num
    93                                  
    94                                      jmp .loop
    95                                  .end:
    96                                  
    97                                      ;print_str text_map
    98                                      ;call_ fun_print_array_byte, numbers, numbers.n+1
    99                                      ;print_primes
   100                                  %endmacro
   101                                  
   102                                  section .text
   103                                  
   104                                  %include "utils.asm"
   105                              <1> ; Print string
   106                              <1> ; ----------------------------------------------
   107                              <1> ; Stack Paramaters:
   108                              <1> ;   %1 string address
   109                              <1> ;   %2 string length in bytes
   110                              <1> fun_print:
   111                              <1>     params .str, .n
   209                              <2>  %define %1 [ebp+12]
   210                              <2>  %define %2 [ebp+8]
   112                              <1>     push_ebp
   149 00000000 55                  <2>  push ebp
   150 00000001 89E5                <2>  mov ebp, esp
   113                              <1>     ; push_locals
   114                              <1>     push_regs eax, ebx, ecx, edx  
   158                              <2> %rep %0
   159                              <2>  push %1
   160                              <2>  %rotate 1
   161                              <2> %endrep
   159 00000003 50                  <3>  push %1
   160                              <3>  %rotate 1
   159 00000004 53                  <3>  push %1
   160                              <3>  %rotate 1
   159 00000005 51                  <3>  push %1
   160                              <3>  %rotate 1
   159 00000006 52                  <3>  push %1
   160                              <3>  %rotate 1
   115                              <1>     
   116 00000007 8B4D0C              <1>     mov     ecx, .str
   117 0000000A 8B5508              <1>     mov     edx, .n
   118 0000000D BB01000000          <1>     mov     ebx, 1
   119 00000012 B804000000          <1>     mov     eax, 4
   120 00000017 CD80                <1>     int     0x80
   121                              <1> 
   122 00000019 8B7D08              <1>     mov edi, .n
   123                              <1>     
   124                              <1>     pop_regs eax, ebx, ecx, edx
   165                              <2> %rep %0
   166                              <2>  %rotate -1
   167                              <2>  pop %1
   168                              <2> %endrep
   166                              <3>  %rotate -1
   167 0000001C 5A                  <3>  pop %1
   166                              <3>  %rotate -1
   167 0000001D 59                  <3>  pop %1
   166                              <3>  %rotate -1
   167 0000001E 5B                  <3>  pop %1
   166                              <3>  %rotate -1
   167 0000001F 58                  <3>  pop %1
   125                              <1>     ; pop_locals
   126                              <1>     pop_ebp
   154 00000020 5D                  <2>  pop ebp
   127                              <1> 
   128 00000021 C3                  <1>     ret
   129                              <1> 
   130                              <1> ; Convert int to str
   131                              <1> ; ----------------------------------------------
   132                              <1> ; Stack params:
   133                              <1> ;   %1 int number
   134                              <1> fun_int_to_str:
   135                              <1>     params .num
   205                              <2>  %define %1 [ebp+8]
   136                              <1> 
   137                              <1>     push_ebp
   149 00000022 55                  <2>  push ebp
   150 00000023 89E5                <2>  mov ebp, esp
   138                              <1>     ;push_locals
   139                              <1>     push_regs eax, ebx, edx, esi, ecx
   158                              <2> %rep %0
   159                              <2>  push %1
   160                              <2>  %rotate 1
   161                              <2> %endrep
   159 00000025 50                  <3>  push %1
   160                              <3>  %rotate 1
   159 00000026 53                  <3>  push %1
   160                              <3>  %rotate 1
   159 00000027 52                  <3>  push %1
   160                              <3>  %rotate 1
   159 00000028 56                  <3>  push %1
   160                              <3>  %rotate 1
   159 00000029 51                  <3>  push %1
   160                              <3>  %rotate 1
   140                              <1> 
   141                              <1>     ; find int number length
   142                              <1>     
   143 0000002A B900000000          <1>     mov ecx, 0      ; counter
   144 0000002F BB0A000000          <1>     mov ebx, 10     ; divisor
   145 00000034 8B4508              <1>     mov eax, .num
   146                              <1> .loop_count:
   147 00000037 BA00000000          <1>     mov edx, 0      ; reset remainder
   148 0000003C F7F3                <1>     div ebx         ; eax: quotient,  edx: remainder
   149                              <1>     
   150 0000003E 41                  <1>     inc ecx         ; counter++
   151 0000003F 83F800              <1>     cmp eax, 0
   152 00000042 75F3                <1>     jne .loop_count
   153                              <1> 
   154                              <1>     ; convert number to string
   155                              <1> 
   156 00000044 BB0A000000          <1>     mov ebx, 10     ; divisor
   157                              <1>     ;mov ecx, buffer.len   ; ecx = last string index
   158 00000049 89CE                <1>     mov esi, ecx   ; ecx = last number index
   159 0000004B 4E                  <1>     dec esi
   160                              <1> 
   161 0000004C 8B4508              <1>     mov eax, .num
   162                              <1> .loop_extract:
   163 0000004F BA00000000          <1>     mov edx, 0      ; reset remainder
   164 00000054 F7F3                <1>     div ebx         ; eax /= ebx; edx = eax mod ebx
   165                              <1> 
   166 00000056 83C230              <1>     add edx, byte '0'
   167 00000059 8896[5A000000]      <1>     mov [buffer+esi], dl
   168 0000005F 8896[5A000000]      <1>     mov [buffer+esi], dl
   169 00000065 4E                  <1>     dec esi         ; index--
   170                              <1>     
   171                              <1>     ; print each digit
   172                              <1>     ;mov [sum], dl  
   173                              <1>     ;call_ fun_print, sum, 1
   174                              <1> 
   175 00000066 83F800              <1>     cmp eax, 0      ; if eax == 0: end
   176 00000069 7FE4                <1>     jg .loop_extract
   177                              <1>     ; end loop
   178                              <1> 
   179                              <1>     ; reset remainder of buffer to zero
   180                              <1> ;.loop_spaces:
   181                              <1> ;    mov [buffer+esi], byte '0'  
   182                              <1> ;    dec esi;
   183                              <1> 
   184                              <1> ;    cmp esi, 0
   185                              <1> ;    jg .loop_spaces       ; if index != 0: loop
   186                              <1>     ; end loop
   187                              <1> 
   188                              <1>     call_ fun_print, buffer, ecx
   184                              <2>  %rep %0-1
   185                              <2>  %rotate 1
   186                              <2>  push %1
   187                              <2>  %endrep
   185                              <3>  %rotate 1
   186 0000006B 68[5A000000]        <3>  push %1
   185                              <3>  %rotate 1
   186 00000070 51                  <3>  push %1
   188                              <2>  %rotate 1
   189 00000071 E88AFFFFFF          <2>  call %1
   190                              <2>  %if %0 > 1
   191 00000076 83C408              <2>  add esp, 4*(%0-1)
   192                              <2>  %endif
   189                              <1> 
   190                              <1>     pop_regs eax, ebx, edx, esi, ecx
   165                              <2> %rep %0
   166                              <2>  %rotate -1
   167                              <2>  pop %1
   168                              <2> %endrep
   166                              <3>  %rotate -1
   167 00000079 59                  <3>  pop %1
   166                              <3>  %rotate -1
   167 0000007A 5E                  <3>  pop %1
   166                              <3>  %rotate -1
   167 0000007B 5A                  <3>  pop %1
   166                              <3>  %rotate -1
   167 0000007C 5B                  <3>  pop %1
   166                              <3>  %rotate -1
   167 0000007D 58                  <3>  pop %1
   191                              <1>     ;pop_locals
   192                              <1>     pop_ebp
   154 0000007E 5D                  <2>  pop ebp
   193 0000007F C3                  <1>     ret
   194                              <1> 
   195                              <1> 
   196                              <1> ; Print an array of positive integers of 8 bits
   197                              <1> ; ----------------------------------------------
   198                              <1> ; Stack Paramaters:
   199                              <1> ;   %1 Array address
   200                              <1> ;   %2 Array length (in bytes)
   201                              <1> fun_print_array_byte:
   202                              <1>     params .vec, .len
   209                              <2>  %define %1 [ebp+12]
   210                              <2>  %define %2 [ebp+8]
   203                              <1> 
   204                              <1>     %define .idx ebx
   205                              <1>     %define .adr ecx
   206                              <1> 
   207                              <1>     push_ebp
   149 00000080 55                  <2>  push ebp
   150 00000081 89E5                <2>  mov ebp, esp
   208                              <1>     ; push_locals
   209                              <1>     push_regs ebx, ecx, edx
   158                              <2> %rep %0
   159                              <2>  push %1
   160                              <2>  %rotate 1
   161                              <2> %endrep
   159 00000083 53                  <3>  push %1
   160                              <3>  %rotate 1
   159 00000084 51                  <3>  push %1
   160                              <3>  %rotate 1
   159 00000085 52                  <3>  push %1
   160                              <3>  %rotate 1
   210                              <1>    
   211 00000086 8B4D0C              <1>     mov .adr, .vec
   212 00000089 BB00000000          <1>     mov .idx, 0
   213 0000008E 31D2                <1>     xor edx, edx         ; clear edx
   214                              <1> .loop:
   215 00000090 8A1419              <1>     mov dl, [.adr+.idx]
   216                              <1>     print_intsp edx
    84                              <2>  call_ fun_int_to_str, %1
   184                              <3>  %rep %0-1
   185                              <3>  %rotate 1
   186                              <3>  push %1
   187                              <3>  %endrep
   185                              <4>  %rotate 1
   186 00000093 52                  <4>  push %1
   188                              <3>  %rotate 1
   189 00000094 E889FFFFFF          <3>  call %1
   190                              <3>  %if %0 > 1
   191 00000099 83C404              <3>  add esp, 4*(%0-1)
   192                              <3>  %endif
    85                              <2>  print_char byte ' '
   111 0000009C C605[68000000]20    <3>  mov [char], byte %1
   112                              <3>  print_str char
    98                              <4>  call_ fun_print, %1, %1.len
   184                              <5>  %rep %0-1
   185                              <5>  %rotate 1
   186                              <5>  push %1
   187                              <5>  %endrep
   185                              <6>  %rotate 1
   186 000000A3 68[68000000]        <6>  push %1
   185                              <6>  %rotate 1
   186 000000A8 6A01                <6>  push %1
   188                              <5>  %rotate 1
   189 000000AA E851FFFFFF          <5>  call %1
   190                              <5>  %if %0 > 1
   191 000000AF 83C408              <5>  add esp, 4*(%0-1)
   192                              <5>  %endif
   217 000000B2 43                  <1>     inc .idx
   218                              <1> 
   219 000000B3 3B5D08              <1>     cmp .idx, .len
   220 000000B6 7CD8                <1>     jl .loop
   221                              <1>     ; end loop
   222                              <1> 
   223                              <1>     println
    70 000000B8 C605[68000000]0A    <2>  mov [char], byte 0x0a
    71                              <2>  call_ fun_print, char, 1
   184                              <3>  %rep %0-1
   185                              <3>  %rotate 1
   186                              <3>  push %1
   187                              <3>  %endrep
   185                              <4>  %rotate 1
   186 000000BF 68[68000000]        <4>  push %1
   185                              <4>  %rotate 1
   186 000000C4 6A01                <4>  push %1
   188                              <3>  %rotate 1
   189 000000C6 E835FFFFFF          <3>  call %1
   190                              <3>  %if %0 > 1
   191 000000CB 83C408              <3>  add esp, 4*(%0-1)
   192                              <3>  %endif
   224                              <1> 
   225                              <1>     pop_regs ebx, ecx, edx
   165                              <2> %rep %0
   166                              <2>  %rotate -1
   167                              <2>  pop %1
   168                              <2> %endrep
   166                              <3>  %rotate -1
   167 000000CE 5A                  <3>  pop %1
   166                              <3>  %rotate -1
   167 000000CF 59                  <3>  pop %1
   166                              <3>  %rotate -1
   167 000000D0 5B                  <3>  pop %1
   226                              <1>     ; pop_locals
   227                              <1>     pop_ebp
   154 000000D1 5D                  <2>  pop ebp
   228 000000D2 C3                  <1>     ret
   229                              <1> 
   230                              <1> ; Print an array of positive integers of 32 bits
   231                              <1> ; ----------------------------------------------
   232                              <1> ; Stack Paramaters:
   233                              <1> ;   %1 Array address
   234                              <1> ;   %2 Array length (in bytes)
   235                              <1> fun_print_array_dword:
   236                              <1>     params .vecd, .lend
   209                              <2>  %define %1 [ebp+12]
   210                              <2>  %define %2 [ebp+8]
   237                              <1> 
   238                              <1>     %define .idx ebx
   239                              <1>     %define .adr ecx
   240                              <1> 
   241                              <1>     push_ebp
   149 000000D3 55                  <2>  push ebp
   150 000000D4 89E5                <2>  mov ebp, esp
   242                              <1>     ; push_locals
   243                              <1>     push_regs ebx, ecx
   158                              <2> %rep %0
   159                              <2>  push %1
   160                              <2>  %rotate 1
   161                              <2> %endrep
   159 000000D6 53                  <3>  push %1
   160                              <3>  %rotate 1
   159 000000D7 51                  <3>  push %1
   160                              <3>  %rotate 1
   244                              <1>    
   245 000000D8 8B4D0C              <1>     mov .adr, .vecd
   246 000000DB BB00000000          <1>     mov .idx, 0
   247                              <1> .loop:
   248                              <1>     print_intsp dword [.adr+.idx]
    84                              <2>  call_ fun_int_to_str, %1
   184                              <3>  %rep %0-1
   185                              <3>  %rotate 1
   186                              <3>  push %1
   187                              <3>  %endrep
   185                              <4>  %rotate 1
   186 000000E0 FF3419              <4>  push %1
   188                              <3>  %rotate 1
   189 000000E3 E83AFFFFFF          <3>  call %1
   190                              <3>  %if %0 > 1
   191 000000E8 83C404              <3>  add esp, 4*(%0-1)
   192                              <3>  %endif
    85                              <2>  print_char byte ' '
   111 000000EB C605[68000000]20    <3>  mov [char], byte %1
   112                              <3>  print_str char
    98                              <4>  call_ fun_print, %1, %1.len
   184                              <5>  %rep %0-1
   185                              <5>  %rotate 1
   186                              <5>  push %1
   187                              <5>  %endrep
   185                              <6>  %rotate 1
   186 000000F2 68[68000000]        <6>  push %1
   185                              <6>  %rotate 1
   186 000000F7 6A01                <6>  push %1
   188                              <5>  %rotate 1
   189 000000F9 E802FFFFFF          <5>  call %1
   190                              <5>  %if %0 > 1
   191 000000FE 83C408              <5>  add esp, 4*(%0-1)
   192                              <5>  %endif
   249 00000101 83C304              <1>     add .idx, 4
   250                              <1> 
   251 00000104 3B5D08              <1>     cmp .idx, .lend
   252 00000107 7CD7                <1>     jl .loop
   253                              <1>     ; end loop
   254                              <1> 
   255                              <1>     println
    70 00000109 C605[68000000]0A    <2>  mov [char], byte 0x0a
    71                              <2>  call_ fun_print, char, 1
   184                              <3>  %rep %0-1
   185                              <3>  %rotate 1
   186                              <3>  push %1
   187                              <3>  %endrep
   185                              <4>  %rotate 1
   186 00000110 68[68000000]        <4>  push %1
   185                              <4>  %rotate 1
   186 00000115 6A01                <4>  push %1
   188                              <3>  %rotate 1
   189 00000117 E8E4FEFFFF          <3>  call %1
   190                              <3>  %if %0 > 1
   191 0000011C 83C408              <3>  add esp, 4*(%0-1)
   192                              <3>  %endif
   256                              <1> 
   257                              <1>     pop_regs ebx, ecx
   165                              <2> %rep %0
   166                              <2>  %rotate -1
   167                              <2>  pop %1
   168                              <2> %endrep
   166                              <3>  %rotate -1
   167 0000011F 59                  <3>  pop %1
   166                              <3>  %rotate -1
   167 00000120 5B                  <3>  pop %1
   258                              <1>     ; pop_locals
   259                              <1>     pop_ebp
   154 00000121 5D                  <2>  pop ebp
   260 00000122 C3                  <1>     ret
   105                                  
   106                                  ; ========================================
   107                                  ; SUBROUTINES
   108                                  ; ========================================
   109                                  
   110                                  ; Subroutine: Testing paramaters access
   111                                  ; ----------------------------------------------
   112                                  ; Stack Parameters:
   113                                  ;   %1 number 1
   114                                  ;   %2 number 2
   115                                  ;   %3 number 3
   116                                  fun_test:
   117                                      params .num1, .num2, .num3
   214                              <1>  %define %1 [ebp+16]
   215                              <1>  %define %2 [ebp+12]
   216                              <1>  %define %3 [ebp+8]
   118                                      push_ebp
   149 00000123 55                  <1>  push ebp
   150 00000124 89E5                <1>  mov ebp, esp
   119                                      push_vars .a, .b, .c
   267                              <1>  %define %1 [ebp-4]
   268                              <1>  %define %2 [ebp-8]
   269                              <1>  %define %3 [ebp-12]
   270 00000126 83EC0C              <1>  sub esp, 4*%0
   120                                      push_regs eax, ebx, ecx
   158                              <1> %rep %0
   159                              <1>  push %1
   160                              <1>  %rotate 1
   161                              <1> %endrep
   159 00000129 50                  <2>  push %1
   160                              <2>  %rotate 1
   159 0000012A 53                  <2>  push %1
   160                              <2>  %rotate 1
   159 0000012B 51                  <2>  push %1
   160                              <2>  %rotate 1
   121                                  
   122 0000012C 8B4510                      mov eax, .num1
   123 0000012F 8945FC                      mov .a, eax
   124                                  
   125 00000132 8B450C                      mov eax, .num2
   126 00000135 8945F8                      mov .b, eax
   127                                  
   128 00000138 8B4508                      mov eax, .num3
   129 0000013B 8945F4                      mov .c, eax
   130 0000013E 8345F405                    add .c, dword 5
   131 00000142 836DF403                    sub .c, dword 3
   132                                  
   133                                      print_intsp dword .a
    84                              <1>  call_ fun_int_to_str, %1
   184                              <2>  %rep %0-1
   185                              <2>  %rotate 1
   186                              <2>  push %1
   187                              <2>  %endrep
   185                              <3>  %rotate 1
   186 00000146 FF75FC              <3>  push %1
   188                              <2>  %rotate 1
   189 00000149 E8D4FEFFFF          <2>  call %1
   190                              <2>  %if %0 > 1
   191 0000014E 83C404              <2>  add esp, 4*(%0-1)
   192                              <2>  %endif
    85                              <1>  print_char byte ' '
   111 00000151 C605[68000000]20    <2>  mov [char], byte %1
   112                              <2>  print_str char
    98                              <3>  call_ fun_print, %1, %1.len
   184                              <4>  %rep %0-1
   185                              <4>  %rotate 1
   186                              <4>  push %1
   187                              <4>  %endrep
   185                              <5>  %rotate 1
   186 00000158 68[68000000]        <5>  push %1
   185                              <5>  %rotate 1
   186 0000015D 6A01                <5>  push %1
   188                              <4>  %rotate 1
   189 0000015F E89CFEFFFF          <4>  call %1
   190                              <4>  %if %0 > 1
   191 00000164 83C408              <4>  add esp, 4*(%0-1)
   192                              <4>  %endif
   134                                      print_intsp dword .b
    84                              <1>  call_ fun_int_to_str, %1
   184                              <2>  %rep %0-1
   185                              <2>  %rotate 1
   186                              <2>  push %1
   187                              <2>  %endrep
   185                              <3>  %rotate 1
   186 00000167 FF75F8              <3>  push %1
   188                              <2>  %rotate 1
   189 0000016A E8B3FEFFFF          <2>  call %1
   190                              <2>  %if %0 > 1
   191 0000016F 83C404              <2>  add esp, 4*(%0-1)
   192                              <2>  %endif
    85                              <1>  print_char byte ' '
   111 00000172 C605[68000000]20    <2>  mov [char], byte %1
   112                              <2>  print_str char
    98                              <3>  call_ fun_print, %1, %1.len
   184                              <4>  %rep %0-1
   185                              <4>  %rotate 1
   186                              <4>  push %1
   187                              <4>  %endrep
   185                              <5>  %rotate 1
   186 00000179 68[68000000]        <5>  push %1
   185                              <5>  %rotate 1
   186 0000017E 6A01                <5>  push %1
   188                              <4>  %rotate 1
   189 00000180 E87BFEFFFF          <4>  call %1
   190                              <4>  %if %0 > 1
   191 00000185 83C408              <4>  add esp, 4*(%0-1)
   192                              <4>  %endif
   135                                      print_intsp dword .c
    84                              <1>  call_ fun_int_to_str, %1
   184                              <2>  %rep %0-1
   185                              <2>  %rotate 1
   186                              <2>  push %1
   187                              <2>  %endrep
   185                              <3>  %rotate 1
   186 00000188 FF75F4              <3>  push %1
   188                              <2>  %rotate 1
   189 0000018B E892FEFFFF          <2>  call %1
   190                              <2>  %if %0 > 1
   191 00000190 83C404              <2>  add esp, 4*(%0-1)
   192                              <2>  %endif
    85                              <1>  print_char byte ' '
   111 00000193 C605[68000000]20    <2>  mov [char], byte %1
   112                              <2>  print_str char
    98                              <3>  call_ fun_print, %1, %1.len
   184                              <4>  %rep %0-1
   185                              <4>  %rotate 1
   186                              <4>  push %1
   187                              <4>  %endrep
   185                              <5>  %rotate 1
   186 0000019A 68[68000000]        <5>  push %1
   185                              <5>  %rotate 1
   186 0000019F 6A01                <5>  push %1
   188                              <4>  %rotate 1
   189 000001A1 E85AFEFFFF          <4>  call %1
   190                              <4>  %if %0 > 1
   191 000001A6 83C408              <4>  add esp, 4*(%0-1)
   192                              <4>  %endif
   136                                      println
    70 000001A9 C605[68000000]0A    <1>  mov [char], byte 0x0a
    71                              <1>  call_ fun_print, char, 1
   184                              <2>  %rep %0-1
   185                              <2>  %rotate 1
   186                              <2>  push %1
   187                              <2>  %endrep
   185                              <3>  %rotate 1
   186 000001B0 68[68000000]        <3>  push %1
   185                              <3>  %rotate 1
   186 000001B5 6A01                <3>  push %1
   188                              <2>  %rotate 1
   189 000001B7 E844FEFFFF          <2>  call %1
   190                              <2>  %if %0 > 1
   191 000001BC 83C408              <2>  add esp, 4*(%0-1)
   192                              <2>  %endif
   137                                  
   138                                      is_reg ax
   135                              <1>  %ifndef TypeOf.%1
   136                              <1>  %define result IMMEDIATE_TYPE
   137                              <1>  %elif TypeOf.%1 = REGISTER_TYPE
   138                              <1>  %define result REGISTER_TYPE
   139                              <1>  %else
   140                              <1>  %define result OTHER_TYPE
   141                              <1>  %endif
   139 000001BF BF00000000                  mov edi, result         ; symbol for macro return
   140                                      print_intln edi
    91                              <1>  print_int %1
    77                              <2>  call_ fun_int_to_str, %1
   184                              <3>  %rep %0-1
   185                              <3>  %rotate 1
   186                              <3>  push %1
   187                              <3>  %endrep
   185                              <4>  %rotate 1
   186 000001C4 57                  <4>  push %1
   188                              <3>  %rotate 1
   189 000001C5 E858FEFFFF          <3>  call %1
   190                              <3>  %if %0 > 1
   191 000001CA 83C404              <3>  add esp, 4*(%0-1)
   192                              <3>  %endif
    78                              <2> 
    92                              <1>  println
    70 000001CD C605[68000000]0A    <2>  mov [char], byte 0x0a
    71                              <2>  call_ fun_print, char, 1
   184                              <3>  %rep %0-1
   185                              <3>  %rotate 1
   186                              <3>  push %1
   187                              <3>  %endrep
   185                              <4>  %rotate 1
   186 000001D4 68[68000000]        <4>  push %1
   185                              <4>  %rotate 1
   186 000001D9 6A01                <4>  push %1
   188                              <3>  %rotate 1
   189 000001DB E820FEFFFF          <3>  call %1
   190                              <3>  %if %0 > 1
   191 000001E0 83C408              <3>  add esp, 4*(%0-1)
   192                              <3>  %endif
   141                                  
   142                                      pop_regs eax, ebx, ecx
   165                              <1> %rep %0
   166                              <1>  %rotate -1
   167                              <1>  pop %1
   168                              <1> %endrep
   166                              <2>  %rotate -1
   167 000001E3 59                  <2>  pop %1
   166                              <2>  %rotate -1
   167 000001E4 5B                  <2>  pop %1
   166                              <2>  %rotate -1
   167 000001E5 58                  <2>  pop %1
   143                                      pop_vars 3
   282 000001E6 83C40C              <1>  add esp, 4*%1
   144                                      pop_ebp
   154 000001E9 5D                  <1>  pop ebp
   145 000001EA C3                          ret
   146                                  
   147                                  ; ----------------------------------------------
   148                                  ; START
   149                                  ; ----------------------------------------------
   150                                  global _start
   151                                  
   152                                  _start:  
   153                                      ;print_strln text_primes
   154                                      generate_primes
    59                              <1>  reset_primes_map
    25                              <2> 
    26 000001EB BB00000000          <2>  mov ebx, 0
    27                              <2> .loop_zero:
    28 000001F0 C683[0A000000]00    <2>  mov [numbers+ebx], byte 0
    29 000001F7 43                  <2>  inc ebx
    30                              <2> 
    31 000001F8 81FB414B4C00        <2>  cmp ebx, numbers.n+1
    32 000001FE 7CF0                <2>  jl .loop_zero
    60                              <1> 
    61                              <1> 
    62                              <1> 
    63                              <1> .sieve:
    64                              <1> 
    65                              <1>  %define .half numbers.n/2
    66                              <1> 
    67                              <1>  %define .num ebx
    68                              <1>  %define .multi eax
    69                              <1> 
    70 00000200 BB02000000          <1>  mov .num, 2
    71                              <1> .loop:
    72 00000205 81FBA0252600        <1>  cmp .num, .half
    73 0000020B 7D22                <1>  jge .end
    74                              <1> 
    75 0000020D 80BB[0A000000]00    <1>  cmp [numbers+.num], byte 0
    76 00000214 7516                <1>  jne .loop_inc
    77                              <1> 
    78 00000216 89D8                <1>  mov .multi, .num
    79                              <1> 
    80 00000218 01C0                <1>  add .multi, .multi
    81                              <1> 
    82                              <1>  .loop2:
    83 0000021A 3D404B4C00          <1>  cmp .multi, numbers.n
    84 0000021F 7F0B                <1>  jg .loop_inc
    85                              <1> 
    86 00000221 C680[0A000000]01    <1>  mov [numbers+.multi], byte 1
    87 00000228 01D8                <1>  add .multi, .num
    88                              <1> 
    89 0000022A EBEE                <1>  jmp .loop2
    90                              <1> 
    91                              <1>  .loop_inc:
    92 0000022C 43                  <1>  inc .num
    93                              <1> 
    94 0000022D EBD6                <1>  jmp .loop
    95                              <1> .end:
    96                              <1> 
    97                              <1> 
    98                              <1> 
    99                              <1> 
   155                                      
   156                                      ;print_str text_byte
   157                                      ;print_intln byte 127
   158                                      
   159                                      ;call_ fun_print_array_byte, vecb, vecb.len
   160                                      ;call_ fun_print_array_dword, vecd, vecd.len
   161                                  
   162                                      ; general tests
   163                                      ;call_ fun_print_array, vec, vec.len, 4
   164                                      ;print_intln 123456
   165                                      ;print_strln msg
   166                                      ;call_ fun_test, 1, 2, 3
   167                                  
   168 0000022F B801000000                  mov eax, 1
   169 00000234 89FB                        mov ebx, edi  ; exit status
   170 00000236 CD80                        int 0x80
   171                                  
   172                                  section .data
   173                                      def_str text_byte,   "Byte: "
    24 00000000 427974653A20        <1>  %1 db %2
    25                              <1>  %1.len equ $ - %1
   174                                      def_str text_primes, "Primes: "
    24 00000006 5072696D65733A20    <1>  %1 db %2
    25                              <1>  %1.len equ $ - %1
   175                                      def_str text_map,    "Map:    "
    24 0000000E 4D61703A20202020    <1>  %1 db %2
    25                              <1>  %1.len equ $ - %1
   176                                      def_str msg, "Printing a string!"
    24 00000016 5072696E74696E6720- <1>  %1 db %2
    24 0000001F 6120737472696E6721  <1>
    25                              <1>  %1.len equ $ - %1
   177                                  
   178 00000028 010000000200000003-         vecd     dd  1,2,3,4,5,6,7,8,9,10
   178 00000031 000000040000000500-
   178 0000003A 000006000000070000-
   178 00000043 000800000009000000-
   178 0000004C 0A000000           
   179                                      vecd.len equ $ - vecd
   180                                  
   181 00000050 010203040506070809-         vecb    db  1,2,3,4,5,6,7,8,9,10
   181 00000059 0A                 
   182                                      vecb.len equ $ - vecb
   183                                  
   184                                      ; needed for printing functions
   185                                      def_str buffer, "000000000000"
    24 0000005A 303030303030303030- <1>  %1 db %2
    24 00000063 303030              <1>
    25                              <1>  %1.len equ $ - %1
   186                                      def_str sep, ", "
    24 00000066 2C20                <1>  %1 db %2
    25                              <1>  %1.len equ $ - %1
   187                                      def_str char, "0"
    24 00000068 30                  <1>  %1 db %2
    25                              <1>  %1.len equ $ - %1
   188                                  
   189                                  segment .bss
   190 00000000 <res Ah>                    vecc    resb 10
   191 0000000A <res 4C4B41h>               numbers resb numbers.n+1
