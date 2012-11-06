;===============================
;         HOMEWORK 1
;           LIBRARY
;===============================


;org 100h
;_main:
;  call test_file
;   ret

;==============================
; prints ASCIIZ string on es:di
;==============================

_print_asciiz_string:
   pusha
   push ds
   .loop:
        mov al, [es:di] ; getChar from es:di location
        call _printc
        inc di
        test al, al
        jnz .loop    ; loop for a specified number of chars in cx
   
   pop ds
   popa
   ret

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
  jc .ende
  mov [cs:file_handle], ax
  
  pop ds
  popa
  ret

.ende:
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
  mov bx, [cs:file_handle]
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
  mov ax, cs
  mov ds, ax

  xor ax, ax
  cmp [file_handle], ax
  jne .dont_open
  call _open_file
  mov al, 'o'
  call _printc
.dont_open:
  mov al, 'w'
  call _printc  
  ;write to file
  ;DS:DX - buffer location
  ;CX - number of bytes to write to file
  ;BX - file handle
  mov dx, buffer 
  mov ah, 40h    ; function number
  mov bx, [file_handle]
  mov cx, [buffer_size]
  int 21h 
  jc .greska
  ;reset buffer
  mov word [buffer_size], 0
  pop ds
  popa
  ret
.greska:
  
  add al, '0'
  call _printc
  pop ds
  popa
  ret
;=================================
; si contains offset adress of
; start of first command line 
;         parameter
;=================================
_get_command_line:
  push ax
  push cx
  push di
  push ds
  
  cld
  mov cx, 0080h  ;max for rep*
  mov di, 81h    ;start of command line in PSP.
  mov al, ' '    ;skip character 
  repe scasb     ;getting location of non space character, acctually one after it
  dec di         ;so we are decreasing it to point on start of first parameter
  mov si, di     ;save it to si
  
  mov     al, 0dh ;going on while we dont hit 0dh -> new line
  repne   scasb   ;get location of new line character, accutally one after it 
  mov byte [di-1], 0 ;making ACIIZ

  pop ds
  pop di
  pop cx
  pop ax
  ret 

;=====================================
;       Takes ASCIIZ strings
;       string1 = DS:DI
;       string2 = ES:SI
;       returns cmp flags
;=====================================
_str_equals:
  pusha
.loop:
  mov al, [ds:di]
  mov bl, [es:si]
  
  ;if reached end of string 1
  test al, al
  jz .check

  ;if reached end of string 2
  test bl, bl
  jz .check

  ;if we are not on the end of the string inc si and di
  inc di
  inc si
  ;check if letters are same
  cmp al, bl
  je .loop
  jmp .end
  ;check if both strings on the end
.check:

  cmp al, bl 

.end:
  popa
  ret

;=========================================
;          set_ds_uninstall
;     sets ds on existing tsr
;=========================================

set_ds_to_tsr:
  pusha
  push es
  xor ax, ax
  mov es, ax
  mov ax, [es:60h*4+2]
  mov ds, ax
  pop es
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
    db  0, 0, 0, 32
    times 70 db 0  
veliki_kamion: db 'bio jedan veliki kamion crvene boje'
file_name: db 'dfjslfs.txt', 0 
file_handle: dw 0
