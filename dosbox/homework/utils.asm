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

        or cx, cx
        jz .end	
.loop:
	mov al, [es:di] ; getChar from es:di location
	call _printc
	inc di
	loop .loop    ; loop for a specified number of chars in cx
.end:	
        popa
	ret

; Clear screen
;--------------------------
_clrscr:
     
	pusha
	mov ah, 02h      ; setting coursor position to (dl, dh)
	mov dh, 0h
	mov dl, 0h
        mov bh, 0h
	int 10h
	mov cx, 2000
        mov al, ' '

.loop:
	call _printc 	
        loop .loop
        mov ah, 02h      ; setting coursor position to (dl, dh)

        mov dh, 0h
        mov dl, 0h
        mov bh, 0h
        int 10h

	popa
	ret


; Print char in al
;------------------------------
_printc:
	push ax
        mov ah, 0eh     ; prepearing int10 for write char
        int 10h         ; writing char to standard output
	pop ax
	ret


segment .data
whitespace: db " "
xlat_lowercase_table:
    db  0, 0
    db  '1234567890', 0, 0
    db  0, 0
    db  'qwertyuiop', 0, 0
    db  0, 0
    db  'asdfghjkl',0,  0,0
    db  0
    db  0, 'zxcvbnm', 0, 0 ,0
    db  0, 0, 0, 0
    times 70 db 0  
  

