main : lib.o main.o dict.o
	ld -o main lib.o main.o dict.o

%.o: %.asm
	nasm -gfelf64 $< -o $@

.PHONY : clean	
clean : 
	rm *.o