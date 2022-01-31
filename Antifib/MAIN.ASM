INCLUDE CS240.inc
.8086

DOS = 21h
TERMINATE = 4C00h
antifib PROTO

.data
msg 	BYTE	"Antifib: "

.code
main PROC
	mov	ax, @data
	mov	ds, ax
	
	mov	dx, OFFSET msg
	call	WriteString
	call	ReadUInt	

	call	antifib

	mov	ax, TERMINATE
	int	DOS
main ENDP
END main
