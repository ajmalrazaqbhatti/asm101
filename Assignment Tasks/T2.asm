[org 0x100]
jmp startProgram

;-------------------------------------
array: dw 1, 2, 3, 4
N: dw 4
flag: dw -1
onescount: dw 0
zerocount: dw 0
;---------------------------------------

;----------------------------------------
countbits:
    mov dx, 16            
    mov word [onescount], 0
    mov word [zerocount], 0

bitcountloop:
    shr ax, 1              ; Shift right through all bits in AX
    jc incbit              ; If carry (bit is 1), jump to incbit
    add word [zerocount], 1
    jmp skip

incbit:
    add word [onescount], 1

skip:
    sub dx, 1             
    jnz bitcountloop       
    ret
;---------------------------------------------
checkEvenOdd:
    test ax, 1             ; Check if AX is even or odd
    jz steven              ; If zero (even), jump to steven
    mov word [flag], 1     ; Flag 1 odd
    ret

steven:
    mov word [flag], 0     ; Flag 0 even
    ret
;------------------------------------------------
prcsswrd:
    mov si, 0             
    mov cx, [N]            

prcss:
    mov ax, [bx + si]      ; Load current array element
    call countbits         ; Count bits in AX
    mov ax, [bx + si]      ; Reload 
    call checkEvenOdd      ; Check if even or odd
    cmp word [flag], 0
    je strzero
    mov ax, [onescount]    ; If odd, replace with onescount
    mov [bx + si], ax
    jmp nxtitm            

strzero:
    mov ax, [zerocount]    ; If even, replace with zerocount
    mov [bx + si], ax

nxtitm:
    add si, 2              ; Move to the next array element
    loop prcss            
    ret
;----------------------------------------------------

startProgram:
    mov bx, array          ; Point BX to start of array
    call prcsswrd          ; Process each word in the array

exitProgram:
    mov ax, 0x4c00
    int 21h
