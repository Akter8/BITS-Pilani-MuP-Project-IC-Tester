;To initialise the model tiny of initial part
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
jmp st1


;To initialise the ports of the 8255s
Port1A equ 00h    ;CHANGE IF THERE IS AN ERROR!!!!!!!!
Port1B equ 02h
Port1C equ 04h
Creg1 equ  06h

Port2A equ 10h
Port2B equ 12h
Port2C equ 14h
Creg2 equ  16h

;Hex codes for keypad
TableK    db    0eeh, 0edh, 0ebh, 0e7h,        ;0, 1, 2, 3
db    0deh, 0ddh, 0dbh, 0d7h,        ;4, 5, 6, 7,
db    0beh, 0bdh, 0bbh, 0b7h,        ;8, 9, Backspace, Enter,
db    07eh                        ;Test

;Hex codes for display
TableD     db     0c0h, 0f9h, 0a4h, 0b0h        ;0, 1, 2, 3,
db    099h, 092h, 082h, 0f8h        ;4, 5, 6, 7,
db    080h, 090h, 08ch, 088h        ;8, 9, P, A,
db    092h, 08eh, 0f9h, 0c7h        ;S, F, I, L


;Initialise the stack
;Stack1 dw 30 dup(0)
;Tstack1 dw 0

;Create the database with IC numbers
NandIC     db '7400'
AndIC    db '7408'
OrIC     db '7432'
XorIC     db '7486'
XnorIC     db '747266'
IpIC    db 6 dup(0)
IpIC2    db 6 dup(08eh)

CntDgts db 0
FLAG    db 0
FAILW    db 08EH,088H,0F9H,0C7H,00h
PASSW    db 08CH,088H,092H,092H


;CODE STARTS FROM HERE
st1:    CLI

;Initialise the segments.
	MOV AX,0200H
	MOV DS,AX
	MOV ES,AX
	MOV SS,AX
	MOV SP,0FFFEH

;Initialise the Stack Pointer.
;lEA SP,Tstack1

;Initialise the 8255s
;8255_1
MOV AL,10001000b
OUT Creg1,AL
MOV AL,11111111B
OUT Port1A,AL
;8255_2
;MOV AL,10001010b
;OUT Creg2,AL

X0:        MOV AL,00H
OUT Port1C,AL
X1:     Z22:    MOV CH,cs:CntDgts
mov al,0h
OUT Port1B,al
cmp ch,0
je zx
MOV bp,0
;LEA SI,CS:IpIC2
mov    bH,cs:IpIC2[bp]
mov    bL,1

Z21:    mov al,0
out Port1B,al
mov    al,bH
out    Port1A,al

mov    AL,BL
out    Port1B,al

;call sub1
rol    bl,1
INC bp
mov    bH,cs:IpIC2[bp]
DEC CH
JNZ Z21
zx:        ;Jump to DISPLAY during every poll
IN AL, Port1C    ;
AND AL,0F0H        ;CHECK FOR KEY RELEASE
j1:        CMP AL,0f0H        ;
JNZ X1

X2:        Z12:    MOV CH,cs:CntDgts
mov al,0h
OUT Port1B,al
cmp ch,0
je zy
MOV bp,0
;LEA SI,CS:IpIC2
mov    bH,cs:IpIC2[bp]
mov    bL,1
Z11:    mov al,0
out Port1B,al

mov    al,bH
out    Port1A,al
mov    AL,BL
out    Port1B,al
;call sub1
rol    bl,1
INC bp
mov    bH,cs:IpIC2[bp]
DEC CH
JNE Z11
zy:
MOV AL,00H
OUT Port1C,AL
IN AL,Port1C
AND AL,0F0H
j2:        CMP AL,0F0H
JZ X2

;call DISDIG
;CALL D20MS
;MOV AL,00H
;OUT Port1C,AL
;IN AL,Port1C
;AND AL,0F0H
;CMP AL,0F0H
;JZ X2
;inc cs:CntDgts
;mov ch,6
;inc CntDgts
;CALL DISDIG
MOV AL,0EH
MOV BL,AL
OUT Port1C,AL
IN  AL,Port1C
AND AL,0F0H
CMP AL,0F0H
JNZ X3

MOV AL,0DH
MOV BL,AL
OUT Port1C,AL
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

X3:        OR AL,BL
MOV CX,0FH
MOV DI,00H
X4:        CMP AL,CS:TableK[DI]
JZ  X5
INC DI
LOOP X4

X5:        LEA BX,TableD
CMP DI,9
JA BCKSPC
CMP cs:CntDgts,6                ;Checking if the number of digits are less than 6 to take input
JE X0
;LEA SI,IpIC
mov Dl,cs:CntDgts
mov dh,0
mov si,dx
MOV AX,DI
ADD AX,'0'
MOV cs:IpIC[si],AL
;LEA SI,IpIC2
MOV AL,CS:TableD[Di]
MOV cs:IPIC2[si],AL
INC cs:CntDgts
jmp x0
;mov ch,6
;call DISDIG                    ;Jump to DISPLAY if there is a digit entered
j3:
BCKSPC:    CMP DI,10                    ;Check for Backspace
JNE ENTER1
CMP cs:CntDgts,0
JE X0                        ;Checking if the digits are more than 0 before backspace
DEC cs:CntDgts
    jmp x0

ENTER1:    CMP DI,11                    ;Check for enter
JNE X0
;If it is enter, we take in only one key-press. ie, TEST
Y0:        MOV AL,00H
OUT Port1C,AL
Y1:
Z32:    MOV CH,cs:CntDgts
cmp ch,0
je zx1
MOV bp,0

mov    bH,cs:IpIC2[bp]
mov    bL,1

Z31:    mov al,0
out Port1B,al
mov    al,bH
out    Port1A,al

mov    AL,BL
out    Port1B,al

;call sub1
rol    bl,1
INC bp
mov    bH,cs:IpIC2[bp]
DEC CH
JNZ Z31
zx1:
IN AL, Port1C
AND AL,0F0H
CMP AL,0F0H
JNZ Y1

MOV AL,00H
OUT Port1C,AL
Y2:;
Z42:    MOV CH,cs:CntDgts
cmp ch,0
je zx2
MOV bp,0

mov    bH,cs:IpIC2[bp]
mov    bL,1

Z41:    mov al,0
out Port1B,al
mov    al,bH
out    Port1A,al

mov    AL,BL
out    Port1B,al

;call sub1
rol    bl,1
INC bp
mov    bH,cs:IpIC2[bp]
DEC CH
JNZ Z41
zx2:
MOV AL,00H
OUT Port1C,AL
IN AL,Port1C
AND AL,0F0H
CMP AL,0F0H
JZ Y2

MOV AL,00H
OUT Port1C,AL
IN AL,Port1C
AND AL,0F0H
CMP AL,0F0H
JZ Y2

MOV AL, 0eH
MOV BL,AL
OUT Port1C,AL
IN  AL,Port1C
AND AL,0F0H
CMP AL,0F0H
JZ Y2


Y3:        OR AL,BL
MOV CX,0FH
MOV DI,00H

Y4:        CMP AL,CS:TableK[DI]
JZ  Y5
INC DI
LOOP Y4

Y5:        CMP DI,12
JNE Y0

MOV AH,cs:CntDgts
CMP AH,4
JE NEXT4
CMP AH,6
JE NEXT6
JMP FAIL
			;Checking in 4 digit IC database
NEXT4:
        MOV CX,4
        ;LEA SI,IpIC
		mov bp,0
d1:     mov al,CS:IpIC[bp]
        ;LEA DI,NandIC
        mov ah,CS:NandIC[bp]
        inc bp
        cmp ah,al            ;Checking for NAND
           jne d2
        dec cx
        CMP CX,0
        JE TESTNAND
        jmp d1   
                   
                   
d2:     mov bp,0
        mov cx,4
d3:     mov al,cs:IpIC[bp]
        ;LEA DI,AndIC
        mov ah,CS:AndIC[bp]
        inc bp
        cmp ah,al            ;Checking for AND
        jne d4
        dec cx
        CMP CX,0
        JE TESTAND
        jmp d3

d4:     mov bp,0
        mov cx,4
d5:     mov al,cs:IpIC[bp]
        ;LEA DI,ORIC  
        mov ah,cs:OrIC[bp]
        inc bp
        cmp ah,al            ;Checking for OR
        jne d6
        dec cx
        CMP CX,0
        JE TESTOR
        jmp d5
        
d6:     mov bp,0
        mov cx,4
d7:     mov al,CS:IpIC[bp]
        ;LEA DI,XORdIC
        mov ah,CS:XorIC[bp]
        inc bp
        cmp ah,al            ;Checking for Xor
        jne d8
        dec cx
        CMP CX,0
        JE TESTXOR
        jmp d7

d8:     JMP FAIL                ;If none of the ICs in the database match, then fail


;Check the IC number in the 6 digit IC database
NEXT6:    mov bp,0
        mov cx,6
d9:               mov al,CS:IpIC[bp]
;LEA DI,NandIC
        mov ah,CS:XnorIC[bp]
        inc bp
        cmp ah,al            ;Checking for Xnor
        jne d10
        dec cx
        CMP CX,0
        JE TESTXNOR
        jmp d9

d10:    JMP FAIL                ;If none of the ICs in the database match, then fail

TESTAND:
;CREG
MOV AL,10001010b
OUT Creg2,AL

;ACTUAL
MOV AL,00
OUT Port2A,AL
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,0
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,0
JNE FAIL


MOV AL,1AH
OUT Port2A,AL
MOV AL,2H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,0
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,0
JNE FAIL

MOV AL,25H
OUT Port2A,AL
MOV AL,1H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,0
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,0
JNE FAIL

MOV AL,3FH
OUT Port2A,AL
MOV AL,3H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,30H
JNE FAIL

JMP PASS

;Testing for NAND-IC
TESTNAND:
;CREG
MOV AL,10001010b
OUT Creg2,AL

MOV AL,00
OUT Port2A,AL
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,30H
JNE FAIL

MOV AL,1AH
OUT Port2A,AL
MOV AL,2H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,30H
JNE FAIL

MOV AL,25H
OUT Port2A,AL
MOV AL,1H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,30H
JNE FAIL

MOV AL,3FH
OUT Port2A,AL
MOV AL,3H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,0
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,0H
JNE FAIL

JMP PASS

;Testing for OR-IC
TESTOR:
MOV AL,10001010b
OUT Creg2,AL


MOV AL,00
OUT Port2A,AL
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,0
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,0H
JNE FAIL

MOV AL,1AH
OUT Port2A,AL
MOV AL,2H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,30H
JNE FAIL

MOV AL,25H
OUT Port2A,AL
MOV AL,1H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,30H
JNE FAIL

MOV AL,3FH
OUT Port2A,AL
MOV AL,3H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,30H
JNE FAIL

JMP PASS

;Testing for XOR-IC
TESTXOR:
;CREG
MOV AL,10001010b
OUT Creg2,AL

MOV AL,00
OUT Port2A,AL
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,0
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,0H
JNE FAIL

MOV AL,1AH
OUT Port2A,AL
MOV AL,2H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,30H
JNE FAIL

MOV AL,25H
OUT Port2A,AL
MOV AL,1H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,03
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,30H
JNE FAIL

MOV AL,3FH
OUT Port2A,AL
MOV AL,3H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,0
JNE FAIL
IN AL,Port2C
AND AL,30H
CMP AL,0H
JNE FAIL

JMP PASS

;Testing for XNOR-IC
TESTXNOR:
;Changing CREG to suite this particular IC
MOV AL,10000011b
OUT Creg2,AL
;CHANGE IF IT IS WRONG !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;ACTUAL TESTING
MOV AL,00
OUT Port2A,AL
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,3H
CMP AL,3H
JNE FAIL

MOV AL,1AH
OUT Port2A,AL
MOV AL,20H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,0
JNE FAIL
IN AL,Port2C
AND AL,3H
CMP AL,0H
JNE FAIL

MOV AL,25H
OUT Port2A,AL
MOV AL,10H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,0
JNE FAIL
IN AL,Port2C
AND AL,3H
CMP AL,0H
JNE FAIL

MOV AL,3FH
OUT Port2A,AL
MOV AL,30H
OUT Port2C,AL
IN AL,Port2B
AND AL,3
CMP AL,3
JNE FAIL
IN AL,Port2C
AND AL,3H
CMP AL,3H
JNE FAIL

JMP PASS




;To display FAIL
FAIL:
MOV DI,5000h


A2:    MOV CH,4
MOV bp,0

mov    bH,cs:FAILW[bp]
mov    bL,1

A1:    mov al,0
out Port1B,al
mov    al,bH
out    Port1A,al

mov    AL,BL
out    Port1B,al

;call sub1
rol    bl,1
INC bp
mov    bH,cs:FAILW[bp]
DEC CH
JNZ A1
dec di
Jnz A2

mov al,0
mov cs:CntDgts,al
jmp st1

;To display PASS
PASS:
MOV DI,5000h

A12:    MOV CH,4
MOV bp,0

mov    bH,cs:PASSW[bp]
mov    bL,1

A11:    mov al,0
out Port1B,al
mov    al,bH
out    Port1A,al

mov    AL,BL
out    Port1B,al

;call sub1
rol    bl,1
INC bp
mov    bH,cs:PASSW[bp]

DEC CH
JNZ A11
dec di
Jnz A12

mov al,0
mov cs:CntDgts,al
jmp st1

DISDIG proc near

Z2:        MOV CH,cs:CntDgts
cmp ch,0
je zz
MOV bp,0
;LEA SI,CS:IpIC2
mov    bH,cs:IpIC2[bp]
mov    bL,1
Z1:     mov    AL,BL
out    Port1B,al
mov    al,bH
out    Port1A,al
;call sub1
rol    bl,1
INC bp
mov    bH,cs:IpIC2[bp]
DEC CH
JNE Z1
zz:
ret
DISDIG endp
;MOV AL,FLAG
;CMP AL,0
;JE X0

;CMP AL,1
;JE Y0

;JMP Y0

D20MS:    mov cx,2220
xn:        loop xn
ret

sub1 proc near
push      cx
mov        cx,10 ; delay generated will be approx 0.45 secs
Z3:          loop        Z3
pop       cx
sub1 endp



; [SOURCE]: C:\Users\ratna\Downloads\BITS ACADS\2.2\INSTR F241 MICROPROC & INTERFACING (MuP)\Project\19_04_02\code2.asm
