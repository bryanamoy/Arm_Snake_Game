;Bryan Moy and Rafsan MD Chowdhury
	.data
border1:	.string " ---------------------------------------- ", 0x0D, 0x0A
border2:	.string "|                                        |", 0x0D, 0x0A
border3:	.string "|                                        |", 0x0D, 0x0A
border4:	.string "|                                        |", 0x0D, 0x0A
border5:	.string "|                                        |", 0x0D, 0x0A
border6:	.string "|                                        |", 0x0D, 0x0A
border7:	.string "|                                        |", 0x0D, 0x0A
border8:	.string "|                                        |", 0x0D, 0x0A
border9:	.string "|                                        |", 0x0D, 0x0A
border10:	.string "|                    *                   |", 0x0D, 0x0A
border11:	.string "|                                        |", 0x0D, 0x0A
border12:	.string "|                                        |", 0x0D, 0x0A
border13:	.string "|                                        |", 0x0D, 0x0A
border14:	.string "|                                        |", 0x0D, 0x0A
border15:	.string "|                                        |", 0x0D, 0x0A
border16:	.string "|                                        |", 0x0D, 0x0A
border17:	.string "|                                        |", 0x0D, 0x0A
border18:	.string " ---------------------------------------- ", 0
	.text
score:	.string "Score:",0
	.global lab6
	.global uart_init
	.global timer_init
	.global output_character
	.global read_character
	.global UART0Handler
	.global Timer0Handler
	.global print_board
	.global stop_game
	.global finish
ptr: .word border1
U0LSR: .equ 0x18			; UART Line Status Register

lab6:
	STMFD SP!,{lr}			; Store register lr on stack
	BL uart_init
	MOV r9, #1
	MOV r11, #0
	MOV r4, #0x01A1
	MOVT r4, #0x2000
	MOV r6, #0x2A
	LDR r0, ptr
	BL print_board
	LDMFD SP!, {lr}
	mov pc, lr

output_character:
	STMFD SP!,{lr}			; Store register lr on stack
	MOV r2, #0xC000
	MOVT r2, #0x4000
	STRB r1, [r2]			; Transmit byte

txFlag:
	LDRB r3, [r2,#U0LSR] 	; load byte of status register
	MOV r5, #0x20 			; r5 = 0x00000020
	AND r3, r3, r5			; Mask bit 5 in status register to get TxFF
	CMP r3, r5
	BEQ txFlag
	LDMFD sp!, {lr}
	MOV pc, lr

read_character:
	STMFD SP!,{lr}			; Store register lr on stack
	LDRB r3, [r2,#U0LSR]	; load status register RxFE
	MOV r5, #0x10
	AND r3, r3, r5			; mask status register to test for 1 or 0
	CMP r3, r5				; compare for 0 or 1
	BEQ read_character		; if equal 0 loop back

	LDRB r1, [r2]			; Read key from Recieve Register
	CMP r1, #0x69			; compare for key 'i'
	BEQ key_i
	CMP r1, #0x6A			; compare for key 'j'
	BEQ key_j
	CMP r1, #0x6B			; compare for key 'k'
	BEQ key_k
	CMP r1, #0x6C			; compare for key 'l'
	BEQ key_l
	B end_key				; if no valid key press go to end
key_i						; key to go up
	SUB r4, r4, #44			; address above head of snake
	STRB r6, [r4]
	MOV r8, #1				; 1 = indicator to go up
	CMP r9, #1
	BEQ start_game
	B end_key
key_j						; key to go left
	SUB r4, r4, #1			; address left head of snake

	STRB r6, [r4]
	MOV r8, #2				; 2 = indicator to go left
	CMP r9, #1
	BEQ start_game
	B end_key
key_k						; key to go down
	ADD r4, r4, #44			; address below head of snake
	STRB r6, [r4]
	MOV r8, #3				; 3 = indicator to go down
	CMP r9, #1
	BEQ start_game
	B end_key
key_l						; key to go right
	ADD r4, r4, #1			; address right of head of snake
	STRB r6, [r4]
	MOV r8, #4				; 4 = indicator to go right
	CMP r9, #1
	BEQ start_game
	B end_key
start_game
	ADD r9, r9, #1
	BL timer_init
	;MOV r0, #0x000C
	;MOVT r0, #0x4003		; Enable Timer GPTM Control Register (GPTMCTL)
	;LDRB r1, [r0]
	;MOV r3, #1
	;ORR r1, r1, r3
	;STRB r1, [r0]			; Enable Timer A, Set bit 0 = 1, TAEN
	;ADD r9, r9, #1
	;B end_key
end_key

	LDMFD sp!, {lr}
	MOV pc, lr

uart_init:
	STMFD SP!,{lr}			; Store register lr on stack
	MOV r0, #0xE618
	MOVT r0, #0x400F		; r2 = 0x400FE618
	MOV r1, #0
	LDR r1, [r0]			; load r3 = [r2]
	MOV r2, #1
	ORR r1, r1, r2			; Provide Clock to UART0, 0x400FE618 = 0x400FE618 | 1
	STR r1, [r0]
	MOV r0, #0xE608
	MOVT r0, #0x400F		; r2 = 0x400FE608
	LDR r1, [r0]			; load r3 = [r2]
	ORR r1, r1, r2			; enable clock to PortA 0x400FE608 = 0x400FE608 | 1
	STR r1, [r0]
	MOV r0, #0xC030
	MOVT r0, #0x4000		; r2 = 0x4000C030
	LDR r1, [r0]			; load r3 = [r2]
	MOV r2, #0
	ORR r1, r1, r2			; Disable UART0 Control 0x4000C030 = 0x4000C030 | 0
	STR r1, [r0]
	MOV r0, #0xC024
	MOVT r0, #0x4000		; r2 = 0x4000C024
	LDR r1, [r0]			; load r3 = [r2]
	MOV r2, #8
	ORR r1, r1, r2			; Set UART0_IBRD_R for 115200 baud 0x4000C024 | 8
	STR r1, [r0]
	MOV r0, #0xC028
	MOVT r0, #0x4000		; r0 = 0x4000C028
	LDR r1, [r0]
	MOV r2, #44
	ORR r1, r1, r2			; Set UART0_FBRD for 115200 baud 0x4000C028 | 44
	STR r1, [r0]
	MOV r0, #0xCFC8
	MOVT r0, #0x4000		; r0 = 0x4000CFC8
	LDR r1, [r0]
	MOV r2, #0
	ORR r1, r1, r2			; Use System Clock 0x4000CFC8 | 0
	STR r1, [r0]
	MOV r0, #0xC02C
	MOVT r0, #0x4000		; r0 = 0x4000C02C
	LDR r1, [r0]
	MOV r2, #0x60
	ORR r1, r1, r2			; Use 8 bit word length, 1 stop but no parity 0x4000C03C | 0x60
	STR r1, [r0]
	MOV r0, #0xC030
	MOVT r0, #0x4000		; r0 = 0x4000C030
	LDR r1, [r0]
	MOV r2, #0x301
	ORR r1, r1, r2			; Enable UART Control 0x4000C030 | 0x301
	STR r1, [r0]
	MOV r0, #0x451C
	MOVT r0, #0x4000		; r0 = 0x4000451C
	LDR r1, [r0]
	MOV r2, #0x03
	ORR r1, r1, r2			; Make PA0 and PA1 as Digital Ports, 0x4000451C | 0x03
	STR r1, [r0]
	MOV r0, #0x4420
	MOVT r0, #0x4000		; r0 = 0x40004420
	LDR r1, [r0]
	ORR r1, r1, r2			; Change PA0, PA1 to use alternate function 0x40004420 | 0x03
	STR r1, [r0]
	MOV r0, #0x452C
	MOVT r0, #0x4000
	LDR r1, [r0]
	MOV r2, #0x11
	ORR r1, r1, r2			; Configure PA0 and Pa1 for UART, 0x4000452C | 0x11
	STR r1, [r0]
	MOV r2, #0				;clear r2
	MOV r5, #0xC038
	MOVT r5, #0x4000		; UART Receive Interrupt Mask (RXIM)
	MOV r2, #0x10
	STRB r2, [r5]			; Write 1 to RXIM
	MOV r5, #0xE100
	MOVT r5, #0xE000		; NVIC
	LDRB r3, [r5]
	MOV r2, #0x20			; "1" to bit 5 of EN0
	ORR r2, r2, r3
	STRB r2, [r5]			; Enable UART Interrupt
	LDMFD SP!, {lr}
	mov pc, lr

timer_init:
	STMFD SP!,{lr}		; Store register lr on stack

	MOV r0, #0xE604
	MOVT r0, #0x400F	; General Purpose Timer Run Mode Clock Gating Control, RCGCTIMER register
	LDRB r1, [r0]
	MOV r2, #0x1
	ORR r1, r1, r2
	STRB r1, [r0]		; Write 1 to connect T0
	MOV r0, #0x000C
	MOVT r0, #0x4003	; GPTM Control Register (GPTMCTL)
	LDRB r1, [r0]
	MOV r2, #0xFE
	AND r1, r1, r2
	STRB r1, [r0]		; Disable TimerA
	MOV r0, #0x0000
	MOVT r0, #0x4003	; GPTM Configuration Register
	LDRB r1, [r0]
	AND r1, r1, r2
	STRB r1, [r0]		; Setup Timer for 32 bit Mode, configuration 0
	MOV r0, #0x0004
	MOVT r0, #0x4003	; GPTM Timer A Mode Register
	LDRB r1, [r0]
	MOV r2, #0x2
	ORR r1, r1, r2
	STRB r1, [r0]		; Configuration 2, Periodic Mode
	MOV r0, #0x0028
	MOVT r0, #0x4003	; Set Interrupt Interval (period), GPTM Timer A Interval Load Register
	MOV r1, #0x0900
	MOVT r1, #0x003D	; 4,000,000 clock ticks for period, 16MHZ -> .25 secs
	STR r1, [r0]
	MOV r0, #0x0018
	MOVT r0, #0x4003	; GPTM Interrupt Mask Register (GPTMIMR)
	LDRB r1, [r0]
	MOV r2, #1
	ORR r1, r1, r2
	STRB r1, [r0]		; Timer A Timeout Interrupt Mask (TATOIM)
	MOV r0, #0xE100
	MOVT r0, #0xE000	; Nested Vector Interrupt Controller (NVIC)
	LDR r1, [r0]
	MOV r2, #0x0000
	MOVT r2, #0x8		; Bit 19 = 1, Enable
	ORR r1, r1, r2
	STR r1, [r0]
	MOV r0, #0x000C
	MOVT r0, #0x4003		; Enable Timer GPTM Control Register (GPTMCTL)
	LDRB r1, [r0]
	MOV r3, #1
	ORR r1, r1, r3
	STRB r1, [r0]			; Enable Timer A, Set bit 0 = 1, TAEN

	LDMFD SP!, {lr}
	mov pc, lr

UART0Handler:
	STMFD SP!,{lr}		; Store register lr on stack
	MOV r2, #0xC000
	MOVT r2, #0x4000
	MOV r0, #0x0000
	MOVT r0, #0x2000
	BL read_character
	MOV r1, #0x0C
	;BL output_character
	MOV r0, #0x0000
	MOVT r0, #0x2000
	LDMFD SP!, {lr}
	BX lr

print_board:
	STMFD SP!,{lr}		; Store register lr on stack
	LDR r0, ptr
printing
	LDRB r1, [r0]			; load character
	CMP r1, #0x00			; compare to null
	BEQ printing_end		; if null branch to timer_init
	BL output_character
	ADD r0, r0, #1			; increment address
	B printing
printing_end
	LDMFD SP!, {lr}
	MOV pc, lr

stop_game:
	STMFD SP!,{lr}		; Store register lr on stack
	MOV r1, #0x0C
	BL output_character	; clear screen
	MOV r1, #0
	ADR r10, score

print_score_string
	LDRB r1, [r10]
	CMP r1, #0x00
	BEQ reset_address
	BL output_character
	ADD r10, r10, #1
	B print_score_string
	MOV r3, #0
reset_address
	MOV r0, #0x0000
	MOVT r0, #0x2000
end_string
	LDRB r10, [r0]
	CMP r10, #0x00
	BEQ null_found
	CMP r10, #0x2A
	BEQ asterisk_found
	ADD r0, r0, #1			; increment address
	B end_string
asterisk_found
	ADD r3, r3, #1			; increment asterisk counter
	ADD r0, r0, #1			; increment address
	B end_string
null_found
	CMP r3, #9
	BGT two_digit_result
	ADD r3, r3, #48
	MOV r1, r3
	BL output_character
	B done
two_digit_result			; convert 2 digit result to char value
	CMP r3, #10
	BLT print_result
	SUB r3, r3, #10
	ADD r11, r11, #1
	B two_digit_result
print_result
	MOV r7, r3
	ADD r7, r7, #48
	MOV r1, r11
	ADD r1, r1, #48
	BL output_character
	MOV r1, r7
	BL output_character
	B done
done
	BL finish
	LDMFD SP!, {lr}
	MOV pc, lr

Timer0Handler:
	STMFD SP!,{lr}		; Store register lr on stack

	MOV r0, #0x0024
	MOVT r0, #0x4003	; GPTM Interrupt Clear Register (GPTMICR)
	LDRB r0, [r1]
	MOV r2, #1
	ORR r1, r1, r2
	STRB r1, [r0]		; Clear interrupt
	MOV r0, #0x0000
	MOVT r0, #0x2000
	BL print_board
	;ADD r9, r9, #1
	CMP r8, #1
	BEQ up
	CMP r8, #2
	BEQ left
	CMP r8, #3
	BEQ down
	CMP r8, #4
	BEQ right
up							; store asterisk above snake head
	SUB r4, r4, #44
	LDRB r7, [r4]
	CMP r7, #0x20
	BNE collision
	STRB r6, [r4]
	B hello
left						; store asterisk left of snake head
	SUB r4, r4, #1
	LDRB r7, [r4]
	CMP r7, #0x20
	BNE collision
	STRB r6, [r4]
	B hello
down						; store asterisk below snake head
	ADD r4, r4, #44
	LDRB r7, [r4]
	CMP r7, #0x20
	BNE collision
	STRB r6, [r4]
	B hello
right						; store asterisk right of snake head
	ADD r4, r4, #1
	LDRB r7, [r4]
	CMP r7, #0x20
	BNE collision
	STRB r6, [r4]
	B hello

collision					; Found collision
	MOV r0, #0x000C
	MOVT r0, #0x4003	; GPTM Control Register (GPTMCTL)
	LDRB r1, [r0]
	MOV r2, #0xFE
	AND r1, r1, r2
	STRB r1, [r0]		; Disable TimerA
	BL stop_game
hello


	LDMFD SP!, {lr}
	BX lr
finish:
	.end
