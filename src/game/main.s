[org 0x7ef0]
[bits 16]

SCREEN_HEIGHT equ 200
SCREEN_WIDTH equ 320

PLAYER_HEIGHT equ 40
PLAYER_WIDTH equ 10

BALL_HEIGHT equ 10
BALL_WIDTH equ 10

KEY_W equ 0x11
KEY_S equ 0x1F

KEY_UP equ 0x48
KEY_DOWN equ 0x50

VGA_MEM_SEG equ 0xA000
BUFFER_MEM_SEG equ 0x6000

COLOR_BLACK equ 0
COLOR_BRIGHT_WHITE equ 15

%macro WAIT_FOR_RTC 0
	;synchronizing game to real time clock (18.2 ticks per sec)
	.sync:
		xor ah,ah
		sti
		int 0x1a ;returns the current tick count in dx
		cli
		cmp word [timer_current], dx
	je .sync ;reloop until new tick
		mov word [timer_current], dx ;save new tick value
%endmacro

main:
    cli
    mov ax, 0x00
	mov ds, ax
	mov ss, ax
    mov es, ax
    mov sp, 0x7ef0
    mov bp, sp

    mov [es:4 * 9], word int09
    mov [es:4 * 9 + 2], cs	

    mov ax, BUFFER_MEM_SEG
    mov es, ax
    
    mov ah, 0
    mov al, 0x13
    int 0x10

    sti

    loop:
        .clearScreen:
            xor  di, di
            mov al, COLOR_BLACK
            mov  cx, SCREEN_WIDTH * SCREEN_HEIGHT
            rep stosb
        
        .render:
            mov bx, word [player1X]
            mov ax, word [player1Y]
            call drawPlayer

            mov bx, word [player2X]
            mov ax, word [player2Y]
            call drawPlayer

            mov bx, word [ballX]
            mov ax, word [ballY]
            call drawBall

        .switchBuffer:
            mov ax, VGA_MEM_SEG
            mov es, ax
            xor di, di

            mov ax, BUFFER_MEM_SEG
            mov ds, ax
            xor si, si
            switchLoop:
                lodsw
                stosw
                cmp si, SCREEN_HEIGHT * SCREEN_WIDTH
                jb switchLoop

            mov ax, BUFFER_MEM_SEG
            mov es, ax

            mov ax, 0
            mov ds, ax

        .update:
            ;--------------------------------------------------
            ; Player Movement
            ;--------------------------------------------------
            mov ax, word [player1Y]

            cmp ax, 0
            jng movPlayer1UpContinue
                cmp byte [keyList+KEY_W], 1
                je movPlayer1Up
            movPlayer1UpContinue:

            cmp ax, SCREEN_HEIGHT - PLAYER_HEIGHT
            jge  movPlayer1DownContinue
                cmp byte [keyList+KEY_S], 1
                je movPlayer1Down
            movPlayer1DownContinue:

            mov word [player1Y], ax
            mov ax, word [player2Y]

            cmp ax, 0
            jng movPlayer2UpContinue
                cmp byte [keyList+KEY_UP], 1
                je movPlayer2Up
            movPlayer2UpContinue:

            cmp ax, SCREEN_HEIGHT - PLAYER_HEIGHT
            jge  movPlayer2DownContinue
                cmp byte [keyList+KEY_DOWN], 1
                je movPlayer2Down
            movPlayer2DownContinue:

            mov word [player2Y], ax

            ;--------------------------------------------------
            ; Ball Movement
            ;--------------------------------------------------

            ;X-Axes wall collision
            mov ax, [ballX]
            cmp ax, SCREEN_WIDTH
            jge 

            .xWallCollisionFalse:

            mov ax, [ballX]
            add ax, [ballDX]
            mov [ballX], ax

            mov ax, [ballY]
            add ax, [ballDY]
            mov [ballY], ax

            jmp endUpdate

            .movPlayer1Up:
            add ax, -5
            jmp .movPlayer1UpContinue

            .movPlayer1Down:
            add ax, 5
            jmp .movPlayer1DownContinue

            .movPlayer2Up:
            add ax, -5
            jmp .movPlayer2UpContinue

            .movPlayer2Down:
            add ax, 5
            jmp .movPlayer2DownContinue

            .endUpdate:

            WAIT_FOR_RTC

        jmp loop

jmp $

;TODO Beschreibung
drawPlayer:
    pusha

    mov cx, PLAYER_HEIGHT
    .drawPlayerLoop:
        push cx

        mov dl, COLOR_BRIGHT_WHITE
        mov cx, PLAYER_WIDTH
        call drawLine
        pop cx
        dec cx
        inc ax
        cmp cx, 0
        jne .drawPlayerLoop
        
    popa
    ret

drawBall: ;Platzhalter sollte in Zukunft Kreise zeichnen
    pusha

    mov cx, BALL_HEIGHT
    .drawBallLoop:
        push cx

        mov dl, COLOR_BRIGHT_WHITE
        mov cx, BALL_WIDTH
        call drawLine
        pop cx
        dec cx
        inc ax
        cmp cx, 0
        jne .drawBallLoop
        
    popa
    ret

;TODO Beschreibung
drawLine:
    pusha
    push dx
    mov  di, 320   ; BytesPerScanline
    mul  di
    add  ax, bx
    mov  di, ax    ; Address DI = (Y * BPS) + X
    pop  ax        ; Color AL
    rep stosb
    popa
    ret

;TODO Beschreibung
int09:
    pusha
    in   al, 0x60
    mov  ah, 0
    mov  bx, ax
    and  bx, 0x7F          ; 7-bit scancode goes to BX
    shl  ax, 1             ; 1-bit press/release goes to AH
    xor  ah, 1             ; -> AH=1 Press, AH=0 Release
    mov  [keyList+bx], ah
    mov  al, 0x20          ; The non specific EOI (End Of Interrupt)
    out  0x20, al
    popa
    iret

;variables
timer_current dw 0

player1X dw 10
player1Y dw 80

player2X dw 300
player2Y dw 80

ballX dw 100
ballY dw 100

ballDX dw 5
ballDY dw 2

keyList: times 128 db 0x00