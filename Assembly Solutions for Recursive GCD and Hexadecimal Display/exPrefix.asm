;Shoham Galili 208010785

.model small
N EQU 5
.stack 100h
.data

	dec_arr dw N dup (?) ;The result of the convertion 
	
.code


;***********************************************************************************************
;HexToDec 
;Inputs: AX, BX, CX, BP, SI
;Outputs: decArr - array of the digits of the number in dec from hex
;This functions calculate the number in the stack and convert it from hex to dec
;***********************************************************************************************
 HexToDec PROC near
	push ax
	push cx
	push bp
	push si
	push bx
	
	mov bp, sp                         ;Set sp to point on bp
	mov ax, [bp +12d]                  ;Get the number to ax - in hex
	mov cx, 5d                         ;Counter of the iterations
	mov si, offset dec_arr             ;Pointer to the first cell on dec_arr
	mov bx, 10d                        ;Set bx = 10
	
	GetDigit:                          ;Loop that divide the number ax to his digits in Dec
		mov dx, 0                      ;Set dx=0
		div bx                         ;Do a/b when: ax= (int) a/b , dx= a mod b 
		mov [si], dx                   ;The digit is a mod b
		add si, 2h                     ;Increment of si
	loop GetDigit
	
	pop bx
	pop si
	pop bp
	pop cx
	pop ax
	RET 2

HexToDec ENDP

;*******************************************
;Print 
;Inputs:  CX, DI, SI
;Outputs: print decArr to the screen
;This function print decArr to the screen
;*******************************************
Print PROC near 

	push cx
	push si
	push di
	
	mov si, offset dec_arr
	add si, 8h                    ;Move to the last cell of dec_arr
	cmp [si], 0
	jnz PrintDigit                ;Check if the first digit is zero
	
	NextCell:                     ;if there is a zero at the beginning- 
		sub si, 2h                ; si to the prev cell
		dec cx
		jz endProc
	
	
	
	PrintDigit:                   ;Print the substring of the number in length=cx
	mov dx, [si]
	add dx, 48d                   ;Convert to ASCI
	mov dh, 2Eh                   ;Set color to text on screen
	mov es:[di], dx               ;Print to screen the digit  
	add di, 2h                    ;Move to the next cell on screen
	sub si, 2h                    ;Move to the next digit on num
	loop PrintDigit
	
	endProc:

	pop di
	pop si
	pop cx
	RET

Print ENDP


;*******************************************************
;numPrefix 
;Inputs:  none
;Outputs: print decArr to the screen in a pyramid
;This function print decArr to the screen in a pyramid
;*******************************************************
numPrefix PROC

	mov ax, 2021h                    ;Set the number of numPrefix
	push ax
	call HexToDec                    ;Convert the number from Hex to Dec
	
	mov di, 340h                     ;The first line on screen 
	
	mov cx, 5                        ;Set the counter of the loop
    call Print
	
	dec cx
	add di, 0A0h                     ;Move to the next line on screen
    call Print
	
	dec cx
	add di, 0A0h                     ;Move to the next line on screen
    call Print
	
	dec cx
	add di, 0A0h                     ;Move to the next line on screen
    call Print
	
	dec cx
	add di, 0A0h                     ;Move to the next line on screen
    call Print
	
	RET
	
numPrefix ENDP




START:

   ;setting data segment
    mov ax, @data
    mov ds, ax
	
	;setting the screen offset
	mov ax, 0B800h
	mov es, ax
	
	call numPrefix


END START