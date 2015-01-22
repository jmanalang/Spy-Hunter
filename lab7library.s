	AREA	GPIO, CODE, READWRITE	
	EXPORT read_character
	EXPORT output_character
	EXPORT read_string
	EXPORT output_string
	EXPORT uart_init
	EXPORT game_state_toggle0
	EXPORT game_state_toggle1
	EXPORT seed_generator
	EXPORT match_change1
	EXPORT linear_congruential
	EXPORT horizontal_coordinate
	EXPORT xy_coordinate
	EXPORT uart0_state_on
	EXPORT uart0_state_off
	EXPORT character_search
	EXPORT bullet_search
	EXPORT quotient
	EXPORT user_respawn
	EXTERN board
	EXPORT life_count
	EXPORT health_LED
	EXPORT RGB_LED
	EXPORT display_digit
	EXPORT display_zero
	EXPORT start_GPIO
	EXPORT off_road_check
	EXPORT clean_arm
	EXPORT board_wipe
	EXPORT score_update
	EXTERN score_view
	EXTERN score_template
	EXPORT timer_0
	EXPORT disable_timer_0
	EXPORT arm_init
	EXPORT timer_1
		
digit_SET	
		DCD 0x00001F80  ; 0
		DCD 0x00001800  ; 1 
		DCD 0x00002D80	; 2
		DCD 0x00002780	; 3
		DCD 0x00003300	; 4
		DCD 0x00003680	; 5
		DCD 0x00003E80	; 6
		DCD 0x00000380	; 7
		DCD 0x00003F80	; 8
		DCD 0x00002380	; 9
		DCD 0x00003B80	; A
		DCD 0x00003E00	; B		 
		DCD 0x00001C00	; C
		DCD 0x00002700	; D
		DCD 0x00003C80	; E
		DCD 0x00003880  ; F
	ALIGN
	
color_SET  		
		DCD	0x00260000; White
		DCD 0x00200000; Green		
		DCD 0x00040000; Blue		
		DCD 0x00020000; Red
	 ALIGN

life_count
	 	DCD 0x000F0000 ; all LED
		DCD	0x00070000 ; 3 
		DCD	0x00030000 ; 2
		DCD	0x00010000 ; 1		 
		DCD 0x00000000 ; 0
	ALIGN
			
linear_storage = "",0
	DCB 0x00
	ALIGN
			
;*******************************************************************************************************************************
; Help set up the UART0, the divisor latch regulation for the upper and lower divisor latch 
;
uart_init
	STMFD SP!,{lr}
	
	LDR r1, =0xE000C00C		; Load the line control register
	LDRB r2, [r1]			; Load byte of line control register into temp r2
	MOV	r2, #0x83			; Enable divisor latch by placing 131 into line control register
	STRB r2, [r1]			; Store the byte back into r1
	LDR	r0, =0xE000C000		; Load the lower register for the uart speed lower divisor latch (base address)
	LDRB r2, [r0]			; Load lower register byte into temp r2
	MOV	r2, #0x14	;78		; Put #0x14 into the lower register to set lower divisor latch <<<<<<changed for baud rate of 57600	 former 0x78
	STRB r2, [r0]			; Store the byte back into lower divisor latch
	LDR	r3, =0xE000C004		; Load the upper divisor latch
	LDRB r2, [r3]	 		; Load byte into temp r2
	MOV	r2,	#0				; Set upper divisor latch with a zero into temp r2
	STRB r2,[r3]			; Store byte into upper divisor latch
	LDR r1, =0xE000C00C		; Load the line control register again
	MOV r2, #3				; Store r3 into line control register
	STRB r2, [r1]			; Store a byte of 3 into line control register 

	LDMFD sp!,{lr}
	BX lr	

;*******************************************************************************************************************************
; This is for outputting a character onto PuTTY
;
output_character
	STMFD sp!, {lr}
	LDR r2, =0xE000C000

looptx						; Loop until THRE is 1
 	LDRB r1, [r2, #0x14]
	AND r1, r1, #0x20
	CMP r1, #0
	BEQ looptx
	STRB r0, [r2]			; Transmit character
	
	LDMFD sp!, {lr}							
	BX lr

;*******************************************************************************************************************************
; This is for reading a character from PuTTY
;
read_character	
	STMFD sp!, {lr}
	LDR r2, =0xE000C000

looprx				   		; Loop until RDR is 1
	LDRB r1, [r2, #0x14]
	AND r1, r1, #0x01
	CMP r1, #0
	BEQ looprx
	LDRB r0, [r2]			; Read character
	LDMFD sp!, {lr}
	BX lr

;*******************************************************************************************************************************
; This is for outputting a string onto PuTTY
;
output_string
	STMFD sp!, {r4, lr}
	MOV r1, r0

out_str_loop	
	LDRB r0, [r4], #1
	CMP r0, #0
	BEQ out_str_done
	BL output_character
	B out_str_loop
	
out_str_done
	LDMFD sp!, {r4, lr}
	BX lr

;*******************************************************************************************************************************
; This is for reading a string from PuTTY
;
read_string
	STMFD sp!, {r4,lr}

read_str_loop	
	BL read_character
	CMP r0, #13
	BEQ end_of_user_input
	BL output_character
	STRB r0, [r4], #1
	B read_str_loop

end_of_user_input
	MOV r0, #0
	STRB r0, [r4], #1
	
	LDMFD sp!, {r4,lr}
	BX lr

;*******************************************************************************************************************************
; This is for pausing and resuming timer0
;
user_respawn
	STMFD SP!, {r0-r12, lr}
	LDR r1, =board
	LDR r3, =421
	ADD r3, r3, r1
user_spawn_point
	LDRB r2, [r3], #-1			; respawn at the first white space from the right
	CMP r2, #0x20
	BNE user_spawn_point
	MOV r4, #0xA9
	ADD r3, r3, #1			; restore the offset
	STRB r4, [r3]			; store the vehicle at the restored position
	
health_penalty
	LDMFD SP!, {r0-r12, lr} 	; Restore registers
	BX lr             	   		; Return
	
;*******************************************************************************************************************************
; This is for pausing and resuming timer0
;
game_state_toggle0
	STMFD SP!,{lr}	
	LDR r0, =0xE0004004		; base address of the timer
	LDRB r1, [r0]			; load byte
	EOR r1, r1, #0x1		; XOR the timer to pause the timer
	STRB r1, [r0]			; store byte
	LDMFD sp!, {lr}
	BX lr


;*******************************************************************************************************************************
; Initialize the GPIO's of the ARM Board such as... Timers, buttons, seven segment display, LEDs, RGB LEDs, UART, etc...
;
arm_init       
	STMFD SP!, {r0-r1, lr}   			; Save registers
	
	; Setup the Push button for interrupts as external interrupt 1
	LDR r0, =0xE002C000					; base address of the push button
	LDR r1, [r0]						; load the word value
	ORR r1, r1, #0x20000000 			; set the 29 bit
	BIC r1, r1, #0x10000000 			; clear bit 28 and leave all other bits alone
	STR r1, [r0]  						; PINSEL0 bits 29:28 = 10
	
	; Setup UART0 to interrupt when data is received 
	LDR r0, =0xE000C000					; Base address of UART0 
	LDR r1, [r0, #0x4]					; Load the value from UART0 interrupt enable register 
	ORR r1, r1, #1						; Set bit0 to 1 to enable receive data available interrupt
	STR r1, [r0, #0x4]					; changed!	

	; Set External Interrupt 1 to be edge sensitive
	LDR r0, =0xE01FC148					; Push button for interrupts base address
	LDR r1, [r0]						; load it
	ORR r1, r1, #2  					; EINT1 = Edge Sensitive
	STR r1, [r0]						; changed!

; Classify sources as FIQ 
	LDR r0, =0xFFFFF000					; Interrupt base address
	LDR r1, [r0, #0xC]					; Interrupt select register
	ORR r1, r1, #0x8000 				; Set External Interrupt 1 as FIQ by setting bit15 to 1
	ORR r1, r1, #0x70 					; Set bits to 1: bit6 for UART0, bit5 for Timer1, bit4 for Timer0 
	STR r1, [r0, #0xC]					; changed!

	; Enable Interrupts
	LDR r1, [r0, #0x10] 				; Interrupt enable register r0 is still Interrupt base address
	ORR r1, r1, #0x8000 				; External Interrupt 1 which is setting bit 15 , pin 6
	ORR r1, r1, #0x70 					; Set bits to 1: bit6 for UART0, bit5 for Timer1, bit4 for Timer0	
	STR r1, [r0, #0x10]					; changed!
	
	; Enable FIQ's, Disable IRQ's
	MRS r0, CPSR						; copy CPSR/SPSR of current mode to register 0
	BIC r0, r0, #0x40					; enable FIQs
	ORR r0, r0, #0x80					; disable IRQs
	MSR CPSR_c, r0						; copy r0 value to CPSR/SPSR MRS and MSR are similar to load and store
	
	LDMFD SP!, {r0-r1, lr} 				; Restore registers
	BX lr             	   				; Return
	
;*******************************************************************************************************************************
; Initialize the GPIO's of the ARM Board such as... Timers, buttons, seven segment display, LEDs, RGB LEDs, UART, etc...
; first one sets timer0, second subroutine disables timer0 and timer1 where the TC stops at a certain value
timer_0       
	STMFD SP!, {r0-r1, lr}   			; Save registers 

; Enable and use Timer0 (for probability seed)
	; Set a Value to Match register (MR0)
	LDR r0, =0xE0004018					; Match Register base address  
	LDR r1, [r0]						; load it
	MOV r1, #79							; Probability is out of 79 so seed would be less than the modulo
	STR r1, [r0]						; changed!

	; Enable Match control register (T0MCR)
	LDR r0, =0xE0004014					; Match control register base address
	LDR r1, [r0]						; load it
	ORR r1, r1, #0x2					; set bit 3 for generating interrupt, bit 4 to reset timer counter when MCR and TCR match
	STR r1, [r0]						; changed!

	; Enable the Timer Control Register (T0TCR)
	LDR r0, =0xE0004004					; Timer control register base address
	LDR r1, [r0]						; load it
	ORR r1, r1, #1						; Set bit 0 to enable, set bit0 to reset the TC register to 0
	STR r1, [r0]						; changed!

	LDMFD SP!, {r0-r1, lr} 				; Restore registers
	BX lr             	   				; Return

disable_timer_0       
	STMFD SP!, {r0-r1, lr}   			; Save registers 
	; Enable Interrupts
	LDR r0, =0xFFFFF000
	LDR r1, [r0, #0x10] 				; Interrupt enable register r0 is still Interrupt base address
	BIC r1, r1, #0x10 					; clear bit4 for Timer0	
	STR r1, [r0, #0x10]					; changed!
	; disable timer0
	; Enable the Timer Control Register (T0TCR)
	LDR r0, =0xE0004004					; Timer control register base address
	LDR r1, [r0]						; load it
	BIC r1, r1, #1						; Set bit 0 to enable, set bit0 to reset the TC register to 0
	STR r1, [r0]						; changed!
	LDR r1, =0xE0004014
	LDR r2, [r1]
	BIC r2, r2, #0x38					; disable the interrupt bit for timer0
	STR r2, [r1]
	LDMFD SP!, {r0-r1, lr} 				; Restore registers
	BX lr  	
	
timer_1       
	STMFD SP!, {r0-r1, lr}   			; Save registers 
	
; Enable and use Timer1 (for board movements)
	; Enable the Timer Control Register (T1TCR)
	LDR r0, =0xE0008004					; Timer control register base address
	LDR r1, [r0]						; load it
	ORR r1, r1, #1						; Set bit 0 to enable, set bit0 to reset the TC register to 0
	STR r1, [r0]						; changed!
		 
	; Enable Match control register (T1MCR)
	LDR r0, =0xE0008014					; Match control register base address
	LDR r1, [r0]						; load it
	BIC r1, r1, #0x20
	ORR r1, r1, #0x18					; set bit 3 for generating interrupt, bit 4 to reset timer counter when MCR and TCR match
	STR r1, [r0]						; changed!
	
	; Set a Value to Match register (MR1)
	LDR r0, =0xE000801C					; Match Register base address 
	LDR r1, [r0]						; load it
	LDR r1, =0x1194000					; The value for the 18.432 MHz
	STR r1, [r0]						; changed!
										
	LDMFD SP!, {r0-r1, lr} 				; Restore registers
	BX lr             	   				; Return

;*******************************************************************************************************************************
; This is for pausing and resuming timer1
;
game_state_toggle1
	STMFD SP!,{lr}
	
	LDR r0, =0xE000C000					; Base address of UART0 
	LDR r1, [r0, #0x4]					; Load the value from UART0 interrupt enable register 
	EOR r1, r1, #1						; Set bit0 to 1 to enable receive data available interrupt
	STR r1, [r0, #0x4]					; changed!	
		
	LDR r0, =0xE0008004		; base address of the timer
	LDRB r1, [r0]			; load byte
	EOR r1, r1, #0x1		; XOR the timer to pause the timer
	STRB r1, [r0]			; store byte
	LDMFD sp!, {lr}
	BX lr

;*******************************************************************************************************************************
; This is for enabling/ disabling interrupt enable register
;
uart0_state_on
	STMFD SP!,{lr}	
	LDR r2, =0xE000C004		; base address of the interrupt enable register 
	LDR r1, [r2]			; load byte
	ORR r1, r1, #0x1		; XOR the timer to enable disable the uart0
	STR r1, [r2]			; store byte
	LDMFD sp!, {lr}
	BX lr

;*******************************************************************************************************************************
; This is for enabling/ disabling interrupt enable register
;
uart0_state_off
	STMFD SP!,{lr}	
	LDR r2, =0xE000C004		; base address of the interrupt enable register 
	LDR r1, [r2]			; load byte
	BIC r1, r1, #0x1		; XOR the timer to enable disable the uart0
	STR r1, [r2]			; store byte
	LDMFD sp!, {lr}
	BX lr


score_update
	STMFD sp!, {r0-r11, lr}
	LDR r1, =score_template				; load base address of the current score
	CMP r7, #10							; is the score incremented by 10
	BEQ tens_place_1					; add it 
	CMP r7, #50							; is the score incremented by 50
	BEQ tens_place_5					; add it
	CMP r7, #75							; is the score incremented by 75
	BEQ one_tens_75 					; add it 
	
one_tens_75
	LDRB r0, [r1, #3]					; load the current ones place value
	ADD r0, r0, #5						; add five to it
	CMP r0, #10							; see if that value is ten or greater
	BGE adjust_ones_tens_75				; carry the one if it is
	STRB r0, [r1, #3]					; if no adjustment, store it to ones place
	B tens_place_75						; jump to add the 70 points
	
adjust_ones_tens_75
	SUB r0, r0, #10						; adjust the number to be only the ones place
	STRB r0, [r1, #3]					; store the proper value back to ones place
	LDRB r0, [r1, #2]					; load value of tens place
	ADD r0, r0, #1						; add the carry bit to tens place
	STRB r0, [r1, #2]					; store it in tens place, worry about proper values later
	B tens_place_75						; handle it
	
adjust_ones
	SUB r0, r0, #10						; adjust the number to be only the ones place
	STRB r0, [r1, #3]					; store the proper value back to ones place
	LDRB r0, [r1, #2]	
	ADD r0, r0, #1						; add the carry bit to tens place
	STRB r0, [r1, #2]					; store it in tens place, worry about proper values later
	B tens_place_75
	
tens_place_1	
	LDRB r0, [r1, #2]					; load byte from the tens place
	ADD r0, r0, #1						; add 1 for tens place
	CMP r0, #10							; compare if we reached ten or higher
	BGE adjust_tens_1					; adjust ut to hold only one digit
	STRB r0, [r1, #2]					; if no adjustment, store it to ones place
	B score_addition_end				; jump to add the 20 points
adjust_tens_1							
	SUB r0, r0, #10						; subtract ten for proper offset
	STRB r0, [r1, #2]					; store the proper tens place value into memory
	B hundreds_place					; check if we incremented the hundreds place

tens_place_5	
	LDRB r0, [r1, #2]					; load byte of the tens place
	ADD r0, r0, #5						; increment tens place by 5
	CMP r0, #10							; compare if it is ten or higher
	BGE adjust_tens_5					; if it is equal or greater than, adjust it to have proper value
	STRB r0, [r1, #2]					; if no adjustment, store it to tens place
	B score_addition_end				; jump to add the 20 points
adjust_tens_5
	SUB r0, r0, #10						; subtract 
	STRB r0, [r1, #2]					; store the adjusted value in tens place
	B hundreds_place					; check if the hundreds place is carried over

tens_place_75	
	LDRB r0, [r1, #2]					; load current tens place value
	ADD r0, r0, #7						; add 7 to current tens place value
	CMP r0, #10						    ; was there a carry over?
	BGE adjust_tens_75				    ; adjust the tens place for the carry over
	STRB r0, [r1, #2]					; if no adjustment, store it to ones place
	B score_addition_end				; if no carry occurs, then we are done with score done 
adjust_tens_75
	SUB r0, r0, #10						; adjust the tens place
	STRB r0, [r1, #2]					; store the adjusted value
	B hundreds_place				   	; check if hundreds place is incremented by carry over
	
hundreds_place
	LDRB r0, [r1, #1]					; the hundreds place had a carry over
	ADD r0, r0, #1						; add the carry over bit here
	CMP r0, #10							; check if we are ten or over
	BGE adjust_hundreds					; adjust the hundreds place
	STRB r0, [r1, #1]					; if not we just end addition
	B score_addition_end			    ; if no carry over occurs, then we are done with the score update
adjust_hundreds
	SUB r0, r0, #10						; adjust the value from the carry over		
	STRB r0, [r1, #1]					; store the value
	B thousands_place					; since hundreds had a carry over, thousands must be incremented
	
thousands_place
	LDRB r0, [r1]				   		; update the thousands place
	CMP r0, #9							; update if we reached the 9 
	BGE	score_addition_end				; end score update
	ADD r0, r0, #1						; increment the thousands place for the carry over 
	STRB r0, [r1]						; store the value into score memory

; convert each of the four bytes to proper ascii values to display the score on putty properly
score_addition_end
ascii_score_conversion					
	LDR r4, =score_view					
	LDRB r0, [r1]					   	
	ADD r0, r0, #0x30
	STRB r0, [r4, #6]
	LDRB r0, [r1, #1]
	ADD r0, r0, #0x30
	STRB r0, [r4, #7]
	LDRB r0, [r1, #2]
	ADD r0, r0, #0x30
	STRB r0, [r4, #8]
	LDRB r0, [r1, #3]
	ADD r0, r0, #0x30
	STRB r0, [r4, #9]
	LDMFD sp!, {r0-r11, lr}
	BX lr
	
;*******************************************************************************************************************************
; The is the random number generator that we obtain from timer0
;
seed_generator		
	STMFD SP!,{lr}			; preserve registers
	BL game_state_toggle0	; stop the timer0 to get its value
	LDR r3, =0xE0004008		; obtain the base address of the timer counter
	LDRB r3, [r3]			; obtain the value from the timer counter register for probability
	BL game_state_toggle0	; resume the timer 
	LDMFD sp!, {lr}			; restore registers
	BX lr					; exit

;*******************************************************************************************************************************
; This changes the match register value under the usage of timer0
;
match_change
	STMFD SP!,{lr}		; preserve registers	
	BL game_state_toggle0	; stop timer
	LDR r0, =0xE0004008		; base address of the timer before it was 4
	LDR r1, [r0]			; load byte before
	MOV r1, #0
	STR r1, [r0]			; this enables the TC to change
	LDR r0, =0xE0004018		; Match Register base address 
	STR r4, [r0]			; update match register 0 value
	BL game_state_toggle0	; resume timer
 	LDMFD sp!, {lr}		; restore registers
	BX lr					; exit

;*******************************************************************************************************************************
; This changes the match register value under the usage of timer1
;
match_change1
	STMFD SP!,{r4, lr}		; preserve registers	
	LDR r0, =0xE0008008		; base address of the timer before it was 4
	LDR r1, [r0]			; load byte before
	MOV r1, #0
	STR r1, [r0]			; this enables the TC to change
	LDR r0, =0xE000801C		; Match Register1 base address 
	STR r4, [r0]			; update match register 0 value
 	LDMFD sp!, {r4, lr}		; restore registers
	BX lr					; exit

;*******************************************************************************************************************************
; This changes the match register value under the usage of timer0
; takes in r0 value
quotient
	STMFD SP!,{lr}		; preserve registers
	MOV r2, #0
	LDR r1, =500
	
quotient_loop
	CMP r0, r1			; is this less than 500?
	BLT quotient_value
	BGE iterative_quotient

quotient_value
	MOV r0, #0
	B end_quotient

iterative_quotient
	SUB r0, r0, r1		; r0 holds quotient
	ADD r2, r2, #1
	CMP r0, r1
	BGE iterative_quotient	;if current value is greater than 500
	BLT end_quotient		; if current value is less than quotient 
 
end_quotient
 	LDMFD sp!, {lr}		; restore registers
	BX lr					; exit
	
;*******************************************************************************************************************************
; This is where the randomization of values occur. Implemented the Linear Congruential Generator
;
linear_congruential
	STMFD SP!,{lr}			; preserve registers	
	MOV r0, r3				; r0 is the new seed that will be generated
	MOV r1, #0				; set counter to 0
	CMP r0, #80
	BGT error
	B quick_multiplier_seed
error
	B error
quick_multiplier_seed
	LSL r0, #4				; multiply the value by 16

ADD_loop5
	ADD r0, r0, r3			; add seed to cumulative value of "a" variable
	ADD r1, r1, #1			; increment counter
	CMP r1, #5				; have we added 5 times yet?
	BLT ADD_loop5			; loop back 

increment_component			
	ADD r0, r0, #13			; Add the increment value "c" variable
	BL modulo				; conduct final operation: modulo m variable
	
; r3 holds the final answer
	LDMFD sp!, {lr}			; restore registers
	BX lr					; exit
	
;*******************************************************************************************************************************
; This is a modulo subroutine derived from our lab2 division code
; Dividend in r3, continue to evaluate for LCG final answer
; Divisor is r2, this is the modulo m for 80
modulo
	STMFD SP!,{lr}			; preserve registers	

iterative_method
	CMP r0, #80
	BLT end_modulo
	BEQ equal_handle
	B iterative_loop

equal_handle
	MOV r0, #0
	B end_modulo

iterative_loop
	SUB r0, r0, #80
	CMP r0, #80
	BGT iterative_loop
	BLT end_modulo
	BEQ equal_handle
 
end_modulo
	MOV r3, r0				; before leaving, the final value is stored into r3 for future uses
; r3 holds the final value when this subroutine exits
 	LDMFD sp!, {lr}			; restore registers
	BX lr					; exit

;*******************************************************************************************************************************
; determine which lane to be on the board
;
horizontal_coordinate
	STMFD SP!,{lr}			; preserve registers	
	
	BL linear_congruential
	CMP r3, #7
	BLE lane1
	CMP r3, #15
	BLE lane2
	CMP r3, #23
	BLE lane3
	CMP r3, #31
	BLE lane4
	CMP r3, #39
	BLE lane5
	CMP r3, #47
	BLE lane6
	CMP r3, #55
	BLE lane7
	CMP r3, #63
	BLE lane8
	CMP r3, #71
	BLE lane9
	CMP r3, #79
	BLE lane10

lane1
	MOV r2, #27
	B horizontal_end
	
lane2
	MOV r2, #29
	B horizontal_end
	
lane3
	MOV r2, #31
	B horizontal_end
	
lane4
	MOV r2, #33
	B horizontal_end

lane5
	MOV r2, #35
	B horizontal_end

lane6
	MOV r2, #37
	B horizontal_end

lane7
	MOV r2, #39
	B horizontal_end

lane8
	MOV r2, #41
	B horizontal_end

lane9
	MOV r2, #43
	B horizontal_end

lane10
	MOV r2, #45

horizontal_end
 	LDMFD sp!, {lr}			; restore registers
	BX lr					; exit	

;*******************************************************************************************************************************
;determine the memory location on the board in memopry
;
xy_coordinate
	STMFD SP!,{lr}			; preserve registers	

	BL linear_congruential
	CMP r3, #4
	BLE vertical1
	CMP r3, #9
	BLE vertical2
	CMP r3, #14
	BLE vertical3
	CMP r3, #19
	BLE vertical4
	CMP r3, #24
	BLE vertical5
	CMP r3, #29
	BLE vertical6
	CMP r3, #34
	BLE vertical7
	CMP r3, #39
	BLE vertical8
	CMP r3, #44
	BLE vertical9
	CMP r3, #49
	BLE vertical10
	CMP r3, #54
	BLE vertical11
	CMP r3, #59
	BLE vertical12
	CMP r3, #64
	BLE vertical13
	CMP r3, #69
	BLE vertical14
	CMP r3, #74
	BLE vertical15
	CMP r3, #79
	BLE vertical16

vertical1
	B coordinates_end 

vertical2
	ADD r2, r2, #25
	B coordinates_end

vertical3
	ADD r2, r2, #50
	B coordinates_end

vertical4
	ADD r2, r2, #75
	B coordinates_end

vertical5
	ADD r2, r2, #100
	B coordinates_end

vertical6
	ADD r2, r2, #125
	B coordinates_end

vertical7
	ADD r2, r2, #150
	B coordinates_end

vertical8
	ADD r2, r2, #175
	B coordinates_end

vertical9
	ADD r2, r2, #200
	B coordinates_end

vertical10
	ADD r2, r2, #225
	B coordinates_end

vertical11
	ADD r2, r2, #250
	B coordinates_end

vertical12
	LDR r0, =0x113
	ADD r2, r2, r0
	B coordinates_end

vertical13
	LDR r0, =0x12C
	ADD r2, r2, r0
	B coordinates_end

vertical14
	LDR r0, =0x145
	ADD r2, r2, r0
	B coordinates_end

vertical15
	LDR r0, =0x15E
	ADD r2, r2, r0
	B coordinates_end

vertical16
	LDR r0, =0x177
	ADD r2, r2, r0

coordinates_end
	LDMFD sp!, {lr}			; restore registers
	BX lr					; exit

;*******************************************************************************************************************************
; takes in r1 that holds a character to traverse the board to find it in the board 
; 
character_search
	STMFD SP!,{lr}
	
iterative_search
	LDRB r2, [r0], #1		; load the character from the board, increment location affterwards
	CMP r2, r1				; compare if character of interest is in that location
	BNE iterative_search	; if it is not, loop
	SUB r1, r0, #1			; restore the offset location
	
	LDMFD sp!, {lr}			; restore registers
	BX lr					; exit	

;*******************************************************************************************************************************
;traverses board to search for all bullets
;
bullet_search
	STMFD SP!,{lr}
	LDR r5, =450			; offset
	LDR r0, =board			; 
	ADD r0, r0, #27			; the first probable place the character would be
	ADD r5, r5, r0
	MOV r1, #0
	
iterative_search2
	LDRB r2, [r0], #1		; load the character from the board, increment location afterwards
	CMP r2, #0x2A			; compare if character of interest is in that location
	BEQ increment_bullet	; if it is not, loop
	CMP r0, r5
	BEQ end_search_bullet
	B iterative_search2

increment_bullet
	SUB r0, r0, #1
	ADD r1, r1, #1
	CMP r1, #2
	ADD r0, r0, #1			; restore local point
	BEQ end_search_bullet
	B iterative_search2
	
end_search_bullet			; r1 will have the bullet counter 
	LDMFD sp!, {lr}			; restore registers
	BX lr					; exit	
	
;*******************************************************************************************************************************
; for game reset, clears the board to original settings
;
;
board_wipe
	STMFD SP!,{r0-r12, lr}   ;change accordingly

	LDR r1, =board				; base address of the board
	LDR r0, =422				; offset of the end of the board
	ADD r2, r1, #27				; address of the first white space on board
	ADD r0, r0, r1				; address of the last probable place on board
	; r0 last space position 436
	; r2 first space position 27
board_searcher				; search from ascending memory order
	LDRB r1, [r2], #1			; load the character from the board, increment memory location afterwards
	CMP r1, #0x42				; B
	BEQ space_maker
	CMP r1, #0x56				; V
	BEQ space_maker
	CMP r1, #0x4D				; M
	BEQ space_maker
	CMP r1, #0x53				; S
	BEQ space_maker
	CMP r1, #0xA9
	BEQ space_maker
	CMP r1, #0x2A
	BEQ space_maker
	CMP r2, r0					; compare if we reached the end of board traversal
	BEQ respawn_sanic			; no more bullet searching on board
	B board_searcher

space_maker
	MOV r3, #0x20
	SUB r2, r2, #1			   
	STRB r3, [r2]
	ADD r2, r2, #1	 
	B board_searcher

respawn_sanic
	MOV r3, #0xA9
	LDR r1, =board
	LDR r2, =408
	STRB r3, [r1, r2]			; store user car at initial location
	LDMFD sp!, {r0-r12, lr}
	BX lr  

;*******************************************************************************************************************************
; clean arm is called when game over phase is stepped in. 
;
clean_arm
	STMFD SP!,{lr}
	
	LDR r0, =0xE0008014			; Match control register base address
	LDR r1, [r0]				; load it
	BIC r1, r1, #0x8
	ORR r1, r1, #0x30			; set bit 3 for generating interrupt, bit 4 to reset timer counter when MCR and TCR match
	STR r1, [r0]	

	LDR r0, =0xE0008000			; clearing interrupt
	LDR r1, [r0]
	ORR r1, r1, #0x2
	STR r1, [r0]
	
	LDR r0, =0xE000C004
	LDR r1, [r0]
	BIC r1, r1, #0x1
	STR r1, [r0]
	
	
	MRS r0, CPSR				; copy CPSR/SPSR of current mode to register 0
	ORR r0, r0, #0xC0
	MSR CPSR_c, r0

	LDMFD SP!, {lr}
	BX lr
	
;*******************************************************************************************************************************
; checks the off road for user character and respawns them appropriately and immediately
off_road_check
	STMFD SP!, {r0-r12, lr}
	LDR r1, =board
	ADD r2, r1, #26
	LDR r5, =426
	ADD r4, r1, r5
	
left_W_check
	LDRB r3, [r2], #25
	CMP r3, #0x57
	BEQ left_W_check
	CMP r3, #0xA9
	BEQ respawn_U
	CMP r2, r4
	BEQ right_W_check

	LDR r1, =board
	ADD r2, r1, #46
	LDR r5, =426
	ADD r4, r1, r5
	
right_W_check
	LDRB r3, [r2], #25
	CMP r3, #0x57
	BEQ right_W_check
	CMP r3, #0xA9
	BEQ respawn_U
	CMP r2, r4
	BNE end_user_spawn
	
respawn_U
	SUB r2, r2, #25				; restore offset
	MOV r3, #0x57				; copy W
	STRB r3, [r2]
	BL user_respawn
	B end_user_spawn
	
end_user_spawn
	LDMFD SP!, {r0-r12, lr} 	; Restore registers
	BX lr             	   		; Return
	
;*******************************************************************************************************************************
; initialize the directions for all gpios
;
start_GPIO
	STMFD SP!,{r0-r12, lr}   ;change accordingly

seven_seg_and_RGB_dir
	LDR r0, =0xE0028008		; gpio direction register - 7 to 13 
	LDR r1, [r0]
	LDR r2, =0x263F80
	ORR r1, r1, r2    ; Set bits 7 to 13 output 17, 18, 21
	STR r1, [r0]			; store direction into port0 gpio reg

LED_dir
	LDR r0, =0xE0028018    ;direction register for port 1	
	LDR r1, [r0]
	ORR r1, r1, #0xF0000    ; Set bits 7 to 13 output 17, 18, 21
	STR r1, [r0]			; store direction into port0 gpio reg	
	
	LDMFD sp!, {r0-r12, lr}
	BX lr

;*******************************************************************************************************************************
; display zero on seven segment 
;
display_zero
	STMFD SP!,{r0-r12, lr}

	LDR r1, =0xE0028000   ; load base address of IO0PIN
	LDR r2, [r1]          ; put that stuff into r2
	ORR r2, r2, #0x3F80       ; set all the bits 7-13 for seven seg
	STR r2, [r1, #0xC]    ; store into  IO0CLR to clear the seven-seg
	
	LDR r4, =digit_SET    ;digit set address
	LDR r2, [r4]      ;load from lookup table with offset of quotient from level
	STR r2, [r1, #4]      ;store into IO0SET to turn on display for level.

	LDMFD sp!, {r0-r12, lr}
	BX lr  
;*******************************************************************************************************************************
; display value on seven segment display to indicate user level
;
display_digit
	STMFD SP!,{r0-r12, lr}

	LDR r1, =0xE0028000   ; load base address of IO0PIN
	LDR r2, [r1]          ; put that stuff into r2
	ORR r2, r2, #0x3F80   ; set all the bits 7-13 for seven seg
	STR r2, [r1, #0xC]    ; store into  IO0CLR to clear the seven-seg
	
	LDR r4, =digit_SET    ;digit set address
	MOV r10, r10, LSL #2    ;take quotient. word accessed - divisible 4
	LDR r2, [r4, r10]      ;load from lookup table with offset of quotient from level
	STR r2, [r1, #4]      ;store into IO0SET to turn on display for level.

	LDMFD sp!, {r0-r12, lr}
	BX lr

;*******************************************************************************************************************************
; generate color LED for game states
;
RGB_LED
	; r10 holds the proper offset
  	STMFD SP!,{r0-r12, lr}

	LDR r0, =0xE0028000		; pin value
	LDR r1, [r0]
	LDR r4, =color_SET

turn_off
	LDR r1, =0x260000		; load all the pins of RGB 
	STR r1, [r0, #0x4]		;Turn off all the RGB LEDs

turn_on
	LDR r1, [r4, r10]		; load the value from lookup table with proper offset 
	STR r1, [r0, #0xC]		;to turn on LED clear bit 18
	
	LDMFD sp!, {r0-r12, lr}
	BX lr

;*******************************************************************************************************************************
; four leds to indicate game user health
;
health_LED	
  	STMFD SP!,{r0-r12, lr}
	LDR r0, =0xE0028010
	LDR r2, =life_count
	LSL r11, #2				
	LDR r4, [r2, r11]

clear_off
	LDR r3, =0x000F0000		; set all off
	STR r3, [r0, #0x4]		;Turn off all the RGB LEDs

set_on
	STR r4, [r0, #0xC]				  
	LDMFD sp!, {r0-r12, lr}
	BX lr

;not in library. Compare on collisions

place_after_collisions	
	
	LDR r0, =life_count    ;load hit_count
	LDRB r1, [r0]
	CMP r1, #0x4		   ;compare if damaged 4 times
	BL Game_Over_Prompt   ;yet to be made
	ADD r1, r1, #0x1	   ;if not dead yet, we increment hit count
	STRB r1, [r0]          ;then we store that a hit has been made
	LDR r4, =0xE0028010		; gpio direction register - 16-31 
	LDR r5, [r4]	
	BIC r5, #0xF0000		;clear 16-19
	STR r5, [r4, #0xC]
	MOV r1, r1, LSL#2
	LDR r2, [r0, r1]
	STR r2, [r4,#0x4]
	
Game_Over_Prompt
	STMFD SP!,{lr}
	;gameoverprompt here in last email
	LDR r0, =0xE0028000		; gpio direction register - 16-31 
	LDR r1, [r0]			
	BIC r1, #0x260000		;clear all values 17, 18, 12
	STR r1, [r0, #0x14]		;Turn off all the RGB LEDs
	ORR r1, #0x20000		;set bit 17 - red LED
	STR r1, [r0, #0xC]		;to turn on red LED clear bit 18
	
	LDMFD SP!, {lr}
	BX lr



	END	