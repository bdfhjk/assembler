main: main.c parse.o unparse.o suma.o roznica.o iloczyn.o iloraz.o shift_left_bcd.o shift_right_bcd.o
	gcc -g -m32 -lm -o main main.c parse.o unparse.o suma.o roznica.o iloczyn.o iloraz.o shift_left_bcd.o shift_right_bcd.o -lm

.SECONDARY:

%.o: %.asm
	nasm -g -f elf32 $<

%: %.o
	ld -m elf_i386 $< -o $@ -lc  --dynamic-linker=/lib/ld-linux.so.2

clean:
	rm main -f *.o *~

