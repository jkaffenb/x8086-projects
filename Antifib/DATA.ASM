INCLUDE CS240.inc
.8086

.data
var1	BYTE	255
var2	SBYTE	+127
var3	WORD	65535
var4	SWORD	-32768
var5	DWORD	12345678h
var6	SDWORD	-2147483648
var7	FWORD	123456781234h
var8	QWORD	1234567812345678h
var9	TBYTE	800000000000001234h
var10	REAL4	-1.2
var11	REAL8	3.2E-260
var12	REAL10	4.6E+4096

.code
main PROC
	mov	ax, @data
	mov	ds, ax
	
	call	DumpMem

	mov	ax, 4C00h
	int	21h
main ENDP
END main
