;----------------------------------------------------------------
;       Level EDitor for CS4
;       by Francois Blanchette
;----------------------------------------------------------------
; NOTE: REQUIERS 94REP.ASM or Corinne.LIB
;-----------------------------------------------------------------
LocalCls	Macro
		push dx
                mov dx,0a000h
                mov gs,dx
                call CLS
                pop dx
		ENDM

DisableLdx	Macro

		push ax
                mov ax,-1
                mov word PTR LDX,ax
                pop ax
                ENDM
;-----------------------------------------------------------------
DrawSigns	Macro
Local ForgetIt
                call Convensions
		push ax
                mov al,byte PTR DysplayCtrl
                cmp al,0
                je ForgetIt
                call DrawCtrlSign

ForgetIt:	pop ax
		ENDM

;------------------------------------------------------------------
McgDraw 	Macro
Local DrawBackground,DB1,DB2,NoInvProc,DObj1,DObj2,Forget0Pix
Local Num1,Num2,OUT222,NonPas0

		pusha

                mov dx,BUFFER
                mov gs,dx

                mov bp,di
                mov bx,offset CS4EDIT

                mov ah,[si+8192]
                and ah,3
                cmp ah,0
                je DrawBackground

                dec ah          ; Type-1
                mov al,3
                mul ah          ; AX= (Type-1)*3
                rol ax,8        ; AX= (Type-1)*3*256
                mov bx,ax
                add bx,offset CS4ANI

                mov al,[si+8192]
                and al,4
                mov ah,0
                shr al,1
                rol ax,8
                add bx,ax

DrawBackground: mov dx,16
DB2:            mov cx,4

DB1:            mov eax,[bx]
                mov gs:[di],eax
                add bx,4
                add di,4
                loop DB1

                add di,140h-16
                mov cx,dx
                dec dx
                loop DB2

                mov di,bp               ; Restore DI

                mov ah,0
                mov bl,[si]
                cmp bl,128
                jb NOINVPROC
                mov ah,-1

NOINVPROC:      and bl,127
                mov bh,0
                rol bx,8
                add bx,offset CS4EDIT

                mov dx,16
DOBJ2:          mov cx,16
DOBJ1:          mov al,[bx]
                cmp al,0
                je FORGET0PIX

                xor al,ah
                mov gs:[di],al

FORGET0PIX:     inc bx
                inc di
                loop DOBJ1

                add di,140h-16
                mov cx,dx
                dec dx
                loop DOBJ2

                mov di,bp                       ; restore DI
                mov al,[si+8192]
                shr al,3
                mov ah,0
                rol ax,8
                cmp ax,0
                je OUT222

                add ax,offset CS4NUM
                mov bx,ax

                mov dx,16
NUM2:           mov cx,16

NUM1:           mov al,[bx]
                cmp al,0
                je NONPAS0
                mov gs:[di],al
NONPAS0:        inc bx
                inc di
                loop NUM1

                add di,140h-16
                mov cx,dx
                dec dx
                loop NUM2

OUT222:   	popa
		ENDM

;-----------------------------------------------------------------------

McgDraw8x8 	Macro
Local DrawBackground,DB1,DB2,NoInvProc,DObj1,DObj2,Forget0Pix
Local Num1,Num2,OUT222,NonPas0,NNTOP

		mov bp,di
                mov bx,offset CS4EDIT

                mov ah,[si+8192]
                and ah,3
                cmp ah,0
                je DrawBackground

                dec ah          ; Type-1
                mov al,3
                mul ah          ; AX= (Type-1)*3
                rol ax,8        ; AX= (Type-1)*3*256
                mov bx,ax
                add bx,offset CS4ANI

                mov al,[si+8192]
                and al,4
                mov ah,0
                shr al,1
                rol ax,8
                add bx,ax

DrawBackground: mov dx,8
DB2:            mov cx,8

DB1:            mov al,[bx]
                mov gs:[di],al
	        inc bx
                inc bx
                inc di
                loop DB1

                add bx,16
                add di,140h-8
                mov cx,dx
                dec dx
                loop DB2

                mov di,bp               ; Restore DI

                mov ah,0
                mov bl,[si]
                cmp bl,128
                jb NOINVPROC
                mov ah,-1

NOINVPROC:      and bl,127
                mov bh,0
                rol bx,8
                cmp bx,0
                je NNTOP             	; Modification
                add bx,offset CS4EDIT

                mov dx,8
DOBJ2:          mov cx,8
DOBJ1:          mov al,[bx]
                cmp al,0
                je FORGET0PIX

                xor al,ah
                mov gs:[di],al

FORGET0PIX:     inc bx
                inc bx
                inc di
                loop DOBJ1

                add bx,16
                add di,140h-8
                mov cx,dx
                dec dx
                loop DOBJ2

      		; NoNeedToPrint
NNTOP:
                mov di,bp                       ; restore DI
                mov al,[si+8192]
                shr al,3
                mov ah,0
                rol ax,8
                cmp ax,0
                je OUT222

                add ax,offset CS4NUM
                mov bx,ax

                mov dx,8
NUM2:           mov cx,8

NUM1:           mov al,[bx]
                cmp al,0
                je NONPAS0
                mov gs:[di],al
NONPAS0:        inc bx
                inc bx
                inc di
                loop NUM1

                add bx,16
                add di,140h-8
                mov cx,dx
                dec dx
                loop NUM2
OUT222:
		ENDM


;-----------------------------------------------------------------------

HMOUSE  MACRO
        push ax
        mov ax,2
        int 33h
        pop ax
        ENDM

SMOUSE MACRO
       push ax
       mov ax,1
       int 33h
       pop ax
       ENDM

PUBLIC CONVENSIONS
PUBLIC PATH

EXTERN CLS:PROC
EXTERN VIDEOSWITCH:PROC
EXTERN LOADOLD:PROC
EXTERN LOADNEW:PROC
EXTERN GETAX:PROC
EXTERN MAKEPATH:PROC
EXTERN QUIT:PROC
EXTERN NOT_FOUND:PROC
EXTERN MELO_PAINT:PROC
EXTERN WBUT:PROC

EXTERN FILENAME:WORD
EXTERN OLD_VIDEO_MODE:WORD
EXTERN EXT:WORD


;----------------------------------------------------------------
ASSUME CS:CODE,DS:DATA,SS:STACK
STACK     SEGMENT STACK
          DB 800H DUP  (0)
STACK     ENDS
;----------------------------------------------------------------

SizeOfCS4ANI 	EQU 9*256
SizeOfCS4EDIT   EQU 128*256
SizeofCS4NUM	EQU 8192

;----------------------------------------------------------------
DATA      SEGMENT PUBLIC 'DATA'
COPYRIGHT      db "Level Editor V2.0: (C) 1994 FRANCOIS BLANCHETTE."
PATH           db 0
CS4EDIT_MCG    db "CS4EDIT.MCG",0
CS4ANI_MCG     db "CS4ANI.MCG",0
CS4NUM_MCG     db "CS4NUM.MCG",0
LEV00_VLA      db "LEV00.CS4",0
SaveLevelText  db "Enter Level number to be saved:$"
LoadLevelText  db "Enter Level number to be loaded:$"
ClearMazeText  db "Do you wish to clear Maze (Y/N)?$"
NUM            db 3,0,0,0,0

align 4
LEVELDATA      db 8192*2 DUP (0)
CS4EDIT        db 128*256 DUP (0)
CS4NUM         db 8192 DUP (0)
CS4ANI         db 9*256 DUP (0)

MX             db 0
MY             db 0
CD             db 0
HCD	       db 0
BC             db 0

align 2
LDX            dw 0
LDY            dw 0

MAZEFORMAT     db 0
DysplayCtrl    db 0
SignColor      db 15

DATA   ENDS
;----------------------------------------------------------------

BUFFER SEGMENT
DB 65535 DUP (0)
BUFFER ENDS

;----------------------------------------------------------------
CODE SEGMENT READONLY PUBLIC 'CODE'
VLAMITS  PROC NEAR
;----------------------------------------------------------------
.386

                call VIDEOSWITCH

                mov ax,0
                int 33h

ResetPoint:   	call CONVENSIONS
                mov di,offset CS4EDIT
                mov cx,32768/4
                mov eax,01010101h
DrawInBlue:     mov [di],eax
                add di,4
                loop DrawInBlue

             	mov dx,DATA
                mov ds,dx
                mov es,dx
                mov dx,offset CS4ANI_MCG
                mov bx,offset CS4ANI
                mov cx,9*256
                call LOADOLD

                mov dx,DATA
                mov ds,dx
                mov es,dx
                mov dx,offset CS4NUM_MCG
                mov bx,offset CS4NUM
                mov cx,8192
                call LOADOLD

                mov dx,DATA
                mov ds,dx
                mov es,dx
                mov dx,offset CS4EDIT_MCG
                mov bx,offset CS4EDIT
                mov cx,32768
                call LOADOLD

RENTRANCE:      mov dx,0a000h
		mov gs,dx
		call CONVENSIONS
                call BORDERS
                call DRAWITEMBAR
                call DRAWMAZE
                call REDRAWMAZE
                SMOUSE

MAINLOOP:       call GETAX
                call CONVENSIONS
                call WBUT
                cmp bx,1
                je LFBUT

                cmp al,"s"
                je SourceUpon
                cmp al,"["
                je DECPAL
                cmp al,"]"
                je INCPAL

                cmp al,"8"
                je UP
                cmp al,"2"
                je DN
                cmp al,"4"
                je LF
                cmp al,"6"
                je RG

                cmp ah,72
          	je UP
          	cmp ah,80
          	je DN
          	cmp ah,75
          	je LF
          	cmp ah,77
          	je RG

          	cmp al,"-"
          	je LOAD_A_LEVEL
          	cmp al,"="
          	je SAVE_A_LEVEL
                cmp al,"f"
                je ChangeMazeFormat

                cmp ah,59
                je ToggleSigns
                cmp al,"q"
                je ToggleSigns
		cmp al," "
                je ToggleSigns
                cmp al,"a"
                je ToggleSigns

                cmp al,"v"
                je TopAndBottom
                cmp ah,62
                je TopAndBottom
                cmp ah,63
                je BlankWaterLavaAndSlimeDec
                cmp ah,64
                je BlankWaterLavaAndSlime

                ;cmp al,"a"
                ;je TopAndBottom
                cmp al,"b"
                je BlanksthatMutate

                cmp al,"z"
                je BlankWaterLavaAndSlimeDec
                cmp al,"x"
                je BlankWaterLavaAndSlime

                cmp al,"n"
                je NumberDec
                cmp al,"m"
                je NumberInc
                cmp al,"C"
                je Clear_Maze
                cmp al,"c"
                je PutBorders

                cmp al,"r"
                je ResetProgram

                cmp al,","
                je DecColor
                cmp al,"."
                je IncColor


                jmp MAINLOOP

                ;--------------------------------------------------

DecColor:	mov al,byte PTR SignColor
		cmp al,0
                je MainLoop
                dec al
                mov byte PTR SignColor,al
                jmp Yeah

IncColor:	mov al,byte PTR signColor
		cmp al,15
                je MainLoop
                inc al
                mov byte PTR SignColor,al
                jmp Yeah








ResetProgram:   call Convensions
		DisableLdx
                Hmouse
                jmp ResetPoint

BlanksThatMutate: mov al,byte PTR CD
		xor al,128
                mov byte PTR CD,al
                jmp Yeah

NumberDec:	mov al,byte PTR HCD
		mov ah,al

                and ah,7
                shr al,3

                cmp al,0
                je MainLoop

                dec al
                shl al,3
                or al,ah

                mov byte PTR HCD,al
                jmp Yeah

                ;<---------------------------------------->

NumberInc:	mov al,byte PTR HCD
		mov ah,al

                and ah,7
                shr al,3

                cmp al,31
                je MainLoop

                inc al
                shl al,3
                or al,ah

                mov byte PTR HCD,al
                jmp Yeah

                ;<--------------------------------------->


TopAndBottom:   DisableLdx
		mov al,byte PTR HCD
		xor al,4
                mov byte PTR HCD,al

Yeah:           DisableLdx
		HMOUSE
                DrawSigns
                SMOUSE
                jmp MAINLOOP

BlankWaterLavaAndSlimeDec:
		mov al,byte PTR HCD
                mov ah,al
                and al,7
		and ah,255-7

                dec al
                cmp al,-1
                jne OKsosoInc
                jmp MainLoop

OKsosoInc:	or al,ah
		mov byte PTR HCD,al
                jmp Yeah


BlankWaterLavaAndSlime:
		mov al,byte PTR HCD
                mov ah,al
                and al,7
		and ah,255-7

                inc al
                cmp al,7
                jbe OKsoso
                jmp MainLoop

OKsoso:		or al,ah
		mov byte PTR HCD,al
                jmp Yeah

ToggleSigns:	mov al,byte PTR DysplayCtrl
		xor al,1
                mov byte PTR DysplayCtrl,al
                cmp al,0
                je CtrlOff

                HMOUSE
                call DrawCtrlSign
                SMOUSE
                jmp MainLoop


CtrlOff:
		call DrawMaze
                HMOUSE
                call RedrawMaze
                SMOUSE
                jmp MainLoop

DrawCtrlSign:   pusha
		mov si,offset LEVELDATA
		mov di,18*16

                mov dx,BUFFER
                mov gs,dx

                mov al,0
                mov [si],al

                mov al,byte PTR HCD
                mov [si+8192],al

                MCGDRAW

                add di,16

                mov al,byte PTR CD
                mov [si],al

                mov al,0
                mov [si+8192],al

                MCGDRAW

                mov al,1
                mov [si],al
                sub di,16

                mov dx,0a000h
                mov es,dx
                mov dx,BUFFER
                mov gs,dx

                mov dx,16
XXXZ2:          mov cx,32

XXXZ1:          mov al,gs:[di]

		cmp al,0
                jne NoProblem
		mov al,61h
NoProblem:
		cmp al,15
		jne ColorSame
                mov al,byte PTR SignColor

ColorSame:	mov es:[di],al
		mov gs:[di],al

                inc di
                loop XXXZ1

		add di,140h-32
                mov cx,dx
                dec dx
                loop XXXZ2
                popa
                ret






ChangeMazeFormat:
		mov ax,-1
                mov word PTR LDX,ax

		mov al,byte PTR MazeFormat
		xor al,1
                mov byte PTR MazeFormat,al
                call DRAWMAZE
		HMOUSE
                call REDRAWMAZE
                SMOUSE
                jmp MainLoop

SourceUpon:     cmp dx,22
		jae MAINLOOP

                mov al,byte PTR MazeFormat
                cmp al,0
                jne Ok40x22
                shr cx,1
                shr dx,1

Ok40x22:     	add cl,byte PTR MX
		add dl,byte PTR MY
                rol dx,7
                add dx,cx
		mov si,dx
                add si,offset LEVELDATA
                mov al,[si]
                mov byte PTR CD,al
                mov al,[si+8192]
                mov byte PTR HCD,al

                DrawSigns		; DrawsSigns in the Upper Right
                			; when requiered.

                jmp MAINLOOP


































LFBUT:		mov al,MazeFormat
		cmp al,0
                je ABAB

		cmp cx,word PTR LDX
		jne NotLDX
                cmp dx,word PTR LDY
                jne NotLDX
	        jmp MainLoop

ABAB:		push cx
		push dx
                shr cx,1
                shr dx,1
                cmp cx,word PTR LDX
                jne NotLDX_ABAB
                cmp dx,word PTR LDY
                jne NOTLDX_ABAB
                pop dx
                pop cx
                jmp MainLoop

NOTLDX_ABAB:    pop dx
		pop cx

NotLDX:		cmp dx,22
                jb DrawingPortion

                mov word PTR LDX,cx
                mov word PTR LDY,dx

                shr cx,1
                shr dx,1

		mov al,byte PTR BC
                add al,cl
                mov byte PTR CD,al

                DrawSigns		; DrawSigns in the upper right
                			; corner when needed.

                jmp MainLoop

DrawingPortion:

                mov al,byte PTR MazeFormat
                cmp al,0
                jne OkItIsBig

                shr cx,1
                shr dx,1

OkItIsBig:      mov word PTR LDX,cx
                mov word PTR LDY,dx

		add dl,byte PTR MY
		rol dx,7
                add cl,byte PTR MX
                add dx,cx
                mov di,dx
                add di,offset LevelData

                mov al,byte PTR CD
                mov [di],al
                mov al,byte PTR HCD
                mov [di+8192],al

                ;Equivate to call DRAWMAZE

                mov si,di
                mov cx,word PTR LDX
                mov dx,word PTR LDY

                rol cx,4
                mov al,0ah*2
                mul dl
                rol ax,8
                add ax,cx
                mov di,ax

                mov al,byte PTR MazeFormat
                cmp al,0
                je P20x11

P40x22:

		mov dx,BUFFER
                mov gs,dx

                mov cx,word PTR LDX
                mov dx,word PTR LDY

                rol cx,3
                mov al,0ah
                mul dl
                rol ax,8
                add ax,cx
                mov di,ax

                push di
		MCGDRAW8x8
                pop di
		jmp DrawInSmall

P20x11:         MCGDRAW

	        HMOUSE
                mov dx,0a000h
                mov gs,dx
                mov dx,BUFFER
                mov es,dx

                mov dx,16
DrawSqr2:       mov cx,4
DrawSqr:        mov eax,es:[di]
                mov gs:[di],eax
                add di,4
                loop DrawSqr

                add di,140h-16
                mov cx,dx
                dec dx
		loop DrawSqr2

                SMOUSE
                jmp MainLoop



DrawInSmall:    HMOUSE
                mov dx,0a000h
                mov gs,dx
                mov dx,BUFFER
                mov es,dx

                mov dx,8
DrawSqr2x:       mov cx,8
DrawSqrx:        mov al,es:[di]
                mov gs:[di],al
                inc di
                loop DrawSqrx

                add di,140h-8
                mov cx,dx
                dec dx
		loop DrawSqr2x

                SMOUSE
                jmp MainLoop

















		;--------------------------------------------
UP:             mov al,byte PTR MY
                cmp al,0
                je MAINLOOP

                dec al
COMUD:          mov byte PTR MY,al
COMALL:         mov ax,-1
                mov word PTR LDX,ax

                call DRAWMAZE

                HMOUSE
                call REDRAWMAZE
                SMOUSE
                jmp MAINLOOP

DN:             mov al,byte PTR MY
                inc al
                jmp COMUD

LF:             mov al,byte PTR MX
                cmp al,0
                je MAINLOOP
                dec al
COMLR:          mov byte PTR MX,al
                jmp COMALL

RG:             mov al,byte PTR MX
                inc al
                jmp COMLR

                ;----------------------------------------------

DECPAL:         mov al,byte ptr BC
                cmp al,0
                je MAINLOOP
                dec al
COMPAL:         mov byte ptr BC,al
                mov ax,-1
                mov word ptr LDX,ax

                HMOUSE
                call DRAWITEMBAR
                SMOUSE
                jmp MAINLOOP

INCPAL:         mov al,byte ptr BC
                cmp al,128-20
                jae MAINLOOP

                inc al
                jmp COMPAL

		;---------------------------------------------------





















                ;---------------------------------------------------------
                ; This routine is purpose to draw the maze onto the screen
                ; either the BIG or the small maze. It depends on the
                ; MAZEFORMAT flag. 0 means BIG, 1 means small.

DRAWMAZE:       pusha
                call CONVENSIONS
                mov dx,BUFFER
                mov gs,dx

                mov al,byte ptr MAZEFORMAT
                cmp al,1
                je SMDRAW

                ; Draw BIG maze onto the screen. This is like the old
                ; days. A never ending routine, that is still used
                ; because I've found anything better.

                ; 1) Load source into SI

                mov al,byte PTR MY
                mov ah,0
                rol ax,7
                add al,byte PTR MX
                mov si,ax
                add si,offset LEVELDATA

                mov di,0
                mov dx,11

R0to10:         push di
                push dx
                mov cx,20

L0to20:         push cx
                mov bp,di

                mov bx,offset CS4EDIT
                mov ah,[si+8192]
                and ah,3
                cmp ah,0
                je DrawBackground

                dec ah          ; Type-1
                mov al,3
                mul ah          ; AX= (Type-1)*3
                rol ax,8        ; AX= (Type-1)*3*256
                mov bx,ax
                add bx,offset CS4ANI

                mov al,[si+8192]
                and al,4
                mov ah,0
                shr al,1
                rol ax,8
                add bx,ax

DrawBackground: mov dx,16
DB2:            mov cx,4

DB1:            mov eax,[bx]
                mov gs:[di],eax
                add bx,4
                add di,4
                loop DB1

                add di,140h-16
                mov cx,dx
                dec dx
                loop DB2

                mov di,bp               ; Restore DI

                mov ah,0
                mov bl,[si]
                cmp bl,128
                jb NOINVPROC
                mov ah,-1

NOINVPROC:      and bl,127
                mov bh,0
                rol bx,8
                cmp bx,0
                je NoNeedToPrint

                add bx,offset CS4EDIT

                mov dx,16
DOBJ2:          mov cx,16
DOBJ1:          mov al,[bx]
                cmp al,0
                je FORGET0PIX

                xor al,ah
                mov gs:[di],al

FORGET0PIX:     inc bx
                inc di
                loop DOBJ1

                add di,140h-16
                mov cx,dx
                dec dx
                loop DOBJ2

                ; NoNeedToPrint

NoNeedToPrint:
                mov di,bp                       ; restore DI
                mov al,[si+8192]
                shr al,3
                mov ah,0
                rol ax,8
                cmp ax,0
                je OUT222

                add ax,offset CS4NUM
                mov bx,ax

                mov dx,16
NUM2:           mov cx,16

NUM1:           mov al,[bx]
                cmp al,0
                je NONPAS0
                mov gs:[di],al
NONPAS0:        inc bx
                inc di
                loop NUM1

                add di,140h-16
                mov cx,dx
                dec dx
                loop NUM2

                ; Time to return from the loop...

OUT222:         mov di,bp
                pop cx
                inc si
                add di,16
                loop L0to20X

                pop dx
                pop di
                add di,0a00h*2
                add si,128-20 ;(ha! 20 per line! C64 time is over)
                mov cx,dx
                dec dx
                loop R0to10X
		jmp DMRET

L0to20X:        jmp L0to20
R0to10X:        jmp R0to10


                ;--------------------------------------------------
                ;--------------------------------------------------
                ; Drawing the small maze isn't a piece of cake but
                ; I hope it won't be too hard. At less not as hard
                ; as building the big one.
                ;--------------------------------------------------
                ; Load source into SI

SMDRAW:		mov al,byte PTR MY
		mov ah,0
                rol ax,7
                mov al,byte ptr MX
                mov si,ax
                add si,offset LEVELDATA

                mov di,0
                mov dx,22

R0to22:         push di
		push dx
                mov cx,40
L0to40:         push cx

		McgDraw8x8

                mov di,bp
                pop cx
                inc si
                add di,8
                loop L0to40x

                pop dx
                pop di
                add di,0a00h
                add si,128-40
                mov cx,dx
                dec dx
                loop R0to22x

DMRET:          DrawSigns		; Draw Informations signs if
		popa			; needed
                ret

L0to40x:	jmp L0to40
R0to22x:	jmp R0to22

REDRAWMAZE:     pusha
                mov dx,BUFFER
                mov gs,dx
                mov dx,0a000h
                mov es,dx
                mov cx,(22*0a00h)/4
                mov si,0
REDMAZ:         mov eax,gs:[si]
                mov es:[si],eax
                add si,4
                loop REDMAZ
                popa
                ret




















                ;------------------------------------------------------
DRAWITEMBAR:    pusha
                mov dx,0a000h
                mov gs,dx
                mov dx,DATA
                mov ds,dx

                mov di,22*0a00h
                mov al,byte ptr BC
                mov ah,0
                rol ax,8
                add ax,offset CS4EDIT
                mov si,ax

                mov dx,20
DIB3:           push di
                mov bx,16
DIB2:           mov cx,4

DIB:            mov eax,[si]
                mov gs:[di],eax
                add si,4
                add di,4
                loop DIB

                add di,140h-16
                mov cx,bx
                dec bx
                loop DIB2

                pop di
                add di,16
                mov cx,dx
                dec dx
                loop DIB3
                popa
                ret






































LOAD_A_LEVEL:  mov bp,sp
               xor dx,dx
               mov bx,0
               mov ah,2
               int 10h

               HMOUSE
               LocalCls
               call CONVENSIONS
               mov dx,offset LoadLevelText
               mov ah,9
               int 21h

               call READ_A_NUM

               mov si,offset NUM+2
               mov di,offset LEV00_VLA+3
               mov al,[si]
               mov [di],al
               mov al,[si+1]
               mov [di+1],al

               mov dx,DATA
               mov ds,dx
               mov es,dx
               mov dx,offset LEV00_VLA
               mov bx,offset LEVELDATA
               mov cx,16384
               call LOADNEW

               jmp RENTRANCE

READ_A_NUM:    mov dx,offset NUM
               mov ah,0ah
               int 21h

               mov si,offset NUM

               mov al,[si+1]
               cmp al,2
               jb READ_OUT

               mov al,[si+2]
               cmp al,30h
               jb READ_OUT
               cmp al,39h
               ja READ_OUT

               mov al,[si+3]
               cmp al,30h
               jb READ_OUT
               cmp al,39h
               ja READ_OUT

               ret

READ_OUT:      ;pop ax
               ;pop ax
               ;mov sp,bp		; This made the program CRASH!
               jmp RENTRANCE

               ; SAVE A FILE

SAVE_A_LEVEL:  mov bp,sp
               HMOUSE
SAVE_A_LEVEL2: xor dx,dx
               mov bx,0
               mov ah,2
               int 10h

               LocalCls
               mov dx,DATA
               mov ds,dx
               mov dx,offset SaveLevelText
               mov ah,9
               int 21h

               call READ_A_NUM

               call CONVENSIONS

               mov si,offset NUM+2
               mov di,offset LEV00_VLA+3
               mov al,[si]
               mov [di],al
               mov al,[si+1]
               mov [di+1],al

               mov dx,offset LEV00_VLA
               call MAKEPATH

               mov dx,offset FILENAME
               mov cx,0
               mov ah,3ch               ; CrÇe un fichier
               int 21h
               jc WRITE_ERROR

               push ax
               mov bx,ax
               mov cx,16384
               mov dx,DATA
               mov ds,dx
               mov dx,offset LEVELDATA
               mov ah,40h               ; êcriture d'un fichier
               int 21h
               jc WRITE_ERROR

               pop bx
               mov ah,3eh               ; Fermeture du fichier
               int 21h
               jc WRITE_ERROR
               jmp RENTRANCE

WRITE_ERROR:   jmp SAVE_A_LEVEL2

	  ;-----------------------------------------------------

PutBorders:     DisableLdx
		call Borders
		call DrawMaze
                HMOUSE
                call RedrawMaze
                SMOUSE
                jmp MainLoop

BORDERS:  pusha
          mov di,offset LEVELDATA
          mov eax,01010101h
          mov cx,((5*128)/4)
PUNDNBORDERS:  mov [di],eax
          mov [di+((64-6)*128)],eax
          add di,4
          loop PUNDNBORDERS

          mov di,offset LEVELDATA
          mov dx,64
PRGTSIDEDOWN:  mov cx,5
PRGTSIDEBORDER:     mov [di],ax
          inc di
          inc di
          loop PRGTSIDEBORDER
          add di,128-10
          mov cx,dx
          dec dx
          loop PRGTSIDEDOWN
          popa
          ret


          ;--------------------------------------------------
CLEAR_MAZE:    HMOUSE
          mov bh,0
          mov ah,2
          xor dx,dx
          int 10h

          mov ah,9
          mov dx,offset CLEARMAZETEXT
          int 21h
          SMOUSE

CLMZINKEY:     call GETAX
          cmp al,"y"
          je APPCLMAZE
          cmp al,0
          je CLMZINKEY
          call Convensions
          DisableLdx
          Hmouse
          jmp Rentrance

APPCLMAZE:call CONVENSIONS
          mov di,offset LEVELDATA
          mov cx,16384/4
          mov eax,0
APPCLMZ:  mov [di],eax
          add di,4
          loop APPCLMZ

       	  call BORDERS
          Hmouse
          jmp Rentrance
























CONVENSIONS PROC NEAR
                push dx
                mov dx,DATA
                mov ds,dx
                pop dx
                ret
CONVENSIONS ENDP




















; -----------------------FIN DU PROGRAMME-----------------------
VLAMITS    ENDP                           ; Fin de la procedure
CODE ENDS                                ; Fin du programme
END     VLAMITS                           ; Point d'entree
;---------------------------------------------------------------
