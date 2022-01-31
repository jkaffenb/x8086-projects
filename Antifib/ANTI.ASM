INCLUDE CS240.inc
.8086

DOS = 21h
TERMINATE = 4C00h

.data
answer	WORD	?

.code
antifib PROC
	mov	ax, @data
	mov	ds, ax

	push	bx
	push	cx
	push	dx
	pushf
		
	mov	ax, dx
	mov	answer, 0
	mov	bx, 1
	mov	cx, 1

	cmp	ax, 0
	je	ending
	cmp	ax, 1
	je	cond
	cmp	answer, 17710
	jg	hardcode
	jmp	top
	

hardcode:
	cmp	ax, 23184
	jle	hard1
	cmp	ax, 37512
	jg	hard2
	cmp	ax, 60697
	jg	hard3

	mov	dx, 25
	jmp	ending
hard3:
	mov	dx, 24
	jmp	ending 

hard2:
	call	DumpRegs
	mov	dx, 23
	jmp	ending

hard1:
	mov	dx, 22
	jmp	ending
top:
	cmp	ax, bx
	jl	cond1

	mov	dx, 0
	add	dx, answer
	add	dx, bx
	mov	answer, bx
	mov	bx, dx
	inc	cx
	inc	cx
		
	loop top
cond1:
	cmp	ax, answer
	je	cond2
	jmp 	cond3
cond3:
	sub	bx, answer
	sub 	ax, answer
	
	cmp	ax, bx
	jle	cond2

	mov	dx, cx
	jmp	ending

cond2:
	dec	cx
	mov	dx, cx
	jmp	ending

cond:
	mov	dx, ax
	jmp	ending

ending:	
	call	WriteInt
	mov	ax, dx
	pop	bx
	pop	cx
	pop	dx
	popf	

	mov	ax, TERMINATE
	int	DOS
ret
antifib ENDP
END  
