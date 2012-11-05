;====================================
;        Timer when to flush 
;       memory buffer to file
;     delay - number of seconds
;====================================

DELAY equ 1

install_flush_timer:
  pusha
  push ds
  push es
  cli
  ;initialising ds - had a lot of problems with this, just to be sure
  mov ax, cs
  mov ds, ax
  ;zero
  xor ax, ax
  ;putting es to 0
  mov es, ax
  ;saving old offset
  mov ax, [es:1ch*4]
  mov [old_1ch_offset], ax
  ;saving old segment
  mov ax, [es:1ch*4 + 2]
  mov [old_1ch_segment], ax

  ;installing new
  mov [es:1ch*4], word flush_timer
  mov [es:1ch*4+2], cs
  pop es
  pop ds
  popa
  sti
  ret

flush_timer:
  pusha
  push ds
  push es
  ;initialising ds - had a lot of problems with this, just to be sure
  mov ax, cs
  mov ds, ax
  ; we are increasing next 55ms, we will round to a second
  inc word [time_unit] 
  
  mov ax, [time_unit]
  mov bx, DELAY*19 ;(19 or 20) * 55ms ~ 1 second, rounded because exact precision is hard to get
  cmp ax, bx
  jne continue ; if this is 19-th increment we are doing some job

  ;reset counter
  mov word [time_unit], 0
  ;check DOS to see if it is safe to use DOS int
  mov ah, 34h
  int 21h
  ;now we have flags adress inside ES:BX
  xor ax, ax ; setting to zero
  cmp ax, [es:bx]
;  jnz fail ; if this is different from zero then DOS is busy 
success:
  ;write to file
  ;DS:DX - buffer location
  ;CX - number of bytes to write to file
  ;BX - file handle
  call _write_to_file
  jmp continue
fail:
  ;set flag need to write
  ;int 28h takes responsibility to finish job
  
continue:
  ;calling old int
  pushf
  call far word [old_1ch]
  pop es
  pop ds
  popa
  iret

%include 'utils.asm'

old_1ch:
old_1ch_offset: dw 0
old_1ch_segment: dw 0
time_unit: dw 0
                                        
