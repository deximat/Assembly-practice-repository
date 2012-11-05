segment .code 

install_debug_realtime:
  pusha
  push ds
  push es
  cli
  ;writing keyboard buffer on scree every time dos is idle
  ;we will do this using int 28h
  
  ;initialising ds - had a lot of problems with this, just to be sure
  mov ax, cs
  mov ds, ax
  ;zero
  xor ax, ax
  ;putting es to 0
  mov es, ax
  ;saving old offset
  mov ax, [es:1ch*4]
  mov [old_28h_offset], ax
  ;saving old segment
  mov ax, [es:1ch*4 + 2]
  mov [old_28h_segment], ax

  ;installing new
  mov [es:1ch*4], word debug_realtime
  mov [es:1ch*4+2], cs
  pop es
  pop ds
  popa
  sti 
  ret

debug_realtime:
  pusha
  push ds
  push es
  ;initialising ds - had a lot of problems with this, just to be sure
  mov ax, cs
  mov ds, ax
  
  mov ah, [second]
  inc ah
  mov al, 20
  mov [second], ah
  cmp ah, al
  jne nastavi
  mov byte [second], 0
  call _clrscr
  mov cx, [buffer_size]
  mov ax, ds
  mov es, ax
  mov di, buffer

  call _debugMemory
nastavi:
  ;calling old int
  pushf
  call far word [old_28h]
  pop es
  pop ds
  popa
  iret
%include 'utils.asm'
old_28h:
old_28h_offset: dw 0
old_28h_segment: dw 0
second: db 0
