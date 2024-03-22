     1                                  ; x86 Assembly Program
     2                                  ;   Allocating and iterating over array
     3                                  ;
     4                                  ; ----------------------------------------------------
     5                                  ; nasm -f elf32 prog.asm -o prog1.o
     6                                  ; gcc -o prog.elf -m32 prog.o -nostdlib -static
     7                                  ; echo $?    <- show last program output
     8                                  ;
     9                                  ; registers: https://en.wikibooks.org/wiki/X86_Assembly/X86_Architecture 
    10                                  
    11                                  ; ========================================
    12                                  ; MACROS
    13                                  ; ========================================
    14                                  %include "macros.asm"
    15                              <1> %ifndef MACROS_MAC
    16                              <1> %define MACROS_MAC
    17                              <1> 
    18                              <1> ; Macro: Signalize program termination
    19                              <1> ;   %1 Exit status
    20                              <1> %macro sys_exit 1
    21                              <1>     mov ebx, %1    ; exit status
    22                              <1>     mov eax, 1    ; sys_exit
    23                              <1>     int 0x80
    24                              <1> %endmacro
    25                              <1> 
    26                              <1> ; Macro: Define String
    27                              <1> ;   %1 symbol name
    28                              <1> ;   %2 string
    29                              <1> %macro def_str 2
    30                              <1>     %1 db  %2
    31                              <1>     %1.len equ $ - %1
    32                              <1> %endmacro
    33                              <1> 
    34                              <1> ; Macro: Initialize array with number
    35                              <1> ; Stack paramaters:
    36                              <1> ;   %1 char
    37                              <1> ;   %2 string address
    38                              <1> ;   %3 string length
    39                              <1> %macro fstring_init 3
    40                              <1>     push %1
    41                              <1>     push %2
    42                              <1>     push %3
    43                              <1>     call fun_string_init 
    44                              <1>     add esp, 4*3
    45                              <1> %endmacro
    46                              <1> 
    47                              <1> ; Macro: Print \n
    48                              <1> %macro fprintln 0
    49                              <1>     push newline
    50                              <1>     push 1
    51                              <1>     call fun_print
    52                              <1>     add esp, 8
    53                              <1> %endmacro
    54                              <1> 
    55                              <1> ; Macro: Print string
    56                              <1> ; paramaters:
    57                              <1> ;   %1 string address
    58                              <1> ;   %2 string length
    59                              <1> %macro fprint 2
    60                              <1>     push %1
    61                              <1>     push %2
    62                              <1>     call fun_print
    63                              <1>     add esp, 8
    64                              <1> %endmacro
    65                              <1> 
    66                              <1> ; ---------------------------------------------------------
    67                              <1> ; PRINT FUNCION UTILITIES
    68                              <1> ; ---------------------------------------------------------
    69                              <1> 
    70                              <1> ; Macro: Print line break
    71                              <1> %macro println 0
    72                              <1>     mov [char], byte 0x0a
    73                              <1>     call_ fun_print, char, 1
    74                              <1> %endmacro
    75                              <1> 
    76                              <1> ; Macro: Print int
    77                              <1> ;   %1 int to print
    78                              <1> %macro print_int 1
    79                              <1>     call_ fun_int_to_str, %1
    80                              <1>     ;call_ fun_print, buffer, buffer.len
    81                              <1> %endmacro
    82                              <1> 
    83                              <1> ; Macro: Print int with trailing space
    84                              <1> ;   %1 int to print
    85                              <1> %macro print_intsp 1
    86                              <1>     call_ fun_int_to_str, %1
    87                              <1>     print_char byte ' '
    88                              <1> %endmacro
    89                              <1> 
    90                              <1> ; Macro: Print int and break line
    91                              <1> ;   %1 int to print
    92                              <1> %macro print_intln 1
    93                              <1>     print_int %1
    94                              <1>     println
    95                              <1> %endmacro
    96                              <1> 
    97                              <1> ; Macro: Print String
    98                              <1> ;   %1 string address
    99                              <1> %macro print_str 1
   100                              <1>     call_ fun_print, %1, %1.len
   101                              <1> %endmacro
   102                              <1> 
   103                              <1> ; Macro: Print String and break line
   104                              <1> ;   %1 string address
   105                              <1> %macro print_strln 1
   106                              <1>     print_str %1
   107                              <1>     println
   108                              <1> %endmacro
   109                              <1> 
   110                              <1> ; Macro: Print char
   111                              <1> ;   %1 char to print
   112                              <1> %macro print_char 1
   113                              <1>     mov [char], byte %1
   114                              <1>     print_str char
   115                              <1> %endmacro
   116                              <1> 
   117                              <1> ; ---------------------------------------------------------
   118                              <1> ; TYPEOF MACRO
   119                              <1> ; ---------------------------------------------------------
   120                              <1> 
   121                              <1> %define IMMEDIATE_TYPE   0
   122                              <1> %define REGISTER_TYPE    1
   123                              <1> %define OTHER_TYPE       2
   124                              <1> %define INTEGER_TYPE_ID  3
   125                              <1> %define FLOAT_TYPE_ID    4
   126                              <1> %define STRING_TYPE_ID   5
   127                              <1> %define FUNCTION_TYPE_ID 6
   128                              <1> 
   129                              <1> %define TypeOf.eax      REGISTER_TYPE
   130                              <1> %define TypeOf.ebx      REGISTER_TYPE
   131                              <1> %define TypeOf.ecx      REGISTER_TYPE
   132                              <1> %define TypeOf.edx      REGISTER_TYPE
   133                              <1> %define TypeOf.edi      REGISTER_TYPE
   134                              <1> %define TypeOf.esi      REGISTER_TYPE
   135                              <1> 
   136                              <1> %macro is_reg 1
   137                              <1>     %ifndef TypeOf.%1
   138                              <1>         %define result IMMEDIATE_TYPE
   139                              <1>     %elif TypeOf.%1 = REGISTER_TYPE
   140                              <1>         %define result REGISTER_TYPE
   141                              <1>     %else
   142                              <1>         %define result OTHER_TYPE
   143                              <1>     %endif
   144                              <1> %endmacro
   145                              <1> 
   146                              <1> ; ---------------------------------------------------------
   147                              <1> ; PUSH / POP UTILITIES FOR SUBROUTINES
   148                              <1> ; ---------------------------------------------------------
   149                              <1> 
   150                              <1> %macro push_ebp 0
   151                              <1>     push ebp
   152                              <1>     mov ebp, esp
   153                              <1> %endmacro
   154                              <1> 
   155                              <1> %macro pop_ebp 0
   156                              <1>     pop ebp
   157                              <1> %endmacro
   158                              <1> 
   159                              <1> %macro push_regs 1-*
   160                              <1> %rep %0
   161                              <1>     push %1
   162                              <1>     %rotate 1       ; rotate macro params to left
   163                              <1> %endrep
   164                              <1> %endmacro
   165                              <1> 
   166                              <1> %macro pop_regs 1-*
   167                              <1> %rep %0
   168                              <1>     %rotate -1      ; rotate macro params to right
   169                              <1>     pop %1
   170                              <1> %endrep
   171                              <1> %endmacro
   172                              <1> 
   173                              <1> ; ---------------------------------------------------------
   174                              <1> ; SUBROUTINE CALL AND PARAMETERS
   175                              <1> ; ---------------------------------------------------------
   176                              <1> ; reg
   177                              <1> ; reg
   178                              <1> ; local     -8
   179                              <1> ; local     -4
   180                              <1> ; ebp       <
   181                              <1> ; @return
   182                              <1> ; param     +8
   183                              <1> ; param     +12
   184                              <1> 
   185                              <1> %macro call_ 1-*
   186                              <1>     %rep %0-1       ; push args
   187                              <1>         %rotate 1   ; rotate left
   188                              <1>         push %1
   189                              <1>     %endrep
   190                              <1>     %rotate 1
   191                              <1>     call %1
   192                              <1>     %if %0 > 1
   193                              <1>         add esp, 4*(%0-1)
   194                              <1>     %endif
   195                              <1> %endmacro
   196                              <1> 
   197                              <1> %macro stack_params_ 1-*    ; DOESN'T WORK...
   198                              <1>     %assign i 8
   199                              <1>     %rep %0
   200                              <1>         %rotate -1          ; rotate macro params right
   201                              <1>         %define %1 [ebp+i]
   202                              <1>         %assign i i+4       ; assign must written before using it
   203                              <1>     %endrep
   204                              <1> %endmacro
   205                              <1> 
   206                              <1> %macro stack_params 1
   207                              <1>     %define %1 [ebp+8]
   208                              <1> %endmacro
   209                              <1> 
   210                              <1> %macro stack_params 2
   211                              <1>     %define %1 [ebp+12]
   212                              <1>     %define %2 [ebp+8]
   213                              <1> %endmacro
   214                              <1> 
   215                              <1> %macro stack_params 3
   216                              <1>     %define %1 [ebp+16]
   217                              <1>     %define %2 [ebp+12]
   218                              <1>     %define %3 [ebp+8]
   219                              <1> %endmacro
   220                              <1> 
   221                              <1> %macro stack_params 4
   222                              <1>     %define %1 [ebp+20]
   223                              <1>     %define %2 [ebp+16]
   224                              <1>     %define %3 [ebp+12]
   225                              <1>     %define %4 [ebp+8]
   226                              <1> %endmacro
   227                              <1> 
   228                              <1> %macro stack_params 5
   229                              <1>     %define %1 [ebp+24]
   230                              <1>     %define %2 [ebp+20]
   231                              <1>     %define %3 [ebp+16]
   232                              <1>     %define %4 [ebp+12]
   233                              <1>     %define %5 [ebp+8]
   234                              <1> %endmacro
   235                              <1> 
   236                              <1> ; ---------------------------------------------------------
   237                              <1> ; LOCAL STACK VARS UTILITIES FOR SUBROUTINES
   238                              <1> ; ---------------------------------------------------------
   239                              <1> 
   240                              <1> ; local2    -8
   241                              <1> ; local1    -4
   242                              <1> ; ebp   <
   243                              <1> ; @return
   244                              <1> ; param1    +8
   245                              <1> ; param2    +12
   246                              <1> 
   247                              <1> %macro push_vars_ 1-*
   248                              <1>     %assign i 0
   249                              <1>     %rep %0
   250                              <1>         %assign i i+4
   251                              <1>         %define %1 [ebp-i]
   252                              <1>         %rotate 1           ; rotate macro params left
   253                              <1>     %endrep
   254                              <1>     sub esp, 4*%0           ; allocate space in stack
   255                              <1> %endmacro
   256                              <1> 
   257                              <1> %macro push_vars 1
   258                              <1>     %define %1 [ebp-4]
   259                              <1>     sub esp, 4*%0           ; allocate space in stack
   260                              <1> %endmacro
   261                              <1> 
   262                              <1> %macro push_vars 2
   263                              <1>     %define %1 [ebp-4]
   264                              <1>     %define %2 [ebp-8]
   265                              <1>     sub esp, 4*%0           ; allocate space in stack
   266                              <1> %endmacro
   267                              <1> 
   268                              <1> %macro push_vars 3
   269                              <1>     %define %1 [ebp-4]
   270                              <1>     %define %2 [ebp-8]
   271                              <1>     %define %3 [ebp-12]
   272                              <1>     sub esp, 4*%0           ; allocate space in stack
   273                              <1> %endmacro
   274                              <1> 
   275                              <1> %macro push_vars 4
   276                              <1>     %define %1 [ebp-4]
   277                              <1>     %define %2 [ebp-8]
   278                              <1>     %define %3 [ebp-12]
   279                              <1>     %define %4 [ebp-16]
   280                              <1>     sub esp, 4*%0           ; allocate space in stack
   281                              <1> %endmacro
   282                              <1> 
   283                              <1> %macro pop_vars 1
   284                              <1>     add esp, 4*%1      ; free locals in stack
   285                              <1> %endmacro
   286                              <1> 
   287                              <1> %endif
    15                                  
    16                                  %macro summation 1-*
    17                                      mov edi, 0
    18                                      %rep %0
    19                                          add edi, %1
    20                                          %rotate 1
    21                                      %endrep
    22                                  
    23                                      print_intln edi
    24                                  %endmacro
    25                                  
    26                                  section .text
    27                                  
    28                                  ; ========================================
    29                                  ; SUBROUTINES
    30                                  ; ========================================
    31                                  
    32                                  ; Testing paramaters access
    33                                  ; ----------------------------------------------
    34                                  ; Stack Parameters:
    35                                  ;   %1 number 1
    36                                  ;   %2 number 2
    37                                  ;   %3 number 3
    38                                  fun_test:
    39                                      stack_params .num1, .num2, .num3
   216                              <1>  %define %1 [ebp+16]
   217                              <1>  %define %2 [ebp+12]
   218                              <1>  %define %3 [ebp+8]
    40                                      ;push_stack .a, .b, .c, eax, ebx, ecx
    41                                      push_ebp
   151 00000000 55                  <1>  push ebp
   152 00000001 89E5                <1>  mov ebp, esp
    42                                      push_vars .a, .b, .c
   269                              <1>  %define %1 [ebp-4]
   270                              <1>  %define %2 [ebp-8]
   271                              <1>  %define %3 [ebp-12]
   272 00000003 83EC0C              <1>  sub esp, 4*%0
    43                                      push_regs eax, ebx, ecx
   160                              <1> %rep %0
   161                              <1>  push %1
   162                              <1>  %rotate 1
   163                              <1> %endrep
   161 00000006 50                  <2>  push %1
   162                              <2>  %rotate 1
   161 00000007 53                  <2>  push %1
   162                              <2>  %rotate 1
   161 00000008 51                  <2>  push %1
   162                              <2>  %rotate 1
    44                                  
    45 00000009 8B4510                      mov eax, .num1
    46 0000000C 8945FC                      mov .a, eax
    47                                  
    48 0000000F 8B450C                      mov eax, .num2
    49 00000012 8945F8                      mov .b, eax
    50                                  
    51 00000015 8B4508                      mov eax, .num3
    52 00000018 8945F4                      mov .c, eax
    53 0000001B 8345F405                    add .c, dword 5
    54 0000001F 836DF40A                    sub .c, dword 10
    55                                  
    56                                      print_intsp dword .a
    86                              <1>  call_ fun_int_to_str, %1
   186                              <2>  %rep %0-1
   187                              <2>  %rotate 1
   188                              <2>  push %1
   189                              <2>  %endrep
   187                              <3>  %rotate 1
   188 00000023 FF75FC              <3>  push %1
   190                              <2>  %rotate 1
   191 00000026 E8BF000000          <2>  call %1
   192                              <2>  %if %0 > 1
   193 0000002B 83C404              <2>  add esp, 4*(%0-1)
   194                              <2>  %endif
    87                              <1>  print_char byte ' '
   113 0000002E C605[3A000000]20    <2>  mov [char], byte %1
   114                              <2>  print_str char
   100                              <3>  call_ fun_print, %1, %1.len
   186                              <4>  %rep %0-1
   187                              <4>  %rotate 1
   188                              <4>  push %1
   189                              <4>  %endrep
   187                              <5>  %rotate 1
   188 00000035 68[3A000000]        <5>  push %1
   187                              <5>  %rotate 1
   188 0000003A 6A01                <5>  push %1
   190                              <4>  %rotate 1
   191 0000003C E887000000          <4>  call %1
   192                              <4>  %if %0 > 1
   193 00000041 83C408              <4>  add esp, 4*(%0-1)
   194                              <4>  %endif
    57                                      print_intsp dword .b
    86                              <1>  call_ fun_int_to_str, %1
   186                              <2>  %rep %0-1
   187                              <2>  %rotate 1
   188                              <2>  push %1
   189                              <2>  %endrep
   187                              <3>  %rotate 1
   188 00000044 FF75F8              <3>  push %1
   190                              <2>  %rotate 1
   191 00000047 E89E000000          <2>  call %1
   192                              <2>  %if %0 > 1
   193 0000004C 83C404              <2>  add esp, 4*(%0-1)
   194                              <2>  %endif
    87                              <1>  print_char byte ' '
   113 0000004F C605[3A000000]20    <2>  mov [char], byte %1
   114                              <2>  print_str char
   100                              <3>  call_ fun_print, %1, %1.len
   186                              <4>  %rep %0-1
   187                              <4>  %rotate 1
   188                              <4>  push %1
   189                              <4>  %endrep
   187                              <5>  %rotate 1
   188 00000056 68[3A000000]        <5>  push %1
   187                              <5>  %rotate 1
   188 0000005B 6A01                <5>  push %1
   190                              <4>  %rotate 1
   191 0000005D E866000000          <4>  call %1
   192                              <4>  %if %0 > 1
   193 00000062 83C408              <4>  add esp, 4*(%0-1)
   194                              <4>  %endif
    58                                      print_intsp dword .c
    86                              <1>  call_ fun_int_to_str, %1
   186                              <2>  %rep %0-1
   187                              <2>  %rotate 1
   188                              <2>  push %1
   189                              <2>  %endrep
   187                              <3>  %rotate 1
   188 00000065 FF75F4              <3>  push %1
   190                              <2>  %rotate 1
   191 00000068 E87D000000          <2>  call %1
   192                              <2>  %if %0 > 1
   193 0000006D 83C404              <2>  add esp, 4*(%0-1)
   194                              <2>  %endif
    87                              <1>  print_char byte ' '
   113 00000070 C605[3A000000]20    <2>  mov [char], byte %1
   114                              <2>  print_str char
   100                              <3>  call_ fun_print, %1, %1.len
   186                              <4>  %rep %0-1
   187                              <4>  %rotate 1
   188                              <4>  push %1
   189                              <4>  %endrep
   187                              <5>  %rotate 1
   188 00000077 68[3A000000]        <5>  push %1
   187                              <5>  %rotate 1
   188 0000007C 6A01                <5>  push %1
   190                              <4>  %rotate 1
   191 0000007E E845000000          <4>  call %1
   192                              <4>  %if %0 > 1
   193 00000083 83C408              <4>  add esp, 4*(%0-1)
   194                              <4>  %endif
    59                                      println
    72 00000086 C605[3A000000]0A    <1>  mov [char], byte 0x0a
    73                              <1>  call_ fun_print, char, 1
   186                              <2>  %rep %0-1
   187                              <2>  %rotate 1
   188                              <2>  push %1
   189                              <2>  %endrep
   187                              <3>  %rotate 1
   188 0000008D 68[3A000000]        <3>  push %1
   187                              <3>  %rotate 1
   188 00000092 6A01                <3>  push %1
   190                              <2>  %rotate 1
   191 00000094 E82F000000          <2>  call %1
   192                              <2>  %if %0 > 1
   193 00000099 83C408              <2>  add esp, 4*(%0-1)
   194                              <2>  %endif
    60                                  
    61                                      is_reg ax
   137                              <1>  %ifndef TypeOf.%1
   138                              <1>  %define result IMMEDIATE_TYPE
   139                              <1>  %elif TypeOf.%1 = REGISTER_TYPE
   140                              <1>  %define result REGISTER_TYPE
   141                              <1>  %else
   142                              <1>  %define result OTHER_TYPE
   143                              <1>  %endif
    62 0000009C BF00000000                  mov edi, result         ; symbol for macro return
    63                                      print_intln edi
    93                              <1>  print_int %1
    79                              <2>  call_ fun_int_to_str, %1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 000000A1 57                  <4>  push %1
   190                              <3>  %rotate 1
   191 000000A2 E843000000          <3>  call %1
   192                              <3>  %if %0 > 1
   193 000000A7 83C404              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
    80                              <2> 
    94                              <1>  println
    72 000000AA C605[3A000000]0A    <2>  mov [char], byte 0x0a
    73                              <2>  call_ fun_print, char, 1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 000000B1 68[3A000000]        <4>  push %1
   187                              <4>  %rotate 1
   188 000000B6 6A01                <4>  push %1
   190                              <3>  %rotate 1
   191 000000B8 E80B000000          <3>  call %1
   192                              <3>  %if %0 > 1
   193 000000BD 83C408              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
    64                                  
    65                                      pop_regs eax, ebx, ecx
   167                              <1> %rep %0
   168                              <1>  %rotate -1
   169                              <1>  pop %1
   170                              <1> %endrep
   168                              <2>  %rotate -1
   169 000000C0 59                  <2>  pop %1
   168                              <2>  %rotate -1
   169 000000C1 5B                  <2>  pop %1
   168                              <2>  %rotate -1
   169 000000C2 58                  <2>  pop %1
    66                                      pop_vars 3
   284 000000C3 83C40C              <1>  add esp, 4*%1
    67                                      pop_ebp
   156 000000C6 5D                  <1>  pop ebp
    68                                  
    69 000000C7 C3                          ret
    70                                  
    71                                  ; Print string
    72                                  ; ----------------------------------------------
    73                                  ; Stack Paramaters:
    74                                  ;   %1 string address
    75                                  ;   %2 string length in bytes
    76                                  fun_print:
    77                                      stack_params .str, .n
   211                              <1>  %define %1 [ebp+12]
   212                              <1>  %define %2 [ebp+8]
    78                                  
    79                                      push_ebp
   151 000000C8 55                  <1>  push ebp
   152 000000C9 89E5                <1>  mov ebp, esp
    80                                      ; push_locals
    81                                      push_regs eax, ebx, ecx, edx  
   160                              <1> %rep %0
   161                              <1>  push %1
   162                              <1>  %rotate 1
   163                              <1> %endrep
   161 000000CB 50                  <2>  push %1
   162                              <2>  %rotate 1
   161 000000CC 53                  <2>  push %1
   162                              <2>  %rotate 1
   161 000000CD 51                  <2>  push %1
   162                              <2>  %rotate 1
   161 000000CE 52                  <2>  push %1
   162                              <2>  %rotate 1
    82                                      
    83 000000CF 8B4D0C                      mov     ecx, .str
    84 000000D2 8B5508                      mov     edx, .n
    85 000000D5 BB01000000                  mov     ebx, 1
    86 000000DA B804000000                  mov     eax, 4
    87 000000DF CD80                        int     0x80
    88                                  
    89 000000E1 8B7D08                      mov edi, .n
    90                                      
    91                                      pop_regs eax, ebx, ecx, edx
   167                              <1> %rep %0
   168                              <1>  %rotate -1
   169                              <1>  pop %1
   170                              <1> %endrep
   168                              <2>  %rotate -1
   169 000000E4 5A                  <2>  pop %1
   168                              <2>  %rotate -1
   169 000000E5 59                  <2>  pop %1
   168                              <2>  %rotate -1
   169 000000E6 5B                  <2>  pop %1
   168                              <2>  %rotate -1
   169 000000E7 58                  <2>  pop %1
    92                                      ; pop_locals
    93                                      pop_ebp
   156 000000E8 5D                  <1>  pop ebp
    94                                  
    95 000000E9 C3                          ret
    96                                  
    97                                  ; Convert int to str
    98                                  ; ----------------------------------------------
    99                                  ; Stack params:
   100                                  ;   %1 int number
   101                                  fun_int_to_str:
   102                                      stack_params .num
   207                              <1>  %define %1 [ebp+8]
   103                                  
   104                                      push_ebp
   151 000000EA 55                  <1>  push ebp
   152 000000EB 89E5                <1>  mov ebp, esp
   105                                      ;push_locals
   106                                      push_regs eax, ebx, edx, esi, ecx
   160                              <1> %rep %0
   161                              <1>  push %1
   162                              <1>  %rotate 1
   163                              <1> %endrep
   161 000000ED 50                  <2>  push %1
   162                              <2>  %rotate 1
   161 000000EE 53                  <2>  push %1
   162                              <2>  %rotate 1
   161 000000EF 52                  <2>  push %1
   162                              <2>  %rotate 1
   161 000000F0 56                  <2>  push %1
   162                              <2>  %rotate 1
   161 000000F1 51                  <2>  push %1
   162                              <2>  %rotate 1
   107                                  
   108                                      ; find int number length
   109                                      
   110 000000F2 B900000000                  mov ecx, 0      ; counter
   111 000000F7 BB0A000000                  mov ebx, 10     ; divisor
   112 000000FC 8B4508                      mov eax, .num
   113                                  .loop_count:
   114 000000FF BA00000000                  mov edx, 0      ; reset remainder
   115 00000104 F7F3                        div ebx         ; eax: quotient,  edx: remainder
   116                                      
   117 00000106 41                          inc ecx         ; counter++
   118 00000107 83F800                      cmp eax, 0
   119 0000010A 75F3                        jne .loop_count
   120                                  
   121                                      ; convert number to string
   122                                  
   123 0000010C BB0A000000                  mov ebx, 10     ; divisor
   124                                      ;mov ecx, buffer.len   ; ecx = last string index
   125 00000111 89CE                        mov esi, ecx   ; ecx = last number index
   126 00000113 4E                          dec esi
   127                                  
   128 00000114 8B4508                      mov eax, .num
   129                                  .loop_extract:
   130 00000117 BA00000000                  mov edx, 0      ; reset remainder
   131 0000011C F7F3                        div ebx         ; eax /= ebx; edx = eax mod ebx
   132                                  
   133 0000011E 83C230                      add edx, byte '0'
   134 00000121 8896[2E000000]              mov [buffer+esi], dl
   135 00000127 8896[2E000000]              mov [buffer+esi], dl
   136 0000012D 4E                          dec esi         ; index--
   137                                      
   138                                      ; print each digit
   139                                      ;mov [sum], dl  
   140                                      ;call_ fun_print, sum, 1
   141                                  
   142 0000012E 83F800                      cmp eax, 0      ; if eax == 0: end
   143 00000131 7FE4                        jg .loop_extract
   144                                      ; end loop
   145                                  
   146                                      ; reset remainder of buffer to zero
   147                                  ;.loop_spaces:
   148                                  ;    mov [buffer+esi], byte '0'  
   149                                  ;    dec esi;
   150                                  
   151                                  ;    cmp esi, 0
   152                                  ;    jg .loop_spaces       ; if index != 0: loop
   153                                      ; end loop
   154                                  
   155                                      call_ fun_print, buffer, ecx
   186                              <1>  %rep %0-1
   187                              <1>  %rotate 1
   188                              <1>  push %1
   189                              <1>  %endrep
   187                              <2>  %rotate 1
   188 00000133 68[2E000000]        <2>  push %1
   187                              <2>  %rotate 1
   188 00000138 51                  <2>  push %1
   190                              <1>  %rotate 1
   191 00000139 E88AFFFFFF          <1>  call %1
   192                              <1>  %if %0 > 1
   193 0000013E 83C408              <1>  add esp, 4*(%0-1)
   194                              <1>  %endif
   156                                  
   157                                      pop_regs eax, ebx, edx, esi, ecx
   167                              <1> %rep %0
   168                              <1>  %rotate -1
   169                              <1>  pop %1
   170                              <1> %endrep
   168                              <2>  %rotate -1
   169 00000141 59                  <2>  pop %1
   168                              <2>  %rotate -1
   169 00000142 5E                  <2>  pop %1
   168                              <2>  %rotate -1
   169 00000143 5A                  <2>  pop %1
   168                              <2>  %rotate -1
   169 00000144 5B                  <2>  pop %1
   168                              <2>  %rotate -1
   169 00000145 58                  <2>  pop %1
   158                                      ;pop_locals
   159                                      pop_ebp
   156 00000146 5D                  <1>  pop ebp
   160 00000147 C3                          ret
   161                                  
   162                                  ; Print an array of positive integers
   163                                  ; ----------------------------------------------
   164                                  ; Stack Paramaters:
   165                                  fun_print_array:
   166                                      %define .idx ebx
   167                                  
   168                                      push_ebp
   151 00000148 55                  <1>  push ebp
   152 00000149 89E5                <1>  mov ebp, esp
   169                                      ; push_locals
   170                                      push_regs ebx
   160                              <1> %rep %0
   161                              <1>  push %1
   162                              <1>  %rotate 1
   163                              <1> %endrep
   161 0000014B 53                  <2>  push %1
   162                              <2>  %rotate 1
   171                                      
   172 0000014C BB00000000                  mov .idx, 0
   173                                  .loop:
   174                                      print_int dword [vec+.idx]
    79                              <1>  call_ fun_int_to_str, %1
   186                              <2>  %rep %0-1
   187                              <2>  %rotate 1
   188                              <2>  push %1
   189                              <2>  %endrep
   187                              <3>  %rotate 1
   188 00000151 FFB3[12000000]      <3>  push %1
   190                              <2>  %rotate 1
   191 00000157 E88EFFFFFF          <2>  call %1
   192                              <2>  %if %0 > 1
   193 0000015C 83C404              <2>  add esp, 4*(%0-1)
   194                              <2>  %endif
    80                              <1> 
   175                                      print_str sep
   100                              <1>  call_ fun_print, %1, %1.len
   186                              <2>  %rep %0-1
   187                              <2>  %rotate 1
   188                              <2>  push %1
   189                              <2>  %endrep
   187                              <3>  %rotate 1
   188 0000015F 68[3B000000]        <3>  push %1
   187                              <3>  %rotate 1
   188 00000164 6A02                <3>  push %1
   190                              <2>  %rotate 1
   191 00000166 E85DFFFFFF          <2>  call %1
   192                              <2>  %if %0 > 1
   193 0000016B 83C408              <2>  add esp, 4*(%0-1)
   194                              <2>  %endif
   176 0000016E 83C304                      add .idx, 4
   177                                  
   178 00000171 83FB1C                      cmp .idx, vec.len
   179 00000174 7CDB                        jl .loop
   180                                      ; end loop
   181                                  
   182                                      println
    72 00000176 C605[3A000000]0A    <1>  mov [char], byte 0x0a
    73                              <1>  call_ fun_print, char, 1
   186                              <2>  %rep %0-1
   187                              <2>  %rotate 1
   188                              <2>  push %1
   189                              <2>  %endrep
   187                              <3>  %rotate 1
   188 0000017D 68[3A000000]        <3>  push %1
   187                              <3>  %rotate 1
   188 00000182 6A01                <3>  push %1
   190                              <2>  %rotate 1
   191 00000184 E83FFFFFFF          <2>  call %1
   192                              <2>  %if %0 > 1
   193 00000189 83C408              <2>  add esp, 4*(%0-1)
   194                              <2>  %endif
   183                                  
   184                                      pop_regs ebx
   167                              <1> %rep %0
   168                              <1>  %rotate -1
   169                              <1>  pop %1
   170                              <1> %endrep
   168                              <2>  %rotate -1
   169 0000018C 5B                  <2>  pop %1
   185                                      ; pop_locals
   186                                      pop_ebp
   156 0000018D 5D                  <1>  pop ebp
   187 0000018E C3                          ret
   188                                  
   189                                  
   190                                  ; ----------------------------------------------
   191                                  ; START
   192                                  ; ----------------------------------------------
   193                                  
   194                                  global _start
   195                                  
   196                                  _start:  
   197                                      call_ fun_print_array
   186                              <1>  %rep %0-1
   187                              <1>  %rotate 1
   188                              <1>  push %1
   189                              <1>  %endrep
   190                              <1>  %rotate 1
   191 0000018F E8B4FFFFFF          <1>  call %1
   192                              <1>  %if %0 > 1
   193                              <1>  add esp, 4*(%0-1)
   194                              <1>  %endif
   198                                  
   199                                      summation 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
    17 00000194 BF00000000          <1>  mov edi, 0
    18                              <1>  %rep %0
    19                              <1>  add edi, %1
    20                              <1>  %rotate 1
    21                              <1>  %endrep
    19 00000199 83C701              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 0000019C 83C702              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 0000019F 83C703              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001A2 83C704              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001A5 83C705              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001A8 83C706              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001AB 83C707              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001AE 83C708              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001B1 83C709              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001B4 83C70A              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001B7 83C70B              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001BA 83C70C              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001BD 83C70D              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001C0 83C70E              <2>  add edi, %1
    20                              <2>  %rotate 1
    19 000001C3 83C70F              <2>  add edi, %1
    20                              <2>  %rotate 1
    22                              <1> 
    23                              <1>  print_intln edi
    93                              <2>  print_int %1
    79                              <3>  call_ fun_int_to_str, %1
   186                              <4>  %rep %0-1
   187                              <4>  %rotate 1
   188                              <4>  push %1
   189                              <4>  %endrep
   187                              <5>  %rotate 1
   188 000001C6 57                  <5>  push %1
   190                              <4>  %rotate 1
   191 000001C7 E81EFFFFFF          <4>  call %1
   192                              <4>  %if %0 > 1
   193 000001CC 83C404              <4>  add esp, 4*(%0-1)
   194                              <4>  %endif
    80                              <3> 
    94                              <2>  println
    72 000001CF C605[3A000000]0A    <3>  mov [char], byte 0x0a
    73                              <3>  call_ fun_print, char, 1
   186                              <4>  %rep %0-1
   187                              <4>  %rotate 1
   188                              <4>  push %1
   189                              <4>  %endrep
   187                              <5>  %rotate 1
   188 000001D6 68[3A000000]        <5>  push %1
   187                              <5>  %rotate 1
   188 000001DB 6A01                <5>  push %1
   190                              <4>  %rotate 1
   191 000001DD E8E6FEFFFF          <4>  call %1
   192                              <4>  %if %0 > 1
   193 000001E2 83C408              <4>  add esp, 4*(%0-1)
   194                              <4>  %endif
   200                                  
   201 000001E5 68[00000000]                push msg
   202 000001EA 6A12                        push msg.len
   203 000001EC E8D7FEFFFF                  call fun_print
   204 000001F1 83C408                      add esp, 4*2
   205                                      println
    72 000001F4 C605[3A000000]0A    <1>  mov [char], byte 0x0a
    73                              <1>  call_ fun_print, char, 1
   186                              <2>  %rep %0-1
   187                              <2>  %rotate 1
   188                              <2>  push %1
   189                              <2>  %endrep
   187                              <3>  %rotate 1
   188 000001FB 68[3A000000]        <3>  push %1
   187                              <3>  %rotate 1
   188 00000200 6A01                <3>  push %1
   190                              <2>  %rotate 1
   191 00000202 E8C1FEFFFF          <2>  call %1
   192                              <2>  %if %0 > 1
   193 00000207 83C408              <2>  add esp, 4*(%0-1)
   194                              <2>  %endif
   206                                  
   207                                      print_strln msg
   106                              <1>  print_str %1
   100                              <2>  call_ fun_print, %1, %1.len
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 0000020A 68[00000000]        <4>  push %1
   187                              <4>  %rotate 1
   188 0000020F 6A12                <4>  push %1
   190                              <3>  %rotate 1
   191 00000211 E8B2FEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 00000216 83C408              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
   107                              <1>  println
    72 00000219 C605[3A000000]0A    <2>  mov [char], byte 0x0a
    73                              <2>  call_ fun_print, char, 1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 00000220 68[3A000000]        <4>  push %1
   187                              <4>  %rotate 1
   188 00000225 6A01                <4>  push %1
   190                              <3>  %rotate 1
   191 00000227 E89CFEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 0000022C 83C408              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
   208                                  
   209                                      print_intln 12
    93                              <1>  print_int %1
    79                              <2>  call_ fun_int_to_str, %1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 0000022F 6A0C                <4>  push %1
   190                              <3>  %rotate 1
   191 00000231 E8B4FEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 00000236 83C404              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
    80                              <2> 
    94                              <1>  println
    72 00000239 C605[3A000000]0A    <2>  mov [char], byte 0x0a
    73                              <2>  call_ fun_print, char, 1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 00000240 68[3A000000]        <4>  push %1
   187                              <4>  %rotate 1
   188 00000245 6A01                <4>  push %1
   190                              <3>  %rotate 1
   191 00000247 E87CFEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 0000024C 83C408              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
   210                                      print_intln 1234
    93                              <1>  print_int %1
    79                              <2>  call_ fun_int_to_str, %1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 0000024F 68D2040000          <4>  push %1
   190                              <3>  %rotate 1
   191 00000254 E891FEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 00000259 83C404              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
    80                              <2> 
    94                              <1>  println
    72 0000025C C605[3A000000]0A    <2>  mov [char], byte 0x0a
    73                              <2>  call_ fun_print, char, 1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 00000263 68[3A000000]        <4>  push %1
   187                              <4>  %rotate 1
   188 00000268 6A01                <4>  push %1
   190                              <3>  %rotate 1
   191 0000026A E859FEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 0000026F 83C408              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
   211                                      print_intln 123456
    93                              <1>  print_int %1
    79                              <2>  call_ fun_int_to_str, %1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 00000272 6840E20100          <4>  push %1
   190                              <3>  %rotate 1
   191 00000277 E86EFEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 0000027C 83C404              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
    80                              <2> 
    94                              <1>  println
    72 0000027F C605[3A000000]0A    <2>  mov [char], byte 0x0a
    73                              <2>  call_ fun_print, char, 1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 00000286 68[3A000000]        <4>  push %1
   187                              <4>  %rotate 1
   188 0000028B 6A01                <4>  push %1
   190                              <3>  %rotate 1
   191 0000028D E836FEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 00000292 83C408              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
   212                                      
   213                                      print_strln msg
   106                              <1>  print_str %1
   100                              <2>  call_ fun_print, %1, %1.len
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 00000295 68[00000000]        <4>  push %1
   187                              <4>  %rotate 1
   188 0000029A 6A12                <4>  push %1
   190                              <3>  %rotate 1
   191 0000029C E827FEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 000002A1 83C408              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
   107                              <1>  println
    72 000002A4 C605[3A000000]0A    <2>  mov [char], byte 0x0a
    73                              <2>  call_ fun_print, char, 1
   186                              <3>  %rep %0-1
   187                              <3>  %rotate 1
   188                              <3>  push %1
   189                              <3>  %endrep
   187                              <4>  %rotate 1
   188 000002AB 68[3A000000]        <4>  push %1
   187                              <4>  %rotate 1
   188 000002B0 6A01                <4>  push %1
   190                              <3>  %rotate 1
   191 000002B2 E811FEFFFF          <3>  call %1
   192                              <3>  %if %0 > 1
   193 000002B7 83C408              <3>  add esp, 4*(%0-1)
   194                              <3>  %endif
   214                                  
   215                                      ; put result in edi
   216                                      call_ fun_test, 1, 10, 100
   186                              <1>  %rep %0-1
   187                              <1>  %rotate 1
   188                              <1>  push %1
   189                              <1>  %endrep
   187                              <2>  %rotate 1
   188 000002BA 6A01                <2>  push %1
   187                              <2>  %rotate 1
   188 000002BC 6A0A                <2>  push %1
   187                              <2>  %rotate 1
   188 000002BE 6A64                <2>  push %1
   190                              <1>  %rotate 1
   191 000002C0 E83BFDFFFF          <1>  call %1
   192                              <1>  %if %0 > 1
   193 000002C5 83C40C              <1>  add esp, 4*(%0-1)
   194                              <1>  %endif
   217                                  
   218 000002C8 B801000000                  mov eax, 1
   219 000002CD 89FB                        mov ebx, edi  ; exit status
   220 000002CF CD80                        int 0x80
   221                                  
   222                                  section .data
   223                                      def_str msg, "Printing a string!"
    30 00000000 5072696E74696E6720- <1>  %1 db %2
    30 00000009 6120737472696E6721  <1>
    31                              <1>  %1.len equ $ - %1
   224                                  
   225 00000012 010000000200000003-         vec dd 1,2,3,4,5,6,7
   225 0000001B 000000040000000500-
   225 00000024 000006000000070000-
   225 0000002D 00                 
   226                                      vec.len equ $ - vec         ; size in bytes
   227                                      vec.n equ vec.len/4         ; numbers of dword elements
   228                                  
   229                                      def_str buffer, "000000000000"
    30 0000002E 303030303030303030- <1>  %1 db %2
    30 00000037 303030              <1>
    31                              <1>  %1.len equ $ - %1
   230                                  
   231                                      def_str char, "0"
    30 0000003A 30                  <1>  %1 db %2
    31                              <1>  %1.len equ $ - %1
   232                                      def_str sep, ", "
    30 0000003B 2C20                <1>  %1 db %2
    31                              <1>  %1.len equ $ - %1
   233                                  
   234                                  segment .bss
   235 00000000 ??                          sum resb 1
