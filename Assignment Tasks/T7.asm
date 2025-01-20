[org 0x0100]   ; Code starts at offset 0x0100 (COM file format)

num: db '12345' ; A string of numbers used for pattern generation

jmp start       ; Skip directly to start label

; Clear the screen by writing blank spaces to video memory
clrscr: 
    push es
    push ax
    push di
    mov ax, 0xb800  ; Video memory segment
    mov es, ax
    mov di, 0       ; Start at the beginning of video memory
nextloc:
    mov word [es:di], 0x0720 ; Blank space with white on black attribute
    add di, 2       ; Move to next character position
    cmp di, 4000    ; 80x25 screen, 4000 bytes total
    jne nextloc
    pop di
    pop ax
    pop es
    ret

; Draw a pyramid pattern using arguments (row, column) passed via the stack
pattern:
    push bp
    mov bp, sp
    push ax
    push bx 
    push si 
    push cx
    push dx
    push di
    mov ax, 0xb800   ; Load video memory segment
    mov es, ax
    mov bx, [bp+4]   ; Row (argument 1)
    mov ax, [bp+6]   ; Column (argument 2)
    mov dx, 1        ; Starting line number
    mov ch, 0x07     ; Character attribute (white on black)
    mov si, 0        ; Index for 'num'

outerloop:
    mov cl, [num+si] ; Get the current character
    add si, 1        ; Move to the next character

innerloop:
    push ax          ; Save column
    mov ax, bx       ; Move row to ax
    mov di, 160      ; Set multiplier to 160 (80 * 2 bytes per character)
    mul di           ; Multiply row by 160 (ax = ax * 160)
    mov di, ax       ; Store result in di
    pop ax           ; Restore column
    add di, ax       ; Add column offset
    shl di, 1        ; Multiply by 2 (2 bytes per character)
    mov [es:di], cx  ; Write character with attribute
    add ax, 1        ; Move to the next column

    cmp si, dx       ; Check if we've completed the current line
    jnz innerloop
    inc bx           ; Move to the next row
    mov ax, [bp+6]   ; Reload column

    inc dx           ; Increment the line number
    cmp dx, 6        ; Stop after 5 rows
    jnz outerloop 

    pop di
    pop dx
    pop cx 
    pop si
    pop bx 
    pop ax 
    pop bp           ; Restore BP
    ret 4            ; Return and clean up 4 bytes of parameters

; Program entry point
start: 
    call clrscr      ; Clear the screen
    mov ax, 2        ; Argument 1: Row
    push ax
    mov ax, 15       ; Argument 2: Column
    push ax
    call pattern     ; Call the pattern procedure
    mov ah, 0x1      ; Wait for keypress
    int 0x21
    mov ax, 0x4c00   ; Exit program
    int 0x21