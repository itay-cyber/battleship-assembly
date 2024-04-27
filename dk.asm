; SCREEN SIZE
; 320 x 200
; https://yassinebridi.github.io/asm-docs/8086_bios_and_dos_interrupts.html#int16h_01h
JUMPS
IDEAL
MODEL small

STACK 200h
DATASEG

; MACROS ;
ma_black equ 00h
ma_red equ 04h
ma_green equ 02h
ma_blue equ 01h
ma_row_end equ 0FFh
ma_sp_end equ 0FDh
ma_nopx equ 0FEh
ma_mario_skin equ 66d
ma_mario_hair equ 6d
ma_yellow equ 44d
ma_boots equ ma_blue

TRUE equ 1
FALSE equ 0

ESCKEY equ 1

DKEY_PRESSED equ 20h
DKEY_RELEASED equ 0A0h

AKEY_PRESSED equ 1E
AKEY_RELEASED equ 9E

	
; CONSTANTS ;
constants db "Constants"
color_white dw 000Fh
color_green dw 000Ah
color_cyan dw 000Bh
color_red dw 0004h
color_lime dw 50
color_gray dw 8
color_bright_pink dw 37
color_pink dw 38

pblock_length dw 10
half_pblock_length dw 5

; VARS ;
g_vdist dw ?
g_hdist dw ?
ladder_stepdist dw ?
ladder_final_stepdist dw 2

mario_x dw ?
mario_y dw ?
save_key db 0

mario_right_leg_x dw ?
mario_right_leg_y dw ?

can_draw db 1

;  STRINGS ;
kte_msg db "Press any key to exit...", 13, 10, '$'
msg1 db 'Start', '$'
msg2 db 'Stop', '$'


; SPRITES ;


smario \
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, \ ; 4 empty
    	ma_red, ma_red, ma_red, ma_red, ma_red,\ ; top of hat
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end ; 4 empty
	;2
	db ma_nopx, ma_nopx, \ ; 2 empty
		ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, \ ; bottom of hat
	   ma_nopx, ma_row_end ; 1 empty
	;3
	db ma_nopx, ma_nopx, \ ; 2 mt
		ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_black, ma_mario_skin, \ ; hair + skin + eyes
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end ; 3 mt
	;4
	db ma_nopx, \ ; 1 mt
		ma_mario_hair, ma_mario_skin, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_black, ma_mario_skin, ma_mario_skin, ma_mario_skin, \
	   ma_nopx, ma_row_end
	;5
	db ma_nopx, \ 
		ma_mario_hair, ma_mario_skin, ma_mario_hair, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_mario_skin, \
	   ma_row_end
	;6
	db ma_nopx, \
		ma_mario_hair, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, \
	   ma_nopx, ma_row_end
	; 7
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_row_end
	; 8
	db ma_nopx, ma_nopx, \
		ma_blue, ma_blue, ma_red, ma_blue, ma_blue, ma_blue, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;9
	db ma_nopx,\
		ma_blue, ma_blue, ma_blue, ma_red, ma_blue, ma_blue, ma_red, ma_blue, ma_blue, ma_blue, \
	   ma_nopx, ma_row_end
	;10
	db ma_blue, ma_blue, ma_blue, ma_blue, ma_red, ma_blue, ma_blue, ma_red, ma_blue, ma_blue, ma_blue, ma_blue,\
		ma_row_end
	;11
	db ma_mario_skin, ma_mario_skin, ma_blue, ma_blue, ma_red, ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_mario_skin, ma_mario_skin,\
		ma_row_end
	;12
	db ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_red, ma_yellow, ma_red, ma_red, ma_yellow, ma_red, ma_mario_skin, ma_mario_skin, ma_mario_skin, \
		ma_row_end
	;13
	db ma_mario_skin, ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_mario_skin, ma_mario_skin, \
		ma_row_end
	;14
	db ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_red, \
	   ma_nopx, ma_nopx, \
	    ma_red, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_row_end
	; 15
	db ma_nopx, \
		ma_boots, ma_boots, ma_boots, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx,\
	    ma_boots, ma_boots, ma_boots, \
	   ma_nopx, ma_row_end
	;16
	db ma_boots, ma_boots, ma_boots, ma_boots, \
		ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	   ma_boots, ma_boots, ma_boots, ma_boots, ma_row_end
	db ma_sp_end

sredcube \
	db ma_red, ma_red, ma_red, ma_red, ma_row_end
	db ma_red, ma_red, ma_red, ma_red, ma_row_end
	db ma_red, ma_red, ma_red, ma_red, ma_row_end
	db ma_red, ma_red, ma_red, ma_red, ma_row_end
	db ma_sp_end
sbluecube \
	db ma_blue, ma_blue, ma_blue, ma_blue, ma_row_end
	db ma_blue, ma_blue, ma_blue, ma_blue, ma_row_end
	db ma_blue, ma_blue, ma_blue, ma_blue, ma_row_end
	db ma_blue, ma_blue, ma_blue, ma_blue, ma_row_end
	db ma_sp_end

	last_sprite_saved_pixels_index dw 0
	saved_pixels_index dw 0
	saved_pixels dd 2000 dup(0) ; double word arr - store pixel x y value and color


CODESEG

; param 1
proc PrintString
	str_offset equ [bp+4]
	
	push bp
	mov bp, sp
	push ax
	push dx
	
	mov ah, 9
	mov dx, str_offset
	int 21h
	
	pop dx
	pop ax
	pop bp

	ret 2

endp


; param 1 -  line startX
; param 2 - line endX
; param 3 - line startY
; param 4 - color
proc DrawHoriz
	line_startX equ [bp+10]
	line_endX equ [bp+8]
	line_startY equ [bp+6]
	color equ [bp+4]
	
	push bp
	mov bp, sp
	push cx
	push dx
	
	mov cx, line_startX
	mov dx, line_startY
	
horiz_loop:
	cmp cx, line_endX
	je hline_drawn
	push color
	call DrawPixel
	inc cx
	jmp horiz_loop
	
hline_drawn:
	pop dx 
	pop cx
	pop bp
	ret 8
endp

; param 1 - line startY
; param 2 - line endY
; param 3 - line startX
; param 4 - color
proc DrawVert
	line_startY equ [bp+10]
	line_endY equ [bp+8]
	line_startX equ [bp+6]
	color equ [bp+4]
	
	push bp
	mov bp, sp
	push cx
	push dx
	
	mov cx, line_startX
	mov dx, line_startY
	
vert_loop:
	cmp dx, line_endY
	je vline_drawn
	push color
	call DrawPixel
	inc dx
	jmp vert_loop

vline_drawn:
	pop dx
	pop cx
	pop bp
	ret 8
endp


; save pixel 
; param 1: pixel x value
; param 2: pixel y value
; param 3: pixel color
proc SavePixel 
	pix_x equ [bp+8]
	pix_y equ [bp+6]
	pix_color equ [bp+4]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si

	lea si, [saved_pixels]
	mov ax, [saved_pixels_index]
	mov bx, 5
	xor dx, dx ; clear dx
	mul bx
	add si, ax

    mov ax, pix_x
	mov [word ptr si], ax
	add si, 2
    mov ax, pix_y
	mov [word ptr si], ax
    add si, 2
    mov al, pix_color
	mov [byte ptr si], al

	inc [saved_pixels_index]

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
endp


; param 1 - color
proc DrawPixel
	color equ [bp+4]

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	
	; draw pixel
	mov al, color
	mov bl, 0
	mov ah, 0ch
	int 10h

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp


; param 1: sprite matrix ds:offset
; param 2: startX
; param 3: startY 
proc DrawSprite
    matrix_of equ [bp+8]
    startX equ [bp+6]
    startY equ [bp+4]
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
	
	mov ax, [saved_pixels_index]
	mov [last_sprite_saved_pixels_index], ax


    mov cx, startX
    mov dx, startY
    mov si, matrix_of
draw_loop:
    cmp [byte ptr si], ma_sp_end ; check for sprite end
    je draw_loop_end
    cmp [byte ptr si], ma_row_end ; check for row end
    je lrow_end
    cmp [byte ptr si], ma_nopx ; check for empty pixel
    je no_px

	; save pixel
	mov ah, 0Dh
	int 10h ; get pixel color
	push cx
	push dx
	push ax
	call SavePixel

    push [word ptr si] ; draw pixel
    call DrawPixel
	
no_px:
    inc cx  
    inc si
    jmp draw_loop

lrow_end:
    mov cx, startX
    inc dx
    inc si
    jmp draw_loop
draw_loop_end:

	pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp


    ret 6
endp    

proc EraseSprite
    push ax
    push bx
    push cx
    push dx
    push si

	lea si, [saved_pixels]
	mov ax, [last_sprite_saved_pixels_index]
	mov bx, 5
	mul bx
	add si, ax
	mov bx, [saved_pixels_index]
	sub bx, [last_sprite_saved_pixels_index]

erase_loop:
	mov cx, [si] ; x
	add si, 2
	mov dx, [si] ; y
	add si, 2
	mov ah, 0
	mov al, [byte ptr si]
	push ax ; color
	call DrawPixel
	inc si
	dec bx
	jnz erase_loop
	mov ax, [last_sprite_saved_pixels_index]
	sub [saved_pixels_index], ax


	pop si
    pop dx
    pop cx
    pop bx
    pop ax


    ret 
endp    

proc WaitKey
	push ax
	mov ah, 0h
	int 16h
	pop ax
	ret
endp


; param - mode 
; 0 - text mode 3h
; 1 - video mode 13h
proc SetMode
	push bp
	mov bp, sp
	push ax
	
	cmp [word ptr bp+4], 0
	jne video
	mov ax, 3h
	int 10h
video:
	cmp [word ptr bp+4], 1
	jne _ret
	mov ax, 13h
	int 10h
_ret:	
	pop ax
	pop bp

	ret 2
endp

; param 1: cursorx 
; param 2: cursory
proc SetCursorPosition
	cursorx equ [bp+6]
	cursory equ [bp+4]
	push bp
	mov bp, sp
	push ax
	push bx
	push dx
	
	mov ah, 2
	mov dh, cursorx
	mov dl, cursory
	mov bh, 0
	int 10h
	
	pop dx
	pop bx
	pop ax
	pop bp
	ret 4
endp

; param 1 : startX
; param 2 : startY
; block = 10 x 8
proc _DrawSingularPinkBlock
    startX equ [bp+6]
    startY equ [bp+4]
    push bp
    mov bp, sp
    push ax
    push bx
    push cx

    mov cx, 2
    mov ax, startX
    mov bx, startY
    add ax, [pblock_length]
_outside_block:  

    push startX
    push ax 
    push bx
    push [color_pink]
    call DRAWHORIZ

    push startX
    push ax
    inc bx
    push bx
    dec bx
    push [color_red]
    call DrawHoriz
    add bx, 7
    loop _outside_block

    mov cx, startX
    mov dx, startY
    add dx, 6

    mov bx, [half_pblock_length]
	dec bx
_middle_chain1:
    push [color_bright_pink]
    call DrawPixel
    inc cx
    push [color_bright_pink]
    call DrawPixel
    dec dx
    dec bx
    jnz _middle_chain1

    mov bx, [half_pblock_length]
_middle_chain2:
    push [color_bright_pink]
    call DrawPixel
    inc cx
    push [color_bright_pink]
    call DrawPixel
    inc dx
    dec bx
    jnz _middle_chain2

    pop cx
	pop bx
	pop ax
    pop bp    
    ret 4
endp

; param 1: n
proc DrawPinkBlockNTimes
	startX equ [bp+8]
	startY equ [bp+6]
	n_times equ [bp+4]
	push bp
	mov bp, sp
	push ax 
	push bx
	push cx
	
	mov cx, n_times
	mov ax, startX
	mov bx, startY
_draw_n_times_loop:
	push ax
	push bx
	call _DrawSingularPinkBlock 	
	add ax, [pblock_length]
	
	loop _draw_n_times_loop

	pop cx
	pop bx
	pop ax
	pop bp	
	ret	6
endp

; param 1: startX
; param 2: startY
; param 3: height
; param 4: number of steps
proc DrawLadder
	startX equ [bp+10]
	startY equ [bp+8]
	ladder_height equ [bp+6]
	n_steps equ [bp+4]

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	; ladder step distance calculation
	mov ax, ladder_height
	mov bx, n_steps
	xor dx, dx
	div bx
	mov [ladder_stepdist], ax
	
	; vertical lines
	mov ax, startY
	mov bx, ax
	add bx, ladder_height
	mov dx, startX
	mov cx, 2
_ladder_outline:
	push ax
	push bx
	push dx
	push [color_cyan]
	call DrawVert 
	add dx, 9
	loop _ladder_outline

	mov cx, n_steps
	mov ax, startX
	mov bx, ax
	add bx, 9
	mov dx, startY
	add dx, [ladder_final_stepdist]
	
	
_ladder_steps:
	push ax
	push bx
	push dx
	push [color_cyan]
	call DRAWHORIZ
	add dx, [ladder_stepdist]
	loop _ladder_steps

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp

	ret 8
endp


proc DrawMap
	push ax
	push bx
	push cx
	push dx
	
	; line of blocks - y180
	push 0
	push 190
	push 18 ; n blocks
	call DrawPinkBlockNTimes
	
	; first staircase
	mov cx, 7
	mov ax, 180
	mov bx, 189
_first_staircase:
	push ax
	push bx
	push 2
	call DrawPinkBlockNTimes
	sub bx, 1
	add ax, [pblock_length]
	add ax, [pblock_length]
	loop _first_staircase

	; second staircase
	mov cx, 15
	mov ax, 280
	mov bx, 154
_second_staircase:
	push ax
	push bx
	push 2
	call DRAWPINKBLOCKNTIMES
	sub bx, 1
	sub ax, [pblock_length]
	sub ax, [pblock_length]
	loop _second_staircase

	; third staircase
	mov cx, 15
	mov ax, 20
	mov bx, 111
_third_staircase:
	push ax
	push bx
	push 2
	call DRAWPINKBLOCKNTIMES
	sub bx, 1
	add ax, [pblock_length]
	add ax, [pblock_length]
	loop _third_staircase
	
	; final layer
	; line of blocks
	push 0
	push 64
	push 22
	call DRAWPINKBLOCKNTIMES

	mov cx, 4
	mov ax, 280
	mov bx, 68
_fourth_staircase:
	push ax
	push bx
	push 2
	call DRAWPINKBLOCKNTIMES
	dec bx
	sub ax, [pblock_length]
	sub ax, [pblock_length]
	loop _fourth_staircase

	; princess tower

	push 150
	push 33
	push 6
	call DRAWPINKBLOCKNTIMES
_ladders:
	;ladders
	; first layer ladder 1
	mov [ladder_final_stepdist], 3
	push 270
	push 162	
	push 23
	push 4
	call DRAWLADDER

	; second layer ladder left
	mov [ladder_final_stepdist], 3
	push 120 ; 7 blocks from left 20 x 7 = 140px
	push 115
	push 31
	push 5
	call DrawLadder
	
	; second layer ladder right
	mov [ladder_final_stepdist], 3
	push 40 ; three blocks from left 20 x 3 = 60px
	push 119
	push 23
	push 4
	call DrawLadder
	
	; third layer ladder right	
	push 240
	push 75
	push 26
	push 4
	call DrawLadder
	
	; third layer broken ladder
	; top half
	push 160
	push 73
	push 7
	push 1
	call DrawLadder
	
	; bottom half
	mov [ladder_final_stepdist], 3
	push 160
	push 93
	push 11
	push 2
	call DrawLadder
	pop dx
	pop cx   
	pop bx
	pop ax
	ret
endp

; param 1 cx
; param 2 dx
proc Delay
	cx_param equ [bp+6]
	dx_param equ [bp+4]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov cx, cx_param
	mov dx, dx_param
	mov ah, 86h ;!!!!! ah not ax you fucker!
	int 15h
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
endp

proc CheckLiftMario
	push ax
	push bx
	push cx
	push dx
	push si
	
	cmp [mario_right_leg_x], 180
	je lift_mario
	cmp [mario_right_leg_x], 200
	je lift_mario
	cmp [mario_right_leg_x], 220
	je lift_mario
	cmp [mario_right_leg_x], 240
	je lift_mario 
	cmp [mario_right_leg_x], 260
	je lift_mario
	cmp [mario_right_leg_x], 280
	je lift_mario
	jmp _ret_check_lift_mario
lift_mario:
	dec [mario_y]

_ret_check_lift_mario:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

proc GameLoop
	push ax
	push bx
	push cx
	push dx
wait_for_key:
	in al, 64h
	cmp al, 10b
	je wait_for_key 
	in al, 60h
	cmp al, ESCKEY
	je exit
	cmp al, DKEY_PRESSED
	je move_mario
	jmp wait_for_key
move_mario:

	push 00h
	push 7530h
	call Delay ; 0.03 seconds

	call EraseSprite
	call CheckLiftMario 

	add [mario_x], 2
	call DrawMario
	jmp wait_for_key
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

proc DrawMario
	push ax
	push bx
	push cx
	push dx
	push offset smario
	push [mario_x]
	push [mario_y]
	call DrawSprite
	mov ax, [mario_x]
	add ax, 12
	mov [mario_right_leg_x], ax
	mov ax, [mario_y]
	add ax, 16
	mov [mario_right_leg_y], ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp


start:
	mov ax, @data
	mov ds, ax
	
	push 1h
	call SetMode

    call DrawMap
	
	mov [mario_x], 10
	mov [mario_y], 174
	mov [mario_right_leg_x], 22
	mov [mario_right_leg_y], 190
	call DrawMario

	
	call GameLoop

	;push offset sredcube
	;push 160
	;push 100
	;call DrawSprite 
	;
	;push 0Fh
	;push 4240h
	;call Delay ; 0.03 seconds
	;
	;push offset sbluecube
	;push 160
	;push 100
	;call DrawSprite
	;
	;push 0Fh
	;push 4240h
	;call Delay ; 0.03 seconds
	;
	;call ERASESPRITE

exit:
	push 0h
	call SetMode
	
	mov ax, 4c00h
	int 21h
END start