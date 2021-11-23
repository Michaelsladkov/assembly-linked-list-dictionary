all: main
	make clean

main : lib.o main.o dict.o
	ld -o main lib.o main.o dict.o

%.o: %.asm
	nasm -g -felf64 $< -o $@

.PHONY : clean	
clean : 
	rm *.o