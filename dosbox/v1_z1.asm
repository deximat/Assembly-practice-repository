;========================
;       OS Lecture 1
;       Hello world
;=======================


	org 100h         ; start adress
	mov ah, 9        ; prepearing int
	mov dx, message  ; putting adress of message into dx
	int 21h          ; int defined for writing to standard output

	ret              ; return to os


message: db 'This is my hello world message$' ; $ terminated string
