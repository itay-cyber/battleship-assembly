; SCREEN SIZE
; 320 x 200
; https://yassinebridi.github.io/asm-docs/8086_bios_and_dos_interrupts.html#int16h_01h
JUMPS
IDEAL
MODEL small

STACK 200h
DATASEG

; MACROS ;
; COLOR CODES
ma_white equ 0Fh
ma_black equ 00h
ma_red equ 04h
ma_dred equ 39
ma_green equ 02h
ma_blue equ 01h
ma_row_end equ 0FFh
ma_sp_end equ 0FDh
ma_nopx equ 0FEh
ma_orange equ 41d
ma_mario_skin equ 66d
ma_donkey_skin equ 43
ma_mario_hair equ 6d
ma_yellow equ 44d
ma_pink equ 38d
ma_boots equ ma_mario_hair

; conditions
TRUE equ 0001h
FALSE equ 0000h
ON_BOUNDS_EDGE equ 0002h

RIGHT equ 00001h
LEFT equ 0000h
UP equ 0003h
DOWN equ 0002h

; animations
MARIO_STANDING equ 0000h
MARIO_RUNNING_1 equ 0001h
MARIO_RUNNING_2 equ 0002h
MARIO_RUNNING_3 equ 0003h

; KEY CODES - SCAN CODES
ESCKEY equ 1
DKEY_PRESSED equ 20h
DKEY_RELEASED equ 0A0h

AKEY_PRESSED equ 1Eh
AKEY_RELEASED equ 9Eh

WKEY_PRESSED equ 11h
WKEY_RELEASED equ 91h

SKEY_PRESSED equ 1Fh
SKEY_RELEASED equ 9Fh

XKEY_PRESSED equ 2Dh
XKEY_RELEASED equ 0ADh

SPACE_PRESSED equ 39h
SPACE_RELEASED equ 0B9h

TICKS_1SECOND equ 18 ; 1 second in ticks
JUMP_HEIGHT equ 8
; CONSTANTS ;
filename db 'test.bmp',0
filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsg db 'Error', 13, 10 ,'$'


constants db "Constants"
color_white dw 000Fh
color_green dw 000Ah
color_cyan dw 000Bh
color_red dw 0004h
color_lime dw 50
color_gray dw 8
color_bright_pink dw 37
color_pink dw 38d



pblock_length dw 10
half_pblock_length dw 5

; VARS ;
ladder_stepdist dw ?
ladder_final_stepdist dw 2
save_pixel_mechanism_enabled dw TRUE

; mario coords
mario_x dw ?
mario_y dw ?

mario_direction dw RIGHT
frame_num dw 0
is_flipped dw FALSE
is_grounded dw TRUE
is_climbing db FALSE
is_moving db FALSE
is_jumping db FALSE
can_jump db TRUE
has_x_been_released db TRUE

is_draw_barrel dw FALSE

jump_pixels_up dw 0
jump_pixels_down dw 0

; mario position points - most unused
mario_right_leg_x dw ?
mario_right_leg_y dw ?
mario_left_leg_x dw ?
mario_left_leg_y dw ?

mario_right_hand dw ?
mario_left_hand dw ?

respawn_count dw 3
gravity_enabled dw 1

; debug configuration
debug db 0
show_coords db 0

; list of y coords to check when colliding with ladder but on floor - so mario doesn't fall through - terminated with 0
floor_edges_list dw 169, 129, 130, 125, 126, 88, 84, 85, 0

;  STRINGS ;dddddd
kte_msg db "Press any key to exit...", 13, 10, '$'
msg1 db 'Start', '$'
msg2 db 'Stop', '$'

yes db 'Yes        $'
no db 'No  $'
underground_msg db 'Underground   $'
inair db 'In Air       $'

is_moving_msg db 'Is Moving: $'
can_jump_msg db 'Can Jump: $'
on_ground_msg db 'On Ground: $' 

gameover_msg db 'Game Over!', 13, 10, '$'
; barrels
barrel_x dw ?
barrel_y dw ?
barrel_direction dw RIGHT

jump_delay dw 4E20h

; SPRITES ;
s_princess \
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	   ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_row_end
	;2
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	   ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_row_end
	;3
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx,  \
	   ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_white, ma_white, ma_white, ma_white, ma_nopx, ma_row_end
	; 4
	db ma_nopx, \
	   ma_mario_skin, ma_mario_skin, ma_nopx, ma_nopx, ma_nopx, ma_mario_skin, ma_mario_skin, ma_white, ma_mario_skin, ma_white, ma_white, ma_black, ma_white, ma_white, ma_row_end
	;5
	db ma_nopx, ma_nopx, \
	   ma_mario_skin, ma_mario_skin, ma_nopx, ma_nopx, ma_nopx, ma_mario_skin, ma_mario_skin, ma_white, ma_white, ma_white, ma_white, ma_white, ma_nopx, ma_row_end
	; 6
	db ma_nopx, ma_nopx, ma_nopx,  \
		ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_white, ma_white, ma_white, ma_white, ma_white, ma_nopx, ma_nopx, ma_row_end
	; 7
	db ma_nopx, \
		ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_pink, ma_pink, ma_white, ma_white, ma_white,\
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	; 8
	db ma_nopx, ma_nopx, \
		ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_pink, ma_pink, ma_pink, ma_white, ma_white, ma_pink, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;9
	db ma_nopx, ma_mario_skin, ma_nopx, ma_mario_skin, ma_nopx, ma_nopx, ma_pink, ma_pink, ma_pink, ma_pink, ma_pink, ma_pink, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;10
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_pink, ma_pink, ma_pink, ma_pink, ma_pink, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;11
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	    ma_pink, ma_pink, ma_pink, ma_pink, ma_pink, ma_pink, ma_pink, ma_white, ma_white, ma_row_end
	;12
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_black, ma_black, ma_black, ma_pink, ma_pink, ma_pink, ma_white, ma_nopx, ma_row_end
	db ma_sp_end

smario_standing \
	db ma_nopx, ma_nopx, ma_nopx,  \ ; 3 empty
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



smario_running_frame_1 \
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end ;12 empty
	;2
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;3
	db ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_row_end
	; 4
	db ma_nopx, ma_nopx, \
		ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_black, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	; 5
	db ma_nopx, \
		ma_mario_hair, ma_mario_skin, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_black, ma_mario_skin, ma_mario_skin, ma_mario_skin, \
	   ma_nopx, ma_row_end
	; 6
	db ma_nopx, \
		ma_mario_hair, ma_mario_skin, ma_mario_hair, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_mario_skin, \
	   ma_row_end
	;7
	db ma_nopx, \
		ma_mario_hair, ma_mario_hair, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, \
	   ma_nopx, ma_row_end
	; 8
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_row_end
	; 9
	db ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_blue, ma_red, ma_nopx, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_row_end
	; 10
	db ma_nopx, ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_nopx, \
	   ma_row_end
	; 11
	db ma_mario_skin, ma_mario_skin, ma_blue, ma_red, ma_red, ma_red, ma_red, ma_red, ma_mario_skin, ma_mario_skin, ma_nopx, ma_nopx, ma_row_end
	; 12
	db ma_mario_skin, ma_nopx, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_nopx, ma_nopx, ma_nopx, \
		ma_row_end
	; 13
	db ma_boots, ma_boots, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_nopx, ma_nopx, ma_nopx, \
		ma_row_end
	; 14
	db ma_boots, ma_boots, ma_blue, ma_blue, ma_nopx, ma_blue, ma_blue, ma_blue, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_row_end
	; 15
	db ma_boots, ma_nopx, ma_nopx, ma_nopx, ma_boots, ma_boots, ma_boots, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_row_end
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_boots, ma_boots, ma_boots, ma_boots, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_row_end 
	db ma_sp_end


smario_running_frame_2 \
	db ma_nopx, ma_nopx, ma_nopx,  \ ; 3 empty
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
		ma_red, ma_red, ma_blue, ma_red, ma_red, ma_red,\
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;9
	db ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;10
	db ma_nopx, \
		ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_yellow, ma_blue, ma_blue, ma_yellow, \
	   ma_nopx, ma_nopx, ma_row_end
	;11
	db ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, \
	   ma_nopx, ma_nopx, ma_row_end
	;12
	db ma_nopx, \
		ma_blue, ma_red, ma_red, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_blue, ma_blue, ma_blue, \
	   ma_nopx, ma_nopx, ma_row_end
	;13
	db ma_nopx, ma_nopx, \
		ma_blue, ma_red, ma_mario_skin, ma_mario_skin, ma_blue, ma_blue, ma_blue, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;14
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_blue, ma_blue, ma_blue, ma_boots, ma_boots, ma_boots, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;15
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_boots, ma_boots, ma_boots, ma_boots, ma_boots, ma_boots, ma_boots, \
	   ma_nopx, ma_nopx, ma_row_end
	; 16
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_boots, ma_boots, ma_boots, ma_boots, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
		
	
	db ma_sp_end

smario_running_frame_3 \
	db ma_nopx, ma_nopx, ma_nopx,  \ ; 3 empty
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
	db ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_red, ma_red, \
		ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;9
	db ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_blue, ma_red, ma_red, ma_mario_skin, ma_mario_skin, ma_row_end
	; 10
	db ma_mario_skin, ma_mario_skin, ma_nopx, ma_red, ma_red, ma_blue, ma_yellow, ma_blue, ma_blue, ma_blue, ma_mario_skin, ma_mario_skin, ma_row_end
	;11
	db ma_nopx, ma_nopx, ma_nopx,\
		ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, \
	   ma_nopx, ma_boots, ma_row_end
	;12
	db ma_nopx, ma_nopx, \
		ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_boots, \
	   ma_row_end
	;13 
	db ma_nopx, \
		ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_boots, \
	   ma_row_end
	;14
	db ma_boots, ma_blue, ma_blue, ma_blue, ma_nopx, ma_nopx, ma_nopx, ma_blue, ma_blue, ma_blue, ma_blue, ma_boots, ma_row_end
	;15
	db ma_boots, ma_boots, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;16
	db ma_boots, ma_boots, ma_boots, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	db ma_sp_end

smario_climbing \
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;2
	db ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_row_end
	;3
	db ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_row_end
	;4
	db ma_nopx, ma_nopx, \
		ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, \
	   ma_nopx, ma_nopx, ma_row_end
	;5
	db ma_nopx, ma_nopx,\
		ma_mario_skin, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_row_end
	;6
	db ma_nopx, ma_nopx,\
		ma_mario_skin, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_row_end
	;7
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_mario_skin, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_hair, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	; 8
	db ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_row_end
	;9
	db ma_nopx, \
		ma_red, ma_red, ma_red, ma_blue, ma_red, ma_red, ma_blue, ma_red, ma_red, ma_red, \
	   ma_nopx, ma_row_end
	;10
	db ma_red, ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_blue, ma_blue, ma_red, ma_red, ma_red, ma_red, ma_row_end
	;11
	db ma_mario_skin, ma_mario_skin, ma_red, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_red, ma_mario_skin, ma_mario_skin, ma_row_end
	;12
	db ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_row_end
	;13
	db ma_mario_skin, ma_mario_skin, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_blue, ma_mario_skin, ma_mario_skin, ma_row_end
	;14
	db ma_nopx, ma_nopx, \
		ma_blue, ma_blue, ma_blue, \
	   ma_nopx, ma_nopx, \
		ma_blue, ma_blue, ma_blue, \
	   ma_nopx, ma_nopx, ma_row_end
	;15
	db ma_nopx, ma_boots, ma_boots, ma_boots, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_boots, ma_boots, ma_boots, ma_nopx, ma_row_end
	;16
	db ma_boots, ma_boots, ma_boots, ma_boots, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_boots, ma_boots, ma_boots, ma_boots, ma_row_end
	db ma_sp_end
sdonkey_kong \
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	   ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end 
	; 2
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \ 
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;3
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, 	ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;4
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;5
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_white, ma_white, ma_donkey_skin, ma_white, ma_white, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;6
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_white, ma_dred, ma_donkey_skin, ma_dred, ma_white, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin,\
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;7	
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	    ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;8
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_orange, \ 
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	; 9
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_orange, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin,ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_orange, ma_orange, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;10
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;11
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_orange, \
	   ma_nopx, ma_nopx, ma_row_end
	;12
	db ma_nopx, ma_nopx, \
		ma_orange, ma_dred, 	ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, \
	   ma_nopx, ma_row_end
	;13
	db ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_row_end
	;14
	db ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_row_end
	;15
	db ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_orange, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_orange, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_row_end
	;16
	db ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_orange, ma_orange, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_orange, ma_orange, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_row_end
	;17
	db ma_nopx, ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_dred, ma_dred, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_row_end
	;18
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_row_end
	;19
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;20
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;21
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_dred, ma_dred, ma_orange, ma_dred, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_dred, ma_orange, ma_dred, ma_dred, ma_orange, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;22
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_dred, ma_orange, ma_orange, ma_orange, ma_orange, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_orange, ma_orange, ma_orange, ma_orange, ma_dred, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;23
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	; 24
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_donkey_skin, ma_orange, ma_donkey_skin, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_donkey_skin, ma_orange, ma_donkey_skin, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	; 25
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_donkey_skin, ma_orange, ma_donkey_skin, ma_orange, ma_donkey_skin, ma_dred, ma_orange, ma_donkey_skin, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, \
	   ma_nopx, ma_nopx, ma_row_end
	; 26
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, ma_dred, ma_dred, ma_orange, ma_dred, ma_orange, ma_dred, ma_dred, ma_orange, ma_dred, ma_dred, ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange, \
	   ma_nopx, ma_nopx, ma_row_end
	; 27
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_orange, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	    ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_orange,  \
	   ma_nopx, ma_nopx, ma_row_end
	;28
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	    ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	;29
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	    ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, ma_dred, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	; 30
	db ma_nopx, ma_nopx, \
		ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_dred, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, \
	   ma_nopx, ma_row_end
	; 31
	db ma_nopx, \
		ma_donkey_skin, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	   	ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_dred, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_donkey_skin, ma_row_end
	; 32
	db ma_donkey_skin, ma_orange, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, \
		ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
	   ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_donkey_skin, ma_orange, ma_row_end 
	db ma_sp_end

sbarrel_front \
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	; 2
	db ma_nopx, \
		ma_blue, ma_red, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_red, ma_blue, \
	   ma_nopx, ma_row_end
	; 3
	db ma_red, ma_blue, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_blue, ma_red, ma_row_end
	; 4
	db ma_mario_skin, ma_blue, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_blue, ma_mario_skin, ma_row_end
	; 5
	db ma_red, ma_blue, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_blue, ma_red, ma_row_end
	; 6
	db ma_red, ma_blue, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_blue, ma_red, ma_row_end
	; 7 
	db ma_mario_skin, ma_blue, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_blue, ma_mario_skin, ma_row_end
	; 8 
	db ma_red, ma_blue, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_blue, ma_red, ma_row_end
	; 9 
	db ma_nopx, \
		ma_blue, ma_red, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_red, ma_blue, \
	   ma_nopx, ma_row_end
	; 10
	db ma_nopx, ma_nopx, ma_nopx, \
		ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, \
	   ma_nopx, ma_nopx, ma_nopx, ma_row_end
	db ma_sp_end
sbarrel_side \
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
	; 2
	db ma_nopx, ma_nopx, \
		ma_mario_skin, ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_mario_skin, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_row_end
	;3
	db ma_nopx, \
		ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_mario_skin, \
	   ma_nopx, ma_row_end
	; 4
	db ma_mario_skin, ma_red, ma_red, ma_blue, ma_blue, ma_red, ma_red, ma_blue, ma_red, ma_red, ma_red, ma_mario_skin, ma_row_end
	; 5
	db ma_mario_skin, ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_red, ma_red, ma_red, ma_red, ma_red, ma_mario_skin, ma_row_end
	; 6
	db ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_red, ma_red, ma_red, ma_red, ma_mario_skin, ma_row_end
	; 7
	db ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_red, ma_blue, ma_blue, ma_red, ma_red, ma_red, ma_mario_skin, ma_row_end
	;8
	db ma_nopx, \
		ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_red, ma_mario_skin, \
	   ma_nopx, ma_row_end
	; 9
	db ma_nopx, ma_nopx, \
		ma_mario_skin, ma_mario_skin, ma_red, ma_red, ma_red, ma_red, ma_mario_skin, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_row_end
	;l0
	db ma_nopx, ma_nopx, ma_nopx, ma_nopx, \
		ma_mario_skin, ma_mario_skin, ma_mario_skin, ma_mario_skin, \
	   ma_nopx, ma_nopx, ma_nopx, ma_nopx, ma_row_end
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
	
	
testsprite \
	db ma_white, ma_green, ma_row_end
	db ma_white, ma_green, ma_row_end
	db ma_white, ma_white, ma_row_end, ma_sp_end



saved_pixels_barrel_index dw 0
saved_pixels_index dw 0

last_sprite_saved_pixels_index dw 0
saved_pixels dd 2000 dup(0) ; double word arr - store pixel x y value and color
saved_pixels_barrel dd 2000 dup(0)

blank db "         $"
game_over dw FALSE
map_redraw_counter dw 0
CODESEG


;;;;; UTILITY FUNCTIONS ;;;;;
; print a 16bit integer on the screen from ax
proc PrintNumber           
	push ax
	push bx
	push cx
	push dx
    mov     bx,10          ;CONST
    xor     cx,cx          ;Reset counter
	; how does this work
a:
 	xor dx,dx          ;Setup for division DX:AX / BX
    idiv bx             ; -> AX is Quotient, Remainder DX=[0,9]
    push dx             ;(1) Save remainder for now
    inc  cx             ;One more digit
    test ax,ax          ;Is quotient zero?
    jnz  a  		;No, use as next dividend
b:
	pop  dx             ;(1)
    add  dl,"0"         ;Turn into character [0,9] -> ["0","9"]
    mov  ah,02h         ;DOS.DisplayCharacter
    int  21h            ; -> AL
    loop b

exit_pn:
	pop dx
	pop bx
	pop cx
	pop ax
	ret
endp

; print a string
; param 1: string offset
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



proc OpenFile
	; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
	openerror :
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	ret
endp OpenFile

proc ReadHeader
	; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
	endp ReadHeader
	proc ReadPalette
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette

proc CopyPal
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
	PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB .
	mov al,[si+2] ; Get red value .
	shr al,2 ; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
	out dx,al ; Send it .
	mov al,[si+1] ; Get green value .
	shr al,2
	out dx,al ; Send it .
	mov al,[si] ; Get blue value .
	shr al,2
	out dx,al ; Send it .
	add si,4 ; Point to next color .
	; (There is a null chr. after every color.)
	loop PalLoop
	ret
endp CopyPal
proc CopyBitmap
	; BMP graphics are saved upside-down .
	; Read the graphic line by line (200 lines in VGA format),
	; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,200
	PrintBMPLoop :
	push cx
	; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	; Read one line
	mov ah,3fh
	mov cx,320
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine
	
	rep movsb ; Copy line to the screen
	 ;rep movsb is same as the following code :
	 ;mov es:di, ds:si
	 ;inc si
	 ;inc di
	 ;dec cx
	;loop until cx=0
	pop cx
	loop PrintBMPLoop
	ret
endp CopyBitmap


; proc to wait for any key press
proc WaitKey
	push ax
	mov ah, 0h
	int 16h
	pop ax
	ret
endp

; set graphical mode
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

; bios delay function 
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

; utility function - returns TRUE if min <= x <= max
; ax - TRUE: In Range, ax - FALSE: Not in range 
; param 1 - number
; param 2 - min
; param 3 - max
proc IsInRange
	num equ [bp+8]
	min_bound equ [bp+6]
	max_bound equ [bp+4]

	push bp
	mov bp, sp
	push bx
	push cx
	push dx

	mov ax, FALSE
	mov bx, num
	
	cmp bx, min_bound
	jb _ret_is_in_range
	
	cmp bx, max_bound
	ja _ret_is_in_range

	mov ax, TRUE
	
_ret_is_in_range:
	pop dx
	pop cx
	pop bx
	pop bp
	
	ret 6
endp


; sets the cursor position
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

; param 1 - tick timestamp output - memory offset - where to put the timestamp
proc SetTickTimestamp
	tick_out_offset equ [bp+4]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx

	mov ah, 00h
    int 1Ah   
	mov bx, tick_out_offset
	mov [word ptr bx], dx

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp

; param 1 - last tick timestamp - int
; output: dx - current tick count
proc GetTickCountFromTimestamp
	initial_ticks equ [bp+4]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx

	mov ah, 00h
	int 1Ah
	sub dx, initial_ticks	

	pop cx
	pop bx
	pop ax
	pop bp
	ret 2

endp


;;;;; UTILIITY FUNCTIONS ;;;;;




;;;;; GRAPHICAL FUNCTIONS ;;;;;

; draw a horizontal line
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

; draw a vertical line
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

; draw a singular pixel
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

; save pixel in DS:saved_pixels 
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


_save_pixel:
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


	inc [saved_pixels_index] ; inc normal saved pixels
_ret_save_pixel:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
endp


; save pixel in DS:saved_pixels 
; param 1: pixel x value
; param 2: pixel y value
; param 3: pixel color
proc SaveBarrelPixel 

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

	lea si, [saved_pixels_barrel]
	mov ax, [saved_pixels_barrel_index]


_save_barrel_pixel:
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


	inc [saved_pixels_barrel_index] ; inc normal saved pixels
_ret_save_pixel_barrel:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
endp




; draw any sprite defined in DS
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
	
	cmp [is_draw_barrel], TRUE
	je _skip_save_last_sprite

	mov ax, [saved_pixels_index]
	mov [last_sprite_saved_pixels_index], ax
_skip_save_last_sprite:
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

	
	cmp [save_pixel_mechanism_enabled], TRUE
	jne _skip_save_pixel

	mov ah, 0Dh
	int 10h ; get pixel color
	cmp [is_draw_barrel], TRUE
	je save_pixel_barrel
	push cx
	push dx
	push ax
	call SavePixel
	jmp _skip_save_pixel
save_pixel_barrel:
	push cx
	push dx
	push ax
	call SaveBarrelPixel

_skip_save_pixel:
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

; draw a sprite - flipped
; param 1: sprite offset
; param 2: start X
; param 3: start Y
; param 4: sprite width - this is neccesary so the proc knows from where to start drawing
proc DrawFlippedSprite
	matrix_of equ [bp+10]
    startX equ [bp+8]
    startY equ [bp+6]
	sprite_width equ [bp+4]
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
	add cx, sprite_width
    mov dx, startY
    mov si, matrix_of
flipped_draw_loop:
    cmp [byte ptr si], ma_sp_end ; check for sprite end
    je flipped_draw_loop_end
    cmp [byte ptr si], ma_row_end ; check for row end
    je flipped_lrow_end
    cmp [byte ptr si], ma_nopx ; check for empty pixel
    je flipped_no_px

	cmp [save_pixel_mechanism_enabled], TRUE
	jne _flipped_skip_save_pixel
	; save pixel
	mov ah, 0Dh
	int 10h ; get pixel color
	push cx
	push dx
	push ax
	call SavePixel

_flipped_skip_save_pixel:
    push [word ptr si] ; draw pixel
    call DrawPixel
	
flipped_no_px:
    dec cx  
    inc si
    jmp flipped_draw_loop

flipped_lrow_end:
    mov cx, startX
	add cx, sprite_width
    inc dx
    inc si
    jmp flipped_draw_loop
flipped_draw_loop_end:

	pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp


    ret 8
endp

; proc to erase the last sprite drawn
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

;;;;; GRAPHICAL FUNCTIONS ;;;;;


;;;;; MAP ;;;;;

; draws a pink block of floor
; param 1 : startX
; param 2 : startY
; block = 10 x8
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

; draws a pink block N times
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

; procedure to draw a ladder
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

; draws the main map backdrop and ladders
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

	; second layer ladder right
	mov [ladder_final_stepdist], 3
	push 120 ; 7 blocks from left 20 x 7 = 140px
	push 115
	push 31
	push 5
	call DrawLadder
	
	; second layer ladder left
	mov [ladder_final_stepdist], 3
	push 40 ; three blocks from left 20 x 3 = 60px
	push 119
	push 23
	push 4
	call DrawLadder
	
	; third layer ladder right	
	push 240
	push 74
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

;;;;; MAP ;;;;;

;;;;; BARRELS ;;;;;

; Check pixel under barrel legs for ground color
; dx: 1 - on ground
; dx: 0 - in air
; dx: 2 - underground - used for elevate
proc BarrelGroundCheck
	push ax
	push bx
	push cx
	;barrel height 10
	mov dx, [barrel_y]
	add dx, 10
	mov cx, [barrel_x]
	
	mov ah, 0Dh ; check pix color
	int 10h
	mov dx, 0
	mov ah, 00
	cmp ax, [color_pink]
	je barrel_grounded
	
	cmp ax, [color_red]
	jne _ret_barrel_ground_check
	mov dx, 2
	jmp _ret_barrel_ground_check
barrel_grounded:
	mov dx, 1
_ret_barrel_ground_check:
	pop cx
	pop bx
	pop ax
	ret
endp

; apply instant gravity to barrel
proc BarrelGravity
	push ax
	push bx
	push cx
	push dx


apply_barrel_grav:
	call BarrelGroundCheck
	cmp dx, FALSE
	jne _ret_barrel_gravity
	inc [barrel_y]
	jmp apply_barrel_grav

_ret_barrel_gravity:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

proc SetBarrelDirection
	push ax
	push bx
	push cx
	push dx
	
	cmp [barrel_x], 304
	je dirleft
	cmp [barrel_x], 4
	je dirright
	jmp _ret_barrel_direction
	
dirleft:
	mov [barrel_direction], LEFT
	jmp _ret_barrel_direction
dirright:
	mov [barrel_direction], RIGHT
_ret_barrel_direction:
	pop dx
	pop cx
	pop bx
	pop ax

	ret
endp

proc BarrelHandler
	push ax
	push bx
	push cx
	push dx

	call SetBarrelDirection

move_barrel:
	cmp [barrel_direction], RIGHT
	jne move_barrel_left
	add [barrel_x], 3
	jmp barrel_gravity
move_barrel_left:
	sub [barrel_x], 3
barrel_gravity:
	call BARRELGROUNDCHECK
	mov ax, [barrel_x]
	
	call BarrelGravity

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

proc DrawBarrel
	push ax
	push bx
	push cx
	push dx
	mov [is_draw_barrel], TRUE
	push offset sbarrel_side
	push [barrel_x]
	push [barrel_y]
	call DrawSprite
	mov [is_draw_barrel], FALSE
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

proc EraseBarrel
	push ax
	push bx
	push cx
	push dx

	
	lea si, [saved_pixels_barrel]
	mov bx, [saved_pixels_barrel_index]

erase_barrel_loop:

	mov cx, [si] ; x
	add si, 2
	mov dx, [si] ; y
	add si, 2
	mov ah, 0
	mov al, [byte ptr si]

	; if not cyan or black
	; colliding with mario
	cmp ax, ma_blue
	je _colliding_with_barrel
	cmp ax, ma_mario_skin
	je _colliding_with_barrel
	cmp ax, ma_boots
	je _colliding_with_barrel
redraw:
	push ax ; color
	call DrawPixel
	inc si
	dec bx
	jnz erase_barrel_loop
	mov [saved_pixels_barrel_index], 0
	jmp _ret_erase_barrel
_colliding_with_barrel:

	dec [respawn_count]
	jnz _restart_game
_ret_erase_barrel:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

;;;;; BARRELS ;;;;;

;;;;; PLAYER/MARIO ;;;;;


; param flipped ? draw mario flipped or not
proc DrawMario
	flipped equ [bp+4]
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	mov [is_draw_barrel], FALSE
	cmp [frame_num], MARIO_RUNNING_1
	je _mario_running1
	cmp [frame_num], MARIO_RUNNING_2
	je _mario_running2
	cmp [frame_num], MARIO_RUNNING_3
	je _mario_running3
	
	; STANDING MARIO
	cmp flipped, TRUE
	je _mario_standing_flipped
	push offset smario_standing
	push [mario_x]
	push [mario_y]
	call DrawSprite 
	jmp _logic
_mario_standing_flipped:
	push offset smario_standing
	push [mario_x]
	push [mario_y]
	push 12
	call DrawFlippedSprite	
	jmp _logic

	; MARIO RUNNING F1
_mario_running1:
	cmp flipped, TRUE
	je _mario_running1_flipped
	push offset smario_running_frame_1
	push [mario_x]
	push [mario_y]
	call DrawSprite
	jmp _logic
_mario_running1_flipped:
	push offset smario_running_frame_1
	push [mario_x]
	push [mario_y]
	push 12 ; mario width
	call DrawFlippedSprite
	jmp _logic

	; MARIO RUNNING F2
_mario_running2:
	cmp flipped, TRUE
	je _mario_running2_flipped
	push offset smario_running_frame_2
	push [mario_x]
	push [mario_y]
	call DrawSprite
	jmp _logic
_mario_running2_flipped:
	push offset smario_running_frame_2
	push [mario_x]
	push [mario_y]
	push 12 ; mario width
	call DrawFlippedSprite
	jmp _logic

	; MARIO RUNNING F3
_mario_running3:
	cmp flipped, TRUE
	je _mario_running3_flipped
	push offset smario_running_frame_3
	push [mario_x]
	push [mario_y]
	call DrawSprite
	jmp _logic
_mario_running3_flipped:
	push offset smario_running_frame_3
	push [mario_x]
	push [mario_y]
	push 12 ; mario width
	call DrawFlippedSprite
_logic:
	cmp [debug], TRUE
	jne skip_debug
	mov cx, [mario_x]
	mov dx, [mario_y]
	push [color_red]
	call Drawpixel
skip_debug:

	mov ax, [mario_x]
	mov [mario_left_leg_x], ax
	add ax, 12
	mov [mario_right_leg_x], ax
	mov cx, [mario_right_leg_x]
	mov ax, [mario_y]
	add ax, 16
	mov [mario_right_leg_y], ax
	mov [mario_left_leg_y], ax

	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
endp


proc DrawMarioClimbing
	push ax
	push bx
	push cx
	push dx
	mov [is_draw_barrel], FALSE
	push offset smario_climbing
	push [mario_x]
	push [mario_y]
	call DrawSprite
	
	mov ax, [mario_x]
	mov [mario_left_leg_x], ax
	add ax, 12
	mov [mario_right_leg_x], ax
	mov ax, [mario_y]
	add ax, 16
	mov [mario_right_leg_y], ax
	mov [mario_left_leg_y], ax
	mov cx, [mario_x]
	mov dx, [mario_y]

	cmp [debug], TRUE
	jne skip_debug_climbing
	push [color_red]
	call Drawpixel
skip_debug_climbing:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp


; check if mario is colliding with x bounds of the map
; returns - dx - 1 for in bounds, 0 for out of bounds
proc CheckIsInBoundsX
	push ax
	push bx
	push cx
	mov dx, 1
	cmp [mario_direction], RIGHT
	jne left_in_bounds
	cmp [mario_right_leg_x], 320
	je out_bounds
	jmp _return_check_is_in_bounds
left_in_bounds:
	cmp [mario_left_leg_x], 0
	jne _return_check_is_in_bounds
out_bounds:
	mov dx, 0
_return_check_is_in_bounds:
	pop cx
	pop bx
	pop ax
	ret
endp

; checks if mario can climb up / down
; returns - dx = 1 for colliding, 0 for not, 2 for on edge of collision
proc CheckIsCollidingWithLadder
	push ax
	push bx
	push cx
	mov dx, 0
	
	; check if colliding with first layer ladder
	
	push [mario_x]
	push 268 ; min bound x collision with first layer ladder
	push 274 ; max bound x collision with first layer ladder
	call IsInRange

	cmp ax, TRUE
	jne check_secondlayer_ladder_right

	; check y range for first layer ladder
	push [mario_y]
	push 137
	push 169
	call IsInRange
	
	cmp ax, TRUE
	jne _return_check_is_colliding_with_ladder
	cmp [mario_y], 137 ; first layer ladder top
	je on_edge
	
	mov dx, 1
	jmp _return_check_is_colliding_with_ladder
	
	;

check_secondlayer_ladder_right:
	; check if colliding with second layer first ladder
	push [mario_x]
	push 118 ; min bound x collision with second layer ladder 1
	push 124 ; max bound x collision with second layer ladder 1
	call IsInRange

	cmp ax, TRUE
	jne check_secondlayer_ladder_left

	; check y range for second layer ladder right
	push [mario_y]
	push 90
	push 130
	call IsInRange 
	
	cmp ax, TRUE
	jne _return_check_is_colliding_with_ladder
	
	cmp [mario_y], 90
	je on_edge
	cmp [mario_y], 91
	je on_edge

	mov dx, 1
	jmp _return_check_is_colliding_with_ladder	

check_secondlayer_ladder_left:
	; check if colliding with second layer second ladder
	push [mario_x]
	push 40 ; min bound x collision with second layer ladder 2
	push 46 ; max bound x collision with second layer ladder 2
	call IsInRange 

	cmp ax, TRUE
	jne check_thirdlayer_broken_ladder
	
	; check y range for second ladder left
	push [mario_y]
	push 94
	push 126
	call IsInRange
	
	cmp ax, TRUE
	jne _return_check_is_colliding_with_ladder

	cmp [mario_y], 94
	je on_edge
	cmp [mario_y], 95
	je on_edge

	mov dx, 1
	jmp _return_check_is_colliding_with_ladder
check_thirdlayer_broken_ladder:
	; check if colliding with third layer broken ladder - bottom half
	push [mario_x]
	push 160
	push 166
	call IsInRange 
	
	cmp ax, TRUE
	jne check_thirdlayer_ladder_right

	; check y range for broken ladder
	push [mario_y]
	push 82
	push 89
	call IsInRange
	
	cmp ax, TRUE
	jne _return_check_is_colliding_with_ladder
	
	cmp [mario_y], 82
	je on_edge
	mov dx, 1
	jmp _return_check_is_colliding_with_ladder

check_thirdlayer_ladder_right:
	; check if collding with third layer ladder right
	push [mario_x]
	push 238
	push 244
	call ISINRANGE
	
	cmp ax, TRUE
	jne _return_check_is_colliding_with_ladder

	; check y range for third layer ladder right
	push [mario_y]
	push 50
	push 85
	call IsInRange 
	
	cmp ax, TRUE
	jne _return_check_is_colliding_with_ladder

	cmp [mario_y], 50
	je on_edge
	mov dx, 1
	jmp _return_check_is_colliding_with_ladder
on_edge:
	mov dx, 2
_return_check_is_colliding_with_ladder:
	pop cx
	pop bx
	pop ax
	ret
endp


;proc CheckCollidingWithBarrel
	;push ax
	;push bx
	;push cx
	;push si
	;
	;mov dx, 0
	;lea si, [saved_pixels_barrel]
	;mov bx, [saved_pixels_barrel_index]
	;add si, 3
	
;_saved_pixels_loop:
	;mov ax, [si]
	;mov al, ah
	;mov ah, 0
	;push 10
	;push 10
	;call SETCURSORPOSITION
	;call PrintNumber
	;push offset blank
	;call PrintString
	;cmp ax, ma_blue
	;je _colliding_with_barrel
	;cmp ax, ma_red
	;je _colliding_with_barrel
	;cmp ax, ma_mario_skin
	;je _colliding_with_barrel
	;cmp ax, ma_boots
	;je _colliding_with_barrel
	;dec bx
	;jnz _saved_pixels_loop
;
	;lea si, [saved_pixels]
	;mov bx, [saved_pixels_index]
	;add si, 3
;_saved_pixels_normal_loop:
	;mov ax, [si]
	;mov al, ah
	;mov ah, 0
	;push 10
	;push 11
	;call SETCURSORPOSITION
	;call PrintNumber
	;push offset blank
	;call PrintString
	;cmp ax, ma_blue
	;je _colliding_with_barrel
	;cmp ax, ma_red
	;je _colliding_with_barrel
	;cmp ax, ma_mario_skin
	;je _colliding_with_barrel
	;cmp ax, ma_boots
	;je _colliding_with_barrel
	;dec bx
	;jnz _saved_pixels_normal_loop
	;jmp _ret_check_colliding_with_barrel

;_colliding_with_barrel:
;	mov dx, 1
;_ret_check_colliding_with_barrel:
;	pop si
;	pop cx
;	pop bx
;	pop ax
;	ret
;endp

; Check pixel under mario's legs for ground color
; dx: 1 - on ground
; dx: 0 - in air
; dx: 2 - underground - used for elevate
proc GroundCheck
	push ax
	push bx
	push cx
	;mario height + 1
	mov dx, [mario_y]
	add dx, 16
	mov cx, [mario_x]
	

	mov ah, 0Dh ; check pix color
	int 10h
	mov dx, 0
	mov ah, 00
	cmp ax, [color_pink]
	je grounded
	
	cmp ax, [color_red]
	jne _ret_ground_check
	mov dx, 2
	jmp _ret_ground_check
grounded:
	mov dx, 1
_ret_ground_check:
	pop cx
	pop bx
	pop ax
	ret
endp

; apply instant gravity to mario
proc Gravity
	push ax
	push bx
	push cx
	push dx


apply_grav:
	call GroundCheck
	cmp dx, FALSE
	jne _ret_gravity
	inc [mario_y]
	jmp apply_grav

_ret_gravity:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp


proc JumpMario
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	mov [is_draw_barrel], FALSE
	cmp [can_jump], TRUE
	jne _ret_jump_mario
	mov [can_jump], FALSE
	mov cx, 10
	call DISPLAYCANJUMP
	call EraseBarrel
jump_loop_up:
	call DrawBarrel
	mov [is_jumping], TRUE
	dec [mario_y]
	push 00h
	push [jump_delay]
	call Delay 
	call EraseSprite

	mov [frame_num], 3
	push [is_flipped]
	call DrawMario

	loop jump_loop_up
	mov cx, 10
jump_loop_down:

	inc [mario_y]
	push 00h
	push [jump_delay]
	call Delay
	call EraseSprite
	mov [frame_num], 3
	push [is_flipped]
	call DrawMario
	;sub [jump_delay], 2000
	loop jump_loop_down
	mov [is_jumping], FALSE
	mov [can_jump], TRUE
_ret_jump_mario:
	mov [jump_delay], 4E20h
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

proc TryJump
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	cmp [is_jumping], TRUE
	jne _ret_try_jump
	; try move up 
	; check jump pixels up
	cmp [jump_pixels_up], JUMP_HEIGHT
	jb try_move_up
	; jump pixels up = 10, move down
	cmp [jump_pixels_down], JUMP_HEIGHT
	jb try_move_down
	
	; finished jump

	mov [can_jump], TRUE
	mov [is_jumping], FALSE
	mov [jump_pixels_up], 0
	mov [jump_pixels_down], 0
	mov [has_x_been_released], TRUE ; this essentially lets you bhop

	jmp _ret_try_jump
try_move_up:
	sub [mario_y], 2
	inc [jump_pixels_up]
	jmp _ret_try_jump
try_move_down:
	add [mario_y], 2
	inc [jump_pixels_down]
_ret_try_jump:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp


; mario elevation handler - checks whether to lift mario a pixel by checking if he is underground
proc SmartMarioElevationHandler
	push ax
	push bx
	push cx
	push dx
	push si

	call GroundCheck
	cmp dx, 2 ; underground
	je _elevate
	jmp _ret_mario_smart_elev
_elevate:
	dec [mario_y]
	
_ret_mario_smart_elev:

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

;;;;; PLAYER/MARIO ;;;;;;

;;;;; ON-SCREEN DEBUG ;;;;;

; display character ground check
proc DisplayOnGround
	push ax
	push bx
	push cx
	push dx
	
	push 3
	push 0
	call SETCURSORPOSITION
	push offset on_ground_msg
	call PrintString 
	call GroundCheck
	cmp dx, TRUE
	je display_yes
	cmp dx, 2h
	je display_underground
	push offset inair
	call PrintString
	jmp _ret_display_on_ground
display_yes:
	push offset yes
	call PrintString
	jmp _ret_display_on_ground
display_underground:
	push offset underground_msg
	call PrintString
_ret_display_on_ground:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp
; display character coordinates on screen
proc DisplayCharacterCoordinates
	push ax
	push bx
	push cx
	push dx
	
	push 0
	push 0
	call SetCursorPosition

	cmp [show_coords], TRUE
	jne _ret_display_coordinates
	mov ax, [mario_x]
	call PRINTNUMBER

	mov dl, ','
	mov ah, 2h
	int 21h

	mov dl, ' '
	mov ah, 2h
	int 21h

	mov ax, [mario_y]
	call PrintNumber

	push offset blank
	call PrintString
	mov dl, 13
	mov ah, 2h
	int 21h	

_ret_display_coordinates:
	pop dx
	pop bx
	pop cx
	pop ax
	ret	
endp

proc DisplayCanJump
	push ax
	push bx
	push cx
	push dx

	push 2
	push 0
	call SETCURSORPOSITION
	push offset can_jump_msg
	call PrintString 
	cmp [can_jump], TRUE
	jne display_cant_jump
	push offset yes 
	call PrintString
	jmp _ret_display_can_jump

display_cant_jump:
	push offset no
	call PrintString 

_ret_display_can_jump:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

proc DisplayIsMoving	
	push ax
	push bx
	push cx
	push dx

	push 1
	push 0
	call SetCursorPosition
	push offset is_moving_msg
	call PrintString
	cmp [is_moving], TRUE
	jne not_moving
	push offset yes
	call PrintString 
	jmp _ret_display_moving

not_moving:
	push offset no
	call PrintString

_ret_display_moving:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp

;;;;; ON-SCREEN DEBUG ;;;;;


proc GameLoop
	push ax
	push bx
	push cx
	push dx
	; gravity
wait_for_key:

	cmp debug, TRUE
	jne skip_print_debug
	call DisplayOnGround
	call DisplayCanJump
	call DisplayIsMoving
	mov [is_moving], FALSE
	; apply gravity and display player coordinates (or not)
	call DisplayCharacterCoordinates
skip_print_debug:
	mov [is_moving], FALSE
	cmp [gravity_enabled], FALSE
	je skip_grav
	call Gravity

skip_grav:

	call TryJump ; try to move mario if he is jumping
	call EraseBarrel ; erase barrel
	call DrawBarrel ; redraw barrel + after barrelx++
	
	push 00h
	push 6D60h
	call Delay ; 0.035 seconds

	call BarrelHandler
	cmp [is_jumping], TRUE ; if jumping
	jne not_jumping
	call EraseSprite ; redraw mario
	mov [frame_num], 3
	push [is_flipped]
	call DrawMario
	jmp skip_grav	

not_jumping:
	; get input
	in al, 64h
	cmp al, 10b
	je wait_for_key 
	in al, 60h
	; check for exit
	cmp al, ESCKEY ; esc
	je exit

	; check for input
	cmp al, DKEY_PRESSED ; d
	mov [mario_direction], RIGHT
	je move_mario

	cmp al, AKEY_PRESSED ; a
	mov [mario_direction], LEFT
	je move_mario

	cmp al, WKEY_PRESSED ; w up
	mov [mario_direction], UP
	je move_mario

	cmp al, SKEY_PRESSED 
	mov [mario_direction], DOWN
	je move_mario

	cmp al, SPACE_RELEASED
	je x_released

	cmp al, SPACE_PRESSED
	je jump_mario

	jmp wait_for_key
x_released:
	mov [has_x_been_released], TRUE
	jmp _after_move
move_mario:
	; check if in bounds
	; check direction
	; move mario by direction
	call CheckIsInBoundsX
	cmp dx, TRUE
	jne _after_move ; not in bounds


	; check for elevation
	call SmartMarioElevationHandler



	; check for ladder collision
	call CheckIsCollidingWithLadder


	call EraseSprite

	; move mario
	cmp [mario_direction], LEFT ; left
	je move_mario_left

	cmp [mario_direction], UP ; up 
	je move_mario_up

	cmp [mario_direction], DOWN ; down
	je move_mario_down

	call GroundCheck
	cmp dx, FALSE
	je _draw_climbing_mario
	; by default, enable gravity - unless not on ground
	mov [gravity_enabled], TRUE
	mov [is_flipped], FALSE ; rightt
	add [mario_x], 2
	mov [is_moving], TRUE
	jmp _draw
	
; move maior directions
move_mario_down:

	; by default, enable gravity - unless not on ground
	mov [gravity_enabled], TRUE
	cmp dx, FALSE ; check if colliding with ladder
	ja cont_mario_move_down ; MARIO COLLIDING
	mov [can_jump], TRUE
	jmp _draw_climbing_mario

cont_mario_move_down:
	; MARIO IS COLLLIDING WITH LADDER
	; LADDER GROUND CHECKS - PREVENT MARIO FROM GOING THROUGH THE FLOOR
	mov [can_jump], FALSE
	lea si, [floor_edges_list]
ladder_ground_checks:
	mov ax, [si]
	cmp ax, 0
	je ladder_ground_checks_complete
	cmp ax, [mario_y]
	je _draw_climbing_mario
	inc si
	jmp ladder_ground_checks
	
ladder_ground_checks_complete:
	mov [gravity_enabled], FALSE
	add [mario_y], 2
	mov [is_moving], TRUE
	jmp _draw_climbing_mario

; move mario up
move_mario_up:

	; by default, enable gravity - unless not on ground
	mov [gravity_enabled], TRUE
	cmp dx, FALSE ; check if colliding with ladder
	je _draw_climbing_mario ; MARIO NOT COLLIDING
	mov [can_jump], FALSE
	cmp dx, ON_BOUNDS_EDGE
	je _draw_climbing_mario
	mov [gravity_enabled], FALSE
	sub [mario_y], 2
	mov [is_moving], TRUE
	jmp _draw_climbing_mario

move_mario_left:
	call GroundCheck
	cmp dx, FALSE
	je _draw_climbing_mario
	; by default, enable gravity - unless not on ground
	mov [gravity_enabled], TRUE
	mov [is_flipped], TRUE
	sub [mario_x], 2
	mov [is_moving], TRUE
	jmp _draw
jump_mario:
	cmp [has_x_been_released], TRUE
	jne _after_move
	mov [has_x_been_released], FALSE
	; call JumpMario
	mov [is_jumping], TRUE
	jmp _after_move
_draw:
	cmp [frame_num], 3
	jne _skip_reset
	mov [frame_num], 0
_skip_reset:
	push [is_flipped]
	call DrawMario
	inc [frame_num]
	jmp _after_move
_draw_climbing_mario:
	mov [can_jump], TRUE
	call DrawMarioClimbing
_after_move:

	cmp debug, TRUE
	jne wait_for_key
	call DisplayIsMoving
	jmp wait_for_key

game_is_over:
	mov ax, [mario_x]
	mov [barrel_x], ax
	jmp wait_for_key
	;push 1	
	;call SetMode
	;push offset gameover_msg
	;call PrintString
	;call WaitKey
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

	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap

	mov ah,1
	int 21h
	push 0h
	call SETMODE
_restart_game:
	push 1h
	call SetMode
	
	mov [save_pixel_mechanism_enabled], FALSE
	push offset sdonkey_kong
	push 6
	push 32
	call DrawSprite

	mov [save_pixel_mechanism_enabled], TRUE

	call DrawMap	
	mov [mario_x], 14
	mov [mario_y], 174
	call DrawMario

	mov [barrel_x], 16
	mov [barrel_y], 10
	call DrawBarrel
	mov [barrel_direction], RIGHT
	

	lea si, [saved_pixels] ; just so i know where they are in memory for debugging
	lea di, [saved_pixels_barrel]


	call GameLoop

exit:
	push 0h
	call SetMode
	
	mov ax, 4c00h
	int 21h
END start