main: main.c library.o
	gcc -g -m32 -o main main.c library.o

.SECONDARY:

%.o: %.asm
	nasm -g -f elf32 $<


%: %.o
	ld -m elf_i386 $< -o $@ -lc --dynamic-linker=/lib/ld-linux.so.2


clean:
	rm -f *.o

