org 100h
jmp start

;==============================================================================
; DATA SECTION - Game Constants and Variables
;==============================================================================

; Game Messages and UI Text
;------------------------------------------------------------------------------
welcome_message    db 'Welcome to Ping Pong Game Developed By Ajmal Razaq & Ahmad Rohan', '$'
game_over_msg     db 'Game Over! Press ESC to exit or SPACE to play again', '$'
player_1_name     db 'Player One: ','$'
player_2_name     db 'Player Two: ','$'
player_1_win_msg  db 'Player one has won!', '$'
player_2_win_msg  db 'Player two has won!', '$'
pause_msg         db 'GAME PAUSED - Press P to Resume', '$'

; Pattern Selection Messages
;------------------------------------------------------------------------------
pattern_no        db 'Press SPACE to start the game without Moving Patterns', '$'
pattern_star      db 'Press 1 for Star Background' ,'$'
pattern_line      db 'Press 2 for Line Background' ,'$'
pattern_arrow     db 'Press 3 for Arrow Background' ,'$'

; Game State Variables
;------------------------------------------------------------------------------
is_paused        db 0    ; 0 = running, 1 = paused
max_score        db 5    ; Game ends when a player reaches this score
game_speed       dw 8    ; Controls ball movement speed (higher = slower)
player_1_score   db 0    ; Player 1's current score
player_2_score   db 0    ; Player 2's current score

; Pattern System Variables
;------------------------------------------------------------------------------
pattern_x        db 2    ; Pattern X position
pattern_y        db 2    ; Pattern Y position
pattern_dir      db 0    ; Pattern movement direction
pattern          dw 0    ; Current pattern character and attribute

; Game Object Positions and Properties
;------------------------------------------------------------------------------
; Paddle 1 (Left Player)
paddle_1_x       db 2    ; Fixed X position for left paddle
paddle_1_y       db 12   ; Initial Y position (can move up/down)

; Paddle 2 (Right Player)
paddle_2_x       db 77   ; Fixed X position for right paddle
paddle_2_y       db 12   ; Initial Y position (can move up/down)

; Ball Properties
ball_pos         db 40, 12   ; Ball position (X, Y) - starts in center
ball_dir         db 1, 1     ; Ball direction (X, Y) - positive = right/down
ball_char        db 'O'      ; Ball character
ball_color       db 0x0F     ; Ball color (white on black)

; Game Constants
;------------------------------------------------------------------------------
SCREEN_WIDTH     equ 80      ; Screen width in characters
SCREEN_HEIGHT    equ 25      ; Screen height in characters
PADDLE_HEIGHT    equ 3       ; Height of each paddle
WALL_COLOR      equ 0x07     ; Color for walls (light gray)
PADDLE_COLOR    equ 0x0C     ; Color for paddles (light red)

;==============================================================================
; Initial Setup Functions
;==============================================================================
start:
    ; Set video mode (80x25 text mode)
    mov ah, 00h
    mov al, 03h
    int 10h
    
    ; Initialize keyboard
    in al, 21h          ; Get current keyboard state
    or al, 2            ; Disable keyboard interrupts
    out 21h, al
    
    ; Show welcome screen (will be implemented in chunk 3)
    ; Jump to game loop (will be implemented in chunk 4)
    jmp show_welcome_screen  ; This label will be defined in later chunks

    ;==============================================================================
; CHUNK 2: CORE GAME FUNCTIONS
;==============================================================================

;------------------------------------------------------------------------------
; Ball Movement and Physics
;------------------------------------------------------------------------------
update_ball:
    push ax
    push bx
    
    ; Update X position based on direction
    mov al, [ball_dir]
    add [ball_pos], al
    
    ; Update Y position based on direction
    mov al, [ball_dir+1]
    add [ball_pos+1], al
    
    ; Check wall collisions (top and bottom)
    cmp byte [ball_pos+1], 3    ; Top wall collision
    jle reverse_ball_vertical
    cmp byte [ball_pos+1], 23   ; Bottom wall collision
    jge reverse_ball_vertical
    
    ; Check paddle collision zones
    mov al, [ball_pos]
    cmp al, 3                   ; Left paddle zone
    je check_left_paddle_hit
    cmp al, 76                  ; Right paddle zone
    je check_right_paddle_hit
    
    ; Check scoring conditions
    cmp al, 0                   ; Ball past left paddle
    jle score_right_point
    cmp al, 78                  ; Ball past right paddle
    jge score_left_point
    
    jmp update_ball_done

reverse_ball_vertical:
    neg byte [ball_dir+1]       ; Reverse Y direction
    call play_wall_bounce       ; Play sound effect
    jmp update_ball_done

;------------------------------------------------------------------------------
; Paddle Collision Detection
;------------------------------------------------------------------------------
check_left_paddle_hit:
    mov al, [ball_pos+1]        ; Get ball Y position
    mov bl, [paddle_1_y]        ; Get paddle Y position
    
    ; Check if ball Y is within paddle bounds
    cmp al, bl
    jl no_paddle_hit            ; Ball above paddle
    add bl, PADDLE_HEIGHT
    cmp al, bl
    jg no_paddle_hit            ; Ball below paddle
    
    ; Ball hit paddle - reverse direction
    neg byte [ball_dir]         ; Reverse X direction
    call play_paddle_hit        ; Play sound effect
    jmp update_ball_done

check_right_paddle_hit:
    mov al, [ball_pos+1]        ; Get ball Y position
    mov bl, [paddle_2_y]        ; Get paddle Y position
    
    ; Check if ball Y is within paddle bounds
    cmp al, bl
    jl no_paddle_hit            ; Ball above paddle
    add bl, PADDLE_HEIGHT
    cmp al, bl
    jg no_paddle_hit            ; Ball below paddle
    
    ; Ball hit paddle - reverse direction
    neg byte [ball_dir]         ; Reverse X direction
    call play_paddle_hit        ; Play sound effect
    jmp update_ball_done

no_paddle_hit:
    jmp update_ball_done

;------------------------------------------------------------------------------
; Scoring System
;------------------------------------------------------------------------------
score_left_point:
    inc byte [player_1_score]
    call play_score
    call reset_ball
    jmp update_ball_done

score_right_point:
    inc byte [player_2_score]
    call play_score
    call reset_ball

update_ball_done:
    pop bx
    pop ax
    ret

;------------------------------------------------------------------------------
; Ball Reset Function
;------------------------------------------------------------------------------
reset_ball:
    push ax
    
    ; Reset ball to center position
    mov byte [ball_pos], 40     ; Center X
    mov byte [ball_pos+1], 12   ; Center Y
    
    ; Randomize initial direction
    in al, 40h                  ; Get system timer value
    and al, 1                   ; Get last bit (0 or 1)
    mov byte [ball_dir], 1      ; Default right direction
    jnz reset_ball_dir_done     ; If 1, keep default
    neg byte [ball_dir]         ; If 0, go left
    
reset_ball_dir_done:
    mov byte [ball_dir+1], 1    ; Reset vertical direction
    pop ax
    ret

;------------------------------------------------------------------------------
; Paddle Movement Functions
;------------------------------------------------------------------------------
move_paddle_up:
    ; Input: BL = current paddle Y position
    ; Returns: New paddle position in BL
    cmp bl, 3                   ; Check top boundary
    jle paddle_move_done        ; Don't move if at top
    dec bl                      ; Move paddle up
    jmp paddle_move_done

move_paddle_down:
    ; Input: BL = current paddle Y position
    ; Returns: New paddle position in BL
    cmp bl, 20                  ; Check bottom boundary
    jge paddle_move_done        ; Don't move if at bottom
    inc bl                      ; Move paddle down
    
paddle_move_done:
    ret

;------------------------------------------------------------------------------
; Score Check Function
;------------------------------------------------------------------------------
check_game_over:
    push ax
    mov al, [max_score]
    
    ; Check if either player has reached max score
    cmp [player_1_score], al
    jge game_is_over
    cmp [player_2_score], al
    jge game_is_over
    
    pop ax
    clc                         ; Clear carry flag - game not over
    ret

game_is_over:
    call play_game_over
    pop ax
    stc                         ; Set carry flag - game is over
    ret




    ;==============================================================================
; CHUNK 3: GRAPHICS AND DISPLAY FUNCTIONS
;==============================================================================

;------------------------------------------------------------------------------
; Screen Management
;------------------------------------------------------------------------------
clear_screen:
    push ax
    mov ah, 00h        ; Video mode function
    mov al, 03h        ; Text mode 80x25, 16 colors
    int 10h
    pop ax
    ret

;------------------------------------------------------------------------------
; Pattern System Functions
;------------------------------------------------------------------------------
print_pattern:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0xB800     ; Video memory segment
    mov es, ax
    
    ; Calculate pattern position
    mov al, [pattern_y]
    mov bl, 160        ; Bytes per row
    mul bl
    mov di, ax
    mov al, [pattern_x]
    mov bl, 2          ; Bytes per character
    mul bl
    add di, ax
    
    ; Print pattern rows
    mov dx, 22         ; Number of rows
pattern_row_loop:
    mov cx, 5          ; Characters per row
    push di
    
pattern_col_loop:
    mov si, [pattern]  ; Get pattern character and attribute
    mov word [es:di], si
    add di, 2
    loop pattern_col_loop
    
    pop di
    add di, 160        ; Move to next row
    dec dx
    jnz pattern_row_loop

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

update_pattern:
    push ax
    inc byte [pattern_x]   ; Move pattern right
    
    ; Check right boundary
    cmp byte [pattern_x], 74
    jl pattern_move_done
    mov byte [pattern_x], 3 ; Reset to left side
    
pattern_move_done:
    pop ax
    ret

;------------------------------------------------------------------------------
; Game Object Rendering
;------------------------------------------------------------------------------
print_ball:
    push ax
    push bx
    push dx
    push es

    mov ax, 0xB800
    mov es, ax

    ; Calculate ball position in video memory
    xor ax, ax
    mov al, [ball_pos+1]   ; Y position
    mov bx, 160
    mul bx
    xor bx, bx
    mov bl, [ball_pos]     ; X position
    shl bx, 1              ; Multiply by 2 for attribute
    add ax, bx
    mov di, ax

    ; Print ball with attribute
    mov ah, [ball_color]
    mov al, [ball_char]
    mov word [es:di], ax

    pop es
    pop dx
    pop bx
    pop ax
    ret

print_paddle_1:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    mov ax, 0xB800
    mov es, ax
    
    ; Calculate paddle position
    mov al, [paddle_1_y]
    mov bl, 160
    mul bl
    mov di, ax
    mov al, [paddle_1_x]
    shl al, 1              ; Multiply by 2 for attribute
    add di, ax
    
    ; Draw paddle
    mov cx, PADDLE_HEIGHT
paddle1_draw:
    mov word [es:di], 0x0CDB  ; Light red paddle character
    add di, 160              ; Next row
    loop paddle1_draw
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print_paddle_2:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    mov ax, 0xB800
    mov es, ax
    
    ; Calculate paddle position
    mov al, [paddle_2_y]
    mov bl, 160
    mul bl
    mov di, ax
    mov al, [paddle_2_x]
    shl al, 1              ; Multiply by 2 for attribute
    add di, ax
    
    ; Draw paddle
    mov cx, PADDLE_HEIGHT
paddle2_draw:
    mov word [es:di], 0x0CDB  ; Light red paddle character
    add di, 160              ; Next row
    loop paddle2_draw
    
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;------------------------------------------------------------------------------
; Field Rendering
;------------------------------------------------------------------------------
print_walls:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    
    mov ax, 0xB800
    mov es, ax
    
    ; Draw top wall
    mov di, 2              ; Skip first column
    mov cx, 78             ; Width of playfield
    mov ax, 0x073D        ; Light gray wall character
    rep stosw

    ; Draw middle separator line
    mov di, 322           ; Second row
    mov cx, 78
    rep stosw
    
    ; Draw bottom wall
    mov di, 3840          ; Last row
    mov cx, 80
    rep stosw
    
    ; Draw left walls (double thickness)
    mov di, 0
    mov cx, 25            ; Height of playfield
left_wall1:
    mov word [es:di], 0x077C
    add di, 160
    loop left_wall1
    
    mov di, 2
    mov cx, 25
left_wall2:
    mov word [es:di], 0x077C
    add di, 160
    loop left_wall2

    ; Draw right walls (double thickness)
    mov di, 156
    mov cx, 25
right_wall1:
    mov word [es:di], 0x077C
    add di, 160
    loop right_wall1
    
    mov di, 158
    mov cx, 25
right_wall2:
    mov word [es:di], 0x077C
    add di, 160
    loop right_wall2

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;------------------------------------------------------------------------------
; Score Display
;------------------------------------------------------------------------------
print_scores:
    push ax
    push bx
    push cx
    push dx
 
    ; Print Player 1 name and score
    mov ax, player_1_name
    push ax              ; String offset
    mov ax, 11          ; String length
    push ax
    mov ax, 0x0114      ; Row 1, Column 20
    push ax
    mov al, 0x07        ; Light gray color
    push ax
    call print_string

    ; Position cursor for Player 1 score
    mov dh, 1           ; Row
    mov dl, 32          ; Column
    mov bh, 0           ; Page
    mov ah, 02h         ; Set cursor position
    int 10h

    ; Print Player 1 score
    mov al, [player_1_score]
    add al, '0'         ; Convert to ASCII
    mov bl, 0x07        ; Light gray color
    mov cx, 1           ; One character
    mov ah, 09h         ; Write character
    int 10h

    ; Print Player 2 name and score
    mov ax, player_2_name
    push ax
    mov ax, 11
    push ax
    mov ax, 0x0132      ; Row 1, Column 50
    push ax
    mov al, 0x07
    push ax
    call print_string

    ; Position cursor for Player 2 score
    mov dh, 1
    mov dl, 62
    mov bh, 0
    mov ah, 02h
    int 10h

    ; Print Player 2 score
    mov al, [player_2_score]
    add al, '0'
    mov bl, 0x07
    mov cx, 1
    mov ah, 09h
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret



    ;==============================================================================
; CHUNK 4: GAME FLOW AND INPUT HANDLING
;==============================================================================

;------------------------------------------------------------------------------
; Sound Effect System
;------------------------------------------------------------------------------
sound_delay:
    push dx
    push ax
sound_delay_loop:
    mov dx, 8000
delay_inner:
    dec dx
    jnz delay_inner
    loop sound_delay_loop
    pop ax
    pop dx
    ret

; Optimized sound effects using common sound routine
play_sound_effect:
    ; Input: AX = frequency, CX = duration
    push ax
    push bx
    
    mov al, 182         
    out 43h, al         
    out 42h, al         
    mov al, ah          
    out 42h, al 
    
    in al, 61h         
    or al, 00000011b
    out 61h, al
    
    call sound_delay
    
    in al, 61h         
    and al, 11111100b
    out 61h, al
    
    pop bx
    pop ax
    ret

;------------------------------------------------------------------------------
; Welcome Screen and Menu
;------------------------------------------------------------------------------
show_welcome_screen:
    call clear_screen
    
    ; Display main welcome message
    mov ax, welcome_message
    push ax
    mov ax, 64              ; Message length
    push ax
    mov ax, 0x0408         ; Row 4, Column 8
    push ax
    mov al, 0x0A           ; Green color
    push ax
    call print_string

    ; Display pattern selection options
    mov ax, pattern_no
    push ax
    mov ax, 53
    push ax
    mov ax, 0x0808
    push ax
    mov al, 0x0A
    push ax
    call print_string

    ; Pattern options
    mov ax, pattern_star
    push ax
    mov ax, 27
    push ax
    mov ax, 0x091A
    push ax
    mov al, 0x0A
    push ax
    call print_string

    mov ax, pattern_line
    push ax
    mov ax, 27
    push ax
    mov ax, 0x0A1A
    push ax
    mov al, 0x0A
    push ax
    call print_string

    mov ax, pattern_arrow
    push ax
    mov ax, 28
    push ax
    mov ax, 0x0B1A
    push ax
    mov al, 0x0A
    push ax
    call print_string

    ret

;------------------------------------------------------------------------------
; Input Handling
;------------------------------------------------------------------------------
handle_welcome_input:
    mov ah, 00h
    int 16h
    
    cmp al, '1'
    je set_pattern_star
    cmp al, '2'
    je set_pattern_line
    cmp al, '3'
    je set_pattern_arrow
    cmp al, 32             ; Space key
    je start_game_no_pattern
    
    jmp handle_welcome_input

check_input:
    mov ah, 01h
    int 16h
    jz no_input
    
    mov ah, 00h
    int 16h
    
    ; Check for pause
    cmp al, 'p'
    je toggle_pause
    cmp al, 'P'
    je toggle_pause
    
    ; Check for paddle movement
    cmp ah, 0x11          ; W key
    je move_left_paddle_up
    cmp ah, 0x1F          ; S key
    je move_left_paddle_down
    cmp ah, 0x48          ; Up arrow
    je move_right_paddle_up
    cmp ah, 0x50          ; Down arrow
    je move_right_paddle_down
    
no_input:
    ret

;------------------------------------------------------------------------------
; Pause System
;------------------------------------------------------------------------------
toggle_pause:
    xor byte [is_paused], 1
    
    cmp byte [is_paused], 1
    je show_pause_screen
    ret

show_pause_screen:
    mov ax, pause_msg
    push ax
    mov ax, 31              ; Message length
    push ax
    mov ax, 0x0C1A         ; Row 12, Column 26
    push ax
    mov al, 0x0E           ; Yellow color
    push ax
    call print_string
    
pause_loop:
    mov ah, 00h
    int 16h
    
    cmp al, 'p'
    je resume_game
    cmp al, 'P'
    je resume_game
    jmp pause_loop

resume_game:
    xor byte [is_paused], 1
    ret

;------------------------------------------------------------------------------
; Game Over Handling
;------------------------------------------------------------------------------
show_game_over:
    call clear_screen

    ; Determine winner
    mov al, [player_1_score]
    cmp al, [player_2_score]
    jg show_player1_wins
    jl show_player2_wins

show_player1_wins:
    mov ax, player_1_win_msg
    jmp display_winner

show_player2_wins:
    mov ax, player_2_win_msg

display_winner:
    push ax
    mov ax, 19              ; Message length
    push ax
    mov ax, 0x0A1C         ; Position
    push ax
    mov al, 0x0F           ; White color
    push ax
    call print_string

    ; Show game over message
    mov ax, game_over_msg
    push ax
    mov ax, 45
    push ax
    mov ax, 0x0C10
    push ax
    mov al, 0x0F
    push ax
    call print_string

wait_for_restart:
    mov ah, 00h
    int 16h
    
    cmp al, 27             ; ESC key
    je exit_game
    cmp al, 32             ; Space key
    je restart_game
    jmp wait_for_restart

;------------------------------------------------------------------------------
; Main Game Loop
;------------------------------------------------------------------------------
game_loop:
    call clear_screen
    
    ; Check if game is paused
    cmp byte [is_paused], 1
    je pause_loop
    
    ; Update game state
    call print_pattern
    call update_pattern
    call print_walls
    call print_ball
    call print_paddle_1
    call print_paddle_2
    call print_scores
    call update_ball
    
    ; Check for game over
    call check_game_over
    jc show_game_over
    
    ; Handle input
    call check_input
    
    ; Control game speed
    call delay
    jmp game_loop

;------------------------------------------------------------------------------
; Game Management
;------------------------------------------------------------------------------
restart_game:
    ; Reset scores
    mov byte [player_1_score], 0
    mov byte [player_2_score], 0
    
    ; Reset ball
    call reset_ball
    
    ; Reset paddles
    mov byte [paddle_1_y], 12
    mov byte [paddle_2_y], 12
    
    jmp game_loop

exit_game:
    mov ax, 4C00h
    int 21h

delay:
    push cx
    push dx
    push ax
    mov cx, [game_speed]
delay_loop:
    push cx
    mov cx, 0FFFFh
delay_inner_loop:
    loop delay_inner_loop
    pop cx
    loop delay_loop
    pop ax
    pop dx
    pop cx
    ret