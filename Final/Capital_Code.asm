;To initiaLise the model tiny of initial part
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


	;To Jump the initiALisation part of the coDe.
	JMP ST1


	;To initiALise the PORTs of the 8255s
	PORT1A equ 00h    
	PORT1B equ 02h
	PORT1C equ 04h
	CREG1 equ  06h

	PORT2A equ 10h
	PORT2B equ 12h
	PORT2C equ 14h
	CREG2 equ  16h

	;Hex coDes for keypaD
	TABLEK    	Db    0eeh, 0eDh, 0eBH, 0e7h,        	;0, 1, 2, 3
				Db    0Deh, 0DDh, 0DBH, 0D7h,        	;4, 5, 6, 7,
				Db    0beh, 0bDh, 0bBH, 0b7h,        	;8, 9, Backspace, Enter,
				Db    07eh                        		;Test

	;Hex coDes for DIsplay
	TABLED     	Db    0c0h, 0f9h, 0a4h, 0b0h,     	;0, 1, 2, 3,
				Db    099h, 092h, 082h, 0f8h,      	;4, 5, 6, 7,
				Db    080h, 090h, 08CH, 088h,       ;8, 9, P, A,
				Db    092h, 08eh, 0f9h, 0c7h,       ;S, F, I, L



	;Create the Database with IC numbers
	NANDIC     	Db '7400'
	ANDIC    	Db '7408'
	ORIC     	Db '7432'
	XORIC     	Db '7486'
	XNORIC     	Db '747266'
	IPIC    	Db 6 Dup(0)
	IPIC2    	Db 6 Dup(08eh)

	CNTDGTS 	Db 0
	FLAG    	Db 0
	FAILW    	Db 08EH,088H,0F9H,0C7H,00h
	PASSW    	Db 08CH,088H,092H,092H


;CODE STARTS FROM HERE-----------------------------------------------------------------------------------------
ST1:    CLI

;InitiALise the segments.
	MOV AX,0200H
	MOV DS,AX
	MOV ES,AX
	MOV SS,AX
	MOV SP,0FFFEH



;InitiALise the 8255s
;8255_1
	MOV AL,10001000b
	OUT CREG1,AL
	MOV AL,11111111B
	OUT PORT1A,AL

	X0:		MOV AL,00H
			OUT PORT1C,AL
	X1:     
	Z22:    MOV CH,CS:CNTDGTS
			MOV AL,0h
			OUT PORT1B,AL
			CMP CH,0
			JE ZX
			MOV BP,0
			MOV    BH,CS:IPIC2[BP]
			MOV    BL,1

			Z21:    MOV AL,0
			OUT PORT1B,AL
			MOV    AL,BH
			OUT    PORT1A,AL

			MOV    AL,BL
			OUT    PORT1B,AL
			ROL    BL,1
			INC BP
			MOV    BH,CS:IPIC2[BP]
			DEC CH
			JNZ Z21
		;Jump to DISPLAY During every poll
			ZX:        
			IN AL, PORT1C    
			AND AL,0F0H        ;CHECK FOR KEY RELEASE
			CMP AL,0f0H        
			JNZ X1
			
		X2:
		Z12:MOV CH,CS:CNTDGTS
			MOV AL,0h
			OUT PORT1B,AL
			CMP CH,0
			JE ZY
			MOV BP,0
			;LEA SI,CS:IPIC2
			MOV    BH,CS:IPIC2[BP]
			MOV    BL,1
		Z11:MOV AL,0
			OUT PORT1B,AL

			MOV AL,BH
			OUT PORT1A,AL
			MOV AL,BL
			OUT PORT1B,AL
			ROL BL,1
			INC BP
			MOV BH,CS:IPIC2[BP]
			DEC CH
			JNE Z11
		ZY:	MOV AL,00H
			OUT PORT1C,AL
			IN AL,PORT1C
			AND AL,0F0H
		J2:	CMP AL,0F0H
			JZ X2
			;call D20MS
			;OUT PORT1C,AL
			;IN AL,PORT1C
			;AND AL,0F0H
			;CMP AL,0F0H
			;JZ X2
			MOV AL,0EH
			MOV BL,AL
			OUT PORT1C,AL
			IN  AL,PORT1C
			AND AL,0F0H
			CMP AL,0F0H
			JNZ X3

			MOV AL,0DH
			MOV BL,AL
			OUT PORT1C,AL
			IN AL,PORT1C
			AND AL,0F0H
			CMP AL,0F0H
			JNZ X3

			MOV AL,0BH
			MOV BL,AL
			OUT PORT1C,AL
			IN  AL,PORT1C
			AND AL,0F0H
			CMP AL,0F0H
			JNZ X3

			MOV AL, 07H
			MOV BL,AL
			OUT PORT1C,AL
			IN  AL,PORT1C
			AND AL,0F0H
			CMP AL,0F0H
			JZ X2

		X3: OR AL,BL
			MOV CX,0FH
			MOV DI,00H
		X4: CMP AL,CS:TABLEK[DI]
			JZ  X5
			INC DI
			LOOP X4

		X5: LEA BX,TABLED
			CMP DI,9
			JA BCKSPC
			CMP CS:CNTDGTS,6                ;CHecking if the number of DIgits are less than 6 to take input
			JE X0
			MOV Dl,CS:CNTDGTS
			MOV Dh,0
			MOV SI,DX
			MOV AX,DI
			ADD AX,'0'
			MOV CS:IPIC[SI],AL
			MOV AL,CS:TABLED[DI]
			MOV CS:IPIC2[SI],AL
			INC CS:CNTDGTS
			JMP x0
							;Jump to DISPLAY if there is a DIgit entereD
		J3:
	
	
		BCKSPC: CMP DI,10                    ;CHeck for Backspace
				JNE ENTER1
				CMP CS:CNTDGTS,0
				JE X0                        ;CHecking if the DIgits are more than 0 before backspace
				DEC CS:CNTDGTS
					JMP x0

		ENTER1: CMP DI,11                    ;CHeck for enter
				JNE X0
				;If it is enter, we take in only one key-press. ie, TEST
			Y0:	MOV AL,00H
				OUT PORT1C,AL
			Y1:
			Z32:MOV CH,CS:CNTDGTS
				CMP CH,0
				JE ZX1
				MOV BP,0
				MOV    BH,CS:IPIC2[BP]
				MOV    BL,1
			Z31:MOV AL,0
				OUT PORT1B,AL
				MOV AL,BH
				OUT PORT1A,AL
				MOV AL,BL
				OUT PORT1B,AL
				ROL BL,1
				INC BP
				MOV    BH,CS:IPIC2[BP]
				DEC CH
				JNZ Z31
			ZX1:
				IN AL, PORT1C
				AND AL,0F0H
				CMP AL,0F0H
				JNZ Y1
				MOV AL,00H
				OUT PORT1C,AL
			Y2:
			Z42:MOV CH,CS:CNTDGTS
				CMP CH,0
				JE ZX2
				MOV BP,0
				MOV    BH,CS:IPIC2[BP]
				MOV    BL,1
			Z41:    MOV AL,0
				OUT PORT1B,AL
				MOV    AL,BH
				OUT    PORT1A,AL

				MOV    AL,BL
				OUT    PORT1B,AL
				ROL    BL,1
				INC BP
				MOV    BH,CS:IPIC2[BP]
				DEC CH
				JNZ Z41
			ZX2:
				MOV AL,00H
				OUT PORT1C,AL
				IN AL,PORT1C
				AND AL,0F0H
				CMP AL,0F0H
				JZ Y2
				MOV AL,00H
				OUT PORT1C,AL
				IN AL,PORT1C
				AND AL,0F0H
				CMP AL,0F0H
				JZ Y2
				;call D20MS
				;MOV AL,00H
				;OUT PORT1C,AL
				;IN AL,PORT1C
				;AND AL,0F0H
				;CMP AL,0F0H
				;JZ Y2
				
				MOV AL, 0eH
				MOV BL,AL
				OUT PORT1C,AL
				IN  AL,PORT1C
				AND AL,0F0H
				CMP AL,0F0H
				JZ Y2
			Y3:	OR AL,BL
				MOV CX,0FH
				MOV DI,00H

			Y4:	CMP AL,CS:TABLEK[DI]
				JZ  Y5
				INC DI
				LOOP Y4
			Y5: CMP DI,12
				JNE Y0
				MOV AH,CS:CNTDGTS
				CMP AH,4
				JE NEXT4
				CMP AH,6
				JE NEXT6
				JMP FAIL

				
				
	;CHecking in 4 DIgit IC Database
		NEXT4:
					MOV CX,4
					MOV BP,0
			D1:     MOV AL,CS:IPIC[BP]

					MOV AH,CS:NANDIC[BP]
					INC BP
					CMP AH,AL            ;CHecking for NAND
					JNE D2
					DEC CX
					CMP CX,0
					JE TESTNAND
					JMP D1   
							   
							   
			D2:     MOV BP,0
					MOV CX,4
			D3:     MOV AL,CS:IPIC[BP]
					MOV AH,CS:ANDIC[BP]
					INC BP
					CMP AH,AL            ;Checking for AND
					JNE D4
					DEC CX
					CMP CX,0
					JE TESTAND
					JMP D3

			D4:     MOV BP,0
					MOV CX,4
			D5:     MOV AL,CS:IPIC[BP]  
					MOV AH,CS:ORIC[BP]
					INC BP
					CMP AH,AL            ;CHecking for OR
					JNE D6
					DEC CX
					CMP CX,0
					JE TESTOR
					JMP D5
					
			D6:     MOV BP,0
					MOV CX,4
			D7:     MOV AL,CS:IPIC[BP]
					;LEA DI,XORDIC
					MOV AH,CS:XORIC[BP]
					INC BP
					CMP AH,AL            ;CHecking for Xor
					JNE D8
					DEC CX
					CMP CX,0
					JE TESTXOR
					JMP D7

			D8:     JMP FAIL                ;If none of the ICS in the Database matCH, then fail


;Check the IC number in the 6 DIgit IC Database
	NEXT6:	MOV BP,0
			MOV CX,6
		D9:	MOV AL,CS:IPIC[BP]
	
			MOV AH,CS:XNORIC[BP]
			INC BP
			CMP AH,AL            ;CHecking for Xnor
			JNE D10
			DEC CX
			CMP CX,0
			JE TESTXNOR
			JMP D9

		D10:JMP FAIL                ;If none of the ICS in the Database matCH, then fail

		
		
;To test for AND IC
	TESTAND:
			;CREG
			MOV AL,10001010b
			OUT CREG2,AL

			;ACTUAL
			MOV AL,00
			OUT PORT2A,AL
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,0
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,0
			JNE FAIL


			MOV AL,1AH
			OUT PORT2A,AL
			MOV AL,2H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,0
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,0
			JNE FAIL

			MOV AL,25H
			OUT PORT2A,AL
			MOV AL,1H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,0
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,0
			JNE FAIL

			MOV AL,3FH
			OUT PORT2A,AL
			MOV AL,3H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,30H
			JNE FAIL

			JMP PASS
			
			

;Testing for NAND-IC
	TESTNAND:
			;CREG
			MOV AL,10001010b
			OUT CREG2,AL

			MOV AL,00
			OUT PORT2A,AL
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,30H
			JNE FAIL

			MOV AL,1AH
			OUT PORT2A,AL
			MOV AL,2H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,30H
			JNE FAIL

			MOV AL,25H
			OUT PORT2A,AL
			MOV AL,1H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,30H
			JNE FAIL

			MOV AL,3FH
			OUT PORT2A,AL
			MOV AL,3H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,0
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,0H
			JNE FAIL

			JMP PASS
			
			

;Testing for OR-IC
	TESTOR:
			MOV AL,10001010b
			OUT CREG2,AL


			MOV AL,00
			OUT PORT2A,AL
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,0
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,0H
			JNE FAIL

			MOV AL,1AH
			OUT PORT2A,AL
			MOV AL,2H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,30H
			JNE FAIL

			MOV AL,25H
			OUT PORT2A,AL
			MOV AL,1H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,30H
			JNE FAIL

			MOV AL,3FH
			OUT PORT2A,AL
			MOV AL,3H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,30H
			JNE FAIL

			JMP PASS
			
			

;Testing for XOR-IC
	TESTXOR:
			;CREG
			MOV AL,10001010b
			OUT CREG2,AL

			MOV AL,00
			OUT PORT2A,AL
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,0
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,0H
			JNE FAIL

			MOV AL,1AH
			OUT PORT2A,AL
			MOV AL,2H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,30H
			JNE FAIL

			MOV AL,25H
			OUT PORT2A,AL
			MOV AL,1H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,03
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,30H
			JNE FAIL

			MOV AL,3FH
			OUT PORT2A,AL
			MOV AL,3H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,0
			JNE FAIL
			IN AL,PORT2C
			AND AL,30H
			CMP AL,0H
			JNE FAIL

			JMP PASS
			
			

;Testing for XNOR-IC
	TESTXNOR:
			;CHanging CREG to suite this particular IC
			MOV AL,10000011b
			OUT CREG2,AL
			;CHANGE IF IT IS WRONG !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			;ACTUAL TESTING
			MOV AL,00
			OUT PORT2A,AL
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,3H
			CMP AL,3H
			JNE FAIL

			MOV AL,1AH
			OUT PORT2A,AL
			MOV AL,20H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,0
			JNE FAIL
			IN AL,PORT2C
			AND AL,3H
			CMP AL,0H
			JNE FAIL

			MOV AL,25H
			OUT PORT2A,AL
			MOV AL,10H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,0
			JNE FAIL
			IN AL,PORT2C
			AND AL,3H
			CMP AL,0H
			JNE FAIL

			MOV AL,3FH
			OUT PORT2A,AL
			MOV AL,30H
			OUT PORT2C,AL
			IN AL,PORT2B
			AND AL,3
			CMP AL,3
			JNE FAIL
			IN AL,PORT2C
			AND AL,3H
			CMP AL,3H
			JNE FAIL

			JMP PASS




;To display 'fail'
	FAIL:
			MOV DI,5000
		A2: MOV CH,4
			MOV BP,0

			MOV BH,CS:FAILW[BP]
			MOV BL,1

		A1: MOV AL,0
			OUT PORT1B,AL
			MOV AL,BH
			OUT PORT1A,AL

			MOV AL,BL
			OUT PORT1B,AL
			ROL BL,1
			INC BP
			MOV BH,CS:FAILW[BP]
			DEC CH
			JNZ A1
			DEC DI
			JNZ A2

			MOV AL,0
			MOV CS:CNTDGTS,AL
			JMP ST1

			
			
;To display 'pass'
	PASS:
			MOV DI,5000h
			
		A12:MOV CH,4
			MOV BP,0

			MOV BH,CS:PASSW[BP]
			MOV BL,1

		A11:MOV AL,0
			OUT PORT1B,AL
			MOV AL,BH
			OUT PORT1A,AL
			MOV AL,BL
			OUT PORT1B,AL
			ROL BL,1
			INC BP
			MOV BH,CS:PASSW[BP]
			DEC CH
			JNZ A11
			DEC DI
			JNZ A12

			MOV AL,0
			MOV CS:CNTDGTS,AL
			JMP ST1
			
			

DISDIG PROC NEAR
	Z2:	MOV CH,CS:CNTDGTS
		CMP CH,0
		JE ZZ
		MOV BP,0
		MOV BH,CS:IPIC2[BP]
		MOV BL,1
	Z1:	MOV AL,BL
		OUT PORT1B,AL
		MOV AL,BH
		OUT PORT1A,AL
		ROL BL,1
		INC BP
		MOV BH,CS:IPIC2[BP]
		DEC CH
		JNE Z1
	ZZ:
	ret
DISDIG endp



D20MS:    MOV CX,2220
xn:       LOOP xn
ret

sub1 PROC NEAR
		PUSH      CX
		MOV        CX,10 ; Delay generateD will be approx 0.45 seCS
		Z3:          LOOP        Z3
		POP       CX
sub1 endp



; [SOURCE]: C:\Users\ratna\DownloaDs\BITS ACADS\2.2\INSTR F241 MICROPROC & INTERFACING (MuP)\ProJEct\19_04_02\coDe2.asm
