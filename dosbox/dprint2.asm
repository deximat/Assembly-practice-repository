; ========================================================
; Prosetaj smajlija, osnovni zadatak (bez varijacija)
; ========================================================

        org 100h

zelena  equ 02h                             ; Boja znakova 

; Ispisivanje u video memoriji
dprint:
        pusha
        mov     ax, 0B800h                  ; Segmentna adresa video memorije (bazna adresa = B8000h)
        mov     es, ax
        mov     bx, word 320                ; Video pozicija = pozicija kursora*2, zbog video atributa.
        mov     dl, zelena
;.loop oznacava trenutak kada korisnik treba da pritisne dugme na tastaturi
;podrazumevamo da bx pokazuje na trenutnu poziciju smajlija
.loop:
        mov     ah, 0                       ; Procitamo karakter sa tastature
        int     16h
        cmp     al, 1bh                     ; Ako je ESC, izlaz
        je      .end
        cmp     al, 119                     ; Ako je w, idi gore
        je      .goup
        cmp     al, 115                     ; Ako je s, idi dole
        je      .godown
        cmp     al, 97                      ; Ako je a, idi levo
        je      .goleft
        cmp     al, 100                     ; Ako je d, idi desno
        je      .goright
;pravi se odgovarajuci skok unutar registra bx
.goup:
        sub     bx, word 160
        jmp     .paint
.godown:
        add     bx, word 160
        jmp     .paint
.goleft:
        sub     bx, word 2
        jmp     .paint
.goright:
        add     bx, word 2
        jmp     .paint
;.paint iscrtava novog smajlija
.paint:
        mov     dl, 1                       ; ASCII kod za smajlija upisujemo u video memoriju
        mov     [es:bx], dl
        inc     bx
        mov     dl, 2                       ; Upisujemo boju
        mov     [es:bx], dl
        dec     bx                          ; Smanjujemo bx da bi bio zadovoljen uslov postavljen u .loop
        jmp     .loop
.end:    
        popa
        ret
