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
    MOV BP, SP
    MOV AX, 2
    PUSH AX
    MOV AX, 3
    PUSH AX
    MOV AX, [BP-2];
    
    ; interrupt to exit
    MOV AH, 4CH
    INT 21H
    
  
MAIN ENDP 
END MAIN 

