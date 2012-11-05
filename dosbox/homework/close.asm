org 100h

xor ax,ax
mov ds, ax
mov ax, [ds:9h*4 + 2]
mov ds, ax

call _close_file

%include 'utils.asm'

ret
