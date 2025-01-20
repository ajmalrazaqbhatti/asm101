[org 0x0100]
jmp start

msg1: db 'Valid key is pressed!'
msg1_len: db 21
msg2: db 'Invalid key is pressed!'
msg2_len: db 23

cls:
    push es
    push ax
    push cx
    push di
    mov ax, 0xb800
    mov es, ax
    mov cx, 2000
    mov di, 0
loop_pr:
    mov ax, 0x0720
    mov [es:di], ax
    add di, 2
    loop loop_pr
    pop di
    pop cx
    pop ax
    pop es
    ret

printstr:
    push bp
    mov bp, sp
    push es
    push ax
    push cx
    push si
    push di
    push ds
    pop es

    mov si, [bp+4]
    mov cl, [bp+6]
    mov ch, 0
    mov ax, 0xb800
    mov es, ax
    mov di, 1992
    mov ah, 0x07

nextchar:
    mov al, [si]
    mov [es:di], ax
    inc si
    add di, 2
    loop nextchar

    pop di
    pop si
    pop cx
    pop ax
    pop es
    pop bp
    ret 4

chk_prs:
    mov ah, 0
    int 16h
    cmp al, 'w'
    je valid_key
    cmp al, 'a'
    je valid_key
    cmp al, 's'
    je valid_key
    cmp al, 'd'
    je valid_key
    jmp invalid_key

valid_key:
    call cls
    mov ax, 0x07
    push ax
    mov al, [msg1_len]
    cbw
    push ax
    mov ax, msg1
    push ax
    call printstr
    jmp chk_prs

invalid_key:
    call cls
    mov ax, 0x07
    push ax
    mov al, [msg2_len]
    cbw
    push ax
    mov ax, msg2
    push ax
    call printstr
    jmp chk_prs

start:
    call cls
    call chk_prs

endprog:
    mov ax, 0x4c00
    int 21h