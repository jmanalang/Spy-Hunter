	AREA interrupts, CODE, READWRITE
	EXPORT lab7
	EXPORT FIQ_Handler
	EXPORT pin_connect_block_setup_for_uart0
	EXTERN digit_SET
	EXTERN color_SET
	EXPORT board
	EXTERN read_character
	EXTERN output_character
	EXTERN read_string
	EXTERN output_string
	EXTERN uart_init
	EXTERN game_state_toggle0
	EXTERN game_state_toggle1
	EXTERN seed_generator
	EXTERN match_change1
	EXTERN linear_congruential
	EXTERN horizontal_coordinate
	EXTERN xy_coordinate
	EXTERN uart0_state_off
	EXTERN uart0_state_on
	EXTERN bullet_search
	EXTERN character_search
	EXTERN quotient
	EXTERN user_respawn
	EXTERN health_LED
	EXTERN RGB_LED
	EXTERN display_digit
	EXTERN display_zero
	EXTERN start_GPIO
	EXTERN life_count
	EXTERN off_road_check
	EXTERN clean_arm
	EXTERN board_wipe
	EXTERN score_update
	EXPORT score_view
	EXPORT score_template
	EXTERN timer_0
	EXTERN disable_timer_0
	EXTERN arm_init
	EXTERN timer_1
		
current_life = "0",0
	DCB 0x00
	ALIGN

timer1_counter = "",0
	DCB 0x00
	ALIGN

game_ender = "1",0
	DCB 0x00
	ALIGN
		
board = "@@@@@@@@@@@@@@@@@@@@@@@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | | | | | | | W@\r\n@W | | | |©| | | | | W@\r\n@@@@@@@@@@@@@@@@@@@@@@@\r\n",0	
	DCB 0x00
	ALIGN

score_view = "Score:0000\r\n",0
	DCB 0x00
	ALIGN

score_template = "0000\r\n",0
	DCB 0x00
	ALIGN
		
score_code = "",0
	DCB 0x00
	ALIGN
		
prompt = "\f                WELCOME TO \r\n\r\n            SSS   PPPP   Y   Y \r\n           S   S  P   P  Y   Y \r\n           S      P   P   YYY \r\n            SSS   PPPP     Y \r\n               S  P        Y \r\n           S   S  P        Y \r\n            SSS   P        Y \r\n\r\n  H   H  U    U  N   N  TTTTT  EEEE  RRRR \r\n  H   H  U    U  N   N    T    E     R   R \r\n  H   H  U    U  NN  N    T    EEEE  R   R \r\n  HHHHH  U    U  N N N    T    E     RRRR \r\n  H   H  U    U  N  NN    T    E     R   R \r\n  H   H   UUUU   N   N    T    EEEE  R   R \r\n\r\n\r\n   PRESS ANY LOWER OR UPPER CASE ALPHA KEY \r\n                 TO CONTINUE \r\n============================================= \r\nEdward Park        2014        Jules Manalang \r\n============================================= \r\n", 0
	DCB 0x00
	ALIGN

instructions = "\f0==================HOW TO PLAY====================0\r\n      Start with 4 lives : Displayed by LEDS       \r\n   Level Up every 500 points : Faster Every Level\r\n\r\nW/S/A/D to move your car     P to fire forward gun\r\n         Q to quit the game at anytime\r\n   Press The Push Button To Pause While In Game\r\n0=========Avoid Getting hit by enemy cars=========0\r\n\r\nV - Van                              2 hits to kill\r\n\r\nM - Motor cycle                       1 hit to kill\r\n\r\nS - Semi-truck                       3 hits to kill\r\n\r\nB - Bulletproof                         Cannot Kill\r\n\r\n0=====================The Road====================0\r\n\r\n|             Road Line - Decorative\r\n\r\nW             Off-Road - Lose a life if you get on\r\n\r\n@             Walls - Game Boundary\r\n\r\n*             Bullet - Kills Enemies\r\n\r\n                PLEASE PRESS 0,1,2,3\r\n                 TO START THE GAME\r\n\r\n\r\nAuthors' notes - The Start of the game is slow.\r\nThere is low spawn probabilty at the start.\r\nPlease be patient.\r\nThe higher the level - The more spawns are likely.",0
	DCB 0x00
	ALIGN 

current_match = "018432000",0
	DCB 0x00
	ALIGN
		
pause = "GAME PAUSED\r\n",0
	DCB 0x00
	ALIGN
		
defeat = "GAME OVER - Play Again?\r\ny - YES\r\nn - NO",0
	DCB 0x00
	ALIGN
		
exiting = "\r\nThanks for playing! Bye!\r\n Report any Bugs to epark4@buffalo.edu or julesman@buffalo.edu",0
	DCB 0x00
	ALIGN
		
formfeed = "\f",0
	DCB 0x00
	ALIGN

; we use storage seed as an array to hold five pieces of data for four independent probability sequences: 
; 0. initial probability respawner
; 1. Vehicle type
; 2. horizontal coordinate location
; 3. bulletproof size
storage_seed = "0000",0
	DCB 0x00
	ALIGN
		
vehicle_traits = "",0
	DCB 0x00
	ALIGN
		
spawn_point = "",0
	DCB 0x00
	ALIGN

spawn_stack = "000000000",0				; reserves 6 data values 
	DCB 0x00
	ALIGN
		
counter_library = "",0
	DCB 0x00
	ALIGN

probability_spawner = "0",0
	DCB 0x00 
	ALIGN

uart_lock_key = "",0					; holds up to 8 data values 
	DCB 0x00
	ALIGN
		
		
;*******************************************************************************************************************************
; The main subroutine of lab7, primarily going through the life span of the program
;
lab7	 	
	STMFD sp!, {lr}

main_menu
	BL off_road_check
	LDR r1, =current_life
	MOV r2, #0
	STRB r2, [r1]
	BL board_wipe						; clears the board
	BL start_GPIO						; sets directions of gpio
	BL display_zero						; display level zero on seven segment display 
	MOV r10, #0
	BL RGB_LED							; set RGB to white for main menu state
	BL health_LED						; display four lit up LEDs
	LDR r1, =game_ender					; load the base address of game ender flag
	LDRB r2, [r1]						; load the byte
	MOV r2, #0							; copy a zero
	STRB r2, [r1] 						; store a zero into base address to indicate game play
	LDR r1, =current_match				; load base address of current match register 1 value
	LDR r0, =18432000					; load the word value
	STR r0, [r1]						; store it
	LDR r1, =timer1_counter				; load the base address of the timer counter for later use
	MOV r0, #0							; copy a zero
	STRB r0, [r1]						; store the zero in memory location for the timer	
	LDR r1, =uart_lock_key				; load base address
	STRB r0, [r1]						; store zero in the uart lock key model functions as a semaphore
	LDR r1, =score_template				; load base address of score template
	STRB r0, [r1]						; ensure thousands place has zero
	STRB r0, [r1, #1]					; ensure hundreds place has zero
	STRB r0, [r1, #2]					; ensure tens place has zero
	STRB r0, [r1, #3]					; ensure ones place has zero
			
	LDR r1, =spawn_stack				; set everything in the pseudo-array to empty (stack is size three conceptually)
	MOV r0, #0
	STRB r0, [r1], #1					; location set to zero
	STRB r0, [r1], #1					; vehicle size set to zero	
	STRB r0, [r1], #1					; location set to zero
	STRB r0, [r1], #1					; vehicle size set to zero	
	STRB r0, [r1], #1					; vehicle size set to zero	
	STRB r0, [r1], #1					; vehicle size set to zero	
	STRB r0, [r1], #1					; vehicle size set to zero
	STRB r0, [r1], #1					; location set to zero
	STRB r0, [r1]						; vehicle size set to zero
	LDR r1, =probability_spawner		; load base address of probability value
	MOV r0, #4							; 4 is the base probability for level zero during game play for 5% initial probability
	STRB r0, [r1]						; store it
	MOV r7, #0							; ensure score count starts off as zero
	BL timer_0							; intialize timer0 for use in initial enemy spawn
	
options
	LDR r4, =prompt						; use r4 as the "message display register"
	BL output_string					; print it
	BL read_character					; get user input
	CMP r0, #0x41						; is it an A?
	BLT input_exception_main_menu		; if it is not an alpha-character, exception
	CMP r0, #0x5A 						; is it a Z?
	BLE reserve_future_seed_uppercase
	CMP r0, #0x61						; is it an a?
	BLT input_exception_main_menu		; if it is not an alpha-character, exception
	CMP r0, #0x7A						; is it a z?
	BLE reserve_future_seed_uppercase
	
input_exception_main_menu	
	B options							; loop to main menu

;******************************************************************************************************************************************************************
reserve_future_seed_uppercase
	BL disable_timer_0					; disable timer0 upon getting a user key hit
	LDR r1, =storage_seed				; load a storage string unit
	CMP r0, #0x5A						; is the character uppercase? Z or less than? 
	BGT reserve_future_seed_lowercase	; if it is, get value from 0 to 26 decimal
	SUB r0, r0, #65						; get a value from 0 to 25
	STRB r0, [r1]						; store the seed for later use
	B seed_procure

reserve_future_seed_lowercase
	SUB r0, r0, #43						; to have proper inputs for linear congruential, subtract r0 to have less than modulo value
	STRB r0, [r1]						; store the user input into memory for later access of steady probability
	
seed_procure
	LDR r2, =storage_seed
	STRB r3, [r2]						; store the stopped timer value into array position 0 to use for enemy respawns
	STRB r0, [r2, #2] 					; store the user's input into array position 2 for determinning future horizontal lane for respawns
	BL seed_generator					; stops the timer and gets the TC value (Seed)
										; r3 has the seed value 
		
intructions_regulation
	LDR r4, =instructions				; base address of the question
	BL output_string					; outputs string
	BL read_character					; read user's input
	MOV r5, #0							; r5 set to zero for counter use
	CMP r0, #0x30						; is user input a 0?
	BEQ set_to_30						; set lower boundary offset zero
	CMP r0, #0x31						; is user input a 1?
	BEQ set_to_31						; set lower boundary offset to 19
	CMP r0, #0x32						; is user input a 2?
	BEQ set_to_32						; set lower boundary offset to 39
	CMP r0, #0x33 						; is user input a 3?
	BEQ set_to_33						; set lower boundary offset to 59
	BNE input_exception_instructions	; return back to waiting for user pressing 0, 1, 2, or 3

input_exception_instructions
	B intructions_regulation
	
; area A
set_to_30								; lower boundary of random sequence is zero
	MOV r4, #0							; offset upper boundary of random sequence
	LDR r2, =storage_seed				; base address of storage_seed
	MOV r3, #19							; store 19 as initial seed
	STRB r3, [r2, #1]					; store the stopped timer value into array position 1 to use for vehicle types
	B linear_congruential_nth_position

; area B
set_to_31								; lower boundary of random sequence is 19
	MOV r4, #19							; offset upper boundary of random sequence
	LDR r2, =storage_seed				; base address of storage_seed
	MOV r3, #39							; store 39 as initial seed
	STRB r3, [r2, #1]					; store the stopped timer value into array position 1 to use for vehicle types
	B linear_congruential_nth_position

; area C
set_to_32								; lower boundary of random sequence is 39
	MOV r4, #39							; offset upper boundary of random sequence
	LDR r2, =storage_seed				; base address of storage_seed
	MOV r3, #59							; store 59 as initial seed
	STRB r3, [r2, #1]					; store the stopped timer value into array position 1 to use for vehicle types
	B linear_congruential_nth_position

; area D
set_to_33								; lower boundary of random sequence is zero
	MOV r4, #59							; offset upper boundary of random sequence
	LDR r2, =storage_seed				; base address of storage_seed
	MOV r3, #78							; store 78 as initial seed
	STRB r3, [r2, #1]					; store the stopped timer value into array position 1 to use for vehicle types
	B linear_congruential_nth_position
	
linear_congruential_nth_position
	BL linear_congruential				; ascertain random value, can be called indefinitely if we want
	ADD r5, r5, #1						; increment the lower boundary
	CMP r5, r4							; compare if lower boundary (counter) matches the upper boundary
	BLT linear_congruential_nth_position	; loop back if counter is less than upper
; the random value is stored in r3
; r3 now becomes the initial seed of the random sequence

randomizations
	LDR r1, =counter_library			; load the counter library 
	MOV r0, #0							; have a total vehicle counter start with 0
	STRB r0, [r1]						; store the initial value of zero of the counter into memory 
	
vehicle_type
	BL linear_congruential				; find a random value to use
	LDR r1, =vehicle_traits				; load the base address of the vehicle roster
	CMP r3, #19							; is the value 19 or less than?
	BLE	semi							; it is a semi vehicle
	CMP r3, #39							; is the value 39 or less than but greater than 19?
	BLE	bulletproof						; it is a bulletproof
	CMP r3, #59							; is the value 59 or less than but greater than 39?
	BLE	van								; it is a van
	CMP r3, #79							; is the value 79 or less than but greater than 59?
	BLE motorcycle						; it is a motorcycle

motorcycle
	MOV r0, #0x4D						; copy symbol M to temporary register
	STRB r0, [r1]						; store it into vehicle roster
	MOV r0, #1							; copy 1 for vehicle size
	STRB r0, [r1, #1]					; store it into vehicle roster
	BL horizontal_coordinate
	BL xy_coordinate
	B memory_location
	
van
	MOV r0, #0x56						; copy symbol V to temporary register
	STRB r0, [r1]						; store it into vehicle roster
	MOV r0, #2							; copy 2 for vehicle size
	STRB r0, [r1, #1]					; store it into vehicle roster
	BL horizontal_coordinate			; x axis value
	BL xy_coordinate					; obtain memory address location
	B memory_location					; branch to memory location label
	
semi
	MOV r0, #0x53						; copy symbol S to temporary register
	STRB r0, [r1]						; store it into vehicle roster
	MOV r0, #3							; copy 3 for vehicle size
	STRB r0, [r1, #1]					; store it into vehicle roster
	BL horizontal_coordinate			; x axis value
	BL xy_coordinate					; obtain memory address location
	B memory_location					; branch to memory location label
	
bulletproof
	MOV r0, #0x42						; copy symbol B to temporary register
	STRB r0, [r1]						; store it into vehicle roster
	BL linear_congruential				; generate another random number
	CMP r3, #25							; is it equal or less than 25
	BLE bullet1							; bulletproof is size 1
	CMP r3, #51							; is it equal or less than 51
	BLE bullet2							; bulletproof is size 2
	CMP r3, #79							; is it equal or less than 79
	BLE bullet3							; bulletproof is size 3

bullet1									; r7 had bullet vehicle size
	LDR r1, =vehicle_traits				; load base address
	MOV r0, #1							; copy a one
	STRB r0, [r1, #1]					; vehicle size roster indicates one
	BL horizontal_coordinate			; x axis value
	BL xy_coordinate					; obtain memory address location
	B memory_location					; branch to memory location label
	
bullet2
	LDR r1, =vehicle_traits				; load base address 
	MOV r0, #2							; copy a two
	STRB r0, [r1, #1]					; vehicle size roster indicates two
	BL horizontal_coordinate			; x axis value
	BL xy_coordinate					; obtain memory address location
	B memory_location					; branch to memory location label
	
bullet3
	LDR r1, =vehicle_traits				; load base address
	MOV r0, #3							; copy a three
	STRB r0, [r1, #1]					; vehicle size roster indicates three
	BL horizontal_coordinate			; x axis value
	BL xy_coordinate					; obtain memory address location

memory_location
	LDR r1, =vehicle_traits				; load base address 
	LDRB r4, [r1, #1]					; r4 holds the current vehicle size
	LDR r1, =board						; load base addres of the board
	ADD r1, r1, r2						; find the spawn coordinate point of the board in memory				*******SPAWN POINT*********
	LDR r0, =spawn_point				; this will save the spawnpoint after the register alters it
	STR r1, [r0]						; save the spawn value
	
occupied_checker						; check if vehicle is already in those locations
	LDRB r0, [r1], #25					; obtain character from memory location
	CMP r0, #0x20						; compare if it is a space
	BNE horizontal_again				; if it is not a space, conduct probability again since it is occupied subroutine is called by recursion
	CMP r0, #0x40						; check if it is the bottom wall
	BEQ horizontal_again				; generate new value
	CMP r0, #0xA9						; is it the user car?
	BEQ horizontal_again				; generate new value
	CMP r0, #0x4D						; is it a motorcycle?
	BEQ horizontal_again				; generate new value
	CMP r0, #0x56						; is it a van?
	BEQ horizontal_again				; generate a new value
	CMP r0, #0x42						; is it a bulletproof?
	BEQ horizontal_again				; generate a new value
	CMP r0, #0x53						; is it a semi?
	BEQ horizontal_again				; generate a new value
	SUB r4, r4, #1						; decrement
	CMP r4, #0							; size is the limit for the check to ensure proper vehicle spawns					
	BGT occupied_checker				; loop back to check the spaces
	B restore_offset					; restore offsets for future use
	
horizontal_again						; regenerate new spawn location
	BL horizontal_coordinate			; x axis value
	BL xy_coordinate					; obtain memory address location
	B memory_location					; branch to memory location label
	
restore_offset							; this undos the checking iteration 
	LDR r0, =spawn_point				; load spawn location
	SWP r1, r1, [r0]					; since r1 has changed, we want the original spawn point instead that was not offsetted	
	LDR r0, =vehicle_traits				; load roster
	LDRB r2, [r0, #1]					; vehicle size
	LDRB r4, [r0] 						; restored
	
spawn_vehicle			
	STRB r4, [r1], #25					; spawn the vehicle character
	SUB r2, r2, #1						; decrement size to indicate one unit spawn occurred
	CMP r2, #0							; check if roster says zero
	BGT spawn_vehicle					; if its greater than, spawn another extension of current enemy vehicle
	
vehicle_count
	LDR r1, =counter_library			; load base address
	LDRB r2, [r1]						; load the vehicle counter
	ADD r2, r2, #1						; increment to signify that enemy spawned on the board
	CMP r2, #5		 					; if there are less than five enemies on the board
	STRB r2, [r1]						; store the counter in memory for later use
	BLT vehicle_type					; loop all the way back to generate and determine the next characteristics of enemy vehicle 
	
;********************************************************************************
; Note that timer0 now functions as a steady rate for the enemy spawn rate 
; the match register will still remain the same to function as the primary modulo

	LDR r4, =formfeed
	BL output_string
	LDR r4, =score_view					; load score view
	BL output_string					; print to indicate initial score zero of game
	LDR r4, =board						; the program will start
	BL output_string					; print it
	BL arm_init							; initialize necessary serial ports and uart
	BL timer_1							; set and eanble timer
		
survival_loop							; Game Phase
	LDR r7, =game_ender					; load base address 
	LDRB r7, [r7]						; load the byte it holds
	CMP r7, #1							; check if it is a one
	BNE survival_loop					; if it is still zero, game still progresses

game_over
	LDR r4, =defeat						; Print an exiting message
	BL output_string					; print it
	MOV r10, #12						; RGB turns red to indicate end game phase
	BL RGB_LED							; update RGB LED
	BL clean_arm						; dusable FIQ and UART RDA interrupt
	
game_over_loop
	BL read_character					; get user input		
	CMP r0, #0x6E						; is it a n?		
	BEQ game_over_exit					; quit game
	CMP r0, #0x79						; is it a y?		
	BEQ game_over_new_game				; start a new game
	B game_over_loop					; ignore invalid keys

game_over_new_game
	B main_menu							; go back to main menu and start the game

game_over_exit
	BL clean_arm						; ensure interrupts and uart are disabled for exiting program
	LDR r4, =exiting					; Print an exiting message
	BL output_string					; print it
	LDMFD sp!, {lr}
	BX lr

;*******************************************************************************************************************************
; This is where the action takes place!
;
FIQ_Handler
	STMFD SP!, {r0-r2, r4-r6, r8-r10, r12, lr} 	; Save registers 

EINT1	; Check for EINT1 interrupt
	
	LDR r0, =0xE01FC140					; load external interrupt flag register					<<<<< check button interrupt
	LDRB r1, [r0]						; load byte it
	TST	r1, #0x2						; if the bit is set, we detect button interrupt
	BNE button_handler					; if bit is set, we branch to button interrupts	
	
	LDR r0, =0xE0008000					; load base address to detect pending interrupt			<<<<< check timer interrupt
	LDRB r1, [r0]						; load byte it
	TST r1, #0x2						; if bit is set we detect timer interrupt
	BNE timer_handler					; if bit 1 is set, branch there	
	
	LDR r0, =0xE000C000					; load base address into r0 the routine	 				<<<<< check uart interrupt
	LDRB r1, [r0, #0x8]					; load the byte of the uart0
	TST r1, #0x01						; if there is a zero in bit0, we detect uart interrupt
	BEQ uart_interrupt					; if bit is not set, we branch to the uart interrupts
	B end_interrupt
	
button_handler
	MOV r10, #8							; move offset of 8
	BL RGB_LED							; turn RGB LED to blue to indicate game pause phase
	BL game_state_toggle1				; stop timer1 to stop the game from running, game resumes when button is pushed again, RGB turns back to green
	LDR r4, =pause
	BL output_string
	B end_interrupt						; end FIQ handler
;******************************************************************************************************************************************************************************************
timer_handler
	BL game_state_toggle1				; stop timer to make adjustments to the board	
	BL off_road_check					; check off road for user car

remove_top_bullets
	LDR r1, =board						; base address of the board
	MOV r0, #46							; offset of the end of the board
	ADD r2, r1, #26						; address of the right side W on the top level of board
	ADD r0, r0, r1						; address of the last probable place on board	

remove_the_bullets
	SUB r0, r0, #1
	LDRB r5, [r0]
	CMP r0, r2							; if we reached the end of board we leave
	BEQ bullet_check_entering_top_level ; completed
	CMP r5, #0x2A						; is the current character a bullet?
	BNE remove_the_bullets

bullet_removal
	MOV r5, #0x20						; copy the space
	STRB r5, [r0]						; store the space where the bullet was previously located
	B remove_the_bullets

bullet_check_entering_top_level
	LDR r1, =board						; base address of the board
	MOV r0, #71							; offset of the end of the board
	ADD r2, r1, #51						; address of the right side W on the top level of board
	ADD r0, r0, r1						; address of the last probable place on board
	LDR r4, =spawn_stack	

	LDRB r6, [r4]				; load the offset position in array 
	ADD r7, r6, r1				; add the offset to get the memory position of interest from the array				
	LDRB r6, [r4, #3]				; load the offset position
	ADD r8, r6, r1				; add the offset to get the memory position of interest from the array
	LDRB r6, [r4, #6]				; load the offset position
	ADD r10, r6, r1				; add the offset to get the memory position of interest from the array
								; invalid data will only hold base address of board
								
entering_top_level_bullet_check
	SUB r0, r0, #1
	LDRB r5, [r0]
	CMP r0, r2							; if we reached the end of board we leave
	BEQ bullet_mover					; completed
	CMP r5, #0x2A						; is the current character a bullet?
	BNE entering_top_level_bullet_check

confirm_bullet_traversal
	SUB r3, r0, #25						; subtract current location to get top level
	CMP r3, r7 							; does top level match one of the array values?
	BEQ array_bullet1
	CMP r3, r8
	BEQ array_bullet2
	CMP r3, r10
	BEQ array_bullet3
	LDRB r5, [r0, #-25]					; get the character that is above the bullet
	CMP r5, #0x20
	BEQ normal_bullet_traversal
	CMP r5, #0x4D						; is it a motorcycle?
	BEQ normal_bullet_hit				; if it is not, continue searching
	CMP r5, #0x56						; is it a van?
	BEQ normal_bullet_hit				; if it is not, continue searching
	CMP r5, #0x42						; is it a bulletproof?
	BEQ bulletproof_defeats_bullet		; if it is not, continue searching
	CMP r5, #0x53						; is it a semi?
	BEQ normal_bullet_hit				; if it is not, continue searching	
	B entering_top_level_bullet_check

bulletproof_defeats_bullet
	MOV r5, #0x20						; copy a space
	STRB r5, [r0]						; store a space where bullet used to be
	B entering_top_level_bullet_check	; loop back to check more bullets
	
normal_bullet_hit						; destroys an enemy vehicle excluding bulletproof. Grants user scoring
	LDRB r3, [r0, #-50]					; load byte of vehicle behind bullet, two levels away
	CMP r3, r5							; compare if that character matches the one right in front of bullet
	MOV r5, #0x20						; copy a space
	STRB r5, [r0]						; store the space where the bullet is gone from collision
	STRB r5, [r0, #-25]					; store the space where the enemy vehicle is gone due to collision
	BEQ scoring_50						; if the character matches, then grant 50 points for hitting enemy with bullet
	B scoring_75							; if character behind is different, assume we destroyed the whole unit to grant 50 plus 25 points
	
scoring_50
	MOV r7, #50							; copy a 50
	BL score_update						; update score
	B entering_top_level_bullet_check	; loop back to find more bullets
	
scoring_75					
	MOV r7, #75							; copy a 75
	BL score_update						; update score
	B entering_top_level_bullet_check

normal_bullet_traversal
	MOV r5, #0x20						; copy a space
	STRB r5, [r0]						; store the space where the bullet used to be		
	MOV r5, #0x2A						; copy a bullet
	STRB r5, [r0, #-25]					; store the bullet in its new location going upwards on board
	B entering_top_level_bullet_check				; loop back to check more bullets

array_bullet1
	MOV r9, #1
	B array_bulletx

array_bullet2
	MOV r9, #4
	B array_bulletx

array_bullet3
	MOV r9, #7

array_bulletx
	LDRB r5, [r0, #-25]
	CMP r5, #0x20
	BEQ normal_bullet_traversal
	CMP r5, #0x42
	BEQ bulletproof_defeats_bullet
	LDRB r6, [r4, r9]			; load the vehicle size 
	MOV r5, #0x20
	STRB r5, [r0]
	STRB r5, [r0, #-25]
	CMP r6, #0					; if size is zero
	BNE scoring_50
	B scoring_75

bullet_mover							; iterate through ascending memory order
	LDR r1, =board						; base address of the board
	LDR r0, =420						; offset of the end of the board
	ADD r2, r1, #71						; address of the first white space on board
	ADD r0, r0, r1						; address of the last probable place on board
	; r0 last space position base+420
	; r2 first space position base+26

timer_bullet_search						; search from ascending memory order
	LDRB r1, [r2], #1					; load the character from the board, increment memory location afterwards
	CMP r2, r0							; compare if we reached the end of board traversal
	BEQ continue_timer1
	CMP r1, #0x2A						; compare if bullet is in that location
	BNE timer_bullet_search				; if it is not a bullet, find more on board
	B bullet_collision_check			; a bullet is found
	; r1 holds the bullet character from board
bullet_collision_check					; we found bullet, now determine collision
	SUB r2, r2, #1						; restore the offset location due to postfix autofixing
	LDRB r4, [r2, #-25]					; check the next level going upward on board since bullet will be going there
	CMP r4, #0x4D						; is next character a motorcycle?
	BEQ bullet_enemy_handle				; handle bullet motorcycle collision
	CMP r4, #0x56						; is next character a van?
	BEQ bullet_enemy_handle				; handle van bullet collision
	CMP r4, #0x53						; is next character a semi? 
	BEQ bullet_enemy_handle				; handle semi bullet collision
	CMP r4, #0x42						; is next character a bulletproof?
	BEQ bullet_bulletproof_handle		; handle bulletproof bullet collision
	CMP r4, #0x20						; is next character a space
	BEQ bullet_mover_continue 			; traverse bullet
; r5 holds next character of obstruction
; r4 holds the current enemy vehicle 
; r1 holds the bullet
bullet_enemy_handle						; destroys an enemy vehicle excluding bulletproof. Grants user scoring
	LDRB r5, [r2, #-50]					; load byte of vehicle behind bullet, two levels away
	CMP r5, r4							; compare if that character matches the one right in front of bullet
	MOV r5, #0x20						; copy a space
	STRB r5, [r2]						; store the space where the bullet is gone from collision
	STRB r5, [r2, #-25]					; store the space where the enemy vehicle is gone due to collision
	BEQ scoring50						; if the character matches, then grant 50 points for hitting enemy with bullet
	B scoring75							; if character behind is different, assume we destroyed the whole unit to grant 50 plus 25 points
	
scoring50
	MOV r7, #50							; copy a 50
	BL score_update						; update score
	B timer_bullet_search				; loop back to find more bullets
	
scoring75					
	MOV r7, #75							; copy a 75
	BL score_update						; update score
	B timer_bullet_search				; loop back to find more bullets

;*****************************************************************************************************************************************************************************************
; this handles the condition when the bullet hits the bulletproof, the vehicle does not get destroyed user does not get any points for hitting
;
bullet_bulletproof_handle				; bullet does not destroy bulletproofs, grant points for hitting?
	MOV r5, #0x20						; copy a space
	STRB r5, [r2]						; store a space where bullet used to be
	B timer_bullet_search				; loop back to check more bullets

; if there are no obstructions in front of bullet, bullet traverses normally on the board
bullet_mover_continue					; bullet travels upward on the board normally
										; r1 is the bullet location 
										; branch to check the collision of any obstructions
	MOV r5, #0x20						; copy a space
	STRB r5, [r2]						; store the space where the bullet used to be		
	MOV r5, #0x2A						; copy a bullet
	STRB r5, [r2, #-25]					; store the bullet in its new location going upwards on board
	B timer_bullet_search				; loop back to check more bullets

;******************************************************************************************************************************************************************************************	
; end of bullet_handling
continue_timer1						; every 1 clock cycle, bullet moves. Every two clock cycles, bullet and all vehicles move
	LDR r1, =timer1_counter			; load base address of timer clock couner
	LDRB r0, [r1]					; load value of counter
	ADD r0, r0, #1					; increment it
	STRB r0, [r1]					; save the counter for later use
	CMP r0, #2						; did the counter reach 2 yet?
	BEQ enemy_mover 				; if it did, all vehicles should move and display is refreshed (note display refresh rate is same as bullet travel)
	B end_timer_handler				; we end the timer interrupt
	
;******************************************************************************************************************************************************************************************
; this is the second clock cycle where all characters on board moves synchronously 
;
enemy_mover		
	LDR r1, =board					; base address of the board
	LDR r0, =420					; offset of the end of the board
	ADD r2, r1, #45					; address of the right side W on the top level of board
	ADD r0, r0, r1					; address of the last probable place on board
									; r0 last space position 401 
									; r2 second level up 46
timer_enemy_search					; search from descending memory order
	LDRB r1, [r0], #-1				; load the character from the board, decrement location afterwards
	CMP r0, r2						; compare if we reach the first white space position of the board, we conclude there are no more enemy vehicles
	BEQ array_top_check		 		; assume that we have traversed through the board
	CMP r1, #0x4D					; is it a motorcycle?
	BEQ enemy_collision_check		; if it is not, continue searching
	CMP r1, #0x56					; is it a van?
	BEQ enemy_collision_check		; if it is not, continue searching
	CMP r1, #0x42					; is it a bulletproof?
	BEQ enemy_collision_check		; if it is not, continue searching
	CMP r1, #0x53					; is it a semi?
	BEQ enemy_collision_check		; if it is not, continue searching
	B timer_enemy_search

;******************************************************************************************************************************************************************************************
; set the pseudo-array as higher priority. after it checks the array, check the level. Exclude the new ones already put there
; the array that we made holds the vehciles that are spawned from the top of our board
; 
array_top_check
	LDR r1, =board				; base address of the board
	MOV r0, #45					; offset of the end of the board
	ADD r2, r1, #26				; address of the right side W on the top level of board
	ADD r0, r0, r1				; address of the last probable place on board
	LDR r4, =spawn_stack

	LDRB r6, [r4]				; load the offset position in array 
	ADD r7, r6, r1				; add the offset to get the memory position of interest from the array				
	LDRB r6, [r4, #3]				; load the offset position
	ADD r8, r6, r1				; add the offset to get the memory position of interest from the array
	LDRB r6, [r4, #6]				; load the offset position
	ADD r10, r6, r1				; add the offset to get the memory position of interest from the array
								; invalid data will only hold base address of board
	
level_array_checker
	LDRB r5, [r0]				; load current character of the board in the top level of board
	CMP r0, r7 					; comfirm if the value is in the array
	BEQ array_1					; value matches array position 1
	CMP r0, r8					; confirm if the value is in the array
	BEQ array_2					; value matches array position 2
	CMP r0, r10					;  confirm if the value is in the array
	BEQ array_3					; value matches array position 3
	
	CMP r0, r2					; if we reached the end of board we leave
	BEQ probability_spawn		; completed
	CMP r5, #0x4D				; is it a motorcycle?
	BEQ enemy_collision_final	; if it is not, continue searching
	CMP r5, #0x56				; is it a van?
	BEQ enemy_collision_final	; if it is not, continue searching
	CMP r5, #0x42				; is it a bulletproof?
	BEQ enemy_collision_final	; if it is not, continue searching
	CMP r5, #0x53				; is it a semi?
	BEQ enemy_collision_final	; if it is not, continue searching	
	SUB r0, r0, #1				; decrement to traverse the board
	B level_array_checker		; loop back to find more enemies

enemy_collision_final
	SUB r4, r4, #6
	LDRB r9, [r0, #25]			; check if enemy vehicle not in array collides something
	CMP r9, #0x20				; is it a space?
	BEQ enemy_mover_continue1	; if it is it will travel downward normally
	CMP r9, #0xA9				; user car
	BEQ enemy_user_handle1		; if it is it will indicate user collision 

; r5 holds user car or space
; r1 holds current enemy vehicle
; r0 current location of the bullet before moving upward 
enemy_mover_continue1			; automatic enemy traversal
	STRB r5, [r0, #25]				; store new unit enemy vehicle used to be
	MOV r5, #0x20
	STRB r5, [r0]			; store the enemy vehicle one space down
	SUB r0, r0, #1
	B level_array_checker

; user collides and respawns at an initial location, one led turns off and checks current health
enemy_user_handle1				; user loses one health for collision and respawns at initial position
	STRB r5, [r0, #25]			; enemy vehicle will traverse downward and ignore user car
	MOV r5, #0x20				; copy a space
	STRB r5, [r0]				; store the space where the vehicle used to be
	LDR r9, =current_life  		; load base address of the life count
	LDRB r11, [r9]				; load the byte of current life
	ADD r11, r11, #1			; increment death count
	STRB r11, [r9]				; store it for future reference
	BL health_LED				; turn off one of the 4 leds
	CMP r11, #4					; compare if all of the leds are off
	BEQ game_over_restore		; game over phase
	BL user_respawn				; user is respawned in original location from the game
	SUB r0, r0, #1				; decrement the count for board traversal
	B level_array_checker		; loop back to find more

array_1
	MOV r3, #0					; provide the proper array offset for position 1
	B array_x					

array_2
	MOV r3, #3					; provide the proper array offset for position 1
	B array_x

array_3
	MOV r3, #6					; provide the proper array offset for position 1
	B array_x

array_x
	LDR r4, =spawn_stack
	ADD r3, r3, #2
	LDRB r6, [r4, r3]			; load the vehicle type to print out from array
	CMP r6, r5					; see if current character in board equals the one in array
	BNE continue_array_x	
	STRB r6, [r0]				; store the vehicle character in the next level down
	STRB r6, [r0, #25]			; if it is equal, we extend the vehicle!
	B really_arrayx				; decrement array vehicle size
	
continue_array_x 				;we assume character on board in that location is not the same if we jumped to here
	CMP r5, #0xA9				; specifically, is character on board a user?
	BEQ	array_collisionx		; collision occurs
	CMP r5, #0x2A				; is there a bullet already there?
	BEQ arraybulletx			
	STRB r6, [r0]				; we assume that the location holds a space,so vehicle can spawn there
	B really_arrayx				; decrement array vehicle size
	
array_collisionx
	MOV r6, #0x20				; have a space there
	STRB r6, [r0]				; store the space in the board
	LDR r9, =current_life  		; load base address of the life count
	LDRB r11, [r9]				; load the current death count
	ADD r11, r11, #1			; death count incremented by 1 due to collision
	STRB r11, [r9]				; store it for future reference
	BL health_LED				; turn off one of the leds
	CMP r11, #4					; compare if leds are all off
	BEQ game_over_restore		; enter game over phase
	BL user_respawn				; respawn user at an initial location of the board
	B really_arrayx				
	
arraybulletx
	CMP r6, #0x42					; is the vehicle about to spawn a bulletproof?				
	BEQ arrayxbullet				; bullet does not destroy bulletproofs so we replace bullet
	SUB r3, r3, #1				   ; decrement offset for vehicle size
	LDRB r6, [r4, r3]				; we assume what we have is a vulnerable enemy vehicle
	ADD r3, r3, #1
	CMP r6, #1						; is the size 1? indicative of size being zero soon
	BEQ array_x_75
	MOV r7, #50					; score incremented by 50 by copying 50 to r7
	BL score_update				; update the score by 50
	MOV r6, #0x20
	STRB r6, [r0]			; store space in that top current level
	B really_arrayx
	
array_x_75
	MOV r7, #75
	BL score_update			; score incremented by 75
	MOV r2, #0x20
	STRB r2, [r0]			; store spacce in that top current level
	B really_arrayx

arrayxbullet
	STRB r6, [r0]			; overwrite bullet with a bulletproof
	
really_arrayx
	SUB r0, r0, #1				; decrement the current board location for the traversal
	SUB r3, r3, #1				; decrement array offset
	LDRB r6, [r4, r3]			; load the vehicle size 
	SUB r6, r6, #1				; decrement the vehicle size
	STRB r6, [r4, r3]
	CMP r6, #0					; if size is zero
	BNE level_array_checker
	MOV r6, #0					; make arary available to use for future respawns 
	SUB r3, r3, #1				; decrement proper offset of the array access to store the zero
	STRB r6, [r4, r3]				; make the position invalid corrseponding to the array
	B level_array_checker		; loop back

;******************************************************************************************************************************************************************************************
enemy_collision_check
	ADD r0, r0, #1				; restore the offset memory location of the vehicle
	LDRB r5, [r0, #25]			; check the next level going downward on board
	CMP r5, #0x20				; is it a space?
	BEQ enemy_mover_continue	; if it is it will travel downward normally
	CMP r5, #0xA9				; user car
	BEQ enemy_user_handle		; if it is it will indicate user collision
	CMP r5, #0x40				; wall
	BEQ enemy_wall_handle		; if it is it will front user points and disappear 
	CMP r5, #0x2A				; is the character a bullet?
	BEQ bullet_enemy_handle_it
								; r5 holds user car, bullet, or space
								; r1 holds current enemy vehicle main
								; r0 current location of the bullet before moving upward 
; check if bullet kills enemy if not bullet proof and grant points
bullet_enemy_handle_it
	CMP r1, #0x42
	BEQ bullet_to_bullet	  	; bulletproof does not go away, no points awarded
	LDRB r4, [r0, #-25]			; load the value behind the vehicle
	CMP r4, r1					; compare if character behind vehicle is the same
	BEQ regular_score			; if character behind 
; assume that the enemy vehicle behind is not the same, we would destroy the whole unit
	MOV r6, #0x20
	STRB r6, [r0]			  	; destory the bullet
	STRB r6, [r0, #25]		   	; destory the vehicle that encountered the bullet
	MOV r7, #75					; grant 75 points for user for killing whole unit
	BL score_update
	B timer_enemy_search		; loop back to find more

regular_score
	MOV r6, #0x20				; move a space
	STRB r6, [r0]				; store space at enemy location
	STRB r6, [r0, #25]			; remove bullet
	MOV r7, #50				   	; grant user 50 points
	BL score_update				
	B timer_enemy_search		; loop back

bullet_to_bullet
	MOV r6, #0x20
	STRB r6, [r0, #25]			; remove bullet
	B timer_enemy_search		; loop back
		
enemy_mover_continue			; automatic enemy traversal
	STRB r5, [r0]				; store the space where the enemy vehicle used to be
	STRB r1, [r0, #25]			; store the enemy vehicle one space down
	B timer_enemy_search

; by perspective of the enemy traversing, if it hits user car, user sustains damage and loses a life indicated from LED
enemy_user_handle				; user loses one health for collision and respawns at initial position
	STRB r1, [r0, #25]			; bulletproof will traverse downward and ignore user car
	MOV r5, #0x20				; copy a space
	STRB r5, [r0]
	LDR r9, =current_life	   ; load base address of the current health total of user
	LDRB r11, [r9]
	ADD r11, r11, #1		   ; increment the led accordingly for the health lose
	STRB r11, [r9]
	BL health_LED
	CMP r11, #4				   ; if r11 holds r11
	BEQ game_over_restore	   ; if all health is gone, game over
	BL user_respawn				; user is respawned in original location from the game
	B timer_enemy_search	   ; loop back

enemy_wall_handle
	MOV r5, #0x20				; copy a space
	STRB r5, [r0]				; store the space where the vehicle is
	BL wall_scoring				; administer scoring
	B timer_enemy_search

wall_scoring
	LDRB r5, [r0, #-25]			; check the character that is above the vehicle when it collides with the south wall
	CMP r5, r1					; is the character the same as the one below it?
	BEQ	timer_enemy_search		; if it is do not award the additional 10 points
	MOV r7, #10					; the enemy car that reaches the bottom border, will grant user ten points
	BL score_update
	B timer_enemy_search		; branch off to find more enemy cars

;******************************************************************************************************************************************************************************************
probability_spawn				; the probability that enemy will spawn
	; the branch and link will take the generated seed from 
	; before linear congruential swap the value somehow and then determine the value for spawning, remove any skewness in generateing vehicles*********************************
	LDR r2, =storage_seed		; load base address of the storage seed
	LDRB  r3, [r2]				; load the current seed from position zero of our array to use in our subroutine
	BL linear_congruential		; r3 holds a value between 0 and 79 inclusively
	STRB r3, [r2]				; store the Xn+1 seed generated for future use
	LDR r1, =probability_spawner ; load base address of the probability boundary base address
	LDRB r1, [r1]				; load the probability value 
	CMP r3, r1					; address of board plus offset of the lane	
	BLE spawn_permission	
	B continue_timer_cycle2
	
spawn_permission				; no worries about other enemy vehicles since all of them on board have already moved by this point, top level guarantee empty spaces
	LDR r2, = storage_seed		; load base address of the storage seed
	LDRB r3, [r2, #1]			; load the current seed from position one of our array to use in our subroutine
	BL linear_congruential		; find a random value to use
	STRB r3, [r2, #1]			; store the Xn+1 seed generated for future use
	CMP r3, #19					; is the value 19 or less than?
	BLE semi_spawner			; it is a semi vehicle
	CMP r3, #39					; is the value 39 or less than but greater than 19?
	BLE	bulletproof_spawner		; it is a bulletproof
	CMP r3, #59					; is the value 59 or less than but greater than 39?
	BLE	van_spawner				; it is a van
	CMP r3, #79					; is the value 79 or less than but greater than 59?
	BLE motorcycle_spawner		; it is a motorcycle

motorcycle_spawner
	LDR r4, = storage_seed		; load base address of the storage seed
	LDRB r3, [r4, #2]			; load the current seed from position two of our array to use in our subroutine
	BL horizontal_coordinate	; r2 holds the offsetted location
	STRB r3, [r4, #2]			; store the Xn+1 seed generated for future use
	LDR r0, =board				; load base address of the board
	ADD r2, r0, r2				; add the base address and the offset to get the horizontal location
	LDRB r5, [r2]				; load the character from that memory location
	CMP r5, #0x20				; check if it is a space character
	BNE	motorcycle_spawner		; if it is not a space, cannot spawn there, try probability again
	; check for an available stack position to occupy
	; at any occurrence of time the stack will accomodate any vehicle at any spawn times due to first level accomodations theory
	
	; do not use r2
	LDRB r4, [r2, #25]		  	; load byte
	CMP r4, #0x4D			   	; compare M
	BEQ motorcycle_spawner		; loop back
	LDR r1, =spawn_stack		; load base address of the stack to store some data
	
m_stack_position_finder
	MOV r4, #0x4D				; copy an M
	STRB r4, [r2]				; store that into the new memory location of the board
	B continue_timer_cycle2		; branch to add data in memory

van_spawner
	LDR r4, = storage_seed		; load base address of the storage seed
	LDRB r3, [r4, #2]			; load the current seed from position two of our array to use in our subroutine
	BL horizontal_coordinate	; r2 holds the offsetted location
	STRB r3, [r4, #2]			; store the Xn+1 seed generated for future use
	LDR r0, =board				; load base address of the board
	ADD r2, r0, r2				; add the base address and the offset to get the horizontal location
	LDRB r5, [r2]				; load the character from that memory location
	CMP r5, #0x20				; check if it is a space character
	BNE	van_spawner		; if it is not a space, cannot spawn there, try probability again
	; check for an available stack position to occupy
	; at any occurrence of time the stack will accomodate any vehicle at any spawn times due to first level accomodations theory
	LDRB r4, [r2, #25]			; load byte
	CMP r4, #0x56			   	; compare if that character is V
	BEQ van_spawner			   	; loop back
	LDR r1, =spawn_stack		; load base address of the stack to store some data
	
v_stack_position_finder
	LDRB r6, [r1], #3			; load the data of the position info. increment the array to next array position 
	CMP r6, #0					; is the position a zero
	BNE v_stack_position_finder	; find the next position
	SUB r1, r1, #3				; restore the array offset
	MOV r4, #0x56				; copy an V
	STRB r4, [r2]				; store that into the new memory location of the board
	STRB r4, [r1, #2]			; store the vehicle type into memory array
	SUB r2, r2, r0				; vehicle mem location minus board base address
	STRB r2, [r1]				; store the position of the spawn location in the even numbered position in stack
	MOV r2, #1					; copy a zero for indicating future spawns for the extension entity of van
	STRB r2, [r1, #1]			; store the zero in the odd numbered position in stack
	B continue_timer_cycle2				; branch to add data in memory

semi_spawner
	LDR r4, = storage_seed		; load base address of the storage seed
	LDRB r3, [r4, #2]			; load the current seed from position two of our array to use in our subroutine
	BL horizontal_coordinate	; r2 holds the offsetted location
	STRB r3, [r4, #2]			; store the Xn+1 seed generated for future use
	LDR r0, =board				; load base address of the board
	ADD r2, r0, r2				; add the base address and the offset to get the horizontal location
	LDRB r5, [r2]				; load the character from that memory location
	CMP r5, #0x20				; check if it is a space character
	BNE	semi_spawner		; if it is not a space, cannot spawn there, try probability again
	; check for an available stack position to occupy
	; at any occurrence of time the stack will accomodate any vehicle at any spawn times due to first level accomodations theory
	LDRB r4, [r2, #25]			; load byte
	CMP r4, #0x53			   	; compare if it is S
	BEQ semi_spawner		   	; loop back
	LDR r1, =spawn_stack		; load base address of the stack to store some data
	
s_stack_position_finder
	LDRB r6, [r1], #3			; load the data of the position info. increment the array to next array position 
	CMP r6, #0					; is the position a zero
	BNE s_stack_position_finder	; find the next position
	SUB r1, r1, #3				; restore the array offset
	MOV r4, #0x53				; copy an S
	STRB r4, [r2]				; store that into the new memory location of the board
	STRB r4, [r1, #2]			; store the vehicle type into memory array
	SUB r2, r2, r0				; vehicle mem location minus board base address
	STRB r2, [r1]				; store the position of the spawn location in the even numbered position in stack
	MOV r2, #2					; copy a zero for indicating future spawns for the extension entity of semi
	STRB r2, [r1, #1]			; store the zero in the odd numbered position in stack
	B continue_timer_cycle2				; branch to add data in memory

bulletproof_spawner
	LDR r4, = storage_seed		; load base address of the storage seed
	LDRB r3, [r4, #3]			; load the current seed from position three of our array to use in our subroutine
	BL linear_congruential		; r2 holds the offsetted location
	STRB r3, [r4, #3]			; store the Xn+1 seed generated for future use
	CMP r3, #25				   ; is it 25
	BLE bullet1_handle		   ; branch there
	CMP r3, #51				   ; is it 51
	BLE bullet2_handle		   ; branch there
	CMP r3, #79				   ;is it 79
	BLE bullet3_handle		   ; branch there

bullet1_handle	
	LDR r4, = storage_seed		; load base address of the storage seed
	LDRB r3, [r4, #2]			; load the current seed from position two of our array to use in our subroutine
	BL horizontal_coordinate	; r2 holds the offsetted location
	STRB r3, [r4, #2]			; store the Xn+1 seed generated for future use
	LDR r0, =board				; load base address of the board
	ADD r2, r0, r2				; add the base address and the offset to get the horizontal location
	LDRB r5, [r2]				; load the character from that memory location
	CMP r5, #0x20				; check if it is a space character
	BNE	bullet1_handle			; if it is not a space, cannot spawn there, try probability again
	; check for an available stack position to occupy
	; at any occurrence of time the stack will accomodate any vehicle at any spawn times due to first level accomodations theory
	LDR r1, =spawn_stack		; load base address of the stack to store some data
	
b1_stack_position_finder
	SUB r1, r1, #2				; restore the stack offset
	MOV r4, #0x42				; copy a B
	STRB r4, [r2]				; store that into the new memory location of the board
	B continue_timer_cycle2				; branch to add data in memory
	
bullet2_handle	
	LDR r4, = storage_seed		; load base address of the storage seed
	LDRB r3, [r4, #2]			; load the current seed from position two of our array to use in our subroutine
	BL horizontal_coordinate	; r2 holds the offsetted location
	STRB r3, [r4, #2]			; store the Xn+1 seed generated for future use
	LDR r0, =board				; load base address of the board
	ADD r2, r0, r2				; add the base address and the offset to get the horizontal location
	LDRB r5, [r2]				; load the character from that memory location
	CMP r5, #0x20				; check if it is a space character
	BNE	bullet2_handle			; if it is not a space, cannot spawn there, try probability again
	; check for an available stack position to occupy
	; at any occurrence of time the stack will accomodate any vehicle at any spawn times due to first level accomodations theory
	LDRB r4, [r2, #25]		   	; load byte
	CMP r4, #0x42			   	; compare if it is B
	BEQ bullet2_handle		   	; loop back
	LDR r1, =spawn_stack		; load base address of the stack to store some data
	
b2_stack_position_finder
	LDRB r6, [r1], #3			; load the data of the position info. increment the array to next array position 
	CMP r6, #0					; is the position a zero
	BNE b2_stack_position_finder	; find the next position
	SUB r1, r1, #3				; restore the array offset
	MOV r4, #0x42				; copy an B
	STRB r4, [r2]				; store that into the new memory location of the board
	STRB r4, [r1, #2]			; store the vehicle type into memory array
	SUB r2, r2, r0				; vehicle mem location minus board base address
	STRB r2, [r1]				; store the position of the spawn location in the even numbered position in stack
	MOV r2, #1					; copy a zero for indicating future spawns for the extension entity of bulletproof
	STRB r2, [r1, #1]			; store the zero in the odd numbered position in stack
	B continue_timer_cycle2				; branch to add data in memory

bullet3_handle		
	LDR r4, = storage_seed		; load base address of the storage seed
	LDRB r3, [r4, #2]			; load the current seed from position two of our array to use in our subroutine
	BL horizontal_coordinate	; r2 holds the offsetted location
	STRB r3, [r4, #2]			; store the Xn+1 seed generated for future use
	LDR r0, =board				; load base address of the board
	ADD r2, r0, r2				; add the base address and the offset to get the horizontal location
	LDRB r5, [r2]				; load the character from that memory location
	CMP r5, #0x20				; check if it is a space character
	BNE	bullet3_handle			; if it is not a space, cannot spawn there, try probability again
	; check for an available stack position to occupy
	; at any occurrence of time the stack will accomodate any vehicle at any spawn times due to first level accomodations theory
	LDRB r4, [r2, #25]			; load byte
	CMP r4, #0x42			   	; is it a B
	BEQ bullet3_handle		   	; lop back
	LDR r1, =spawn_stack		; load base address of the stack to store some data
	
b3_stack_position_finder
	LDRB r6, [r1], #3			; load the data of the position info. increment the array to next array position 
	CMP r6, #0					; is the position a zero
	BNE b3_stack_position_finder	; find the next position
	SUB r1, r1, #3				; restore the array offset
	MOV r4, #0x42				; copy an B
	STRB r4, [r2]				; store that into the new memory location of the board
	STRB r4, [r1, #2]			; store the vehicle type into memory array
	SUB r2, r2, r0				; vehicle mem location minus board base address
	STRB r2, [r1]				; store the position of the spawn location in the even numbered position in stack
	MOV r2, #2					; copy a zero for indicating future spawns for the extension entity of bulletproof
	STRB r2, [r1, #1]			; store the zero in the odd numbered position in stack
	B continue_timer_cycle2				; branch to add data in memory

continue_timer_cycle2			; every 1 clock cycle, bullet moves. Every two clock cycles, bullet and all vehicles move
	LDR r1, =timer1_counter		; load base address of timer clock couner
	LDRB r0, [r1]				; load value of counter
	SUB r0, r0, #2				; increment it
	STRB r0, [r1]				; save the counter for later use

end_timer_handler
; check if the user levels up!!!
	LDR r1, =score_template

; this traverses the score template to get the user's value from ones digit to thousands digit
ones_mult
	LDRB r5, [r1, #3]
	ADD r0, r5, #0			; add to total
	MOV r4, #0				; reset counter

tens
	LDRB r5, [r1, #2]
	CMP r5, #0
	BEQ hundreds_c
	
tens_mult
	ADD r0, r0, #10
	ADD r4, r4, #1
	CMP r4, r5 
	BNE tens_mult
	MOV r4, #0

hundreds_c
	LDRB r5, [r1, #1]
	CMP r5, #0
	BEQ thousands_c
	
hundreds_mult
	ADD r0, r0, #100		; adjust these registers to r0 to accomodate total
	ADD r4, r4, #1
	CMP r4, r5 
	BNE hundreds_mult
	MOV r4, #0

thousands_c
	LDR r8, =1000
	LDRB r5, [r1]
	CMP r5, #0
	BEQ quotient_step
	
thousands_mult
	ADD r0, r0, r8
	ADD r4, r4, #1
	CMP r4, r5 
	BNE thousands_mult

quotient_step
	BL quotient					; quotient is the current level of the game being played now
	MOV r10, r2				   ; retain value in r10
	LSL r2, #1				   ; times the value by 2
	ADD r2, r2, #4			   ; add 4 to it

adjust_probability_level
	LDR r0, =probability_spawner
	LDRB r5, [r0]				; load the current
	CMP r2, r5					; if our current level is the same as the previous level state, we do not change match register
	BEQ end_this_timer
	STRB r2, [r0]				; store the new value of the current probability spawn constant for future use
; add in the value to change the match register
	BL display_digit			; update the display
	LDR r4, =1843200				; ten percent of the current match register	is decremented
	LDR r5, =current_match		; load the current match register value
	LDR r6, [r5] 			   ; load the value 
	SUB r4, r6, r4				; decrement current value by .1 seconds r4 holds the current match register value to update
	STR r4, [r5]				; store the updated match value for current use
	BL match_change1			; change the match register of the timer1 
;**********************************************************************************************************
end_this_timer
	LDR r1, =uart_lock_key		; enable the uart when game is on every two clock cycles
	MOV r2, #0					; copy a zero
	STRB r2, [r1]				; reset the uart key to enable it
	BL game_state_toggle1		; stop timer
	B end_timer

uart_interrupt	  	
	BL read_character			; read the user's input
	CMP r0, #0x71				; is user input a q?				
	BEQ game_over_restore	   	; go to game end phase 
	BL off_road_check			; check for user car in off roads
	LDR r1, =uart_lock_key		; checks if the lock is set
	LDRB r2, [r1]				; load it
	CMP r2, #1					; is it a one?
	BEQ end_interrupt			; if lock is set end interrupt
	;check if locked if locked end interrupt
	
	CMP r0, #0x70				; is user input a p?				
	BEQ bullet					; spawn and move the bullet
	CMP r0, #0x61				; is user input an a?
	BEQ user_car				; move user car left
	CMP r0, #0x73				; is user input an s?
	BEQ user_car				; move user car down
	CMP r0, #0x77				; is user input a w?
	BEQ user_car				; move user car up
	CMP r0, #0x64				; is user input a d?
	BEQ user_car				; move user car right
	BNE end_interrupt
	
	; branch to set lock if valid input else just don't lock and end interrupt 
	; branch depending on output

user_car
	MOV r4, r0					; copies a user's direction
	MOV r1, #0xA9				; copy the user car to  r1
	LDR r0, =board
	ADD r0, r0, #26				; the first probable place the character would be
	BL character_search			; finds the character in the board
	; r1 has the location of the car
	B perimeter_check

bullet
	BL bullet_search			; r1 bullet counter check if there are two bullets on the board already
	CMP r1, #1					; check if there are two bullets on board already
	BLE bullet_spawn		   	; grant permission to spawn a bullet
	B set_uart_lock			   	; user cannot spawn more bullets
	
bullet_spawn
	MOV r1, #0xA9				; copy a car
	LDR r0, =board
	ADD r0, r0, #26				; the first probable place the character would be
	BL character_search			; r1 will have car location
	LDRB r0, [r1, #-25]			; load the character in front of user car
	CMP r0, #0x42				; is it a bulletproof?
	BEQ set_uart_lock			; bullet does not overwrite a bulletproof
	CMP r0, #0x40				; is it a border?
	BEQ set_uart_lock			; bullet does not overwrite the wall
	CMP r0, #0x20				; is it a space?
	BNE expect_vehicle			; if it is not a space, we assume it is a vulnerable vehicle (M, V, or S)
	MOV r0, #0x2A				; copy a bullet
	STRB r0, [r1, #-25]			; we store the bullet and do not award points for killing a unit
	B set_uart_lock				; lock the uart
	
expect_vehicle					; bullet about to kill an enemy right in front of user car
	; r0 currently holds an enemy vehicle character of M, V, or S
	LDRB r5, [r1, #-50]			; load byte of vehicle behind bullet (two levels away)
	CMP r5, r0					; compare if that character matches the one right in front of bullet
	MOV r5, #0x20				; copy a space
	STRB r5, [r1, #-25]			; store the space where the enemy vehicle is gone due to immediate collision with bullet
	BEQ score50					; if the character matches, then grant 50 points for hitting enemy with bullet
	B score75					; if character behind is different, assume we destroyed the whole unit to grant 50 plus 25 points
	
score50
	MOV r7, #50					; copy a 50
	BL score_update				; update score
	B set_uart_lock				; loop back to find more bullets
	
score75					
	MOV r7, #75					; copy a 75
	BL score_update				; update score
	B set_uart_lock				; loop back to find more bullets
	
perimeter_check
	CMP r4, #0x61				; is user input an a?
	BEQ west_wall_check			; move user car left
	CMP r4, #0x73				; is user input an s?
	BEQ south_wall_check		; move user car down
	CMP r4, #0x77				; is user input a w?
	BEQ north_wall_check		; move user car up
	CMP r4, #0x64				; is user input a d?
	BEQ east_wall_check			; move user car right

west_wall_check
	LDRB r2, [r1, #-1]			; check if character is the wall	
	CMP r2, #0x40				; is the right character a wall?
	BEQ set_uart_lock			; end uart interrupt and lock it
	CMP r2, #0x57				; is the right character a W
	BEQ off_road_left		   	; check off road
	SUB r1, r1, #2			   	; decrement location
	LDRB r2, [r1]				; load
	CMP r2, #0x20			   	; can user car traverse there?
	BEQ left_move			   	; move left
	B west_collision_check		; assume that the user will collide into some enemy vehicle

south_wall_check
	LDRB r2, [r1, #25]			; check if character is the wall
	CMP r2, #0x40				; did user meet a wall
	BEQ set_uart_lock		   	; lock uart
	CMP r2, #0x20			   	; did user encounter a space
	BEQ down_move			   	; move down
	B user_collision_check	    ; collision occurs

north_wall_check
	LDRB r2, [r1, #-25]			; check if character is the wall	
	CMP r2, #0x40				; did user meet a wall
	BEQ set_uart_lock		   	; lock uart
	CMP r2, #0x20			   	; user meets a space
	BEQ up_move				   	; move up
	B user_collision_check	   	; collision occurs
	
east_wall_check
	LDRB r2, [r1, #1]			; check if character is the wall	
	CMP r2, #0x40				; is the right character a wall?
	BEQ set_uart_lock		   	; lock uart
	CMP r2, #0x57				; is the right character a W
	BEQ off_road_right		   	; off road encountered
	ADD r1, r1, #2		   		; decrement location by 2
	LDRB r2, [r1]				; load
	CMP r2, #0x20		   		; did user meet a space
	BEQ right_move			   	; move right
	B east_collision_check		; assume that the user will collide into some enemy vehicle

; user collides with enemy, sustains damage, respawns, checks if it is game over
east_collision_check
	MOV r2, #0x20
	STRB r2, [r1, #-2]			; remove user car
	LDR r9, =current_life
	LDRB r11, [r9]
	ADD r11, r11, #1
	STRB r11, [r9] 
	BL health_LED
	CMP r11, #4
	BEQ game_over_restore
	BL user_respawn
	B set_uart_lock

; user collides with enemy, sustains damage, respawns, checks if it is game over	
west_collision_check
	MOV r2, #0x20				; 20
	STRB r2, [r1, #2]			; remove user car
	LDR r9, =current_life
	LDRB r11, [r9]
	ADD r11, r11, #1
	STRB r11, [r9] 
	BL health_LED
	CMP r11, #4
	BEQ game_over_restore
	BL user_respawn
	B set_uart_lock

; user collides, sustains damage, respawns, checks if it is game over
user_collision_check
	MOV r2, #0x20				; copy a space
	STRB r2, [r1]				; user has collided with the enemy vehicle, user sustains damage
	LDR r9, =current_life
	LDRB r11, [r9]
	ADD r11, r11, #1
	STRB r11, [r9] 	
	BL health_LED
	CMP r11, #4
	BEQ game_over_restore
	BL user_respawn	
	B set_uart_lock

left_move
	MOV r2, #0xA9				; copy a user
	STRB r2, [r1]				; user moves
	MOV r2, #0x20			   	; previous location empty
	STRB r2, [r1, #2]		   ; store it
	B set_uart_lock

down_move
	MOV r2, #0x20				 ; copy space
	STRB r2, [r1]				 ; empty location
	MOV r2, #0xA9				 ; copy user
	STRB r2, [r1, #25]			 ; user moves
	B set_uart_lock				 ; lock uart

right_move
	MOV r2, #0x20				 ; copy space
	STRB r2, [r1, #-2]			 ; empyt location
	MOV r2, #0xA9				 ; copy user
	STRB r2, [r1]				 ; move user
	B set_uart_lock				 ; lock uart

; user moves up and replaces previous location with a space
up_move
	MOV r2, #0x20
	STRB r2, [r1]
	MOV r2, #0xA9	
	STRB r2, [r1, #-25]
	B set_uart_lock

;user enters off road, sustains damage, and respawns
off_road_left
	MOV r2, #0x20				; copy a space
	STRB r2, [r1]
	MOV r2, #0xA9
	STRB r2, [r1, #-1]
	LDR r9, =current_life
	LDRB r11, [r9]
	ADD r11, r11, #1
	STRB r11, [r9]
	BL health_LED 
	CMP r11, #4
	BEQ game_over_restore
	B set_uart_lock

;user enters off road, sustains damage, and respawns
off_road_right
	MOV r2, #0x20				; copy a space
	STRB r2, [r1]
	MOV r2, #0xA9				
	STRB r2, [r1, #1]
	LDR r9, =current_life
	LDRB r11, [r9]
	ADD r11, r11, #1
	STRB r11, [r9]
	BL health_LED
	CMP r11, #4
	BEQ game_over_restore	
	B set_uart_lock

; prevent user from making multiple inputs at a time
set_uart_lock
	LDR r1, =uart_lock_key
	LDRB r2, [r1]
	MOV r2, #1					; 1 means to lock it
	STRB r2, [r1]
	B FIQ_Exit

end_interrupt
	CMP r10, #8				  ; check if it is 8
	BNE green_light			   ; game state
	B keep_blue				   ; pause state

green_light
	MOV r10, #4
	BL RGB_LED

keep_blue	
	LDR r0, =0xE01FC140			; load external interrupt flag register
	LDR r1, [r0]			 
	ORR r1, r1, #3
	STR r1, [r0]
	B FIQ_Exit

end_timer	
	MOV r10, #4					; change RGB to red
	BL RGB_LED					; indicated game end phase with red light
;	LDR r4, =formfeed			; formfeed to clear the PuTTY
;	BL output_string			; print it
;	LDR r4, =score_view
;	BL output_string			; print  the score 
;	LDR r4, =board				; obtain the border
;	BL output_string			; print out the border in PuTTY

	LDR r0, =0xE0008000			; clearing interrupt
	LDR r1, [r0]
	ORR r1, r1, #0x2
	STR r1, [r0]
	LDR r0, =0xE01FC140			; load external interrupt flag register
	LDR r1, [r0]			 
	ORR r1, r1, #3
	STR r1, [r0]
	B FIQ_Exit	


game_over_restore
	BL game_state_toggle1		 ; stop timer1 to stop all movement on board
	BL clean_arm				 ; clear uart and timers and interrupts
	LDR r1, =game_ender		   ; load base
	MOV r2, #1				   ; add a 1 to indicate game end 
	STRB r2, [r1]
	
FIQ_Exit
end_FIQ
	LDR r4, =formfeed			; formfeed to clear the PuTTY
	BL output_string			; print it
	LDR r4, =score_view
	BL output_string			; print  the score 
	LDR r4, =board				; obtain the border
	BL output_string			; print out the border in PuTTY
	LDMFD SP!, {r0-r2, r4-r6, r8-r10, r12, lr}
	SUBS pc, lr, #4				; return to interrupted instruction

pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000 		; PINSEL0
	LDR r1, [r0]	
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr

	END