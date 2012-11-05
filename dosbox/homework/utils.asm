;===============================
;         HOMEWORK 1
;           LIBRARY
;===============================


;org 100h
;_main:
;  call test_file
;   ret
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


test_file:
  call _open_file
  call _write_to_file
  call _close_file
  ret
;  buffer: db 'blablabla234', 0
;  buffer_size: dw 11  
;========================================
; open new file for write and store handle
;========================================
_open_file:
  pusha
  push ds
  mov ax, cs
  mov ds, ax
  
  ; open file for write
  mov ah, 3ch
  mov al, 0h
  mov cx, 0h
  mov dx, file_name
  int 21h
  jc ende
  mov [file_handle], ax
  
  pop ds
  popa
  ret

ende:
  mov al, 'j'
  call _printc
  pop ds
  popa
  ret

;========================================
; close file with file_handle
;========================================
_close_file:
  pusha
  push ds
  mov ax, cs
  mov ds, ax
  mov ah, 3eh
  mov bx, [file_handle]
  int 21h
  pop ds
  popa
  ret


;========================================
; write buffer to file
; =======================================

_write_to_file:
  pusha 
  push ds
  mov al, 'c'
  call _printc
  ;write to file
  ;DS:DX - buffer location
  ;CX - number of bytes to write to file
  ;BX - file handle
  mov ax, cs
  mov ds, ax
  mov dx, veliki_kamion
  mov ah, 40h    ; function number
  mov bx, [file_handle]
  mov cx, 12
  int 21h 
  ;reset buffer
  mov word [buffer_size], 0
  pop ds
  popa
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
veliki_kamion: db 'bio jedan veliki kamion crvene boje'
file_name: db 'index.txt', 0
file_handle: dw 0
