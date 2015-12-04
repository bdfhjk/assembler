main: main.c parse.o unparse.o suma.o roznica.o
	gcc -g -m32 -o main main.c parse.o unparse.o suma.o roznica.o

.SECONDARY:

%.o: %.asm
	nasm -g -f elf32 $<


%: %.o
	ld -m elf_i386 $< -o $@ -lc --dynamic-linker=/lib/ld-linux.so.2


clean:
	rm main -f *.o *~

