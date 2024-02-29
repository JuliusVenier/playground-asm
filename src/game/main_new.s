[org 0x7ef0]
[bits 16]

; --------------------------------------------------------------------------------
;                  Macro Includes
; --------------------------------------------------------------------------------
%include "macros.s"

; --------------------------------------------------------------------------------
;                  Hauptprogramm
; --------------------------------------------------------------------------------

;Vorhandener Keyboard Interrupt überschreiben 
cli
mov [es:4 * 9], word int09 
mov [es:4 * 9 + 2], cs
sti


start:
;Variablen initialisieren
mov [player1X], 10
mov [player1Y], 80

mov [player2X], 300
mov [player2Y], 80

mov [ballX], 100
mov [ballY], 100

mov [ballDX], 5
mov [ballDY], 2


.loop:
    
jmp .loop

; --------------------------------------------------------------------------------
;                  Funktionen
; --------------------------------------------------------------------------------

; --------------------------------------------------------------------------------
;                  Interrupts
; --------------------------------------------------------------------------------

;Eigener Interrupt um mehrere Tasten eingaben auf einmal zu lesen
;Code von https://stackoverflow.com/users/3144770/sep-roland
int09:
    push ax
    push bx

    in al, 0x60
    xor ah, ah 
    mov bx, ax
    and bx, 0x7F          ; 7-bit scancode goes to BX
    shl ax, 1             ; 1-bit press/release goes to AH
    xor ah, 1             ; -> AH=1 Press, AH=0 Release
    mov [keyList+bx], ah
    mov al, 0x20          ; The non specific EOI (End Of Interrupt)
    out 0x20, al

    pop bx
    pop ax

    iret

; --------------------------------------------------------------------------------
;                  Deklarationen
; --------------------------------------------------------------------------------
player1X: dw 0
player1Y: dw 0

player2X: dw 0
player2Y: dw 0

ballX: dw 0
ballY: dw 0

ballDX: dw 0
ballDY: dw 0

keyList: times 128 db 0x00