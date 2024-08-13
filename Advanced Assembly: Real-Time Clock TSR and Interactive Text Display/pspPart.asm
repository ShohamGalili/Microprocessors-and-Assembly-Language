;Hadas Yosefzada 213486764
;Shoham Galili 208010785

.model small
.stack 100h
.data
	out_msg db '"It',"'",'s hardware that makes a machine fast. It',"'",'s software that makes a fast machine slow." - Craig Bruce','$'
	count_3_times db 0
	row db 12
	column db 0
	backgroundColor db 1Fh
	sec_to_wait dw 23d
	flag_continue_or_stop_writing db 0 ;the flag is 0 if im in continue and 1 if i stoped
	;noClockMsg db ' /NOCLK','$'
	;clockFlag db 1 ;clockFlag = 1 if we dont want to show the clock, clockFlag = 0 if we want to show the clock
.code
	public print_main
	;extern ISR_New_1C:far
	extern finish_tsr:near
	extern HERE:near
;*********************
;Black_Screen
;Outputs: This function cPrint Black background on screen
;*********************
;Print Black background on screen
	Black_Screen PROC near uses es ax cx si
	
		mov ax, 0B800h
		mov es, ax        ;Set ax to Screen
		mov si, 0h
		mov ax,' '        ;Print ' ' to screen 
		mov cx, 1280h     ;Set cx to Screen Size
		
		ScreenLoop:	
			mov es:[si],ax
			sub cx, 2h
			add si, 2h
			cmp cx, 0 
		jnz ScreenLoop
		
	ret
	Black_Screen ENDP
	
	;*********************
;*********************
;Delay_one_sec
;Outputs: This function waits sec_to_wait
;*********************	
	Delay_one_sec PROC near uses ax cx 
	
		if_key_was_pressed:
		in al,64h
		test al, 00000001b ;Check Lsb- if LSB ==1 --> Key was pressed if LSB ==0 --> Key wasn't pressed
		jz delay
			
		in al,60h ;Read Scan Code from keyboard port
		
		Check_plus: 
		cmp al, 31d ;Check if s has pressed - speed it up
		jnz check_if_minus
		shr sec_to_wait ,1 ;sec_to_wait = sec_to_wait / 2
			
		check_if_minus:
		cmp al, 32d ;Check if d has pressed - delay it
		jnz check_if_p
		shl sec_to_wait ,1 ;sec_to_wait = sec_to_wait * 2
		
		check_if_p:
		cmp al, 25d ;Check if p has pressed - stop or continue writing
		jnz delay
		cmp flag_continue_or_stop_writing , 0 ;check if the flag is zero
		jz change_flag_to_1 
		mov flag_continue_or_stop_writing , 0 ;if flag == 1 change flag to 0
		jmp delay
		change_flag_to_1:
		mov flag_continue_or_stop_writing , 1 ;if flag == 0 change flag to 1
		
		delay:
		mov ax,sec_to_wait ;sec_to_wait times for the loop of 100ms
		outLoop:
			xor cx,cx ;cx=0
		wait100msec:
			nop
		loop wait100msec
		
		dec ax ;ax=ax-1.
		jnz outLoop
		
	;if past a sec:	
	end_Delay_one_sec:	
	ret
	Delay_one_sec ENDP
	
;*********************
;*********************
;check_strings
;Outputs: This function update th clock flag
;*********************	


check_strings proc near uses di bx ds
	
		;check if psp in offset 81h == ' /NOCLK' --> ds=PSP
		mov di,0
		
		;check first character:
		mov dl, ds:[81h + di]
		cmp dl, ' '						
		jnz changeFlagTo0	;if the command line != noClockMsg then we want to show the clock				
		inc di
		
		;check second character:
		mov dl, ds:[81h + di]
		cmp dl, '/'						
		jnz changeFlagTo0	;if the command line != noClockMsg then we want to show the clock
		inc di
		
		;check thired character:
		mov dl, ds:[81h + di]
		cmp dl, 'N'						
		jnz changeFlagTo0	;if the command line != noClockMsg then we want to show the clock
		inc di
		
		;check fourth character:
		mov bl, ds:[81h + di]
		cmp bl, 'O'						
		jnz changeFlagTo0	;if the command line != noClockMsg then we want to show the clock
		inc di
		
		;check fifth character:
		mov bl, ds:[81h + di]
		cmp bl, 'C'						
		jnz changeFlagTo0	;if the command line != noClockMsg then we want to show the clock
		inc di
		
		;check sixth character:
		mov bl, ds:[81h + di]
		cmp bl, 'L'					
		jnz changeFlagTo0	;if the command line != noClockMsg then we want to show the clock
		inc di
		
		;check seventh character:
		mov bl, ds:[81h + di]
		cmp bl, 'K'				 
		jnz changeFlagTo0	;if the command line != noClockMsg then we want to show the clock
		
		;we dont want to show the clock
		mov ax,1					
		ret
	
	changeFlagTo0:
		mov ax,0
		ret
		
	check_strings endp

;*********************
;********main*********
;*********************
main:
	;call check_strings
	call check_strings
	;setting data
	mov dx, @data
	mov ds,dx 
	
	call Black_Screen
	
	cmp ax , 1
	jz print_main ; we dont want to jump to the clock
	jmp HERE
	
	print_main:
	push ax
	;resat all registers
	xor ax,ax
	xor cx,cx
	xor si,si
	;xor es,es
	xor bx,bx
	xor dx,dx
	
		
	;mask interrupts from keyboard
	cli
	in al, 21h
	or al, 02h
	out 21h, al
	sti
	
	mov cx,102d ; the length of the full sentence
	mov si,0 ;reset counter on the string
	
	;;call Black_Screen
	
	;SET CURSOR POSITION
	mov ah,02h ;use service 2 of int 10h
	mov dh,12d ;row number 12
	mov dl,0d ;coulomn number 0
	int 10h ;now the cursor position is in the center
	
	;now the loop starts:
	print_sentence:
	cmp flag_continue_or_stop_writing , 1 ;check if the flag is 1
	jz if_flag_1 ;we dont want to change the backgrount if we are on stop
	cmp count_3_times,3 ;if past 3 times
	jnz continue
	cmp backgroundColor, 7Fh ; the limit
	jnz continue_1
	mov backgroundColor,0Fh
	continue_1:
	mov count_3_times,0 ;count_3_times=0
	add backgroundColor , 10h
	
	continue:
	;PRINT OUTPUT with color
	push cx
	mov cx,1
	mov al, out_msg[si] ;one character
	mov bl , backgroundColor ; background color
	mov ah , 09h ;use service 09h of int 10h
	int 10h
	pop cx
	;cmp flag_continue_or_stop_writing , 0 ;check if flag = 0 --> continue print_sentence
	;jnz CURSOR_POSITION
	;if flag = 0 we want to continue the print
	inc si ;si++
	inc column ;column++

	CURSOR_POSITION:
	;SET CURSOR POSITION
	mov ah,02h ;use service 2 of int 10h
	mov dh,row ;row
	mov dl,column ;coulomn
	int 10h ;now the cursor position is in the center
	
	inc count_3_times ;count_3_times++
	jmp end_loop ; if flag = 0 we dont want to inc cx
	
	if_flag_1:
	inc cx ;save every loop the time tat i need for the whole sentence
	
	end_loop:
	call Delay_one_sec
	
	loop print_sentence
	
	;out of the loop:
	add row,2
	;SET CURSOR POSITION
	mov ah,02h ;use service 2 of int 10h
	mov dh,row ;row
	mov dl,0 ;coulomn
	int 10h ;now the cursor position is in the center
	
	;unmask keyboard
	cli
	mov al,0
	out 21h,al
	sti
	
	pop ax
	cmp ax , 1
	jz regular_exit
	jmp finish_tsr
	
	;if we didnt print the clock
	regular_exit:
	;return to OS
	mov ax, 4c00h
	int 21h

end main