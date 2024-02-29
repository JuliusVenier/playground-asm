[org 0x7C00]
[bits 16]

KERNEL_LOCATION equ 0x7ef0

jmp 0x0000:main

main:

    cli
    mov ax, 0x00
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00
	mov bp, sp
    sti

	mov [BOOT_DISK], dl

    mov bx, KERNEL_LOCATION
	mov dh, 60
	call disk_read

    jmp KERNEL_LOCATION
    jmp $

disk_read:
	mov ah, 0x02
	mov al, dh
	mov ch, 0x00
	mov cl, 0x02
	mov dh, 0x00
	mov dl, [BOOT_DISK]
	int 0x13
    ret

BOOT_DISK: 
    db 0x00

times 510-($-$$) db 0x00
dw 0xAA55