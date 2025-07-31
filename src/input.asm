; WooshCalc, a fast and lightwieght arithmetic calculator.
; Copyright (C) 2025 Wojciech Zduniak <githubinquiries.ladder140@passinbox.com>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU Affero General Public License as published
; by the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU Affero General Public License for more details.
;
; You should have received a copy of the GNU Affero General Public License
; along with this program. If not, see <https://www.gnu.org/licenses/>.

SECTION .rodata
	INPUT_DECO		DB		"(WooshCalc) ", 0
	INPUT_DECO_LEN		EQU		$ - INPUT_DECO
	AGPL3_WARRANTY_FILE	DB		"PLACEHOLDER_W_FOR_MAKE", 0
	AGPL3_CONDITIONS_FILE	DB		"PLACEHOLDER_C_FOR_MAKE", 0
	EXIT_CMD		DB		"exit", 0
	HLP_CMD			DB		"help", 0
	SHOW_W_CMD		DB		"showw", 0
	SHOW_C_CMD		DB		"showc", 0
	HELP_MSG		DB		"List of commands:", 10, 9, "1. Exit", 10, 9, "2. Help", 10, 9, "3. Show W", 10, 9, \
						"4. Show C", 10, "Any arithmetic expressions are valid, view README.md for full", \
						" instructions.", 10, "Wooshcalc commands are case-insensitive.", 10, 10, 0
	HELP_MSG_LEN		EQU		$ - HELP_MSG
SECTION .bss
	raw_input_buffer	RESB		101
	clean_input_buffer	RESB		101
	file_buffer		RESB		34524
SECTION .text
	GLOBAL			getInput
	GLOBAL			runCommandsFromInput
; ================
; GLOBAL FUNCTIONS
; ================

getInput:
	; WRITE SYSCALL
	MOV			EAX, 4
	MOV			EBX, 1 ; STDOUT
	MOV			ECX, INPUT_DECO
	MOV			EDX, INPUT_DECO_LEN
	INT			0x80
	; READ SYSCALL
	MOV			EAX, 3
	XOR			EBX, EBX ; STDIN
	MOV			ECX, raw_input_buffer
	MOV			EDX, 101 ; BUFFER SIZE
	INT 			0x80
	; MAKING INPUT PARSABLE
	XOR			ECX, ECX
	XOR			EDX, EDX
	JMP 			_makeBufferParsable
	MOV			EDX, clean_input_buffer
runCommandsFromInput:
	; STORING THE CLEAN BUFFER AND PREP
	MOV			ESI, clean_input_buffer
	XOR 			ECX, ECX
	XOR			DL, DL
	; IS EXIT COMMAND?
	MOV 			EDI, EXIT_CMD
	CALL			_compareInputStrings
	CMP			EAX, 0 ; DID IT FAIL?
	JE			_exitCMD
	; IS HELP COMMAND?
	MOV			EDI, HLP_CMD
	CALL			_compareInputStrings
	CMP			EAX, 0 ; DID IT FAIL?
	JE			_helpCMD
	; IS AGPL3  WARRANTY COMMAND?
	MOV			EBX, AGPL3_WARRANTY_FILE
	MOV			EDI, SHOW_W_CMD
	CALL			_compareInputStrings
	CMP			EAX, 0 ; DID IT FAIL?
	JE			_printFile
	; IS AGPL3 CONDITIONS COMMAND?
	MOV			EBX, AGPL3_CONDITIONS_FILE
	MOV			EDI, SHOW_C_CMD
	CALL			_compareInputStrings
	CMP			EAX, 0 ; DID IT FAIL?
	JE			_printFile
	RET

; ===============
; LOCAL FUNCTIONS
; ===============
_compareInputStrings:
	; ESI & EDI for string addresses - ECX MUST BE 0
	MOV			DL, [EDI + ECX]
	CMP			DL, [ESI + ECX]
	JNE			_doneFailure
	CMP 			DL, 0
	JE			_doneSuccess
	INC			ECX
	JMP			_compareInputStrings
_exitCMD:
	; EXIT SYSCALL
	MOV			EAX, 1
	XOR			EBX, EBX
	INT			0x80
_helpCMD:
	; WRITE SYSCALL
	MOV			EAX, 4
	MOV			EBX, 1 ; STDOUT
	MOV			ECX, HELP_MSG
	MOV			EDX, HELP_MSG_LEN
	INT			0x80
	RET
_printFile:
	; OPEN SYSCALL
	MOV			EAX, 5
	XOR 			ECX, ECX ; O_RDONLY
	INT			0x80
	; SYS_READ FILE
	MOV			EBX, EAX ; FILE DESCRIPTOR
	PUSH			EBX
	MOV			EAX, 3
	MOV			ECX, file_buffer
	MOV			EDX, 34524 ; BUFFER SIZE
	INT			0x80
	; SYS_WRITE FILE CONTENTS
	MOV			EDI, EAX
	MOV			EAX, 4
	MOV			EBX, 1 ; STDOUT
	MOV			ECX, file_buffer
	MOV			EDX, EDI
	INT			0x80
	; CLOSE SYSCALL
	POP			EBX
	MOV			EAX, 6
	INT			0x80
	RET
_makeBufferParsable:
	; PREP
	XOR			EBX, EBX
	; STORING THE RAW BUFFER
	MOV			AL, [raw_input_buffer + ECX]
	; IS NULL-TERMINATOR?
	CMP			AL, 0
	JE			_doneSuccess
	; IS SPACE?
	CMP			AL, 32
	JE			_skipCharacter
	; IS NEWLINE?
	CMP			AL, 10
	JE			_nullTerminateCleanString
	; IS CAPITAL LETTER?
	CMP			AL, 'A'
	JB			_copyStdCharacter ; LOOP REPEATS HERE
	CMP			AL, 'Z'
	JA			_copyStdCharacter ; LOOP REPEATS HERE
	JBE			_copyCapitalCharacter ; LOOP REPEATS HERE
_nullTerminateCleanString:
	SUB			EBX, EDX
	ADD			EBX, ECX
	MOV			BYTE		[clean_input_buffer + EBX], 0 ; NULL-TERMINATOR
	JMP			_doneSuccess
_skipCharacter:
	INC			EDX
	INC 			ECX
	JMP			_makeBufferParsable
_copyCapitalCharacter:
	ADD			AL, 32
	SUB			EBX, EDX
	ADD			EBX, ECX
	MOV			[clean_input_buffer + EBX], AL
	INC 			ECX
	JMP			_makeBufferParsable
_copyStdCharacter:
	SUB			EBX, EDX
	ADD			EBX, ECX
	MOV			[clean_input_buffer + EBX], AL
	INC 			ECX
	JMP			_makeBufferParsable
_doneSuccess:
	XOR			EAX, EAX
	RET
_doneFailure:
	MOV			EAX, 1
	RET
