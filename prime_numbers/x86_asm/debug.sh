name="${1%.*}"

# assemble
nasm -f elf32 $1 -gdwarf -o $name.o -l ${name}_lst.asm

# link
gcc -o $name.elf -m32 $name.o -nostdlib -static

# debug
gdb -q $name.elf

echo "exit code:" $?