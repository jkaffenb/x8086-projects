TITLE Project 3

;procs.asm
;Jack Kaffenbarger

INCLUDE CS240.inc
.8086

.data
oldax	WORD	?
oldbx	WORD	?
oldcx	WORD	?
olddx	WORD	?
oldss 	WORD	?
oldsp 	WORD	?
oldbp 	WORD	?
oldsi 	WORD	?
olddi 	WORD	?
oldes 	WORD	?
oldds 	WORD	?
oldof	WORD	?
olddf	WORD	?
oldif	WORD	?
oldtf	WORD	?
oldsf	WORD	?
oldzf	WORD	?
oldacf	WORD	?
oldpf	WORD	?
oldcf	WORD	?
myflags	WORD	?

.code
SaveMachineState PROC
	mov	oldax, ax
	mov	oldbx, bx
	mov	oldcx, cx
	mov	olddx, dx

	mov	oldss, ss
	mov	oldsp, sp
	mov	oldbp, bp

	mov	oldsi, si
	mov	olddi, di
	mov	oldds, ds
	mov	oldes, es

	push	ax
	pushf
	pop	ax
	mov	myflags, ax

	and	ax, 1h
	mov	oldcf, ax
	mov	ax, myflags

	and	ax, 4h
	mov	oldpf, ax
	mov	ax, myflags

	and	ax, 10h
	mov	oldacf, ax
	mov	ax, myflags

	and	ax, 40h
	mov	oldzf, ax
	mov	ax, myflags

	and	ax, 80h
	mov	oldsf, ax
	mov	ax, myflags

	and	ax, 100h
	mov	oldtf, ax
	mov	ax, myflags

	and	ax, 200h
	mov	oldif, ax
	mov	ax, myflags

	and	ax, 400h
	mov	olddf, ax
	mov	ax, myflags

	and	ax, 800h
	mov	oldof, ax
	mov	ax, myflags


	push	myflags
	popf
	pop	ax

ret
SaveMachineState ENDP

.data
mycomparedx	WORD	?
axchanged BYTE "Register AX's value has changed. Old value: ", 0
bxchanged BYTE "Register BX's value has changed. Old value: ", 0
cxchanged BYTE "Register CX's value has changed. Old value: ", 0
dxchanged BYTE "Register DX's value has changed. Old value: ", 0
sschanged BYTE "Register SS's value has changed. Old value: ", 0
spchanged BYTE "Register SP's value has changed. Old value: ", 0
bpchanged BYTE "Register BP's value has changed. Old value: ", 0
sichanged BYTE "Register SI's value has changed. Old value: ", 0
dichanged BYTE "Register DI's value has changed. Old value: ", 0
eschanged BYTE "Register ES's value has changed. Old value: ", 0
dschanged BYTE "Register DS's value has changed. Old value: ", 0
flagmsgfirst	BYTE	"Flag value has changed. Old value: ", 0
flagmsgsecond	BYTE	", new value: ", 0
clear	BYTE	"clear", 0
set	BYTE "set", 0
newof	WORD	?
newdf	WORD	?
newif	WORD	?
newtf	WORD	?
newsf	WORD	?
newzf	WORD	?
newacf	WORD	?
newpf	WORD	?
newcf	WORD	?
newsp WORD ?
mynewflags	WORD	?
by	BYTE ", new value: ", 0

.code
CompareMachineState PROC
	mov	newsp, sp
	push dx
	push	ax
	pushf
	mov	mycomparedx, dx

	pop dx
	mov	mynewflags, dx

	cmp oldax, ax
	jne	axdiff
axjmp:
	cmp oldbx, bx
	jne	bxdiff
bxjmp:
	cmp oldcx, cx
	jne	cxdiff
cxjmp:
	mov	dx, mycomparedx
	cmp olddx, dx
	jne	dxdiff
dxjmp:
	mov	dx, ss
	cmp	oldss, dx
	jne	ssdiff
ssjmp:
	mov	dx, newsp
	cmp	oldsp, dx
	jne	spdiff
spjmp:
	cmp oldbp, bp
	jne	bpdiff
bpjmp:
	cmp oldsi, si
	jne	sidiff
sijmp:
	cmp olddi, di
	jne	didiff
dijmp:
	mov	dx, es
	cmp oldes, dx
	jne	esdiff
esjmp:
	mov	dx, ds
	cmp oldds, dx
	jne	dsdiff

jmp	dsjmp
axdiff:
	mov dx, OFFSET axchanged
	call	WriteString
	mov	dx, oldax
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, ax
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	axjmp
bxdiff:
	mov dx, OFFSET bxchanged
	call	WriteString
	mov	dx, oldbx
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, bx
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	bxjmp
cxdiff:
	mov dx, OFFSET cxchanged
	call	WriteString
	mov	dx, oldcx
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, cx
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	cxjmp
dxdiff:
	mov dx, OFFSET dxchanged
	call	WriteString
	mov	dx, olddx
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, mycomparedx
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	dxjmp
ssdiff:
	mov dx, OFFSET sschanged
	call	WriteString
	mov	dx, oldss
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, ss
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	ssjmp
spdiff:
	mov dx, OFFSET spchanged
	call	WriteString
	mov	dx, oldsp
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, newsp
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	spjmp
bpdiff:
	mov dx, OFFSET bpchanged
	call	WriteString
	mov	dx, oldbp
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, bp
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	bpjmp
sidiff:
	mov dx, OFFSET sichanged
	call	WriteString
	mov	dx, oldsi
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, si
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	sijmp
didiff:
	mov dx, OFFSET dichanged
	call	WriteString
	mov	dx, olddi
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, di
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	dijmp
esdiff:
	mov dx, OFFSET eschanged
	call	WriteString
	mov	dx, oldes
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, es
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	esjmp
dsdiff:
	mov dx, OFFSET dschanged
	call	WriteString
	mov	dx, oldds
	call	WriteInt
	mov	dx, OFFSET by
	call	WriteString
	mov	dx, ds
	call	WriteInt
	mov	dl, '.'
	call	WriteChar
	call	NewLine
	jmp	dsjmp

dsjmp:
	; pop	ax
	; mov	mynewflags, ax
	mov	ax, mynewflags

	and	ax, 1h
	mov	newcf, ax
	mov	ax, mynewflags

	and	ax, 4h
	mov	newpf, ax
	mov	ax, mynewflags

	and	ax, 10h
	mov	newacf, ax
	mov	ax, mynewflags

	and	ax, 40h
	mov	newzf, ax
	mov	ax, mynewflags

	and	ax, 80h
	mov	newsf, ax
	mov	ax, mynewflags

	and	ax, 100h
	mov	newtf, ax
	mov	ax, mynewflags

	and	ax, 200h
	mov	newif, ax
	mov	ax, mynewflags

	and	ax, 400h
	mov	newdf, ax
	mov	ax, mynewflags

	and	ax, 800h
	mov	newof, ax
	mov	ax, mynewflags
	mov	dx, newof
	cmp	oldof, dx
	jne	ofmsg
ofjmp:
	mov	dx, newdf
	cmp	olddf, dx
	jne	dfmsg
dfjmp:
	mov	dx, newif
	cmp	oldif, dx
	jne	ifmsg
ifjmp:
	mov	dx, newtf
	cmp	oldtf, dx
	jne	tfmsg
tfjmp:
	mov dx, newsf
	cmp oldsf, dx
	jne sfmsg
sfjmp:
	mov dx, newzf
	cmp oldzf, dx
	jne zfmsg
zfjmp:
	mov dx, newacf
	cmp oldacf, dx
	jne acfmsg
acfjmp:
	mov	dx, newpf
	cmp oldpf, dx
	jne pfmsg
pfjmp:
	mov dx, newcf
	cmp oldcf, dx
	jne cfmsg
cfjmp:
	jmp ending
cfmsg:
	cmp oldcf, 0
	je clearsetcf
	mov	dl, "C"
	call	WriteChar
	mov	dl, " "
	call	WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET set
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET clear
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp cfjmp
clearsetcf:
	mov	dl, "C"
	call	WriteChar
	mov	dl, " "
	call WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET clear
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET set
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp cfjmp
pfmsg:
	cmp oldpf, 0
	je clearsetpf
	mov	dl, "P"
	call	WriteChar
	mov	dl, " "
	call	WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET set
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET clear
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp pfjmp
clearsetpf:
	mov	dl, "P"
	call	WriteChar
	mov	dl, " "
	call WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET clear
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET set
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp pfjmp
acfmsg:
	cmp oldacf, 0
	je clearsetacf
	mov	dl, "A"
	call	WriteChar
	mov	dl, " "
	call	WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET set
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET clear
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp acfjmp
clearsetacf:
	mov	dl, "A"
	call	WriteChar
	mov	dl, " "
	call WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET clear
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET set
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp acfjmp
zfmsg:
	cmp oldzf, 0
	je clearsetzf
	mov	dl, "Z"
	call	WriteChar
	mov	dl, " "
	call	WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET set
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET clear
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp zfjmp
clearsetzf:
	mov	dl, "Z"
	call	WriteChar
	mov	dl, " "
	call WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET clear
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET set
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp zfjmp
sfmsg:
	cmp oldsf, 0
	je clearsetsf
	mov	dl, "S"
	call	WriteChar
	mov	dl, " "
	call	WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET set
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET clear
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp sfjmp
clearsetsf:
	mov	dl, "S"
	call	WriteChar
	mov	dl, " "
	call WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET clear
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET set
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp sfjmp
tfmsg:
	cmp oldtf, 0
	je clearsettf
	mov	dl, "T"
	call	WriteChar
	mov	dl, " "
	call	WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET set
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET clear
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp tfjmp
clearsettf:
	mov	dl, "T"
	call	WriteChar
	mov	dl, " "
	call WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET clear
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET set
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp tfjmp
ifmsg:
	cmp oldif, 0
	je clearsetif
	mov	dl, "I"
	call	WriteChar
	mov	dl, " "
	call	WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET set
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET clear
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp ifjmp
clearsetif:
	mov	dl, "I"
	call	WriteChar
	mov	dl, " "
	call WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET clear
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET set
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp ifjmp
dfmsg:
	cmp olddf, 0
	je clearsetdf
	mov	dl, "D"
	call	WriteChar
	mov	dl, " "
	call	WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET set
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET clear
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp dfjmp
clearsetdf:
	mov	dl, "D"
	call	WriteChar
	mov	dl, " "
	call WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET clear
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET set
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp dfjmp
ofmsg:
	cmp oldof, 0
	je clearsetof
	mov	dl, "O"
	call	WriteChar
	mov	dl, " "
	call	WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET set
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET clear
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp ofjmp
clearsetof:
	mov	dl, "O"
	call	WriteChar
	mov	dl, " "
	call WriteChar
	mov	dx, OFFSET flagmsgfirst
	call	WriteString
	mov dx,	OFFSET clear
	call	WriteString
	mov	dx, OFFSET flagmsgsecond
	call WriteString
	mov	dx, OFFSET set
	call WriteString
	mov	dl, "."
	call	WriteChar
	call NewLine
	jmp ofjmp

ending:
	push	mynewflags
	popf
	pop	ax
	pop dx
ret
CompareMachineState ENDP

.data
divisor	WORD	1000h
negative_symbol	BYTE	"-", 0

.code
PrintInt PROC
	pushf
	push ax
	push bx
	push dx
	push si

	mov	si, 0
	cmp	ax, 0
	JG	positive

	cmp	ax, 0
	JL	negative

	mov	dx, 0
	call	WriteUInt
	jmp	ending

positive:
	mov	bx, 10
	mov	dx, 0
	div bx
	push dx
	mov	bx, 10
	mov	dx, 0
	div bx
	push dx
	mov	bx, 10
	mov	dx, 0
	div bx
	push dx
	mov	bx, 10
	mov	dx, 0
	div bx
	push dx
	mov	dx, ax
	cmp	dx, 0
	jne	printanswer
remveleading:
	inc si
	pop dx
	cmp	dx, 0
	je	remveleading
printanswer:
	cmp	si, 4
	je	trash
	call	WriteUInt
	pop	dx
	inc si
	jmp	printanswer
trash:
	call	WriteUInt
	jmp ending
negative:
	mov	dx, OFFSET negative_symbol
	call	WriteString
	mov	bx, -1
	imul bx
	jmp	positive

ending:
	pop si
	pop dx
	pop bx
	pop ax
	popf
ret
PrintInt ENDP

HexOut PROC
	pushf
	push bx
	push cx
	push si
	push dx
	mov	si, 1
	cmp	cx, 0
	je	ending

	mov	dl, [bx]
	call	WriteHexByte

	cmp	cx, 1
	je	ending

top:
		cmp	si, cx
		je	ending
		mov	dl, ' '
		call	WriteChar
		mov	dl, [bx + si]
		call	WriteHexByte
		inc	si
		jmp	top

ending:
	pop dx
	pop si
	pop cx
	pop bx
	popf
ret
HexOut ENDP

.data
msg	SWORD	8000h
hexdata	BYTE 5, 10, 15

.code
main PROC
	mov	ax, @data
	mov	ds, ax

	mov	ax, 4C00h
	int	21h
main ENDP
END
