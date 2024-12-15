org 0x0100
message: db "Hi,From Ajmal"
start:
mov ah, 00h
mov al, 03h
int 10h
mov ax,0
mov ah,0
int 16h
mov ah,0x13
mov al,1
mov bh,0
mov bl,7
mov dx,0x0101
mov cx,13
push cs
pop es
mov bp,message
int 0x10
mov ax,0x4c00
int 21h