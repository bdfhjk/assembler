main: main.c library.o
	gcc -m64 -g -o main main.c library.o

.SECONDARY:

%.o: %.asm
	nasm -f elf64 -F dwarf -g $<
	
%: %.o
	ld -b64 -$< -o $@ -lc --dynamic-linker=/lib64/ld-linux-x86-64.so.2
	
clean:
	rm -f *.o
	rm -f main
