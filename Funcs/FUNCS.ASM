INCLUDE cs240.inc
.8086

.data
factanswer	WORD	?
fibanswer	WORD	?
msg	BYTE	"HELLO WORLD!", 0

.code
Factorial PROC
	push	cx
	push	dx
	pushf
	cmp	ax, 1
	je	case1
	cmp	ax, 0
	je	case0
	mov	factanswer, ax
	dec	factanswer
	mov	cx, factanswer	
top:
	mul	factanswer
	dec	factanswer
	loop 	top
	jmp	ending
case1:
	mov	ax, 1
	jmp 	ending
case0:	
	mov	ax, 0
	jmp	ending
ending:
	popf
	pop	dx
	pop	cx
ret
Factorial ENDP

Fibonacci PROC
;need to push and pop
	push	bx
	push	cx
	pushf

	cmp	ax, 0
	je	ending
	cmp	ax, 1
	je	ending
	mov	cx, ax
	dec 	cx
	mov	bx, 1
	mov	fibanswer, 1
	mov	ax, 0
top:
	add	ax, bx
	mov	bx, fibanswer
	mov	fibanswer, ax
	loop top
ending:
	popf
	pop	cx
	pop	bx

ret
Fibonacci ENDP

PrintString PROC
	push	ax
	push	bx
	push	si
	pushf

	mov	si, 0
	mov	bx, dx
cond:
	mov	dl, BYTE PTR [bx + si]
	mov	ah, 02h
	int	21h
	inc	si
	cmp 	BYTE PTR [bx + si], 0
	jne	cond	
		
	popf
	pop	si
	pop	bx	
	pop	ax
ret
PrintString ENDP

.data
answerarray	BYTE	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"

.code
PrintHexDigit PROC
;changes dx but writehexdigit does not? maybe fix
	push	ax
	push	bx
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
	int	21h

	popf
	pop	si
	pop	bx
	pop	ax
ret
PrintHexDigit ENDP

.data
nums	SWORD	5, -5, 10, -10, 33 
myax	SWORD	?

.code
SumArray PROC
	mov	myax, ax
	push	bx
	push	cx
	push	si

	mov	bx, ax
	mov	ax, 0
	mov	si, 0
	jo	ofcond
	pushf
	jmp	top
ofcond:
	jc	carrycond
	test	al, al
	pushf
	jmp	top
carrycond:	
	test	al, al
	stc
	pushf
top:
	add	ax, SWORD PTR [bx + si]
	jo	cond
	add	si, 2
	loop top
	jmp	ending
cond:
	popf
	mov	al, 127
	rol	al, 1
	stc
	mov	ax, myax
	jmp	ending1	
ending:
	popf
ending1:
	pop	si
	pop	cx
	pop	bx 
ret
SumArray ENDP

main PROC
	mov	ax, @data
	mov	ds, ax
		
;	mov	dl, 0ABh
;	call	DumpRegs
;	call	WriteHexDigit
;	call	DumpRegs
;	mov	dl, 0ABh
;	call	PrintHexDigit
;	call	DumpRegs

	mov	ax, 4C00h
	int	21h
main ENDP
END  
