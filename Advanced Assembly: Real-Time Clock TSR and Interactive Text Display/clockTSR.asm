;Shoham Galili 208010785

.model tiny

.code
	;public ISR_New_1C
	public finish_tsr
	public HERE
	extern print_main:near
	ms dw 00d ;ms of timer
	seconds dw 00d ;seconds of timer
	minutes dw 00d ;minutes of timer
	backcolor db 3d ;turkiz color
	recent_ah db 0d
	org 100h ;making space in the memory for PSP

HERE:
	jmp IVT_REPLACE

	
;*********************
;*********************
;ISR_New_1C
;Outputs: This function change int 1C
;*********************	
ISR_New_1C proc far uses ax es dx bx cx

	mov ax, 0B800h
	mov es, ax        ;Set ax to Screen
	
	;print minutes on screen
		mov ax , minutes
		mov bh , 10d
		div bh ;al=(int)ax/bh , ah=ax mod bh
		add ah , 30h ;convert to ascii
		add al , 30h ;convert to ascii
		mov recent_ah , ah
		mov ah , backcolor
		mov es:[0h] , ax
		mov al , recent_ah
		mov es:[2h] , ax
		
		mov al ,':' ;ascii to print
		mov es:[4h] , ax
		
		;print seconds on screen
		mov ax , seconds
		mov bh , 10d
		div bh ;al=(int)ax/bh , ah=ax mod bh
		add ah , 30h ;convert to ascii
		add al , 30h ;convert to ascii
		mov recent_ah , ah
		mov ah , backcolor
		mov es:[6h] , ax
		mov al , recent_ah
		mov es:[8h] , ax
		
		mov al ,':' ;ascii to print
		mov es:[10d] , ax
		
		
		;print ms on screen
		mov ax , ms
		mov bh , 10d
		div bh ;al=(int)ax/bh , ah=ax mod bh
		add ah , 30h ;convert to ascii
		mov bl , ah ;the Unity digit
		mov ah ,0 ;ax=al
		div bh ;al=(int)ax/bh , ah=ax mod bh
		add ah , 30h ;convert to ascii
		add al , 30h ;convert to ascii
		mov recent_ah , ah
		mov ah , backcolor
		mov es:[12d] , ax ;hundreds digit
		mov al , recent_ah
		mov es:[14d] , ax ;tens digit
		mov bh , backcolor
		mov es:[16d] , bx ;the Unity digit
		
	;calc the timer
	
	cmp ms , 990d ;990 ms is a mul of 55ms and almost a sec
	jnz inc_ms
	
	;if has past one sec
	mov ms , 0d ;reset ms
	cmp seconds , 59d ;60 sec is one minute
	jnz inc_sec
	
	;if has past one minute
	mov seconds , 0d;reset sec
	inc minutes ;min++
	jmp prev_isr ;we dont want to inc sec
	
	inc_sec:
	inc seconds ;sec++
	cmp backcolor ,3d
	jnz change_to_turkiz
	mov backcolor ,5d ;magenta color
	jmp prev_isr
	change_to_turkiz:
	mov backcolor ,3d
	jmp prev_isr ;we dont want to inc ms
	
	inc_ms:
	add ms, 55d ;the interrupt happens every 55ms
	
	prev_isr:
		int 80h ;use the old interrupt
		iret
	
ISR_New_1C endp
	
	End_TSR:
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~MAIN~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	IVT_REPLACE:
	; IVT is location is '0000' address of RAM
	mov ax,0h
	mov es,ax
	
	cli
	;moving Int1C into IVT[0a0h]
	mov ax,es:[1Ch*4] ;copying old ISR1C IP to free vector
	mov es:[80h*4],ax
	mov ax,es:[1Ch*4+2] ;copying old ISR1C CS to free vector
	mov es:[80h*4+2],ax
	;moving ISR_New_1C into IVT[1C]
	mov ax,offset ISR_New_1C ;copying IP of ISR_New to IVT[1C]
	mov es:[1Ch*4],ax
	mov ax,cs ;copying CS of ISR_New to IVT[1C]
	mov es:[1Ch*4+2],ax
	sti
	
	jmp print_main
	
	finish_tsr:
	;exit the program and saving ISR_New_1C in the TSR
	mov dx, offset End_TSR
	int 27h
	
end 
