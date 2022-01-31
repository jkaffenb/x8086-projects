TITLE Project 5

;project5.asm
;Jack Kaffenbarger


INCLUDE CS240.inc
.8086

.data
buffer	BYTE	10 dup(?)
bufsize	WORD	?
delayhigh	WORD	0
delaylow	WORD	0 
myhigh	WORD	?
mylow	WORD	?
mylowcounter	WORD	0
myhighcounter	WORD	0

.code
mWrite	MACRO	text
	local string
.data
string	BYTE	text, 0
.code
	push	dx
	mov	dx, OFFSET string
	call	WriteString
	pop	dx
ENDM

SafeRead PROC
	push	bp
	mov	bp, sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	pushf

	mov	dx, 0
	mov	ax, 0
	mov	si, 0
	mov	bx, [bp + 6]

top:
	mov	ah, 01h		;take keyboard input
	int	16h		
	jnz	top

	mov	ah, 10h		;scan keyboard input
	int	16h
	
	and	ax, 00FFh	;get ascii value

	cmp	al, 03h
	je	ctrlc		;user inputs ctrl + c	

	cmp	al, 08h		;user inputs backspace
	je	backspace

	cmp	al, 0Dh		;user inputs enter
	je	eenter

				;check if at max, beep if so
	cmp	si, 10
	je	beep

	mov	dl, al		;write character to screen
	call	WriteChar
	
	mov	[bx + si], al

	inc	si
	jmp	top

beep:
	mov	dl, 07h
	call	WriteChar
	jmp	top

backspace:
	cmp	si, 0
	je	top
	dec	si
	mov	dl, al
	call	WriteChar
	mov	dl, 20h
	call	WriteChar
	mov	dl, 08h
	call	WriteChar
	jmp	top
eenter:
	inc	si
	mov	ax, 0
	mov	[bx + si], ax
	dec	si
	mov	[bp + 4], si
	jmp	ending
ctrlc:
	call	NewLine
	mWrite	"Aborted Program!"
	jmp	ending
ending:	
	mov	dx, [bp + 4]
	popf
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
ret
SafeRead ENDP

HexOut PROC
	pushf	
	push bx
	push cx
	push si
	push dx
	mov 	si, 1
	cmp	cx, 0
	je	ending

	mov	dl, [bx]
	call	WriteChar ;HexByte

	cmp	cx, 1
	je	ending

top:
	cmp	si, cx
	je	ending
	mov	dl, ' '
	call	WriteChar
	mov	dl, [bx + si]
	call	WriteChar
	;call	WriteHexByte
	inc	si
	jmp	top

ending:
	pop	dx
	pop	si
	pop	cx
	pop	bx
	popf
ret
HexOut ENDP	

Delay PROC
	push	bp

	mov	bp, sp
	push	ax			;push flags
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	pushf	

	mov	ah, 2Ch			;get first value
	int	21h

	mov	bx, dx			;convert seconds
	mov	cl, 3
	shl	bx, cl
	mov	di, bx
	mov	bx, dx
	add	di, bx
	add	di, bx
	
top:
	mov	ah, 2Ch			;get new time
	int	21h
	and	dx, 00FFh

	mov	bx, dx
	mov	cl, 3
	shl	bx, cl
	mov	si, bx
	mov	bx, dx
	add	si, bx
	add	si, bx
	
	cmp	si, di			;make sure didn't loop over
	jb	addcar
	je	cond1
	jmp	addnorm

addcar:
	mov	dx, 1000		;add with a carry
	sub	dx, di
	add	dx, si
	mov	ax, mylow	
	add	mylow, dx
	cmp	mylow, ax
	jb	bitadd
	jmp	cond1

addnorm:
	mov	dx, si			;add to counter normally
	sub	dx, di
	mov	ax, mylowcounter
	add	mylowcounter, dx
	cmp	mylowcounter, ax
	jb	bitadd
	jmp	cond1	

bitadd:
	inc	myhighcounter		;add if bottom counter is full
	mov	mylowcounter, 0
	jmp	cond1

cond1:
	mov	di, si			;check if highcounter is the same
	mov	dx, [bp + 6]
	cmp	myhighcounter, dx
	jb	top
	mov	dx, [bp + 4]		;check if lowcounter is the same
	cmp	mylowcounter, dx
	jb	top
	jmp	ending			;if both equal or >, jmp ending
ending:
	popf
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp

ret
Delay ENDP

main PROC
	mov	ax, @data
	mov	ds, ax

;	mov	ax, delayhigh
;	push	ax
;	mov	ax, 5000
;	push	ax
;	call	DumpRegs
;	call	Delay
;	call	DumpRegs

;	mov	ax, OFFSET buffer
;	push	ax
;	mov	ax, bufsize
;	push	ax
;	call	DumpRegs
;	call	SafeRead
;	call	DumpRegs
;	pop	cx
;	inc	cx
;	pop	bx
;	call	HexOut

	mov	ax, 4C00h
	int	21h
main ENDP 
END 
