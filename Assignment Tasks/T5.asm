[org 0x0100]
jmp start
str_min: db 'min '
strlen1: dw 4
str_max: db 'Max '
strlen2: dw 4
str_med: db 'Median '
strlen3: dw 7

;-------------------------------------------------
arr: dw 7,3,2,1,4,6,5,8,9,1
isswaped: db 0
minnum: dw 0
maxnum: dw 0
median: dw 0
;----------------------------------------------------


;------------------------------------------------
clear_scr:
push ax
push es
push di
call initscr
mov di, 0
ClearLoop:
mov word [es:di], 0x0720
add di, 2
cmp di, 3998
jne ClearLoop
pop di
pop es
pop ax
ret
;-------------------------------------------------


;-----------------------------------------------
initscr:
   mov ax, 0xb800
   mov es,ax
   ret
;--------------------------------------------------


;-----------------------------------------------

bblsort:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push si
    mov bx, [bp+6]
    mov cx, [bp+4]
    dec cx
    shl cx, 1

outrloop:
    mov si, 0
    mov byte [isswaped], 0

innerloop:
    mov ax, [bx+si]
    cmp ax, [bx+si+2]
    jbe noswap
    mov dx, [bx+si+2]
    mov [bx+si+2], ax
    mov [bx+si], dx
    mov byte [isswaped], 1

noswap:
    add si, 2
    cmp si, cx
    jne innerloop

    cmp byte [isswaped], 1
    je outrloop

    pop si
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4
;--------------------------------------------------------






;--------------------------------------------------------
statsofarr:
    mov ax, arr
    push ax
    mov ax, 10
    push ax
    call bblsort
    mov ax, [arr]
    mov [minnum], ax
    mov bx, [arr+18]
    mov [maxnum], bx
    mov cx, [arr+8]
    add cx, [arr+10]
    shr cx, 1
    mov [median], cx
    ret
;--------------------------------------------------------


;-------------------------------------------------------
printstr:
    push bp
    mov bp, sp
    push es
    push di
    push si
    push cx          
    call initscr
    mov di, [bp+8] 
    mov si, [bp+6]  
    mov cx, [bp+4]   
    mov ah, 0x07    

print_loop:
    mov al, [si]         
    mov [es:di], ax    
    add di, 2            
    inc si              
    dec cx              
    jnz print_loop      

    add di, 2            
    mov al, 0x30         
    add al, [bp+10]      
    mov [es:di], ax      

    pop cx              
    pop si
    pop di
    pop es
    pop bp
    ret 8                

disp:
    call clear_scr
    mov ax, [minnum]
    push ax
    mov ax, 202
    push ax
    mov ax, str_min
    push ax
    mov ax, [strlen1]
    push ax
    call printstr

    mov ax, [maxnum]
    push ax
    mov ax, 362
    push ax
    mov ax, str_max
    push ax
    mov ax, [strlen2]
    push ax
    call printstr

    mov ax, [median]
    push ax
    mov ax, 522
    push ax
    mov ax, str_med
    push ax
    mov ax, [strlen3]
    push ax
    call printstr

    ret
;-----------------------------------------------------


start:
    call statsofarr
    call disp
end_prg:
    mov ax, 0x4c00
    int 21h