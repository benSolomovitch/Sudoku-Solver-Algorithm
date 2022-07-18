;Ben Solomovitch
;Guided by Izabella Tevlin
;This is a Sudoku solver algorithm
;All you have to do is enter the fixed number to the cells and press space when finished
;Use Back Space to erase
;The recommended way of running is through tasm/zi Sudoku... tlink/v sudoku... td sudoku... (press f9)
IDEAL
MODEL small
STACK 100h
DATASEG
;Algorithm's variabls
	code db 81 dup (0)
	change db 81 dup (0)
	numberCheck db (?)
	numberPlace dw (?);low line high column 
	lastCheck db (?)
	firstCheck db (?)
	flag db (?)
	numberAdress dw (?)
;graphics' variabls
	x dw (?)
	y dw (?)
	color db (?)
	startX dw (?)
	endX dw (?)
	startY dw (?)
	endY dw (?)
	index dw 0
;screens' variabls
	rules1 db 'Are you a professional Sudoku solver?$'
	rules2 db 'Or you just tried once to solve a$'
	rules3 db 'Sudoku puzzle and gave up... So this$'
	rules4 db 'app is exactly for you! All you$'
	rules5 db 'have to do is enter the fixed numbers$'
	rules6 db 'with keys 1-9 and press space.$'
	rules7 db 'Then the computer would solve it!$'
	rules8 db 'So, are you ready for some magic?$'
	title1 db 'Sudoku Solver Algorithm$'
	pressToRestart db 'Press r to restart...$'
	playText db 'Play!$'
	rulesText db 'Rules & Help$'
	exitText db 'Exit$'
	escText db 'esc$'
	sureYou db 'Sure you want to exit?$'
	yesText db 'Yes$'
	noText	db 'No!$'
	illegalText db 'Illegal Puzzle$'
	settingsText db 'Settings$'
	screenStatus db 0
	settingsSwitch db 'Here you can change the table color$'
	settingsUse db 'Use arrows to switch my color$'
	tableColor db 0
	colorArr db 0,1,2,3,4,5,6,43,37,38
CODESEG

;Signifies the cells of the fixed numbers.
proc Rock
push ax
push bx
push cx
push dx
	mov cl,81
	xor dx, dx
	mov bx,offset code
FindRock:
	mov bx,offset code
	add bx,dx
	mov al,[byte ptr bx]
	mov bx,offset change
	add bx,dx
	mov [byte ptr bx],al
	inc dx
	loop FindRock
	mov bx,offset change
	mov cl,81
MarkRock:
	cmp [byte ptr bx],0
	je MarkRockLoop
	mov [byte ptr bx],2
MarkRockLoop:
	inc bx
	loop MarkRock
	mov cl,81
	mov bx,offset change
	xor dx,dx
LastZero:
	cmp [byte ptr bx],0
	jne LoopLastZero
	mov dh,dl
LoopLastZero:
	inc bx
	inc dl
	loop LastZero
	mov [lastCheck],dh
	mov cl,81
	mov bx,offset change
	xor dx,dx
FirstZero:
	cmp [byte ptr bx],0
	je EndFirst
	inc bx
	inc dl
	loop FirstZero
EndFirst:	
	mov [firstCheck],dl
pop dx
pop cx
pop bx
pop ax
	ret
endp Rock
;Finds the first place which can be changed.
proc ZeroPlace
push ax
push bx
push cx
push dx
	push 0
	mov cl,81
	mov bx, offset change
FindZero:;finds the first zero
	cmp [byte ptr bx],0
	je HaveZero
	inc bx
	pop dx
	inc dx  
	push dx
	loop FindZero
	mov [flag],1
	jmp FinZero
HaveZero:
	pop ax ;place return in ax
	mov dl,9
	div dl
	mov [numberPlace],ax
	mov [flag],0
FinZero:
pop dx
pop cx
pop bx
pop ax
	ret
endp ZeroPlace
;Tries to increase the value of a cell.
proc IncOneZero
push ax
push bx
push dx
	cmp [flag],1
	jne Continue;Table Finished
	mov [flag],0
	pop dx
	pop bx
	pop ax
	ret
Continue:
	push [numberPlace]
	push offset change
	call FindEveryPlace
	mov bx,[numberAdress]
	cmp [byte ptr bx],0
	jne StartOfInc
	inc [byte ptr bx]
	push [numberPlace]
	push offset code
	call FindEveryPlace
	mov bx,[numberAdress]
	mov al,[byte ptr bx]
	mov [numberCheck],al
StartOfInc:
	inc [numberCheck]
	xor ax,ax
	cmp [numberCheck],10
	jb IncPlace
	jmp Fin
IncPlace:
	push [numberPlace]
	push offset code
	call FindEveryPlace
	mov bx,[numberAdress]
	mov al,[numberCheck]
	mov [byte ptr bx],al
	push 9
	call ColumnLineCheck
	cmp [flag],1
	je StartOfInc
	push 1
	call ColumnLineCheck
	cmp [flag],1
	je StartOfInc
	call SquareCheck
	cmp [flag],1
	je StartOfInc
Okay:
	mov [flag],0
	jmp AfterInc
Fin:
	mov [flag],1
AfterInc:
pop dx
pop bx
pop ax
	ret
endp IncOneZero
;Checks whether the digit is valid by column or line.
proc ColumnLineCheck
push bp
	mov bp,sp
push ax
push bx
push cx
push dx
	;For Line checking push 1
	;For Column checking push 9
	mov dx,[bp+4]
	cmp dx,9
	je ColumnPrepare
	push dx
	push [numberPlace]
	push offset code
	call FindEveryPlace
	mov bx,[numberAdress]
	mov ax,[numberPlace]
	sub bl,ah
	jmp StartCL
ColumnPrepare:
	push dx
	mov dx,[numberPlace]
	mov bx,offset code
	add bl,dh
StartCL:
	mov cl,9
	xor ax,ax
Verify:
	mov dl,[numberCheck]
	cmp dl,[byte ptr bx]
	jne LoopVer
	inc al
	cmp al,2
	je WrongCL
LoopVer:
	pop dx
	add bx,dx
	push dx
	loop Verify
	pop ax
	mov [flag],0
	jmp AfterPrint
WrongCL:
	pop ax
	mov [flag],1
AfterPrint:
pop dx
pop cx
pop bx
pop ax
pop bp
	ret 2
endp ColumnLineCheck
;Converts the cell location to the difference from the first cell.
proc FindEveryPlace
push bp
	mov bp,sp
push ax
push bx
push dx
	;mov ax place
	;mov bx the offset of table
	mov ax,[bp+6]
	mov bx,[bp+4]
	mov dh,ah
	xor ah,ah
	mov dl,9
	mul dl
	add al,dh
	add bx,ax
	mov [numberAdress],bx
pop dx
pop bx
pop ax
pop bp
	ret 4
endp FindEveryPlace
;Checks if a digit is valid by its square.
proc SquareCheck
push ax
push bx
push cx
push dx
	mov ax,[numberPlace]
	mov cl,4
FindWidth:
	inc ah
	mov dh,3
	mov bl,ah
	mov al,ah
	xor ah,ah
	div dh
	cmp ah,0
	je HaveWidth
	mov ah,bl
	loop FindWidth
HaveWidth:
	mov ah,bl
	dec ah
	xor al,al
	push ax
	mov ax,[numberPlace]
	mov cl,4
FindHight:
	inc al
	mov dh,3
	mov bl,al
	xor ah,ah
	div dh
	cmp ah,0
	je HaveHight
	mov al,bl
	loop FindHight
HaveHight:
	mov al,bl
	dec al
	xor ah,ah
	pop dx
	mov bx,dx
	mov ah,bh
VerifySquare:
	mov dl,al
	sub dl,2
	mov cl,ah
	sub cl,2
	xor ah,ah
	push 0
	mov al,dl
	mov dl,9
	mul dl
	add al,cl
	mov bx,offset code
	add bl,al
	mov ah,3
	mov cl,3
RowCheck:
	mov al,[byte ptr bx]
	cmp al,[numberCheck]
	jne SeemsGood
	pop dx
	inc dx
	push dx
	cmp dx,2
	je PrintMe
SeemsGood:
	inc bx
	dec ah
	cmp ah,0
	jne RowCheck
	mov ah,3
	add bx,6
	loop RowCheck
	pop ax
	mov [flag],0
	jmp AfterPrintMe
PrintMe:
	pop ax
	mov [flag],1
AfterPrintMe:
pop dx
pop cx
pop bx
pop ax
	ret
endp SquareCheck
;Allows the algorithm to revert to previous cells.
proc RecIt
push ax
push bx
push dx
	mov ax,[numberPlace]
	mov dh,ah
	xor ah,ah
	mov dl,9
	mul dl
	add al,dh
	cmp al,[firstCheck]
	je ErrorMessage
	push [numberPlace]
	push offset code
	call FindEveryPlace
	mov bx,[numberAdress]
	xor al,al
	mov [byte ptr bx],al
	push [numberPlace]
	push offset change
	call FindEveryPlace
	mov bx,[numberAdress]
	mov [byte ptr bx],0
TheOne:
	dec bx
	cmp [byte ptr bx],1
	jne TheOne
	mov [byte ptr bx],0
	mov [flag],0
	jmp EndRect
ErrorMessage:
	mov [flag],1
EndRect:
pop dx
pop bx
pop ax
	ret
endp RecIt
;Checks if the rocks are valid
proc RockCheck
push ax
push bx
push cx
push dx
	xor dx,dx
LoopFirstCheck:
	mov bx,offset change
	add bl,dl
	cmp [byte ptr bx],2
	jne EndLoopFirstCheck
	xor ah,ah
	mov al,dl
	mov dh,9
	div dh
	mov [numberPlace],ax
	mov bx,offset code
	add bl,dl
	mov dh,[byte ptr bx]
	mov [numberCheck],dh
	push 1
	call ColumnLineCheck
	cmp [flag],1
	je EndFirstCheck
	push 9
	call ColumnLineCheck
	cmp [flag],1
	je EndFirstCheck
	call SquareCheck
	cmp [flag],1
	je EndFirstCheck
EndLoopFirstCheck:
	inc dl
	cmp dl,80
	jne LoopFirstCheck
	mov [flag],0
EndFirstCheck:
pop dx
pop cx
pop bx
pop ax
	ret
endp RockCheck
;Includes all the procedures of the solving algorithm.
proc Try
	call rock
	call RockCheck
	cmp [flag],1
	jne CanStart
	mov [x],91
	mov [y],10
	push 4
	push 1
	push offset illegalText
	call PrintStringGraphics
	jmp EndTry
CanStart:
	mov [flag],0
LoopIt:
	call ZeroPlace
	call IncOneZero
	cmp [flag],0
	je Good
	call RecIt
	cmp [flag],1
	jne Good
	mov [x],91
	mov [y],10
	push 4
	push 1
	push offset illegalText
	call PrintStringGraphics
	jmp EndTry
Good:
	mov bx,offset change
	add bl,[lastCheck]
	cmp [byte ptr bx],1
	jne LoopIt
	mov [flag],0
EndTry:
	ret
endp Try
;Switches to graphics mode.
proc GraphicsMode
push ax
	mov ax, 13h
	int 10h
pop ax
	ret
endp GraphicsMode
;Displays a vertical line.
proc VerticaLine
push [y]
push cx
	mov cx, [startY]
	mov [y], cx
VerticalLoop:
	call Dot
	inc [y]
	mov cx, [endY]
	inc cx
	cmp [y], cx
	jne VerticalLoop
pop cx
pop [y]
	ret
endp VerticaLine
;Changes background color.
proc BackgroundColor
	mov [y],0
BackgroundLoop:
	mov [startX],0
	mov [endX],319
	call HorizontalLine
	inc [y]
	cmp [y],199
	jbe BackgroundLoop
	ret
endp BackgroundColor
;Displays an horizontal line.
proc HorizontalLine
push [x]
push cx
	mov cx, [startX]
	mov [x], cx
HorizontalLoop:
	call Dot
	inc [x]
	mov cx, [endX]
	inc cx
	cmp [x], cx
	jne HorizontalLoop
pop cx
pop [x]
	ret
endp HorizontalLine
;Displays a dot.
proc Dot
push cx
push ax
push bx
push dx
	mov al, [color]
	mov bl, 01h
	mov cx, [x]
	mov dx, [y]
	mov ah, 0Ch
	int 10h
pop dx
pop bx
pop ax
pop cx
	ret
endp Dot
;Displays horizontal lines of the table.
proc HorizontalTable
push [x]
push [y]
push ax
push cx
	mov ax,[x]
	mov [startX],ax
	mov [endX],ax
	add [endX],42
	mov cx,[y]
	add cx,42
HorizontalTableLoop:
	call HorizontalLine
	add [y],14
	cmp [y],cx
	jbe HorizontalTableLoop
pop cx
pop ax
pop [y]
pop [x]
	ret
endp HorizontalTable
;Displays vertical lines of the table.
proc VerticalTable
push [x]
push [y]
push ax
push cx
	mov ax,[y]
	mov [startY],ax
	mov [endY],ax
	add [endY],42
	mov cx,[x]
	add cx,42
VerticalTableLoop:
	call VerticaLine
	add [x],14
	cmp [x],cx
	jbe VerticalTableLoop
pop cx
pop ax
pop [y]
pop [x]
	ret
endp VerticalTable
;Displays three squares of the table.
proc TableThree
push [x]
push [y]
push cx
	mov cx,3
TableThreeLoop:
	call HorizontalTable
	call VerticalTable
	add [x],43
	loop TableThreeLoop
pop cx
pop [y]
pop [x]
	ret
endp TableThree
;Displays the table.
proc SudokuTable
	mov [x],85
	mov [y],29
	mov [index],0
push ax
push cx
push [x]
push [y]
;minus nine for minus pixel
push [y]
	mov cx,2
HorizontalSudokuLoop:
	push cx
	mov ax,[x]
	mov [startX],ax
	mov [endX],ax
	add [endX],130;e
	call HorizontalLine
	add [y],130;e
	pop cx
	loop HorizontalSudokuLoop	
pop [y]
push [x]
push [y]
	mov cx,2
	inc [y]
VerticalSudokuLoop:
	push cx
	mov ax,[y]
	mov [startY],ax
	mov [endY],ax
	add [endY],128
	call VerticaLine
	add [x],130 
	pop cx
	loop VerticalSudokuLoop	
pop [y]
pop [x]
	inc [y]
	inc [x]
	mov cx,3
SudokuTableLoop:
	call TableThree
	add [y],43
	loop SudokuTableLoop
pop [y]
pop [x]
	add [x],2
	add [y],2
	mov [color],41
	call Marker
pop cx
pop ax
	ret
endp SudokuTable
;Displays the marker on the table.
proc Marker
push ax
push cx
push [y]
	mov cx,2
HorizontalMarker:
	push cx
	mov ax,[x]
	mov [startX],ax
	mov [endX],ax
	add [endX],12
	call HorizontalLine
	add [y],12
	pop cx
	loop HorizontalMarker
pop [y]
push [x]
push [y]
	mov cx,2
	inc [y]
VerticalMarker:
	push cx
	mov ax,[y]
	mov [startY],ax
	mov [endY],ax
	add [endY],10
	call VerticaLine
	add [x],12
	pop cx
	loop VerticalMarker
pop [y]
pop [x]
pop cx
pop ax
	ret
endp Marker
;Manages all game inputs.
proc Move
push ax
WaitForData:
	mov  ah, 0
	int  16h 
	cmp ah,48h;up
	jne Left
	call UpMove
	jmp WaitForData
Left:
	cmp ah,04Bh;left
	jne Right
	call LeftMove
	jmp WaitForData
Right:
	cmp ah,4Dh;right
	jne Down1
	call RightMove
	jmp WaitForData
Down1:
	cmp ah,50h;down
	jne Digit
	call DownMove
	jmp WaitForData
Digit:
	cmp ah,2h
	jb BackSpace
	cmp ah,0Ah
	ja BackSpace
	xor ah,ah
	push 0
	push ax
	sub al,30h
	mov bx,offset code
	add bx,[index]
	mov [byte ptr bx],al
	call DigitDisplay
	jmp WaitForData
BackSpace:
	cmp ah,0Eh
	jne EscInput
	mov bx,offset code
	add bx,[index]
	mov [byte ptr bx],0
	mov [color],92
	add [x],4
	add [y],3
	call EraseDigit
	sub [x],4
	sub [y],3
	jmp WaitForData
EscInput:
	cmp ah,1
	jne SpaceInput
	mov [screenStatus],0
	jmp EndMove
	call RestartArray
SpaceInput:
	cmp ah,39h
	je EndMove
Fine:
	jmp WaitForData
EndMove:
	mov [color],92
	call Marker
pop ax
	ret
endp Move
;Moves to the right on table.
proc RightMove
push ax
push dx
	mov ax,[index]
	inc ax
	mov dl,9
	div dl
	cmp ah,0
	je EndRight
	inc [index]
	mov [color],92
	call Marker
	mov ax,[index]
	mov dl,3
	div dl
	cmp ah,0
	jne SimpleRight
	inc [x]
SimpleRight:
	add [x],14
	mov [color],41
	call Marker
EndRight:
pop dx
pop ax
	ret
endp RightMove
;Moves to the left on table.
proc LeftMove
push ax
push dx
	mov ax,[index]
	mov dl,9
	div dl
	cmp ah,0
	je EndLeft
	dec [index]
	mov [color],92
	call Marker
	mov ax,[index]
	inc ax
	mov dl,3
	div dl
	cmp ah,0
	jne SimpleLeft
	dec [x]
SimpleLeft:
	sub [x],14
	mov [color],41
	call Marker
EndLeft:
pop dx
pop ax
	ret
endp LeftMove
;Moves up on table.
proc UpMove
push ax
push dx
	mov ax,[index]
	cmp ax,9
	jb EndUp
	sub [index],9
	mov [color],92
	call Marker
	mov ax,[index]
	add ax,9
	mov dl,9
	div dl
	xor ah,ah
	mov dl,3
	div dl
	cmp ah,0
	jne SimpleUp
	dec [y]
SimpleUp:
	sub [y],14
	mov [color],41
	call Marker
EndUp:
pop dx
pop ax
	ret
endp UpMove
;Moves down on table.
proc DownMove
push ax
push dx
	mov ax,[index]
	cmp ax,71
	ja EndDown
	add [index],9
	mov [color],92
	call Marker
	mov ax,[index]
	mov dl,9
	div dl
	xor ah,ah
	mov dl,3
	div dl
	cmp ah,0
	jne SimpleDown
	inc [y]
SimpleDown:
	add [y],14
	mov [color],41
	call Marker
EndDown:
pop dx
pop ax
	ret
endp DownMove
;Reads the color of a pixel
proc ReadColor
push [x]
push [y]
push ax
push cx
push dx
	mov  bh,0h 
	mov  cx,[x]
	mov  dx,[y]
	mov  ah,0Dh 
	int  10h ; return al the pixel value read
	mov [color],al
pop dx
pop cx
pop ax
pop [y]
pop [x]
	ret
endp ReadColor
;Switches the color of the pixel in preparation of printing.
proc ColorChange
;Gets color as parameter
push bp
	mov bp,sp
push ax
	cmp [color],0Fh
	je ToBlack
ToWhite:
	mov [color],92
	call Dot
	mov ax,[bp+4]
	jmp EndChange
ToBlack:
	mov ax,[bp+4]
	mov [color],al
	call Dot
EndChange:
pop ax
pop bp
	ret 2
endp ColorChange
;Prints a char in graphics mode.
proc PrintCharGraphics
;Gets Char as a parameter
push bp
	mov bp,sp
push ax
push bx
push cx
push dx
push di
	mov di,[bp+4]
	mov al,1  ;Write mode
	mov bh,1  ;Page Number 
	mov bl,0Fh  ;Color 
	mov CX,1  ;Number of characters in string 
	mov dh,0  ;Row 
	mov dl,0 ;Column
	mov [ES:BP],di
	mov ah,13h
	int 10h
pop di
pop dx
pop cx
pop bx
pop ax
pop bp
	ret 2
endp PrintCharGraphics
;Prints a char in graphics mode in the top left corner of the screen.
proc TopPrint
;Gets color as parameter [bp+6]
;Gets char as parameter [bp+4]
push bp
	mov bp,sp
push di
push dx
push cx
push ax
push bx
push [x]
push [y]
	mov ax,[bp+4]
	push ax
	call PrintCharGraphics
	mov [x],0
	mov [y],0
	mov ax,8
	mov bx,[bp+6]
BeforeReading:
	push [x]
	mov cl,8
Reading:
	call ReadColor
	push bx
	call ColorChange
	inc [x]
	loop Reading
	pop [x]
	inc [y]
	dec ax
	cmp ax,0
	ja BeforeReading
pop [y]
pop [x]
pop bx
pop ax
pop cx
pop dx
pop di
pop bp
	ret 4
endp TopPrint
;Includes all the procedures for printing a char in a specific cell.
proc DigitDisplay
;Gets color as parameter [bp+6]
;Gets char as parameter [bp+4]
push bp
	mov bp,sp
push ax
push bx
push cx
push dx
	mov ax,[bp+6]
	push ax
	mov ax,[bp+4]
	push ax
	call TopPrint
push [x]
push [y]
	add [x],4
	add [y],3
	xor dx,dx
	mov bx,8
Changeing:
	push [x]
	xor ax,ax
	push bx
	mov cl,8
LineChange:
	push [x]
	push [y]
	mov [x],ax
	mov [y],dx
	call ReadColor
	pop [y]
	pop [x]
	call Dot
	inc [x]
	inc ax
	loop LineChange
	inc [y]
	inc dx
	pop bx
	pop [x]
	dec bx
	cmp bx,0
	jne Changeing
	mov [x],0
	mov [y],0
	mov [color],92
	call EraseDigit
pop [y]
pop [x]
pop dx
pop cx
pop bx
pop ax
pop bp
	ret 4
endp DigitDisplay
;Erasing a char from the table.
proc EraseDigit
push ax
push cx
push [x]
push [y]
	mov ax,8
ColumnDown:
	push ax
	push [x]
	mov cl,8
LineBackGround:
	call Dot
	inc [x]
	loop LineBackGround
	pop [x]
	inc [y]
	pop ax
	dec ax
	cmp ax,0
	ja ColumnDown
pop [y]
pop [x]
pop cx
pop ax
	ret
endp EraseDigit
;Switches to text mode.
proc TextMode
push ax
	mov ax, 2
	int 10h
pop ax
	ret
endp TextMode
;Prints the digit in each cell after solving the puzzle.
proc TablePrint
	mov [x],87
	mov [y],31
	mov cl,81
	mov [index],0
	mov bx,offset change
LoopPrintOne:
	mov bx,offset change
	add bx,[index]
	cmp [byte ptr bx],1
	jne ContiPrint
	mov bx,offset code
	add bx,[index]
	xor ah,ah
	mov al,[byte ptr bx]
	add ax,30h
	push 41
	push ax
	call DigitDisplay
ContiPrint:
	mov ax,[index]
	inc ax
	mov dx,9
	div dl
	cmp ah,0
	je DownPrintLine
	mov ax,[index]
	inc ax
	mov dl,3
	div dl
	cmp ah,0
	jne SimpleRightPrint
	inc [x]
SimpleRightPrint:
	add [x],14
	jmp EndOne
DownPrintLine:
	mov [x],87
	mov ax,[index]
	inc ax
	mov dl,9
	div dl
	xor ah,ah
	mov dl,3
	div dl
	cmp ah,0
	jne SimpleDownPrint
	inc [y]
SimpleDownPrint:
	add [y],14
EndOne:
	inc [index]
	loop LoopPrintOne
	ret
endp TablePrint
;Ends the game.
proc EndGame
	call TextMode
	mov ax, 4c00h
	int 21h
	ret
endp EndGame
;Restarts the arrays in order to restart the game.
proc RestartArray
push bp
	mov bp,sp
push bx
push cx
	mov cl,81
	mov bx,[bp+4]
ZeroForCode:
	mov [byte ptr bx],0
	inc bx
	loop ZeroForCode
pop cx
pop bx
pop bp
	ret 2
endp RestartArray
;Prints a string in graphics mode.
proc PrintStringGraphics
;Gets color as parameter [bp+8]
;Gets as parameter 0 for print without pause or 1 for pausing [bp+6]
;Gets offset of a string as parameter [bp+4]
push bp
	mov bp,sp
push ax
push bx
push cx
push dx
	mov dx,[bp+8]
	mov cx,[bp+6]
	mov bx,[bp+4]
PrintString:
	mov al,[byte ptr bx]
	cmp al,24h;$
	je EndPrintString
	xor ah,ah
	push dx
	push ax
	call DigitDisplay
	inc bx 
	add [x],8
	cmp cx,0
	je WithOutPause
	call PauseText
WithOutPause:
	jmp PrintString
EndPrintString:
pop dx
pop cx
pop bx
pop ax
pop bp
	ret 6
endp PrintStringGraphics
;For text printing effects.
proc PauseText
push cx
	mov cx,1400h
BigLoop:
	push cx
	mov cl,95
SmallLoop:
	loop SmallLoop
	pop cx
	loop BigLoop
pop cx
	ret
endp PauseText
;For text printing effects.
proc Waiting
push ax
push cx
push es
	mov  ax, 40h 
	mov  es, ax 
	mov  ax, [es:6Ch] 
StartTimer:  
	cmp  ax, [es:6Ch]
	je  StartTimer
	mov cx, 15  
DelayLoop: 
	mov  ax, [es:6Ch] 
Tick: 
	cmp  ax, [es:6Ch]
	je  Tick 
	loop  DelayLoop
pop es
pop cx
pop ax
	ret
endp Waiting
;Prints the lobby.
proc LobbyPrint
push bp
	mov bp,sp
push ax
	mov ax,[bp+4]
	mov [y],40
	mov [x],60
	cmp ax,1
	jne AfterWaiting1
	call Waiting
AfterWaiting1:
	push 43
	push ax
	push offset title1
	call PrintStringGraphics
	cmp ax,1
	jne AfterWaiting2
	call Waiting
AfterWaiting2:
	mov [x],130
	mov [y],70
	push 2
	push 0
	push offset playText
	call PrintStringGraphics
	cmp ax,1
	jne AfterWaiting3
	call Waiting
AfterWaiting3:
	add [y],30
	mov [x],102
	push 55
	push 0
	push offset rulesText
	call PrintStringGraphics
	cmp ax,1
	jne AfterWaiting4
	call Waiting
AfterWaiting4:
	add [y],30
	mov [x],118
	push 43
	push 0
	push offset settingsText
	call PrintStringGraphics
	cmp ax,1
	jne AfterWaiting5
	call Waiting
AfterWaiting5:
	add [y],30
	mov [x],134
	push 4
	push 0
	push offset exitText
	call PrintStringGraphics
	call PauseText
	mov [x],82
	mov [y],70
	call LobbyMarker
pop ax
pop bp
	ret 2
endp LobbyPrint
;prints lobby's marker
proc LobbyMarker
	push 5
	push 175
	call DigitDisplay
	ret
endp LobbyMarker
;Manages all the lobby's inputs.
proc Lobby
;push 1 for Effects else 0.
push bp
	mov bp,sp
push ax
	mov ax,[bp+4]
	mov [color],92
	call BackgroundColor
	mov [index],0
	push ax
	call LobbyPrint
LobbyInput:
	mov ah,0
	int 16h
	cmp ah,48h;up
	je UpLobby
	cmp ah,50h
	je DownLobby
	cmp ah,1Ch
	je EnterLobby
	jmp LobbyInput
EnterLobby:
	cmp [index],0
	jne MoveToRules
	mov [screenStatus],1
	jmp EndLobbyInput
MoveToRules:
	cmp [index],1
	jne Settings
	call Rules
	mov [screenStatus],0
	jmp EndLobbyInput
Settings:
	cmp [index],2
	jne ExitLobby
	call SettingsPrint
	mov [screenStatus],0
	jmp EndLobbyInput
ExitLobby:
	call EscScreen
	mov [screenStatus],0
	jmp EndLobbyInput
UpLobby:
	call UpLobbyMove
	jmp LobbyInput
DownLobby:
	call DownLobbyMove
	jmp LobbyInput
EndLobbyInput:
pop ax
pop bp
	ret 2
endp Lobby
;Moves up in lobby.
Proc UpLobbyMove
	cmp [index],0
	je UpLobbyEnd
	dec [index]
	push 92
	push 175
	call DigitDisplay
	sub [y],30
	mov [x],82
	call LobbyMarker
	call PauseText
UpLobbyEnd:
	ret
endp UpLobbyMove
;Moves down in lobby.
proc DownLobbyMove
	cmp [index],3
	je DownLobbyEnd
	inc [index]
	push 92
	push 175
	call DigitDisplay
	add [y],30
	mov [x],82
	call LobbyMarker
	call PauseText
DownLobbyEnd:
	ret
endp DownLobbyMove
;Prints the rules & help screen.
proc Rules
push ax
	mov [color],92
	call BackgroundColor
	mov [x],102
	mov [y],20
	push 55
	push 0
	push offset rulesText
	call PrintStringGraphics
	mov [x],10
	mov [y],50
	push 0
	push 0
	push offset rules1
	call PrintStringGraphics
	mov [x],10
	add [y],15
	push 0
	push 0
	push offset rules2
	call PrintStringGraphics
	mov [x],10
	add [y],15
	push 0
	push 0
	push offset rules3
	call PrintStringGraphics
	mov [x],10
	add [y],15
	push 0
	push 0
	push offset rules4
	call PrintStringGraphics
	mov [x],10
	add [y],15
	push 0
	push 0
	push offset rules5
	call PrintStringGraphics
	mov [x],10
	add [y],15
	push 0
	push 0
	push offset rules6
	call PrintStringGraphics
	mov [x],10
	add [y],15
	push 0
	push 0
	push offset rules7
	call PrintStringGraphics
	mov [x],10
	add [y],15
	push 3
	push 0
	push offset rules8
	call PrintStringGraphics
	call EscPrint
RulesInput:
	mov ah,0
	int 16h
	cmp ah,1
	jne RulesInput
	mov [color],92
	call BackgroundColor
pop ax
	ret
endp rules
;Prints settings screen & manages all settings inputs.
proc SettingsPrint
push ax
push bx
push dx
	mov [color],92
	call BackgroundColor
	mov [x],12
	mov [y],50
	push 3
	push 0
	push offset settingsSwitch
	call PrintStringGraphics
	mov bx,offset colorArr
	mov [index],0
ColorArrLoop:
	mov bx,offset colorArr
	add bx,[index]
	mov [x],34
	mov [y],80
	mov dl,[byte ptr bx]
	push dx
	push 0
	push offset settingsUse
	call PrintStringGraphics
SettingsInput:
	mov ah,0
	int 16h
	cmp ah,04Bh;left
	je LeftSettings
	cmp ah,4Dh;right
	je RightSettings
	cmp ah,1Ch;right
	je EndSettings
	jmp SettingsInput
LeftSettings:
	cmp [index],0
	jne NormalLeftSettings
	mov [index],9
	jmp ColorArrLoop
NormalLeftSettings:
	dec [index]
	jmp ColorArrLoop
RightSettings:
	cmp [index],9
	jne NormalRightSettings
	mov [index],0
	jmp ColorArrLoop
NormalRightSettings:
	inc [index]
	jmp ColorArrLoop
EndSettings:
	mov bx,offset colorArr
	add bx,[index]
	mov dl,[byte ptr bx]
	mov [tableColor],dl
pop dx
pop bx
pop ax
	ret
endp SettingsPrint
;Prints esc in corner.
proc EscPrint
	mov [y],185
	mov [x],0
	push 4
	push 0
	push offset escText
	call PrintStringGraphics
	ret
endp EscPrint
;Prints the exit screen.
proc EscScreen
push [index]
push ax
	mov [index],0
	mov [color],92
	call BackgroundColor
	mov [y],50
	mov [x],62
	push 0
	push 0
	push offset sureYou
	call PrintStringGraphics
	mov [y],100
	mov [x],85
	push 47
	push 0
	push offset noText
	call PrintStringGraphics
	mov [y],100
	mov [x],195
	push 4
	push 0
	push offset yesText
	call PrintStringGraphics
	mov [x],70
	mov [y],100
	call LobbyMarker
EscScreenInput:
	mov ah,0
	int 16h
	cmp ah,04Bh;left
	je LeftEsc
	cmp ah,4Dh;right
	je RightEsc
	cmp ah,1Ch
	je EnterEsc
LeftEsc:
	cmp [index],0
	je EscScreenInput
	push 92
	push 175
	call DigitDisplay
	dec [index]
	mov [x],70
	mov [y],100
	call LobbyMarker
	jmp EscScreenInput
RightEsc:
	cmp [index],1
	je EscScreenInput
	push 92
	push 175
	call DigitDisplay
	inc [index]
	mov [x],180
	mov [y],100
	call LobbyMarker
	jmp EscScreenInput
EnterEsc:
	cmp [index],0
	je EndEsc
	call EndGame
EndEsc:
pop ax
pop [index]
	ret
endp EscScreen
;Includes all the procedures of the playing screen.
proc SudokuScreen
	call EscPrint
	mov [color],92
	call BackgroundColor
	call EscPrint
	mov al,[tableColor]
	mov [color],al
	call SudokuTable
	ret
endp SudokuScreen
Start:
	mov ax, @data
	mov ds, ax
	call GraphicsMode
	push 1
Game:
	push offset code
	call RestartArray
	push offset change
	call RestartArray
	call Lobby
	cmp [screenStatus],0
	jne AfterLobby
	push 0
	jmp Game
AfterLobby:
	call SudokuScreen
	call Move
	cmp [screenStatus],0
	jne TryTable
BackToStart:
	push 0
	jmp Game
TryTable:
	call Try
	cmp [flag],0
	jne AfterFinalPrint
	call TablePrint
AfterFinalPrint:
	push offset code
	call RestartArray
	push offset change
	call RestartArray
	mov [x],65
	mov [y],180
	call Waiting
	push 3
	push 1
	push offset pressToRestart
	call PrintStringGraphics
WaitForRestart:
	mov ah,0
	int 16h
	cmp ah,13h
	je AfterLobby
	cmp ah,1
	je BackToStart
	jmp WaitForRestart
exit:
	mov ax, 4c00h
	int 21h
END start