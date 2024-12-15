[org 0x0100]
jmp start




;------------------------------------------------
arr: db 1, 2, 4, 6, 3, 7, 6   
arr_new: db 0,0,0,0,0,0,0    
missing: db 0             
N :db 7
;-----------------------------------------------






;-----------------------------------------------
rm_du:
    push ax
    push bx
    push cx
    push si
    push di            
    mov bx,0            
    mov si,0          
outer_loop:
    mov al, [arr + bx]        
    mov di, 0                 
    mov dx, si                
    mov cx, 1               
inner_loop:
    cmp di, dx                
    je store_unique           
    mov ah, [arr_new + di]    
    cmp al, ah              
    je duplicate_found        
    inc di                    
    jmp inner_loop          
store_unique:
    mov [arr_new + si], al    
    inc si                   
    jmp end_check           
duplicate_found:
   mov cx,0
end_check:
    inc bx                  
    cmp bx,[N]                 
    jl outer_loop             
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret                       
;------------------------------------------------------------








;------------------------------------------------------------
find_missing:
    push ax
    push bx
    push cx
    push si
    mov bl, 1                
    
outer_loop_missing:
    mov di, 0               
    mov cx, 0                

inner_loop_missing:
    cmp di, 7                 
    je check_missing          
    mov al, [arr_new + di]    
    cmp al, bl                
    je found_number           
    inc di                    
    jmp inner_loop_missing    

found_number:
    mov cx, 1               

check_missing:
    cmp cx, 0                 
    jne next_number         
    mov [missing], bl         
    jmp end_missing          

next_number:
    inc bl                    
    cmp bl,[N]
    jle outer_loop_missing    

end_missing:
    pop si
    pop cx
    pop bx
    pop ax
    ret                       
;--------------------------------------------------------------------







;--------------------------------------------------------------------
print_missing:
push ax
push es
push di
mov ax,0xb800
mov es,ax
mov di,0
loop_scr:
mov word[es:di],0x0720
add di,2
cmp di,4000
jl loop_scr
mov di,2000
mov al, 0x30
mov ah, 0x07
add al,[missing]
mov word [es:di],ax
pop di
pop es
pop ax
ret
;--------------------------------------------------------------------



start:
    call rm_du               
    call find_missing         
    call print_missing  
end_prg:      
    mov ax, 0x4c00          
    int 21h
