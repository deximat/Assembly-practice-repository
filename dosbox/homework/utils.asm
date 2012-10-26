;===============================
;         HOMEWORK 1
;           LIBRARY
;===============================




;==============================
;    debugMemoryLocation
;    cx = number of bytes
;    es:di = start location
;==============================

_debugMemory:
	pusha
	
.loop
	mov al, [es:di] ; getChar from es:di location
	call _printc
	inc di
	loop .loop    ; loop for a specified number of chars in cx
	popa
	ret

; Clear screen
;--------------------------
_clrscr:
	pusha
	mov ah, 02h      ; setting coursor position to (dl, dh)
	mov dh, 0h
	mov dl, 0h
	int 10h
	mov cx, 2000
        mov si, whitespace

.loop:
	call _printc 	
	loop .loop
	int 10h
	popa
	ret


; Print char in al
;------------------------------
_printc
	push ax
        mov ah, 0eh     ; prepearing int10 for write char
        int 10h         ; writing char to standard output
	pop ax
	ret

segment .data
whitespace: db " "
