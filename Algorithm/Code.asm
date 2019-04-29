#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#


	;To jump the initialisation part of the code.
	jmp St1
	
	
	;To initialise the ports of the 8255s
	Port1A equ 03000h	;CHANGE IF THERE IS AN ERROR!!!!!!!!
	Port1B equ 03002h
	Port1C equ 03004h
	Creg1 equ  03006h
	
	Port2A equ 04000h
	Port2B equ 04002h
	Port2C equ 04004h
	Creg2 equ  04006h
	
	;Hex codes for keypad
	TableK	db	0eeh, 0edh, 0ebh, 0e7h,		;0, 1, 2, 3
			db	0deh, 0ddh, 0dbh, 0d7h,		;4, 5, 6, 7,
			db	0beh, 0bdh, 0bbh, 0b7h,		;8, 9, Backspace, Enter,
			db	07eh						;Test
			
	;Hex codes for display
	TableD 	db 	0c0h, 0f9h, 0a4h, 0b0h,		;0, 1, 2, 3,
				099h, 092h, 082h, 0f8h,		;4, 5, 6, 7,
				080h, 090h, 09ch, 088h,		;8, 9, P, A,
				092h, 08eh, 0f9h, 0c7h		;S, F, I, L
	
	
	;Initialise the stack
	Stack1 dw 30 dup(0)
	Tstack1 dw 0
	
	;Create the database with IC numbers
	NandIC 	db '7400'
	AndIC	db '7408'
	OrIC 	db '7432'
	XorIC 	db '7486'
	XnorIC 	db '747266'
	IpIC	db 6 dup(0)
	
	CntDgts db 0
	
	
	
	;CODE STARTS FROM HERE
St1:	CLI
		
		;Initialise the segments.
		MOV AX,0200h
		MOV DS,AX
		MOV ES,AX
		MOV SS,AX
		
		;Initialise the Stack Pointer.
		lEA SP,Tstack1
		
		;Initialise the 8255s
		;8255_1
		MOV AL,10001000b
		OUT Creg1,AL
		
		;8255_2
		MOV AL,10001010b
		OUT Creg2,AL
		
		
		;Keypress checking
X0:		MOV AL,00H
		OUT Port1C,AL
X1: 	IN AL, Port1C
		AND AL,0F0H
		CMP AL,0F0H
		JNZ X1
		CALL D20MS
		MOV AL,00H
		OUT Port1C,AL
X2:		IN AL,Port1C
		AND AL,0F0H
		CMP AL,0F0H
		JZ X2
		CALL D20MS
		MOV AL,00H
		OUT Port1C,AL
		IN AL,Port1C
		AND AL,0F0H
		CMP AL,0F0H
		JZ X2
		MOV AL,0EH
		MOV BL,AL
		OUT Port1C,AL
		IN  AL,Port1C
		AND AL,0F0H
		CMP AL,0F0H
		JNZ X3
		MOV AL,0DH
		MOV BL,AL
		OUT Port1C ,AL
		IN AL,Port1C
		AND AL,0F0H
		CMP AL,0F0H
		JNZ X3
		MOV AL,0BH
		MOV BL,AL
		OUT Port1C,AL
		IN  AL,Port1C
		AND AL,0F0H
		CMP AL,0F0H
		JNZ X3
		MOV AL, 07H
		MOV BL,AL
		OUT Port1C,AL
		IN  AL,Port1C
		AND AL,0F0H
		CMP AL,0F0H
		JZ X2
X3:		OR AL,BL
		MOV CX,0FH
		MOV DI,00H
X4:		CMP AL,CS:TableK[DI]
		JZ  X5
		INC DI
		LOOP X4
X5:		LEA BX,TableD
		CMP DI,9
		JG BCKSPC
		CMP CntDgts,6				;Checking if the number of digits are less than 6 to take input
		JE X0
		LEA SI,IpIC
		MOV AL,CS:[BX+DI]
		MOV [SI+CntDgts],AL
		INC CntDgts
		JMP DISDIG					;Jump to DISPLAY if there is a digit entered
		
		
BCKSPC:	CMP DI,10					;Check for Backspace
		JNE ENTER1
		CMP CntDgts,0
		JE X0						;Checking if the digits are more than 0 before backspace
		DEC CntDgts
		
		
ENTER1:	CMP DI,11					;Check for enter
		JNE X0
		;If it is enter, we take in only one key-press. ie, TEST
				Y0:		MOV AL,00H
				OUT Port1C,AL
		Y1: 	IN AL, Port1C
				AND AL,0F0H
				CMP AL,0F0H
				JNZ Y1
				CALL D20MS
				MOV AL,00H
				OUT Port1C,AL
		Y2:		IN AL,Port1C
				AND AL,0F0H
				CMP AL,0F0H
				JZ Y2
				CALL D20MS
				MOV AL,00H
				OUT Port1C,AL
				IN AL,Port1C
				AND AL,0F0H
				CMP AL,0F0H
				JZ Y2
				MOV AL,0EH
				MOV BL,AL
				OUT Port1C,AL
				IN  AL,Port1C
				AND AL,0F0H
				CMP AL,0F0H
				JNZ Y3
				MOV AL,0DH
				MOV BL,AL
				OUT Port1C ,AL
				IN AL,Port1C
				AND AL,0F0H
				CMP AL,0F0H
				JNZ Y3
				MOV AL,0BH
				MOV BL,AL
				OUT Port1C,AL
				IN  AL,Port1C
				AND AL,0F0H
				CMP AL,0F0H
				JNZ Y3
				MOV AL, 07H
				MOV BL,AL
				OUT Port1C,AL
				IN  AL,Port1C
				AND AL,0F0H
				CMP AL,0F0H
				JZ Y2
		Y3:		OR AL,BL
				MOV CX,0FH
				MOV DI,00H
		Y4:		CMP AL,CS:TableK[DI]
				JZ  Y5
				INC DI
				LOOP Y4
		Y5:		CMP DI,12
				JNE Y0
				
				CMP CntDgts,4
				JE NEXT4
				CMP CntDgts,6
				JE NEXT6
				JMP FAIL
				
				;Checking in 4 digit IC database
		NEXT4:	MOV CX,4			
				CLD
				LEA SI,IpIC
				LEA DI,NandIC			;Checking for NAND
				REPE CMPSB
				CMP CX,0
				JE TESTNAND
				
				MOV CX,4
				CLD
				LEA SI,IpIC
				LEA DI,AndIC			;Checking for AND
				REPE CMPSB
				CMP CX,0
				JE TESTAND
				
				MOV CX,4
				CLD
				LEA SI,IpIC
				LEA DI,OrIC				;Checking for OR
				REPE CMPSB
				CMP CX,0
				JE TESTOR
				
				MOV CX,4
				CLD
				LEA SI,IpIC
				LEA DI,XorIC			;Checking for XorIC
				REPE CMPSB
				CMP CX,0
				JE TESTXOR
				
				JMP FAIL				;If none of the ICs in the database match, then fail
				
				
				;Check the IC number in the 6 digit IC database
		NEXT6:	MOV CX,6
				CLD
				LEA SI,IpIC
				LEA DI,XnorIC			;Check for XnorIC
				REPE CMPSB
				CMP CX,0
				JE TESTXNOR
				
				JMP FAIL				;If none of the ICs in the database match, then fail
				
		;;;;HAVE TO WRITE FROM HERE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
				;Testing for AND-IC
		TESTAND:
		
		
				;Testing for NAND-IC
		TESTNAND:	
	
	
				;Testing for OR-IC
		TESTOR:
		
		
				;Testing for XOR-IC
		TESTXOR:
				
				
				;Testing for XNOR-IC
		TESTXNOR:

	
	;To display every digit after input of display
DISDIG:

	;To display FAIL
FAIL:

	;To display PASS
PASS:



;Delay generated will be approx 0.45 secs
;Delay Function
D20MS:	mov cx,2220
xn:		loop xn
ret

	