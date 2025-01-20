[org 0x100]
jmp start

;--------------------------------------------------------------------------
rollno: dw 0x0524
upperBitCount: dw 0
lowerBitCount: dw 0
totalBitCount: dw 0
finalBitCount: dw 0
allAlerts: db 'All Alerts: '          
criticalAlerts: db 'Critical Alerts: '   
warningAlerts: db 'Warning Alerts: '   
infoAlerts: db 'Info Alerts: '
;-------------------------------------------------------------------------------

;--------------------------------------------------------------------------

initscr:
   mov ax, 0xb800
   mov es,ax
   ret

;----------------------------------------------------------------------------


clrscr:
    call initscr 
    mov di, 0
loop_scr:
    mov word [es:di], 0x0720
    add di, 2
    cmp di, 4000
    jne loop_scr
    ret
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
print_section:
    push ax
    push di
    mov di, 160
    mov ax, allAlerts
    push ax
    mov ax, [finalBitCount]
    push ax
    push word 12
    call print
    mov di, 320
    mov ax, criticalAlerts
    push ax
    mov ax, [upperBitCount]
    push ax
    push word 15
    call print
    mov di, 480
    mov ax, warningAlerts
    push ax
    mov ax, [lowerBitCount]
    push ax
    push word 15
    call print
    mov di, 640
    mov ax, infoAlerts
    push ax
    mov ax, [totalBitCount]
    push ax
    push word 12
    call print
    pop di
    pop ax
    ret
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
print:
    push bp
    mov bp, sp
    mov ax, 0xb800
    mov es, ax
    mov si, [bp+8]
    mov cx, [bp+4]
    mov ah, 07h
printer:
    mov al, [si]
    mov [es:di], ax
    add si, 1
    add di, 2
    loop printer
    mov ax, [bp+6]
    mov ah, 07h
    add al, 0x30
    mov [es:di], ax
    pop bp
    ret 4
;-----------------------------------------------------------------------------



;-----------------------------------------------------------------------------
countbits:
    push bp
    mov bp, sp
    mov bx, [bp+4]  ; BX points to the data
    mov ax, [bx]
    and ah, 0xF0     ;UPPER AH 4 BITS
    mov dx, 0
extract1:
    shl ah, 1
    jnc skip1
    add dx, 1
skip1:
    cmp ah, 0
    jne extract1
    mov [upperBitCount], dx
    mov ax, [bx]
    and ah, 0x0F  ; LOWER AH 4 BITS
    mov dx, 0
extract2:
    shr ah, 1
    jnc skip2
    add dx, 1
skip2:
    cmp ah, 0
    jne extract2
    mov [lowerBitCount], dx
    mov ax, [bx]
    mov dx, 0
loop_bitcount:
    shl al, 1 ; AL 8 BITS
    jnc skip3
    add dx, 1
skip3:
    cmp al, 0
    jne loop_bitcount
    mov [totalBitCount], dx
    mov ax, [upperBitCount]
    add ax, [lowerBitCount]
    add ax, [totalBitCount]
    mov [finalBitCount], ax
    pop bp
    ret 2
;-----------------------------------------------------------------------------




start:
    call clrscr
    mov ax, rollno
    push ax
    call countbits
    call print_section

;-----------------------------------------------------------------------------
end_prg:
    mov ax, 0x4c00
    int 21h


