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

EXTERN getInput
EXTERN runCommandsFromInput

SECTION .rodata
	INTRO_MSG	DB		"Welcome to WooshCalc!! >:3", 10, \
					"Type 'help' for a list of commands.", 10, \
					"Current version is: v0.1.0-alpha.1", 10, 10, 0
	len 		EQU 		$ - INTRO_MSG
SECTION .text
	GLOBAL  	_start
_start:
	; WRITE SYSCALL
	MOV		EAX, 4
	MOV		EBX, 1
	MOV		ECX, INTRO_MSG
	MOV 		EDX, len
	INT 		0x80
	JMP		_input_loop
_input_loop:
	call getInput ; EDX contains input buffer now
	call runCommandsFromInput ; You can exit the program from here
	; MATH PARSING WOULD GO HERE
	jmp _input_loop
