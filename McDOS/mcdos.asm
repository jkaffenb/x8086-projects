.model tiny,stdcall
INCLUDE mcdoslib.inc
INCLUDE mcdoshlp.inc
.code

DOS = 21h
TERMINATE = 4C00h

ORG	100h

entry:
	jmp main

OldKeyboardInterrupt LABEL DWORD
OldKeyboardOffset WORD ?
OldKeyboardSegment WORD ?
KeyCode	WORD 	?
BufferLength WORD ?
NormalMode WORD 1
MacroMode WORD 0
ReadTriggerMode WORD 0
RecordMacroMode WORD 0
NormalPage	BYTE ?
MacroPage		BYTE ?
ReadTriggerPage BYTE ?
RecordMacroPage BYTE ?
MacroArray BYTE 3300 DUP(?)
MacroPosition WORD 0
CurrentMacroLength BYTE 0
NumberofMacros BYTE 0
mybx WORD ?

;scancode high, ascii low

MY_GetInterruptVector	PROC
	push ax
	mov ah, 35h
	int 21h
	pop	ax
	ret
MY_GetInterruptVector ENDP

MY_SetInterruptVector	PROC
	push ax
	mov ah, 25h
	int 21h
	pop ax
	ret
MY_SetInterruptVector ENDP

WriteKeyCode PROC
	pushf
	push ax
	push dx

	in	al, 60h

	test	al, 080h	; Only process key releases
	jz	ending

	mov dx, cs:KeyCode
	call WriteChar

ending:
	pop dx
	pop ax
	popf
ret
WriteKeyCode ENDP

SaveKeyCode PROC
	push bx
	push dx
	push si

	mov bx, 40h
	mov es, bx
	mov bx, 1ah
	mov si, es:[bx]
	mov dx, es:[si]
	mov cs:KeyCode, dx
	;call 	WriteHexWord

	pop si
	pop dx
	pop bx
	ret
SaveKeyCode ENDP

ResetBuffer PROC
	push bx
	push dx
	push si
	mov bx, 40h
	mov es, bx
	mov bx, 1ah
	;mov dx, 40h:1ah
	mov  dx, es:[bx]
	mov bx, 1ch
	mov es:[bx], dx

	; tail 1ch
	; head 1ah
	; buffer 1eh
	pop si
	pop dx
	pop bx
	ret
ResetBuffer ENDP

SaveKeyboardInterrupt PROC
	push 	ax
	push	bx
	push	es

	mov	al, 9
	call	MY_GetInterruptVector 			;DOS_GetInterruptVector
	mov	cs:OldKeyboardSegment, es
	mov	cs:OldKeyboardOffset, bx

	pop	es
	pop	bx
	pop ax
	ret
SaveKeyboardInterrupt ENDP

InstallNewKeyboardInterrupt PROC
	push	ax
	push	dx
	push	es

	mov	ax, cs
	mov	es, ax
	mov	dx, KeyboardInterruptHandler
	mov	al, 9
	call	MY_SetInterruptVector				;DOS_SetInterruptVector

	pop	es
	pop	dx
	pop	ax
	ret
InstallNewKeyboardInterrupt ENDP

InstallOldKeyboardInterrupt PROC
	push	ax
	push	dx
	push	ds

	mov	ds, cs:OldKeyboardSegment
	mov	dx, cs:OldKeyboardOffset
	mov	al, 9
	call	MY_SetInterruptVector

	pop	ds
	pop	dx
	pop	ax
	ret
InstallOldKeyboardInterrupt ENDP

CheckMacroKey PROC
	pushf
	push	ax
	push bx
	push cx
	push dx

	in	al, 60h

	test	al, 080h	; Only process key releases
	jz	done

	; mov dx, 0
	; mov dl, al
	; call NewLine				;to get correct scan code
	; call WriteHexWord
	; call NewLine

	cmp al, 0B6h
	je setmacromode

;search through array to see if a macro is available
	mov bx, 1
	mov ax, cs:KeyCode
	mov cx, 0
	mov cl, cs:NumberofMacros
top1:
	cmp cx, 0
	je done

	mov dl, MacroArray[bx]
	cmp dl, al
	je insertmacro

	dec cx
	add bx, 33
	jmp top1

	jmp done

insertmacro:
		mov dl, MacroArray[bx]
		mov dx, 0
		mov dl, MacroArray[bx + 1]
		mov cx, 0
		mov al, MacroArray[bx + 1]
		mov cs:mybx, bx

		mov bx, 40h
		mov es, bx
		mov bx, 1ch					;get tail
		mov si, 1eh
		mov es:[bx], si
		mov bx, 1ah
		mov es:[bx], si

		mov bx, cs:mybx
	top2:
			cmp cl, al
			je done1
			mov dl, MacroArray[bx + 3]
			; call WriteChar
			call InsertKey
			inc cx
			inc cx
			inc bx
			inc bx
			jmp top2
setmacromode:
	call NewLine
	PrintString "Entering Macro Mode..."
	call NewLine
	mov cs:NormalMode, 0
	mov cs:MacroMode, 1

	mov ah, 05h
	mov bl, cs:NormalPage
	inc bl
	mov cs:MacroPage, bl
	mov al, bl
	int 10h
	PrintString "You are now in Macro Mode!"
	call NewLine
	PrintString "Commands:"
	call NewLine
	PrintString "'=' to define a macro"
	call NewLine
	PrintString "'esc' to exit macro mode"
	call NewLine
	jmp done
done1:
	call NewLine
	;call	DumpKeyboardBufferASCII
	jmp done
done:
	pop dx
	pop bx
	pop cx
	pop	ax
	popf
	ret
CheckMacroKey ENDP

KeyboardInterruptHandler PROC
	; PrintString "."
	pushf
	call	cs:OldKeyboardInterrupt
	;call	DumpKeyboardBufferASCII
	call 	SaveKeyCode
	call 	WriteKeyCode
	call  ResetBuffer
	call 	SetMode
	iret
KeyboardInterruptHandler ENDP

SetMode PROC
	pushf
	push ax
	push bx
	push dx
	push si
	mov dx, cs:NormalMode
	cmp dx, 1
	je	CheckNormal

	mov dx, cs:MacroMode
	cmp dx, 1
	je	CheckMacro

	mov dx, cs:ReadTriggerMode
	cmp dx, 1
	je	CheckTriggerMode

	mov dx, cs:RecordMacroMode
	cmp dx, 1
	je	CheckRecordMacro

	jmp ending

CheckTriggerMode:
	in	al, 60h
	test	al, 080h	; Only process key releases
	jz	ending

	;move the keycode into the macro position

	mov dx, cs:KeyCode
	mov bx, cs:MacroPosition
	mov MacroArray[bx], dh
	mov MacroArray[bx + 1], dl

	mov cs:ReadTriggerMode, 0
	mov cs:RecordMacroMode, 1

	mov ah, 05h
	mov al, ReadTriggerPage
	inc al
	mov RecordMacroPage, al
	int 10h

	call NewLine
	PrintString "You are now defining a macro, corresponding to the key below"
	call NewLine

	call WriteChar
	call NewLine
	PrintString "Type '-' to finish recording the macro"
	call NewLine
	PrintString "Input a maximum of 15 characters: "
	jmp ending

Errormsg:
	call Newline
	PrintString "You are at maximum macro length! Please exit by inputting '-'."
	call Newline
	jmp ending

ExitRecordMacroMode:
	mov bx, cs:MacroPosition
	mov dl, cs:CurrentMacroLength			;put in the macro length
	mov MacroArray[bx + 2], dl

	add bx, 33												;move the macro position down
	mov cs:MacroPosition, bx

	mov bx, 0
	mov bl, cs:NumberofMacros					;add one to the macro counter
	inc bx
	mov cs:NumberofMacros, bl

	mov cs:CurrentMacroLength, 0		;set and move pages
	mov cs:RecordMacroMode, 0
	mov cs:MacroMode, 1
	mov ah, 05h
	mov al, cs:MacroPage
	int 10h
	call NewLine
	PrintString "You are now in Macro Mode!"
	call NewLine
	jmp ending

CheckRecordMacro:
	in	al, 60h
	test	al, 080h	; Only process key releases
	jz	ending

	cmp al, 08Ch	;user exits RecordMacroMode
	je	ExitRecordMacroMode

	mov dl, cs:CurrentMacroLength
	cmp dl, 30
	je Errormsg

	mov bl, cs:CurrentMacroLength 		;check
	mov dx, cs:KeyCode
	mov si, MacroPosition
	mov MacroArray[bx + si + 3], dh
	inc bx
	mov MacroArray[bx + si + 3], dl
	inc bx
	mov cs:CurrentMacroLength, bl

	jmp ending

CheckMacro:
	in	al, 60h
	test	al, 080h	; Only process key releases
	jz	ending
	cmp al, 081h
	je EscMacroMode
	cmp al, 08Dh
	je PlusMacroMode
	jmp ending

PlusMacroMode:
	mov ah, 05h
	mov al, cs:MacroPage
	inc al
	int 10h
	mov cs:ReadTriggerPage, al
	mov cs:ReadTriggerMode, 1
	mov cs:MacroMode, 0
	call NewLine
	PrintString "Type your macro trigger"
	call NewLine
	jmp ending

EscMacroMode:
	;go back to normal window
	mov ah, 05h
	mov al, cs:NormalPage						;move page
	int 10h
	mov cs:NormalMode, 1						;set page
	mov cs:MacroMode, 0
	call NewLine
	PrintString "Back in Normal Mode!"
	call NewLine
	jmp	ending

CheckNormal:
	mov ah, 0Fh
	int 10h
	mov cs:NormalPage, bh
	call 	CheckMacroKey
	jmp ending

ending:
	pop si
	pop dx
	pop bx
	pop ax
	popf
	ret
SetMode ENDP

InsertKey PROC
	push bx
	push dx
	push si

	mov dl, MacroArray[bx + 3]
	mov dh, MacroArray[bx + 2]

	mov bx, 40h
	mov es, bx
	mov bx, 1ch					;get tail
	mov si, es:[bx]			;si is tail

	mov es:[si], dx ; es:[si] is data at tail

	inc si
	inc si							;move tail
	mov es:[bx], si			;update tail

ending:
	pop si
	pop dx
	pop bx
	ret
InsertKey ENDP

GetBufferLength PROC
	push bx
	push cx
	push dx
	push si
	mov bx, 40h
	mov es, bx
	mov bx, 1ah
	mov  dx, es:[bx] ;dx is head location
	mov bx, 1ch
	mov  si, es:[bx]	;si is tail location
	cmp	dx, si
	je	resultzero
	ja	case1
	jb	case2
	jmp	ending

case1:
	;h >  t
	mov cx, 1
	sub dx, si
	shr dx, cl
	mov bx, 16
	sub bx, dx
	mov dx, bx
	mov cs:BufferLength, dx
	jmp	ending
case2:
	;h < t
	mov cx, 1
	sub si, dx
	shr si, cl
	mov dx, si
	mov cs:BufferLength, dx
	jmp ending

resultzero:
	mov dx, 0
	mov cs:BufferLength, dx
	jmp	ending

ending:
	pop si
	pop dx
	pop cx
	pop bx
ret
GetBufferLength ENDP


main PROC
	mov	ax, cs
	mov	ds, ax

	call	PrintVersion

	mov	al, 9
	call	ShowInterruptVector

	call	SaveKeyboardInterrupt

	call	InstallNewKeyboardInterrupt
	mov	al, 9
	call	ShowInterruptVector

	call	WaitForF12

	call	InstallOldKeyboardInterrupt
	mov	al, 9
	call	ShowInterruptVector

	;call	FlushKeyboardBuffer

	;call TerminateStayResident
	mov	ax, TERMINATE
	int 	DOS
main ENDP

END entry

HPRESSED BYTE 0
HPRESS = 0A3h
IPRESS = 097h

CatchHi PROC
	pushf
	push	ax

	in	al, 60h

	test	al, 080h	; Only process key releases
	jz	done

	cmp	al, HPRESS	; Is it an h?
	je	found_H

	cmp	al, IPRESS	; Is it an i?
	je	found_I

	mov	cs:HPRESSED, 0	; Neither h, nor i
	jmp	done

found_H:
	mov	cs:HPRESSED, 1	; h was pressed,
	jmp	done

found_I:
	cmp	cs:HPRESSED, 0	; i was pressed, was h before?
	mov	cs:HPRESSED, 0	; h wasn't just pressed
	je	done
	PrintLine	"Hi!"	; i was pressed after an h

done:
	pop	ax
	popf
	ret
CatchHi ENDP
