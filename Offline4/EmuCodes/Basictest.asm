.MODEL SMALL 
.STACK 100H 
.DATA

ARR DW 1,2,3,4,5
t0 DW ?
t1 DW ?
t2 DW ?
t3 DW ?
.CODE 
MAIN PROC
    PUSH BP
    MOV BP, SP
    SUB  SP, 2					;declaring variable a 
    SUB  SP, 2					;declaring variable b 
    SUB  SP, 2					;declaring variable c 
    PUSH 5						;pushing constant
    PUSH 4						;pushing constant
    POP CX						;starting %
    POP AX
    CWD
    IDIV CX
    PUSH DX						;ending %
    POP CX 						;popping logic_expn val from RHS
    MOV [BP + -2], CX 			;assigning value to a
    PUSH 0						;pushing constant
    
    ; interrupt to exit
    MOV AH, 4CH
    INT 21H
    
  
MAIN ENDP 
END MAIN 
