name="${1%.*}"

# assemble
nasm -f elf32 $1 -o $name.o

# link
gcc -o $name.elf -m32 $name.o -nostdlib -static

# run
./$name.elf