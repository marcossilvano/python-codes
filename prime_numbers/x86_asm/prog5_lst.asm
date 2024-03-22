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
    16                              <1> ; Macro: Define String
    17                              <1> ;   %1 symbol name
    18                              <1> ;   %2 string
    19                              <1> %macro def_str 2
    20                              <1>     %1 db  %2
    21                              <1>     %1.len equ $ - %1
    22                              <1> %endmacro
    23                              <1> 
    24                              <1> ; Macro: Initialize array with number
    25                              <1> ; Stack paramaters:
    26                              <1> ;   %1 char
    27                              <1> ;   %2 string address
    28                              <1> ;   %3 string length
    29                              <1> %macro fstring_init 3
    30                              <1>     push %1
    31                              <1>     push %2
    32                              <1>     push %3
    33                              <1>     call fun_string_init 
    34                              <1>     add esp, 4*3
    35                              <1> %endmacro
    36                              <1> 
    37                              <1> ; Macro: Print \n
    38                              <1> %macro fprintln 0
    39                              <1>     push newline
    40                              <1>     push 1
    41                              <1>     call fun_print
    42                              <1>     add esp, 8
    43                              <1> %endmacro
    44                              <1> 
    45                              <1> ; Macro: Print string
    46                              <1> ; paramaters:
    47                              <1> ;   %1 string address
    48                              <1> ;   %2 string length
    49                              <1> %macro fprint 2
    50                              <1>     push %1
    51                              <1>     push %2
    52                              <1>     call fun_print
    53                              <1>     add esp, 8
    54                              <1> %endmacro
    55                              <1> 
    56                              <1> ; ---------------------------------------------------------
    57                              <1> ; PRINT FUNCION UTILITIES
    58                              <1> ; ---------------------------------------------------------
    59                              <1> 
    60                              <1> ; Macro: Print line break
    61                              <1> %macro println 0
    62                              <1>     mov [char], byte 0x0a
    63                              <1>     call_ fun_print, char, 1
    64                              <1> %endmacro
    65                              <1> 
    66                              <1> ; Macro: Print int
    67                              <1> ;   %1 int to print
    68                              <1> %macro print_int 1
    69                              <1>     call_ fun_int_to_str, %1
    70                              <1>     ;call_ fun_print, buffer, buffer.len
    71                              <1> %endmacro
    72                              <1> 
    73                              <1> ; Macro: Print int with trailing space
    74                              <1> ;   %1 int to print
    75                              <1> %macro print_intsp 1
    76                              <1>     call_ fun_int_to_str, %1
    77                              <1>     print_char byte ' '
    78                              <1> %endmacro
    79                              <1> 
    80                              <1> ; Macro: Print int and break line
    81                              <1> ;   %1 int to print
    82                              <1> %macro print_intln 1
    83                              <1>     print_int %1
    84                              <1>     println
    85                              <1> %endmacro
    86                              <1> 
    87                              <1> ; Macro: Print String
    88                              <1> ;   %1 string address
    89                              <1> %macro print_str 1
    90                              <1>     call_ fun_print, %1, %1.len
    91                              <1> %endmacro
    92                              <1> 
    93                              <1> ; Macro: Print String and break line
    94                              <1> ;   %1 string address
    95                              <1> %macro print_strln 1
    96                              <1>     print_str %1
    97                              <1>     println
    98                              <1> %endmacro
    99                              <1> 
   100                              <1> ; Macro: Print char
   101                              <1> ;   %1 char to print
   102                              <1> %macro print_char 1
   103                              <1>     mov [char], byte %1
   104                              <1>     print_str char
   105                              <1> %endmacro
   106                              <1> 
   107                              <1> ; ---------------------------------------------------------
   108                              <1> ; TYPEOF MACRO
   109                              <1> ; ---------------------------------------------------------
   110                              <1> 
   111                              <1> %define IMMEDIATE_TYPE   0
   112                              <1> %define REGISTER_TYPE    1
   113                              <1> %define OTHER_TYPE       2
   114                              <1> %define INTEGER_TYPE_ID  3
   115                              <1> %define FLOAT_TYPE_ID    4
   116                              <1> %define STRING_TYPE_ID   5
   117                              <1> %define FUNCTION_TYPE_ID 6
   118                              <1> 
   119                              <1> %define TypeOf.eax      REGISTER_TYPE
   120                              <1> %define TypeOf.ebx      REGISTER_TYPE
   121                              <1> %define TypeOf.ecx      REGISTER_TYPE
   122                              <1> %define TypeOf.edx      REGISTER_TYPE
   123                              <1> %define TypeOf.edi      REGISTER_TYPE
   124                              <1> %define TypeOf.esi      REGISTER_TYPE
   125                              <1> 
   126                              <1> %macro is_reg 1
   127                              <1>     %ifndef TypeOf.%1
   128                              <1>         %define result IMMEDIATE_TYPE
   129                              <1>     %elif TypeOf.%1 = REGISTER_TYPE
   130                              <1>         %define result REGISTER_TYPE
   131                              <1>     %else
   132                              <1>         %define result OTHER_TYPE
   133                              <1>     %endif
   134                              <1> %endmacro
   135                              <1> 
   136                              <1> ; ---------------------------------------------------------
   137                              <1> ; PUSH / POP UTILITIES FOR SUBROUTINES
   138                              <1> ; ---------------------------------------------------------
   139                              <1> 
   140                              <1> %macro push_ebp 0
   141                              <1>     push ebp
   142                              <1>     mov ebp, esp
   143                              <1> %endmacro
   144                              <1> 
   145                              <1> %macro pop_ebp 0
   146                              <1>     pop ebp
   147                              <1> %endmacro
   148                              <1> 
   149                              <1> %macro push_regs 1-*
   150                              <1> %rep %0
   151                              <1>     push %1
   152                              <1>     %rotate 1       ; rotate macro params to left
   153                              <1> %endrep
   154                              <1> %endmacro
   155                              <1> 
   156                              <1> %macro pop_regs 1-*
   157                              <1> %rep %0
   158                              <1>     %rotate -1      ; rotate macro params to right
   159                              <1>     pop %1
   160                              <1> %endrep
   161                              <1> %endmacro
   162                              <1> 
   163                              <1> ; ---------------------------------------------------------
   164                              <1> ; SUBROUTINE CALL AND PARAMETERS
   165                              <1> ; ---------------------------------------------------------
   166                              <1> ; reg
   167                              <1> ; reg
   168                              <1> ; local     -8
   169                              <1> ; local     -4
   170                              <1> ; ebp       <
   171                              <1> ; @return
   172                              <1> ; param     +8
   173                              <1> ; param     +12
   174                              <1> 
   175                              <1> %macro call_ 1-*
   176                              <1>     %rep %0-1       ; push args
   177                              <1>         %rotate 1   ; rotate left
   178                              <1>         push %1
   179                              <1>     %endrep
   180                              <1>     %rotate 1
   181                              <1>     call %1
   182                              <1>     %if %0 > 1
   183                              <1>         add esp, 4*(%0-1)
   184                              <1>     %endif
   185                              <1> %endmacro
   186                              <1> 
   187                              <1> %macro params_ 1-*    ; DOESN'T WORK...
   188                              <1>     %assign i 8
   189                              <1>     %rep %0
   190                              <1>         %rotate -1          ; rotate macro params right
   191                              <1>         %define %1 [ebp+i]
   192                              <1>         %assign i i+4       ; assign must written before using it
   193                              <1>     %endrep
   194                              <1> %endmacro
   195                              <1> 
   196                              <1> %macro params 1
   197                              <1>     %define %1 [ebp+8]
   198                              <1> %endmacro
   199                              <1> 
   200                              <1> %macro params 2
   201                              <1>     %define %1 [ebp+12]
   202                              <1>     %define %2 [ebp+8]
   203                              <1> %endmacro
   204                              <1> 
   205                              <1> %macro params 3
   206                              <1>     %define %1 [ebp+16]
   207                              <1>     %define %2 [ebp+12]
   208                              <1>     %define %3 [ebp+8]
   209                              <1> %endmacro
   210                              <1> 
   211                              <1> %macro params 4
   212                              <1>     %define %1 [ebp+20]
   213                              <1>     %define %2 [ebp+16]
   214                              <1>     %define %3 [ebp+12]
   215                              <1>     %define %4 [ebp+8]
   216                              <1> %endmacro
   217                              <1> 
   218                              <1> %macro params 5
   219                              <1>     %define %1 [ebp+24]
   220                              <1>     %define %2 [ebp+20]
   221                              <1>     %define %3 [ebp+16]
   222                              <1>     %define %4 [ebp+12]
   223                              <1>     %define %5 [ebp+8]
   224                              <1> %endmacro
   225                              <1> 
   226                              <1> ; ---------------------------------------------------------
   227                              <1> ; LOCAL STACK VARS UTILITIES FOR SUBROUTINES
   228                              <1> ; ---------------------------------------------------------
   229                              <1> 
   230                              <1> ; local2    -8
   231                              <1> ; local1    -4
   232                              <1> ; ebp   <
   233                              <1> ; @return
   234                              <1> ; param1    +8
   235                              <1> ; param2    +12
   236                              <1> 
   237                              <1> %macro push_vars_ 1-*
   238                              <1>     %assign i 0
   239                              <1>     %rep %0
   240                              <1>         %assign i i+4
   241                              <1>         %define %1 [ebp-i]
   242                              <1>         %rotate 1           ; rotate macro params left
   243                              <1>     %endrep
   244                              <1>     sub esp, 4*%0           ; allocate space in stack
   245                              <1> %endmacro
   246                              <1> 
   247                              <1> %macro push_vars 1
   248                              <1>     %define %1 [ebp-4]
   249                              <1>     sub esp, 4*%0           ; allocate space in stack
   250                              <1> %endmacro
   251                              <1> 
   252                              <1> %macro push_vars 2
   253                              <1>     %define %1 [ebp-4]
   254                              <1>     %define %2 [ebp-8]
   255                              <1>     sub esp, 4*%0           ; allocate space in stack
   256                              <1> %endmacro
   257                              <1> 
   258                              <1> %macro push_vars 3
   259                              <1>     %define %1 [ebp-4]
   260                              <1>     %define %2 [ebp-8]
   261                              <1>     %define %3 [ebp-12]
   262                              <1>     sub esp, 4*%0           ; allocate space in stack
   263                              <1> %endmacro
   264                              <1> 
   265                              <1> %macro push_vars 4
   266                              <1>     %define %1 [ebp-4]
   267                              <1>     %define %2 [ebp-8]
   268                              <1>     %define %3 [ebp-12]
   269                              <1>     %define %4 [ebp-16]
   270                              <1>     sub esp, 4*%0           ; allocate space in stack
   271                              <1> %endmacro
   272                              <1> 
   273                              <1> %macro pop_vars 1
   274                              <1>     add esp, 4*%1      ; free locals in stack
   275                              <1> %endmacro
   276                              <1> 
   277                              <1> %endif
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
    16                                  ; generate prime numbers up to N
    17                                  %define numbers.n 10
    18                                  
    19                                  %macro generate_primes 0
    20                                      ; zero array to zero
    21                                      mov ebx, 0
    22                                  .loop_zero:
    23                                      mov [numbers+ebx], byte 1
    24                                      inc ebx
    25                                  
    26                                      cmp ebx, numbers.n
    27                                      jl .loop_zero
    28                                  
    29                                      call_ fun_print_array, numbers, numbers.n+1, 1
    30                                  
    31                                  .sieve:
    32                                      ; Sieve of Eratosthenes
    33                                      %define .half   numbers.n/2
    34                                  
    35                                      %define .num ebx
    36                                      %define .multi eax
    37                                  
    38                                      mov .num, 2
    39                                  .loop:
    40                                      cmp .num, .half
    41                                      jge .end
    42                                  
    43                                      cmp [numbers+.num], byte 0
    44                                      jne .loop_inc
    45                                  
    46                                      mov .multi, .num
    47                                      mul .multi
    48                                  
    49                                      .loop2:
    50                                          cmp .multi, numbers.n
    51                                          jg .loop_inc
    52                                  
    53                                          mov [numbers+.multi], byte 1
    54                                          add .multi, .num
    55                                  
    56                                          jmp .loop2
    57                                  
    58                                      .loop_inc:
    59                                          inc .num
    60                                  
    61                                      jmp .loop
    62                                  .end:
    63                                  
    64                                      call_ fun_print_array, numbers, numbers.n+1, 1
    65                                  %endmacro
    66                                  
    67                                  section .text
    68                                  
    69                                  %include "utils.asm"
    70                              <1> ; Print string
    71                              <1> ; ----------------------------------------------
    72                              <1> ; Stack Paramaters:
    73                              <1> ;   %1 string address
    74                              <1> ;   %2 string length in bytes
    75                              <1> fun_print:
    76                              <1>     params .str, .n
   201                              <2>  %define %1 [ebp+12]
   202                              <2>  %define %2 [ebp+8]
    77                              <1>     push_ebp
   141 00000000 55                  <2>  push ebp
   142 00000001 89E5                <2>  mov ebp, esp
    78                              <1>     ; push_locals
    79                              <1>     push_regs eax, ebx, ecx, edx  
   150                              <2> %rep %0
   151                              <2>  push %1
   152                              <2>  %rotate 1
   153                              <2> %endrep
   151 00000003 50                  <3>  push %1
   152                              <3>  %rotate 1
   151 00000004 53                  <3>  push %1
   152                              <3>  %rotate 1
   151 00000005 51                  <3>  push %1
   152                              <3>  %rotate 1
   151 00000006 52                  <3>  push %1
   152                              <3>  %rotate 1
    80                              <1>     
    81 00000007 8B4D0C              <1>     mov     ecx, .str
    82 0000000A 8B5508              <1>     mov     edx, .n
    83 0000000D BB01000000          <1>     mov     ebx, 1
    84 00000012 B804000000          <1>     mov     eax, 4
    85 00000017 CD80                <1>     int     0x80
    86                              <1> 
    87 00000019 8B7D08              <1>     mov edi, .n
    88                              <1>     
    89                              <1>     pop_regs eax, ebx, ecx, edx
   157                              <2> %rep %0
   158                              <2>  %rotate -1
   159                              <2>  pop %1
   160                              <2> %endrep
   158                              <3>  %rotate -1
   159 0000001C 5A                  <3>  pop %1
   158                              <3>  %rotate -1
   159 0000001D 59                  <3>  pop %1
   158                              <3>  %rotate -1
   159 0000001E 5B                  <3>  pop %1
   158                              <3>  %rotate -1
   159 0000001F 58                  <3>  pop %1
    90                              <1>     ; pop_locals
    91                              <1>     pop_ebp
   146 00000020 5D                  <2>  pop ebp
    92                              <1> 
    93 00000021 C3                  <1>     ret
    94                              <1> 
    95                              <1> ; Convert int to str
    96                              <1> ; ----------------------------------------------
    97                              <1> ; Stack params:
    98                              <1> ;   %1 int number
    99                              <1> fun_int_to_str:
   100                              <1>     params .num
   197                              <2>  %define %1 [ebp+8]
   101                              <1> 
   102                              <1>     push_ebp
   141 00000022 55                  <2>  push ebp
   142 00000023 89E5                <2>  mov ebp, esp
   103                              <1>     ;push_locals
   104                              <1>     push_regs eax, ebx, edx, esi, ecx
   150                              <2> %rep %0
   151                              <2>  push %1
   152                              <2>  %rotate 1
   153                              <2> %endrep
   151 00000025 50                  <3>  push %1
   152                              <3>  %rotate 1
   151 00000026 53                  <3>  push %1
   152                              <3>  %rotate 1
   151 00000027 52                  <3>  push %1
   152                              <3>  %rotate 1
   151 00000028 56                  <3>  push %1
   152                              <3>  %rotate 1
   151 00000029 51                  <3>  push %1
   152                              <3>  %rotate 1
   105                              <1> 
   106                              <1>     ; find int number length
   107                              <1>     
   108 0000002A B900000000          <1>     mov ecx, 0      ; counter
   109 0000002F BB0A000000          <1>     mov ebx, 10     ; divisor
   110 00000034 8B4508              <1>     mov eax, .num
   111                              <1> .loop_count:
   112 00000037 BA00000000          <1>     mov edx, 0      ; reset remainder
   113 0000003C F7F3                <1>     div ebx         ; eax: quotient,  edx: remainder
   114                              <1>     
   115 0000003E 41                  <1>     inc ecx         ; counter++
   116 0000003F 83F800              <1>     cmp eax, 0
   117 00000042 75F3                <1>     jne .loop_count
   118                              <1> 
   119                              <1>     ; convert number to string
   120                              <1> 
   121 00000044 BB0A000000          <1>     mov ebx, 10     ; divisor
   122                              <1>     ;mov ecx, buffer.len   ; ecx = last string index
   123 00000049 89CE                <1>     mov esi, ecx   ; ecx = last number index
   124 0000004B 4E                  <1>     dec esi
   125                              <1> 
   126 0000004C 8B4508              <1>     mov eax, .num
   127                              <1> .loop_extract:
   128 0000004F BA00000000          <1>     mov edx, 0      ; reset remainder
   129 00000054 F7F3                <1>     div ebx         ; eax /= ebx; edx = eax mod ebx
   130                              <1> 
   131 00000056 83C230              <1>     add edx, byte '0'
   132 00000059 8896[44000000]      <1>     mov [buffer+esi], dl
   133 0000005F 8896[44000000]      <1>     mov [buffer+esi], dl
   134 00000065 4E                  <1>     dec esi         ; index--
   135                              <1>     
   136                              <1>     ; print each digit
   137                              <1>     ;mov [sum], dl  
   138                              <1>     ;call_ fun_print, sum, 1
   139                              <1> 
   140 00000066 83F800              <1>     cmp eax, 0      ; if eax == 0: end
   141 00000069 7FE4                <1>     jg .loop_extract
   142                              <1>     ; end loop
   143                              <1> 
   144                              <1>     ; reset remainder of buffer to zero
   145                              <1> ;.loop_spaces:
   146                              <1> ;    mov [buffer+esi], byte '0'  
   147                              <1> ;    dec esi;
   148                              <1> 
   149                              <1> ;    cmp esi, 0
   150                              <1> ;    jg .loop_spaces       ; if index != 0: loop
   151                              <1>     ; end loop
   152                              <1> 
   153                              <1>     call_ fun_print, buffer, ecx
   176                              <2>  %rep %0-1
   177                              <2>  %rotate 1
   178                              <2>  push %1
   179                              <2>  %endrep
   177                              <3>  %rotate 1
   178 0000006B 68[44000000]        <3>  push %1
   177                              <3>  %rotate 1
   178 00000070 51                  <3>  push %1
   180                              <2>  %rotate 1
   181 00000071 E88AFFFFFF          <2>  call %1
   182                              <2>  %if %0 > 1
   183 00000076 83C408              <2>  add esp, 4*(%0-1)
   184                              <2>  %endif
   154                              <1> 
   155                              <1>     pop_regs eax, ebx, edx, esi, ecx
   157                              <2> %rep %0
   158                              <2>  %rotate -1
   159                              <2>  pop %1
   160                              <2> %endrep
   158                              <3>  %rotate -1
   159 00000079 59                  <3>  pop %1
   158                              <3>  %rotate -1
   159 0000007A 5E                  <3>  pop %1
   158                              <3>  %rotate -1
   159 0000007B 5A                  <3>  pop %1
   158                              <3>  %rotate -1
   159 0000007C 5B                  <3>  pop %1
   158                              <3>  %rotate -1
   159 0000007D 58                  <3>  pop %1
   156                              <1>     ;pop_locals
   157                              <1>     pop_ebp
   146 0000007E 5D                  <2>  pop ebp
   158 0000007F C3                  <1>     ret
   159                              <1> 
   160                              <1> ; Print an array of positive integers
   161                              <1> ; ----------------------------------------------
   162                              <1> ; Stack Paramaters:
   163                              <1> ;   %1 Array address
   164                              <1> ;   %2 Array length (in bytes)
   165                              <1> ;   %3 Element length (int bytes)
   166                              <1> fun_print_array:
   167                              <1>     params .vec, .len, .step
   206                              <2>  %define %1 [ebp+16]
   207                              <2>  %define %2 [ebp+12]
   208                              <2>  %define %3 [ebp+8]
   168                              <1> 
   169                              <1>     %define .idx ebx
   170                              <1>     %define .adr ecx
   171                              <1> 
   172                              <1>     push_ebp
   141 00000080 55                  <2>  push ebp
   142 00000081 89E5                <2>  mov ebp, esp
   173                              <1>     ; push_locals
   174                              <1>     push_regs ebx, ecx
   150                              <2> %rep %0
   151                              <2>  push %1
   152                              <2>  %rotate 1
   153                              <2> %endrep
   151 00000083 53                  <3>  push %1
   152                              <3>  %rotate 1
   151 00000084 51                  <3>  push %1
   152                              <3>  %rotate 1
   175                              <1>    
   176 00000085 8B4D10              <1>     mov .adr, .vec
   177 00000088 BB00000000          <1>     mov .idx, 0
   178                              <1> .loop:
   179                              <1>     print_intsp byte [.adr+.idx]
    76                              <2>  call_ fun_int_to_str, %1
   176                              <3>  %rep %0-1
   177                              <3>  %rotate 1
   178                              <3>  push %1
   179                              <3>  %endrep
   177                              <4>  %rotate 1
   178                              <4>  push %1
   178          ******************  <4>  error: invalid combination of opcode and operands
   180                              <3>  %rotate 1
   181 0000008D E890FFFFFF          <3>  call %1
   182                              <3>  %if %0 > 1
   183 00000092 83C404              <3>  add esp, 4*(%0-1)
   184                              <3>  %endif
    77                              <2>  print_char byte ' '
   103 00000095 C605[52000000]20    <3>  mov [char], byte %1
   104                              <3>  print_str char
    90                              <4>  call_ fun_print, %1, %1.len
   176                              <5>  %rep %0-1
   177                              <5>  %rotate 1
   178                              <5>  push %1
   179                              <5>  %endrep
   177                              <6>  %rotate 1
   178 0000009C 68[52000000]        <6>  push %1
   177                              <6>  %rotate 1
   178 000000A1 6A01                <6>  push %1
   180                              <5>  %rotate 1
   181 000000A3 E858FFFFFF          <5>  call %1
   182                              <5>  %if %0 > 1
   183 000000A8 83C408              <5>  add esp, 4*(%0-1)
   184                              <5>  %endif
   180 000000AB 035D08              <1>     add .idx, .step
   181                              <1> 
   182 000000AE 3B5D0C              <1>     cmp .idx, .len
   183 000000B1 7CDA                <1>     jl .loop
   184                              <1>     ; end loop
   185                              <1> 
   186                              <1>     println
    62 000000B3 C605[52000000]0A    <2>  mov [char], byte 0x0a
    63                              <2>  call_ fun_print, char, 1
   176                              <3>  %rep %0-1
   177                              <3>  %rotate 1
   178                              <3>  push %1
   179                              <3>  %endrep
   177                              <4>  %rotate 1
   178 000000BA 68[52000000]        <4>  push %1
   177                              <4>  %rotate 1
   178 000000BF 6A01                <4>  push %1
   180                              <3>  %rotate 1
   181 000000C1 E83AFFFFFF          <3>  call %1
   182                              <3>  %if %0 > 1
   183 000000C6 83C408              <3>  add esp, 4*(%0-1)
   184                              <3>  %endif
   187                              <1> 
   188                              <1>     pop_regs ebx, ecx
   157                              <2> %rep %0
   158                              <2>  %rotate -1
   159                              <2>  pop %1
   160                              <2> %endrep
   158                              <3>  %rotate -1
   159 000000C9 59                  <3>  pop %1
   158                              <3>  %rotate -1
   159 000000CA 5B                  <3>  pop %1
   189                              <1>     ; pop_locals
   190                              <1>     pop_ebp
   146 000000CB 5D                  <2>  pop ebp
   191 000000CC C3                  <1>     ret
    70                                  
    71                                  ; ========================================
    72                                  ; SUBROUTINES
    73                                  ; ========================================
    74                                  
    75                                  ; Subroutine: Testing paramaters access
    76                                  ; ----------------------------------------------
    77                                  ; Stack Parameters:
    78                                  ;   %1 number 1
    79                                  ;   %2 number 2
    80                                  ;   %3 number 3
    81                                  fun_test:
    82                                      params .num1, .num2, .num3
   206                              <1>  %define %1 [ebp+16]
   207                              <1>  %define %2 [ebp+12]
   208                              <1>  %define %3 [ebp+8]
    83                                      push_ebp
   141 000000CD 55                  <1>  push ebp
   142 000000CE 89E5                <1>  mov ebp, esp
    84                                      push_vars .a, .b, .c
   259                              <1>  %define %1 [ebp-4]
   260                              <1>  %define %2 [ebp-8]
   261                              <1>  %define %3 [ebp-12]
   262 000000D0 83EC0C              <1>  sub esp, 4*%0
    85                                      push_regs eax, ebx, ecx
   150                              <1> %rep %0
   151                              <1>  push %1
   152                              <1>  %rotate 1
   153                              <1> %endrep
   151 000000D3 50                  <2>  push %1
   152                              <2>  %rotate 1
   151 000000D4 53                  <2>  push %1
   152                              <2>  %rotate 1
   151 000000D5 51                  <2>  push %1
   152                              <2>  %rotate 1
    86                                  
    87 000000D6 8B4510                      mov eax, .num1
    88 000000D9 8945FC                      mov .a, eax
    89                                  
    90 000000DC 8B450C                      mov eax, .num2
    91 000000DF 8945F8                      mov .b, eax
    92                                  
    93 000000E2 8B4508                      mov eax, .num3
    94 000000E5 8945F4                      mov .c, eax
    95 000000E8 8345F405                    add .c, dword 5
    96 000000EC 836DF403                    sub .c, dword 3
    97                                  
    98                                      print_intsp dword .a
    76                              <1>  call_ fun_int_to_str, %1
   176                              <2>  %rep %0-1
   177                              <2>  %rotate 1
   178                              <2>  push %1
   179                              <2>  %endrep
   177                              <3>  %rotate 1
   178 000000F0 FF75FC              <3>  push %1
   180                              <2>  %rotate 1
   181 000000F3 E82AFFFFFF          <2>  call %1
   182                              <2>  %if %0 > 1
   183 000000F8 83C404              <2>  add esp, 4*(%0-1)
   184                              <2>  %endif
    77                              <1>  print_char byte ' '
   103 000000FB C605[52000000]20    <2>  mov [char], byte %1
   104                              <2>  print_str char
    90                              <3>  call_ fun_print, %1, %1.len
   176                              <4>  %rep %0-1
   177                              <4>  %rotate 1
   178                              <4>  push %1
   179                              <4>  %endrep
   177                              <5>  %rotate 1
   178 00000102 68[52000000]        <5>  push %1
   177                              <5>  %rotate 1
   178 00000107 6A01                <5>  push %1
   180                              <4>  %rotate 1
   181 00000109 E8F2FEFFFF          <4>  call %1
   182                              <4>  %if %0 > 1
   183 0000010E 83C408              <4>  add esp, 4*(%0-1)
   184                              <4>  %endif
    99                                      print_intsp dword .b
    76                              <1>  call_ fun_int_to_str, %1
   176                              <2>  %rep %0-1
   177                              <2>  %rotate 1
   178                              <2>  push %1
   179                              <2>  %endrep
   177                              <3>  %rotate 1
   178 00000111 FF75F8              <3>  push %1
   180                              <2>  %rotate 1
   181 00000114 E809FFFFFF          <2>  call %1
   182                              <2>  %if %0 > 1
   183 00000119 83C404              <2>  add esp, 4*(%0-1)
   184                              <2>  %endif
    77                              <1>  print_char byte ' '
   103 0000011C C605[52000000]20    <2>  mov [char], byte %1
   104                              <2>  print_str char
    90                              <3>  call_ fun_print, %1, %1.len
   176                              <4>  %rep %0-1
   177                              <4>  %rotate 1
   178                              <4>  push %1
   179                              <4>  %endrep
   177                              <5>  %rotate 1
   178 00000123 68[52000000]        <5>  push %1
   177                              <5>  %rotate 1
   178 00000128 6A01                <5>  push %1
   180                              <4>  %rotate 1
   181 0000012A E8D1FEFFFF          <4>  call %1
   182                              <4>  %if %0 > 1
   183 0000012F 83C408              <4>  add esp, 4*(%0-1)
   184                              <4>  %endif
   100                                      print_intsp dword .c
    76                              <1>  call_ fun_int_to_str, %1
   176                              <2>  %rep %0-1
   177                              <2>  %rotate 1
   178                              <2>  push %1
   179                              <2>  %endrep
   177                              <3>  %rotate 1
   178 00000132 FF75F4              <3>  push %1
   180                              <2>  %rotate 1
   181 00000135 E8E8FEFFFF          <2>  call %1
   182                              <2>  %if %0 > 1
   183 0000013A 83C404              <2>  add esp, 4*(%0-1)
   184                              <2>  %endif
    77                              <1>  print_char byte ' '
   103 0000013D C605[52000000]20    <2>  mov [char], byte %1
   104                              <2>  print_str char
    90                              <3>  call_ fun_print, %1, %1.len
   176                              <4>  %rep %0-1
   177                              <4>  %rotate 1
   178                              <4>  push %1
   179                              <4>  %endrep
   177                              <5>  %rotate 1
   178 00000144 68[52000000]        <5>  push %1
   177                              <5>  %rotate 1
   178 00000149 6A01                <5>  push %1
   180                              <4>  %rotate 1
   181 0000014B E8B0FEFFFF          <4>  call %1
   182                              <4>  %if %0 > 1
   183 00000150 83C408              <4>  add esp, 4*(%0-1)
   184                              <4>  %endif
   101                                      println
    62 00000153 C605[52000000]0A    <1>  mov [char], byte 0x0a
    63                              <1>  call_ fun_print, char, 1
   176                              <2>  %rep %0-1
   177                              <2>  %rotate 1
   178                              <2>  push %1
   179                              <2>  %endrep
   177                              <3>  %rotate 1
   178 0000015A 68[52000000]        <3>  push %1
   177                              <3>  %rotate 1
   178 0000015F 6A01                <3>  push %1
   180                              <2>  %rotate 1
   181 00000161 E89AFEFFFF          <2>  call %1
   182                              <2>  %if %0 > 1
   183 00000166 83C408              <2>  add esp, 4*(%0-1)
   184                              <2>  %endif
   102                                  
   103                                      is_reg ax
   127                              <1>  %ifndef TypeOf.%1
   128                              <1>  %define result IMMEDIATE_TYPE
   129                              <1>  %elif TypeOf.%1 = REGISTER_TYPE
   130                              <1>  %define result REGISTER_TYPE
   131                              <1>  %else
   132                              <1>  %define result OTHER_TYPE
   133                              <1>  %endif
   104 00000169 BF00000000                  mov edi, result         ; symbol for macro return
   105                                      print_intln edi
    83                              <1>  print_int %1
    69                              <2>  call_ fun_int_to_str, %1
   176                              <3>  %rep %0-1
   177                              <3>  %rotate 1
   178                              <3>  push %1
   179                              <3>  %endrep
   177                              <4>  %rotate 1
   178 0000016E 57                  <4>  push %1
   180                              <3>  %rotate 1
   181 0000016F E8AEFEFFFF          <3>  call %1
   182                              <3>  %if %0 > 1
   183 00000174 83C404              <3>  add esp, 4*(%0-1)
   184                              <3>  %endif
    70                              <2> 
    84                              <1>  println
    62 00000177 C605[52000000]0A    <2>  mov [char], byte 0x0a
    63                              <2>  call_ fun_print, char, 1
   176                              <3>  %rep %0-1
   177                              <3>  %rotate 1
   178                              <3>  push %1
   179                              <3>  %endrep
   177                              <4>  %rotate 1
   178 0000017E 68[52000000]        <4>  push %1
   177                              <4>  %rotate 1
   178 00000183 6A01                <4>  push %1
   180                              <3>  %rotate 1
   181 00000185 E876FEFFFF          <3>  call %1
   182                              <3>  %if %0 > 1
   183 0000018A 83C408              <3>  add esp, 4*(%0-1)
   184                              <3>  %endif
   106                                  
   107                                      pop_regs eax, ebx, ecx
   157                              <1> %rep %0
   158                              <1>  %rotate -1
   159                              <1>  pop %1
   160                              <1> %endrep
   158                              <2>  %rotate -1
   159 0000018D 59                  <2>  pop %1
   158                              <2>  %rotate -1
   159 0000018E 5B                  <2>  pop %1
   158                              <2>  %rotate -1
   159 0000018F 58                  <2>  pop %1
   108                                      pop_vars 3
   274 00000190 83C40C              <1>  add esp, 4*%1
   109                                      pop_ebp
   146 00000193 5D                  <1>  pop ebp
   110 00000194 C3                          ret
   111                                  
   112                                  ; ----------------------------------------------
   113                                  ; START
   114                                  ; ----------------------------------------------
   115                                  global _start
   116                                  
   117                                  _start:  
   118                                      ;generate_primes
   119 00000195 BB00000000                  mov ebx, 0
   120                                  .loop:
   121                                      call_ fun_print_array, vecb, vecb.len, 1
   176                              <1>  %rep %0-1
   177                              <1>  %rotate 1
   178                              <1>  push %1
   179                              <1>  %endrep
   177                              <2>  %rotate 1
   178 0000019A 68[3A000000]        <2>  push %1
   177                              <2>  %rotate 1
   178 0000019F 6A0A                <2>  push %1
   177                              <2>  %rotate 1
   178 000001A1 6A01                <2>  push %1
   180                              <1>  %rotate 1
   181 000001A3 E8D8FEFFFF          <1>  call %1
   182                              <1>  %if %0 > 1
   183 000001A8 83C40C              <1>  add esp, 4*(%0-1)
   184                              <1>  %endif
   122                                  
   123                                      ; general tests
   124                                      ;call_ fun_print_array, vec, vec.len, 4
   125                                      ;print_intln 123456
   126                                      ;print_strln msg
   127                                      ;call_ fun_test, 1, 2, 3
   128                                  
   129 000001AB B801000000                  mov eax, 1
   130 000001B0 89FB                        mov ebx, edi  ; exit status
   131 000001B2 CD80                        int 0x80
   132                                  
   133                                  section .data
   134                                      def_str msg, "Printing a string!"
    20 00000000 5072696E74696E6720- <1>  %1 db %2
    20 00000009 6120737472696E6721  <1>
    21                              <1>  %1.len equ $ - %1
   135                                  
   136 00000012 010000000200000003-         vec     dd  1,2,3,4,5,6,7,8,9,10
   136 0000001B 000000040000000500-
   136 00000024 000006000000070000-
   136 0000002D 000800000009000000-
   136 00000036 0A000000           
   137                                      vec.len equ $ - vec
   138                                  
   139 0000003A 010203040506070809-         vecb    db  1,2,3,4,5,6,7,8,9,10
   139 00000043 0A                 
   140                                      vecb.len equ $ - vecb
   141                                  
   142                                      ; needed for printing functions
   143                                      def_str buffer, "000000000000"
    20 00000044 303030303030303030- <1>  %1 db %2
    20 0000004D 303030              <1>
    21                              <1>  %1.len equ $ - %1
   144                                      def_str sep, ", "
    20 00000050 2C20                <1>  %1 db %2
    21                              <1>  %1.len equ $ - %1
   145                                      def_str char, "0"
    20 00000052 30                  <1>  %1 db %2
    21                              <1>  %1.len equ $ - %1
   146                                  
   147                                  segment .bss
   148 00000000 <res Ah>                    vecc    resb 10
   149 0000000A <res Bh>                    numbers resb numbers.n+1
