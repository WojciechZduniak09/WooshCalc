all:
	rm -rf bin/ 2> /dev/null
	mkdir bin/
	mkdir bin/objects
	nasm -f elf32 src/main.asm -o bin/objects/main.o
	ld -m elf_i386 bin/objects/main.o -o bin/WooshCalc
.PHONY: clean
clean:
	rm -rf bin/
