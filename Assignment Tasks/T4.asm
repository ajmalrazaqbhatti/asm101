[org 0x0100]
jmp start
ttlsum: dw 0     
num: dw 5


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
;-----------------------------------------------

initscr:
   mov ax, 0xb800
   mov es,ax
   ret

;--------------------------------------------------

dispnum:
   push bp
   mov bp, sp
   push es
   push ax
   push bx
   push cx
   push dx
   push di
   call initscr
   mov ax, [bp+4]
   mov bx, 10
   mov cx, 0 
prnxt: 
   mov dx, 0
   div bx
   add dl, 0x30 
   push dx 
   inc cx      
   cmp ax, 0
   jnz prnxt 
   mov di, 2000
nxtloc: 
   pop dx 
   mov dh, 0x07 
   mov [es:di], dx 
   add di, 2 
   loop nxtloc

   pop di
   pop dx
   pop cx
   pop bx
   pop ax
   pop es
   pop bp

ret 2


;---------------------------------------------------------








;---------------------------------------------------------
cummsum:
    push bp
    mov bp, sp
    push ax
    push bx   
    push si     
    mov dx,0          
    mov bx, 0
    mov si,1           
outrloop:
    mov ax, 1          
strloop:
    add [ttlsum], ax     
    cmp ax, si        
    je revloop           
    inc ax              
    jmp strloop      
    skip:
    inc bx  
    inc si            
    cmp bx,[bp+4]       
    jne outrloop      
    jmp endfunc  

revloop:
    cmp ax, 1           
    je skip            
    dec ax             
    add [ttlsum], ax       
    jmp revloop          

 endfunc:
    pop si
    pop bx
    pop ax 
    pop bp
    ret

;-----------------------------------------------------------------


start:
    mov ax,[num]
    add ax,5
    push ax
    call cummsum
    call clear_scr
    mov ax, [ttlsum] 
    push ax 
    call dispnum 

end_prg:
    mov ax, 0x4c00      
    int 21h
