SECTION .DATA
	intro_msg 	DB	"Welcome to WooshCalc!! :3", 0xA
	len 		EQU $ - msg
SECTION .TEXT
	GLOBAL  	_start
_start:
	; WRITE SYSCALL
	MOV		EAX, 4
	MOV		EBX, 1
	MOV		ECX, intro_msg
	MOV 		EDX, len
	INT 		0x80
	; EXIT SYSCALL
	MOV		EAX, 1
	XOR		EBX, EBX
	INT		0X80
