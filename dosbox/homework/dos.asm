;================================
;          DOS HANDLER
; takes responsibility of writing
;  to file if timer was unable
;   to write due bios was busy
;================================

segment .code 

install_dos_handler:
  pusha
  push ds
  push es
  cli
  ;writing keyboard buffer to file when dos is idle and flag is set
  ;we will do this using int 28h
  
  ;initialising ds - had a lot of problems with this, just to be sure 
  mov ax, cs
  mov ds, ax
  ;zero
  xor ax, ax
  ;putting es to 0
  mov es, ax
  ;saving old offset
  mov ax, [es:28h*4]
  mov [old_28h_offset], ax
  ;saving old segment
  mov ax, [es:28h*4 + 2]
  mov [old_28h_segment], ax

  ;installing new
  mov [es:28h*4], word dos_handler
  mov [es:28h*4+2], cs
  
  sti
  pop es
  pop ds
  popa 
  ret

uninstall_dos_handler:
  pusha
  push ds
  push es
  cli

  ; set ds to tsr segment to be able to get old int info
  call set_ds_to_tsr
  ;zero
  xor ax, ax
  ;putting es to 0
  mov es, ax
  ;restoring old
  ;offset
  mov ax, [old_28h_offset]
  mov [es:28h*4], ax
  ;segment
  mov ax, [old_28h_segment]
  mov [es:28h*4+2], ax
  
  sti
  pop es
  pop ds
  popa
  ret

dos_handler:
  pusha
  push ds
  push es
  
  ;initialising ds - had a lot of problems with this, just to be sure
  mov ax, cs
  mov ds, ax
  ;if there is no need to write skip everything
  cmp [int_28h_flag], byte 1h
  jne .skip_write
  ;clear flag
  mov [int_28h_flag], byte 0h
  cmp [buffer_size], 0h
  je .skip_write
  ;check DOS to see if it is safe to use DOS int
  mov ah, 34h
  int 21h
  ;now we have flags adress inside ES:BX
  xor ax, ax ; setting to zero
  cmp al, [es:bx]
  jnz .skip_write ; if this is different from zero then DOS is busy 
.success:
  ;write to file
  ;DS:DX - buffer location
  ;CX - number of bytes to write to file
  ;BX - file handle
  call _write_to_file
.skip_write:
  ;calling old int
  pushf
  call far word [old_28h]
  
  pop es
  pop ds
  popa
  iret


old_28h:
old_28h_offset: dw 0
old_28h_segment: dw 0
int_28h_flag: db 0
