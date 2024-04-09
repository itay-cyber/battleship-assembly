; SCREEN SIZE
; 320 x 200
; https://yassinebridi.github.io/asm-docs/8086_bios_and_dos_interrupts.html#int16h_01h

IDEAL
MODEL small
STACK 200h
	
DATASEG

; CONSTANTS ;
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

;  STRINGS ;
kte_msg db "Press any key to exit...", 13, 10, '$'

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


; param 1 - grid size
; param 2 - startX
; param 3 - endX
; param 4 - startY
; param 5 - endY
; param 6 - color
proc DrawGrid
	grid_size equ [bp+14]
	startX equ [bp+12]
	endX equ [bp+10]
	startY equ [bp+8]
	endY equ [bp+6]
	color equ [bp+4]

	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	
	mov ax, endX
	sub ax, startX
	mov bx, grid_size
	xor dx, dx
	div bx
	mov [g_hdist], ax
	
	mov ax, endY
	sub ax, startY
	mov bx, grid_size
	xor dx, dx
	div bx
	mov [g_vdist], ax

	
	; draw horiz line
	push startX ; startX
	push endX ; endX
	push startY ; startY
	push color
	call DrawHoriz
	mov ax, startX
	mov bx, startY
	mov cx, grid_size
	inc cx
	
	
	
grid_loop:
	push startY
	push endY
	push ax
	push color
	call DrawVert
	add ax, [g_hdist]
	
	push startX
	push endX
	push bx
	push color
	call DrawHoriz
	add bx, [g_vdist]
	loop grid_loop
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 12
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




; param 1 - color
proc DrawPixel
	color equ [bp+4]

	push bp
	mov bp, sp
	push ax
	push bx
	
	; draw pixel
	mov al, color
	mov bl, 0
	mov ah, 0ch
	int 10h
	
	pop bx
	pop ax
	pop bp
	ret 2
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


; startx 
; startY
; length/size
; color
proc DrawX
	startX equ [bp+10]
	startY equ [bp+8]
	xLen equ [bp+6]
	color equ [bp+4]
	
	
	push bp
	mov bp, sp
	push cx
	push dx
	push bx
	mov bx, 0
	mov cx, startX
	mov dx, startY

diag1_loop:
	push color 
	call DrawPixel
	
	inc cx
	inc dx
	
	inc bx
	cmp bx, xLen
	jne diag1_loop

	mov cx, startX
	add cx, xLen
	dec cx
	mov dx, startY
	mov bx, 0
	
diag2_loop:
	push color
	call DrawPixel
	dec cx
	inc dx
	inc bx
	cmp bx, xLen
	jne diag2_loop
	

	pop bx
	pop dx
	pop cx
	pop bp
	ret 8
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
	push 18
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


start:
	mov ax, @data
	mov ds, ax
	
	push 1h
	call SetMode

    call DrawMap

	call WaitKey
	push 0h
	call SetMode
	
exit:
	mov ax, 4c00h
	int 21h
END start