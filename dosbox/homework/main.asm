;=================================
;            HOMEWORK 1
;            KEYLOGGER
;=================================



org 100h

bufferSize equ 100    ; size of a buffer for keylogger

segment .code

; postavlja BX 

_main:
	
	;call _checkIfKeyloggerInstalled
	;or ax, ax
	;jnz alreadyInstalled
	call _clrscr
	mov di, alreadyInstalledMessage
	mov cx, 10
	call _debugMemory
	ret 
.installKeylogger:
	
.keyloggerAllreadyInstalled:
	
	;call _clrscr
	;mov di, alreadyInstalledMessage
	;call _print

	ret
alreadyInstalled:
	
segment .data

testVar: db "1233456"
programName: db "keylogger"
alreadyInstalledMessage: db "Keylogger is already installed", 0
keyBuffer: times bufferSize db 0

%include "utils.asm"

