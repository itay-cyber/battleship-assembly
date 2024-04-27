IDEAL
MODEL small
STACK 200h
	
DATASEG

color_white dw 000Fh
color_green dw 000Ah
color_cyan dw 000Bh
color_red dw 0004h

g_vdist dw ?
g_hdist dw ?


CODESEG

; SCREEN SIZE
; 320 x 200
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

proc MouseLoop

Mloop:
	mov ax, 3
	int 33h
	
	cmp bx, 1
	jne Mloop
	shr cx, 1
	mov ax, 2
	int 33h
	push cx
	push dx
	push 5
	push [color_cyan]
	call DrawX
	mov ax, 1
	int 33h
	ret

endp


start:
	mov ax, @data
	mov ds, ax
	
	push 1h
	call SetMode
	
	
	; draw grid
	;param 1 - grid size
	; param 2 - startX
	; param 3 - endX
	; param 4 - startY
	; param 5 - endY
	; param 6 - color
	push 5
	push 165
	push 316
	push 20
	push 170
	push [color_cyan]
	call DrawGrid

	push 5
	push 4
	push 155
	push 20
	push 170
	push [color_red]
	call DrawGrid
	
	
	mov ax, 0
	int 33h
	
	mov ax, 1
	int 33h
_m:
	call MouseLoop
	jmp _m

	call WaitKey
	
	push 0h
	call SetMode
	
exit:
	mov ax, 4c00h
	int 21h
END start