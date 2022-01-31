Title Project 4

;hexdump.asm
;Jack Kaffenbarger

INCLUDE CS240.inc
.8086

.data
myhigh	WORD	0000h
mylow	WORD	0000h
count	WORD	?
limit	WORD	17
spaces	WORD	?
answerarray	BYTE	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"
stararray	BYTE	?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
starcount	WORD	?
mysi	WORD	?
mydi	WORD	?

.code
PrintHexWord PROC
	push	bx
	push	dx
	pushf
	mov	bx, dx
	mov	dl, bh
	call	PrintHexByte
	mov	dl, bl
	call	PrintHexByte

	pop	bx
	pop	dx
	popf	
ret
PrintHexWord ENDP

PrintHexByte	PROC
	push	bx
	push	dx
	push	si
	pushf
	mov	si, 0
	mov	bl, dl
	cmp	bl, 16
	jb	lstbytezero
top:
	sub	bl, 16
	inc	si
	cmp	bl, 16
	jb	lstbyte
	jmp	top
lstbyte:
	mov	dx, si
	call	PrintHexDigit
	mov	dl, bl
	call	PrintHexDigit
	jmp	ending
lstbytezero:
	mov	dx, 0
	call	PrintHexDigit
	mov	dl, bl
	call	PrintHexDigit
	jmp	ending
ending:
	popf
	pop si
	pop dx
	pop bx

ret
PrintHexByte ENDP

PrintHexDigit	PROC
	push	ax
	push	bx
	push	dx
	push	si
	pushf
	
	mov	si, dx
	jmp	cond1
cond2:
	sub	si, 16
	
cond1:
	cmp	si, 16
	ja	cond2
	mov	bx, OFFSET answerarray
	mov	dl, BYTE PTR [bx + si]
	mov	ah, 02h
	int 	21h
	
	popf
	pop	si
	pop	dx
	pop	bx
	pop	ax	
ret
PrintHexDigit	ENDP

.code
GetCommandTail PROC
SPACE = 20h
	push es
	push	ax
	push	bx
	push	cx
	push	dx
	push	bp
	push	si
	push	di
	mov	ah, 62h
	int	21h
	mov	es, bx
	
	mov	si, dx
	mov	di, 81h
	mov	cx, 0
	mov	cl, es:[di-1]
	cmp	cx, 0
	je	L2
	cld
	mov	al, SPACE
	repz	scasb
	jz	L2
	dec	di
	inc	cx

L1:	mov	al, es:[di]
	mov	[si], al
	inc	si
	inc	di
	loop	L1
	clc
	jmp 	L3
L2:	stc
L3:	mov	byte ptr [si], 0

	;pop registers
	pop di
	pop bp
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es

ret
GetCommandTail ENDP

main PROC
	mov	ax, @data
	mov	ds, ax
	
	mov	ax, 3D00h			;open file
	call	GetCommandTail
	int	21h
	mov	si, ax	

	mov	bx, si			;read first 16
	mov	ax, 3F00h
	mov	cx, 16
	int	21h

	mov	cx, ax
	mov	di, dx
	cmp	cx, 0
	je	ending			;error reading file or file done
	cmp	cx, 16
	jne	setlimit
	jmp	nolimit
setlimit:
	mov	limit, cx
	jmp	nolimit
nolimit:
	mov	count, 0		;set limit if < 16 bytes left
	call	NewLine
	mov	dx, myhigh
	call	PrintHexWord
	mov	dx, mylow
	call	PrintHexWord
	jmp	offsetaddition
nolimit3:
	add	mylow, cx
nolimit2:
	mov	dx, ' '
	call	WriteChar
	mov	dx, ' '
	call	WriteChar
	jmp	midl
offsetaddition:
	mov	dx, mylow
	cmp	dx, 0FFF0h		;managing addition with DWORD
	jne	nolimit3
	add	myhigh, 1
	mov	mylow, 0
	jmp	nolimit2	
midl:
	mov	bx, count		;print middle left block
	mov	dx, [di]
	call	PrintHexByte
	mov	stararray[bx], dl
	mov	dx, ' '
	call	WriteChar
	inc	di
	inc	count
	mov	dx, count
	cmp	dx, limit
	je	lastoff
	cmp	count, 8
	jne	midl
	jmp	midm
midm:
	mov	dx, ' '
	call	WriteChar		;print middle block
	jmp	midr
midr:
	mov	bx, count
	mov	dx, [di]
	call	PrintHexByte
	mov	stararray[bx], dl	;print middle right block
	mov	dx, ' '
	call	WriteChar
	inc	di
	inc	count
	mov	dx, count
	cmp	dx, limit
	je	lastoff
	cmp	count, 16
	jne	midr
	jmp	right
right:
	mov	dx, ' '
	call	WriteChar		;print right ascii characters
	mov	dx, '|'
	call	WriteChar
	mov	count, 16
rightlop:
	dec	di
	dec	count
	cmp	count, 0
	jne	rightlop
printright:
	cmp	count, 16
	je	readprep
	mov	dx, [di]
	cmp	dl, 020h
	jae	checkless
	jmp	printperiod
checkless:
	cmp	dl, 07Fh
	jb	printnormal		;check to make sure printable
	jmp	printperiod
printnormal:
	inc	di
	call	WriteChar
	inc	count
	jmp	printright
printperiod:
	inc	di
	mov	dx, '.'			;if not printable, '.'
	call	WriteChar
	inc 	count
	jmp	printright
	jmp	ending
rplusone:
	add	ax, 2
	jmp	trash
lastoff:
	dec	di
	mov	dx, 16
	sub	dx, count		;case for the last offset
	mov	ax, 3
	mul	dx
	;dec	ax
	cmp	count, 8
	jbe	rplusone
	inc	ax
trash:	
	mov	dx, ' '
	jmp	spacelop
spacelop: 
	cmp	ax, 0			;case to format the ascii correctly
	je	lastline		;with last line
	call	WriteChar
	dec	ax
	jmp	spacelop
lastline:
	mov	dx, '|'
	call	WriteChar
decdi:
	dec	di
	dec	count			;decrement di to print ascii
	cmp	count, 0
	jne	decdi
	mov	ax, limit
printrightend:
	cmp	ax, count
	je	almstend		
	mov	dx, [di]
	cmp	dl, 020h
	jge	checklessend
	jmp	printperiodend
checklessend:
	cmp	dl, 07Fh
	jl	printnormalend
	jmp	printperiodend
printnormalend:				;cases involving ascii and last line
	inc	di
	call	WriteChar
	inc	count	
	jmp	printrightend
printperiodend:
	inc	di
	mov	dx, '.'
	call	WriteChar
	inc	count
	jmp	printrightend
	jmp	ending
almstend:
	mov	dx, '|'
	call	WriteChar
	call	NewLine
	mov	dx, myhigh
	call	PrintHexWord
	mov	dx, mylow
	call	PrintHexWord
	jmp	ending
readprep:
	mov	dx, '|'
	call	WriteChar		;prepare to read next line
	mov	count, 0
	jmp	checkstar
checkstar:
	mov	count, 0
	mov	bx, si 			;read next 16
	mov	ax, 3F00h
	mov	cx, 16
	int	21h

	mov	cx, ax
	cmp	cx, 0
	je	ending			;error reading file or file done
	cmp	cx, 16
	jne	setlimit
	mov	di, dx
	mov	starcount, 0
	jmp	checkstarloop
checkstarloop:
	mov	bx, starcount
	mov	dl, [di]
	cmp	dl, stararray[bx]	;loop to check if new line is same
	jne	resetdi			;as last line, print star and 
	cmp	starcount, 15		;increment offset if so
	je	printstar
	inc	di
	inc	starcount
	jmp	checkstarloop
resetdi:
	cmp	starcount, 0
	je	nolimit
	dec	starcount
	dec	di
	jmp	resetdi
printstar:
	call	NewLine
	mov	dx, '*'
	call	WriteChar

	;jmp	checkstar
	mov	dx, mylow	;inc the offset
	cmp	dx, 0FFF0h
	jne	nolimitstar3
	add	myhigh, 1
	mov	mylow, 0
	jmp	checkstar 

nolimitstar3:
	add	mylow, cx
	mov	dx, mylow
	jmp	checkstar

ending:
	mov	ax, 4C00h
	int	21h
main ENDP
END main
