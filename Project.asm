.386
.model flat, stdcall
.stack 8192
ExitProcess PROTO,          ; exit program
    dwExitCode:DWORD        ; return code

WriteConsoleA PROTO,                   ; write a buffer to the console
    handle:DWORD,                     ; output handle
    lpBuffer:PTR BYTE,                ; pointer to buffer
    nNumberOfCharsToWrite:DWORD,      ; size of buffer
    lpNumberOfCharsWritten:PTR DWORD, ; number of chars written
    lpReserved:PTR DWORD              ; 0 (not used)

ReadConsoleA PROTO,
    handle:DWORD,                     ; input handle
    lpBuffer:PTR BYTE,                ; pointer to buffer
    nNumberOfCharsToRead:DWORD,       ; number of chars to read
    lpNumberOfCharsRead:PTR DWORD,    ; number of chars read
    lpReserved:PTR DWORD              ; 0 (not used - reserved)

GetStdHandle proto, a1:dword

CloseHandle PROTO,      ; close file handle
    handle:DWORD

;ReadFile proto, a1: dword, a2: ptr byte, a3: dword, a4:ptr dword, a5: ptr dword
	ReadFile PROTO,       ; read buffer from input file
    fileHandle:DWORD,     ; handle to file
    pBuffer:PTR BYTE,     ; ptr to buffer
    nBufsize:DWORD,       ; number bytes to read
    pBytesRead:PTR DWORD, ; bytes actually read
    pOverlapped:PTR DWORD ; ptr to asynchronous info

CreateFileA PROTO,           ; create new file
    pFilename:PTR BYTE,     ; ptr to filename
    accessMode:DWORD,       ; access mode
    shareMode:DWORD,        ; share mode
    lpSecurity:DWORD,       ; can be NULL
    howToCreate:DWORD,      ; how to create the file
    attributes:DWORD,       ; file attributes
    htemplate:DWORD         ; handle to template file

WriteFile PROTO,             ; write buffer to output file
    fileHandle:DWORD,        ; output handle
    pBuffer:PTR BYTE,        ; pointer to buffer
    nBufsize:DWORD,          ; size of buffer
    pBytesWritten:PTR DWORD, ; number of bytes written
    pOverlapped:PTR DWORD    ; ptr to asynchronous info

.data
printout byte "What would you like to do?",0ah,"  1.) Hide",0ah,"  2.) Recover",0ah,"Enter your selection: "
printin byte 3 dup(?)
buff byte 53082 dup(?)
h byte '1'
r byte '2'
h1 byte "Please Specify the source PPM file: "
h2 byte "Please Specify the output PPM file: "
h3 byte "Please Enter Phrase to hide (Phrase must not exceed 50 characters): "
h4 byte "Your Phrase has been hidden in file: "
h5 byte " ",0ah,0ah
sourceppm byte 60 dup(?)
outputppm byte 60 dup(?)
phrase byte 100 dup(?)
sourceL dword ?
outputL dword ?
phraseL dword ?
r1 byte "Recovered message is:  "
namee byte 15 dup(?)
phrasee byte 50 dup(?)
sourceE byte 3 dup(?)
dsourceE byte 3 dup(?)
outputE byte 3 dup(?)
ppm byte "ppm"
ppm1 byte "ppm"
n2 byte "Recovered",0ah
error byte "Please select 1 or 2 only",0ah,0ah
e1 byte "Invalid file extention. Please enter file with .ppm extention",0ah,0ah
x dword ?
handle dword ?
count dword ?

.code
main proc
Console:
	;Writing onto Console
	mov eax,0
	;mov sourceE[0],0
	;mov outputE[0],0
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset printout, lengthof printout, offset x,0

	;Taking User Input
	invoke GetStdHandle, -10
	invoke ReadConsoleA, eax, offset printin, lengthof printin, offset x,0 

	mov al,printin     ;move user input in "al" for comparision
	cmp al,h
	JNE Recover
	Call Encrypt
	jmp Exit

Recover:
	cmp al,r
	JNE Err
	Call Decrypt
	jmp Exit

Err:
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset error, lengthof error, offset x,0
	jmp Console

Exit:
	jmp Console

	invoke ExitProcess,0
main endp

Encrypt proc uses esi eax ecx ebx edx ebp edi
	;Taking Source PPM filepath
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset h1, lengthof h1, offset x,0
	invoke GetStdHandle, -10
	invoke ReadConsoleA, eax, offset sourceppm, lengthof sourceppm, offset x,0
	
	
	;Adding null terminator at end of source filepath
	mov esi,x
	sub esi,2
	mov sourceL,esi
	mov al,0
	mov sourceppm[esi],al
	
	jmp SEE1
	;Exception for source.ppm
	sub sourceL,3
	mov edx,sourceL
	mov ecx,4 
	mov ebp,0 ;counter for .ppm
	SE:
		mov bl,sourceppm[edx]
		mov sourceE[ebp],bl
		cmp sourceE[ebp],0
		JE SEE
		inc edx
		inc ebp
	loop SE
	jmp SEE1
	
	SEE:
		mov cl,ppm
		cmp sourceE,cl
		JE SEE1
		invoke GetStdHandle, -11
		invoke WriteConsoleA, eax, offset e1, lengthof e1, offset x,0
		jmp RETURN
	SEE1:
	
	
	;Taking Output PPM filepath
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset h2, lengthof h2, offset x,0
	invoke GetStdHandle, -10
	invoke ReadConsoleA, eax, offset outputppm, lengthof outputppm, offset x,0 

	;Adding null terminator at end of output filepath
	mov esi,x
	sub esi,2
	mov outputL,esi
	mov al,0
	mov outputppm[esi],al
	
	jmp PEE1
	;Exception for output.ppm
	sub outputL,3
	mov edx,outputL
	mov ecx,4
	mov ebp,0 ;counter for .ppm
	PE:
		mov bl,outputppm[edx]
		mov outputE[ebp],bl
		cmp outputE[ebp],0
		JE PEE
		inc edx
		inc ebp
	loop PE
	jmp PEE1
	
	PEE:
		mov cl,ppm1
		cmp outputE,cl
		JE PEE1
		invoke GetStdHandle, -11
		invoke WriteConsoleA, eax, offset e1, lengthof e1, offset x,0
		jmp RETURN
	PEE1:

	;Taking Phrase to be encrypted
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset h3, lengthof h3, offset x,0
	invoke GetStdHandle, -10
	invoke ReadConsoleA, eax, offset phrase, lengthof phrase, offset x,0

	;Adding null terminator at end of phrase
	mov esi,x
	sub esi,2
	mov phraseL,esi
	mov al,0
	mov phrase[esi],al

	;Reading file data
	invoke CreateFileA, offset sourceppm, 1 ,1,0,3, 128, 0
	invoke ReadFile, eax, offset buff, lengthof buff, offset x,0
	mov esi, offset buff
	mov handle,eax
	Invoke CloseHandle, handle
	
	;invoke GetstdHandle,-11
	;invoke WriteConsoleA, eax,offset buff, lengthof buff, offset x ,0

	;Creating new file copy
	;invoke CreateFileA, offset outputppm, 2 ,1,0,2, 128, 0
	;invoke WriteFile, eax, offset buff, lengthof buff, offset x,0
	;mov handle,eax
	;Invoke CloseHandle, handle

	;finding first byte of image
	mov ecx, 50
	mov esi,0 ;for indexing
	mov ebp,0 ;counter for 0ah
	mov al,0ah
	L1:
		cmp al, buff[esi]
		JNE L3
		L2:
		inc ebp
		cmp ebp,3
		JE L4
		L3:
		inc esi
	loop L1
	L4:
	inc esi

	;starting encryption
	add phraseL,1
	mov ecx,phraseL
	mov edi,0 ;counter for phrase
	Eouter:
		mov dl,phrase[edi]
		mov ebx,ecx
		mov ecx,8
		Einner:
			ROL dl,1
			JNC A
			OR buff[esi],00000001b
			jmp Endloop
			A:
			AND buff[esi],11111110b
			Endloop:
			inc esi
		loop Einner
		mov ecx,ebx
		inc edi
	loop Eouter

	;Creating new file copy
	invoke CreateFileA, offset outputppm, 2 ,1,0,2, 2, 0
	invoke WriteFile, eax, offset buff, lengthof buff, offset x,0
	mov handle,eax
	Invoke CloseHandle, handle

	;finding file name
	mov ebx,35
	mov ebp,0 ;counter to namee
	FN:
		mov dl, outputppm[ebx]
		mov namee[ebp],dl
		cmp dl,0
		JE FNE
		inc ebx
		inc ebp
	loop FN
	FNE:

	;Writing success message
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset h4, lengthof h4, offset x,0
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset namee, lengthof namee, offset x,0
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset h5, lengthof h5, offset x,0

	RETURN:
	ret
Encrypt endp

Decrypt proc uses esi eax ecx ebx edx ebp edi
	;Taking Source File path
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset h1, lengthof h1, offset x,0
	invoke GetStdHandle, -10
	invoke ReadConsoleA, eax, offset sourceppm, lengthof sourceppm, offset x,0

	;Adding null terminator at end of source filepath
	mov esi,x
	sub esi,2
	mov sourceL,esi
	mov al,0
	mov sourceppm[esi],al 
	
	jmp SEE1
	;Exception for source.ppm
	sub sourceL,3
	mov edx,sourceL
	mov ecx,4 
	mov ebp,0 ;counter for .ppm
	SE:
		mov bl,sourceppm[edx]
		mov dsourceE[ebp],bl
		cmp dsourceE[ebp],0
		JE SEE
		inc edx
		inc ebp
	loop SE
	jmp SEE1
	
	SEE:
		mov cl,ppm
		cmp dsourceE,cl
		JE SEE1
		invoke GetStdHandle, -11
		invoke WriteConsoleA, eax, offset e1, lengthof e1, offset x,0
		jmp RETURN
	SEE1:

	;Reading source file
	invoke CreateFileA, offset sourceppm, 1 ,1,0,3, 128, 0
	invoke ReadFile, eax, offset buff, lengthof buff, offset x,0
	mov esi, offset buff
	mov handle,eax
	Invoke CloseHandle, handle

	;finding first byte of image
	mov ecx, 50
	mov esi,0 ;for indexing
	mov ebp,0 ;counter for 0ah
	mov al,0ah
	L1:
		cmp al, buff[esi]
		JNE L3
		L2:
		inc ebp
		cmp ebp,3
		JE L4
		L3:
		inc esi
	loop L1
	L4:
	inc esi

	;starting decryption
	mov ebp,0 ;counter for phrase
	mov ecx, lengthof buff
	Douter:
		mov count,ecx
		mov ecx,8
		mov edx, 0
		mov ebx,0
		mov al,10000000b
		Dinner:
			mov bl, buff[esi]
			ROR bl,1
			JNC A
			OR dl,al
			A:
			SHR al,1
			inc esi
		loop Dinner
		cmp dl,0
		JE L5
		mov ecx,count
		mov phrase[ebp],dl
		inc ebp
		
		
	loop Douter
	L5:
	pop ecx
	
	;Writing message on Console
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset r1, lengthof r1, offset x,0
	invoke GetStdHandle, -11
	invoke WriteConsoleA, eax, offset phrase, lengthof phrase, offset x,0
	
	RETURN:
	ret
Decrypt endp
end main
