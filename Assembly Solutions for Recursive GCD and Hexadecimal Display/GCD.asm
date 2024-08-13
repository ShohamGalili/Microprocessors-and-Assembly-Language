;Shoham Galili 208010785

.model small
.stack 100h
.data
 RESULT dw ?
 input_arr dw 3024, 1234, 1244, 44, 12414
 inputLen EQU 5
.code

;***********************************************************
;RecGCD 
;Inputs:
;AX - NUMBER 1
;BX - NUMBER 2
;Outputs: RESULT- the GCD of ax and bx
;This functions calculate the GCD of AX,BX
;***********************************************************

  recGCD PROC near
	;save registers values
	push ax
	push bx
	push dx
	cmp bx,0                   ;check if bx=0
	jz EndProc                 ;check if bx=0
	
	mov dx, 0
	div bx                     ;do a/b when: ax= (int) a/b , dx= a mod b 
	mov ax, bx
	mov bx, dx                 ;bx= a mod b
	
	call recGCD
	jmp ending 
	
	EndProc:
		mov result, ax          ;return a
	ending:
	                            ;restore registers values
	pop dx
	pop bx
	pop ax
	RET
  recGCD ENDP


;***********************************************************
;ArrGCD
;Inputs:
;input_arr - array of numbers
;cx - counter of  iterations 
;Outputs: RESULT in ax
;This functions calculate the GCD of an array
;***********************************************************

  arrGCD PROC near
	;save registers values
	push cx

	
	;Base Case- if cx=0:
	cmp cx, 0
	jz stop
	
	;Else:
	dec cx                   ;cx= cx-1
	                         ;mov ax, [si]
	add si, 2h               ;increment si for the next cell
	mov bx, [si]
	call recGCD              ;call for calc gcd
	mov ax, [di]             ;update ax to the result of the two prev cells
	call arrGCD
	
	
	stop:
	pop cx
	RET
	
  arrGCD ENDP









START:

   ;setting data segment
    mov ax, @data
    mov ds, ax

	mov si, offset input_arr  ;The adress of the first cell in the array
	mov di, offset result     ;The adress of RESULT
	mov cx, inputLen          ;counter of iterations 
	dec cx                    ;Set cx= cx-1
	mov ax, [si]              ;Set ax to be the first cell in the array
	call arrGCD
	
  ;Return To OS
  mov ax, 4c00h
  int 21h 

END START