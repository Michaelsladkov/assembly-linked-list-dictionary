main : lib.o main.o dict.o
	ld -o main lib.o main.o dict.o

lib.o : lib.asm
	nasm -felf64 lib.asm -o lib.o

main.o : main.asm
	nasm -felf64 main.asm -o main.o

dict.o : dict.asm
	nasm -felf64 dict.asm -o dict.o
	
clean : 
	rm -r *.o