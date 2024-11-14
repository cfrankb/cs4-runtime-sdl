;----------------------------------------------------------------
;       CREEPSPREAD IV
;       by Francois Blanchette
;----------------------------------------------------------------

; Nouvelle version revisée... 21 février 1995
INCLUDE \MASM61\LISTING\SSFSMAC.INC
;----------------------------------------------------------------
PrintBigOne	Macro Destination:REQ, Source:REQ, Color1:REQ, Color2:REQ
Local 		Destination,Source,Color1,Color2
Local 		XChkAgainXyzB,XIdSignsMatchB,LoopDB1,LoopDB2,XDBNulPix
Local 		LightGreen,PlaceColor
Local		NoSource, NoDestination
Local		EndDrawSeq, NextFont

                push ax
                push bx
                push cx
                push di
                push dx

                call Convensions

                mov dx,Screen
                mov gs,dx

                mov ax, Source
                cmp ax,-1
                je NoSource
                mov si,Source

NoSource:       mov ax, Destination
                cmp ax,-1
                je NoDestination
		mov di,Destination

NoDestination:

NextFont:       mov al,fs:[si]
		cmp al,-1
                je EndDrawSeq
                cmp al,0
                je EndDrawSeq

		push di
		push si

                mov si,offset SIGNSTABLE
XCHKAGAINXYZB:	cmp al,[si]
                je XIDSIGNSMATCHB
                inc si
                jmp XCHKAGAINXYZB

XIDSIGNSMATCHB:	sub si,offset SIGNSTABLE
		rol si,10

		mov dx,SIGNSEG
                mov es,dx
                mov dx,SCREEN
                mov gs,dx

                mov bx,32
LOOPDB2:        mov cx,32

LOOPDB1:        mov al,es:[si]
                cmp al,0
                je XDBNULPIX

                cmp al,5*8+2
                jne LIGHTGREEN
                mov al,Color1
                jmp PLACECOLOR
LIGHTGREEN:	mov al,Color2

PLACECOLOR:     mov gs:[di],al
		mov gs:[di+140h],al

XDBNULPIX:      inc di
	       	inc si
		loop LOOPDB1

                add di,140h*2-(16*2)
                mov cx,bx
                dec bx
                loop LOOPDB2

                pop si
                pop di
                add di,32
                inc si
        	jmp NextFont

EndDrawSeq:     inc si
                pop dx
                pop di
                pop cx
                pop bx
                pop ax
		ENDM


;------------------------------------------------------------------------
Print16x16Sign	Macro destination:REQ, source:REQ, color1:REQ, color2:REQ
Local 		Destination,Source,Color1,Color2
Local 		XChkAgainXyzB,XIdSignsMatchB,LoopDB1,LoopDB2,XDBNulPix
Local 		LightGreen,PlaceColor
Local		NoSource, NoDestination
Local		EndDrawSeq, NextFont

                push ax
                push bx
                push cx
                push di
                push dx

                call Convensions

                mov dx,Screen
                mov gs,dx

                mov ax, Source
                cmp ax,-1
                je NoSource
                mov si,Source

NoSource:       mov ax, Destination
                cmp ax,-1
                je NoDestination
		mov di,Destination

NoDestination:

NextFont:       mov al,fs:[si]
		cmp al,-1
                je EndDrawSeq
                cmp al,0
                je EndDrawSeq

		push di
		push si

                mov si,offset SIGNSTABLE
XCHKAGAINXYZB:	cmp al,[si]
                je XIDSIGNSMATCHB
                inc si
                jmp XCHKAGAINXYZB

XIDSIGNSMATCHB:	sub si,offset SIGNSTABLE
		rol si,10

		mov dx,SIGNSEG
                mov es,dx
                mov dx,SCREEN
                mov gs,dx

                mov bx,16
LOOPDB2:        mov cx,16

LOOPDB1:        mov al,es:[si]
                cmp al,0
                je XDBNULPIX

                cmp al,5*8+2
                jne LIGHTGREEN
                mov al,Color1
                jmp PLACECOLOR
LIGHTGREEN:	mov al,Color2

PLACECOLOR:     mov gs:[di],al

XDBNULPIX:      inc di
	       	inc si
                inc si
		loop LOOPDB1

                add di,140h-16
                add si,32
                mov cx,bx
                dec bx
                loop LOOPDB2

                pop si
                pop di
                add di,16
                inc si
        	jmp NextFont

EndDrawSeq:     inc si
                pop dx
                pop di
                pop cx
                pop bx
                pop ax
		ENDM

;-----------------------------------------------------------------
ReadXYForCreature Macro

                mov dl,es:[bx]
                mov dh,es:[bx+256]
                ENDM

;----------------------------------------------------------------
Getsi		Macro

                mov al,dh
                mov ah,0
                shl ax,7		; AX=CCY*128
                or al,dl		; AX=CCY*128+CCX
                mov si,ax		; SI=CCY*128+CCX
                add si,offset LevelData
                ENDM

;----------------------------------------------------------------
DrawKey		Macro Destination,Source:REQ,Frame:REQ
Local 	 	Destination,Source,Frame,QuitMacro,Dk1,Dk2

		cmp byte Ptr Source,0
                je QuitMacro

                mov di,Destination
                mov si,Frame

                mov dx,16
DK2:            mov cx,4

DK1:            mov eax,[si]
                mov gs:[di],eax
                add si,4
                add di,4
                loop DK1

                add di,140h-16
                mov cx,dx
                dec dx
                loop DK2
QuitMacro:
		ENDM

;----------------------------------------------------------------
DecMem		Macro Destination:REQ, Value:REQ
Local 		Destination, Value, Ok

		push ax
		mov al,byte Ptr Destination
                sub al,Value

                mov ah,byte Ptr Destination
                cmp al,ah
                jb OK
                mov al,0
Ok:		mov byte Ptr Destination,al
		pop ax

		ENDM

;------------------------------------------------------------------
BlankObj	Macro
                mov al,0
                mov [si],al

                mov al,[si+8192]
                and al,7
                mov [si+8192],al

                mov al,0
                mov byte Ptr PV,al

                mov al,byte Ptr HPv
                and al,4
                mov byte Ptr HPv,al
		ENDM

;----------------------------------------------------------------
IncMem		Macro Destination:REQ, Value:REQ
Local 		Destination, Value, Ok

		push ax
		mov al,byte Ptr Destination
                add al,Value

                mov ah,byte Ptr Destination
                cmp al,ah
                ja OK
                mov al,-1
Ok:		mov byte Ptr Destination,al
		pop ax

		ENDM

;----------------------------------------------------------------
AddToScore	Macro Value:REQ
Local 		Value, IncNext, IncMore, OutOfMacro, ContNorm

                push ax
                push cx
                push si
		mov cx,Value
	       	mov si,offset SCORE+7

IncMore:        mov al,[si]
                inc al
                mov [si],al
                cmp al,39h
                ja IncNext
ContNorm:  	loop IncMore
                jmp OutOfMacro

IncNext:        mov al,30h
		mov [si],al
		dec si
                mov al,[si]
                inc al
                mov [si],al
                cmp al,39h
                ja IncMore
                mov si,offset SCORE+7
                jmp ContNorm

OutOfMacro:     pop si
		pop cx
                pop ax
		ENDM

;----------------------------------------------------------------
MoveUp 		Macro Source:REQ
Local           Source, ToBuf, SosoUP1, Last

                mov cx,4
                mov si,Source
                mov di,offset Forcefi2
ToBuf:          mov eax,[si]
                mov [di],eax
                add si,4
                add di,4
                loop ToBuf

		mov cx,(256-16)/4
                mov di,Source
SosoUP1:        mov eax,[di+16]
                mov [di],eax
                add di,4
                loop SosoUP1

                mov si,offset Forcefi2
                mov di,Source+256-16
                mov cx,4
Last:           mov eax,[si]
                mov [di],eax
                add si,4
                add di,4
                loop Last
		ENDM

;----------------------------------------------------------------
ColorFlow 	Macro Destination:REQ
Local ScanAgain,DoNotRestore, IgnoreNul, Destination

		mov cx,256
		mov si,destination
SCANAGAIN:      mov al,ds:[si]
                cmp al,(4*8)+1
                jb IGNORENUL
                cmp al,(4*8)+8
                ja IGNORENUL
                inc al
                cmp al,(4*8)+8
                jne DONOTRESTORE
                mov al,(4*8)+2
DONOTRESTORE:	mov ds:[si],al
IGNORENUL:	inc si
		loop SCANAGAIN
                ENDM

;----------------------------------------------------------------
DrawLine	Macro Destination:REQ, Lenght:REQ, Color:REQ
Local Destination, Lenght, Color, EndOfDraw
Local DW1, DW1B, DW2, DW2B, OutSoso

		pusha
		mov cl,lenght
                mov ch,0
                mov al,Color
                mov di,Destination
                add di,140h

                cmp cx,0
                je EndOfDraw

DW2:            push cx
                push di
                mov cx,6
DW1:            mov gs:[di],al
                add di,140h
                loop DW1
      		pop di
                pop cx

                inc di
                loop DW2

EndOfDraw:      mov cx,255
                sub cl,lenght
                cmp cl,0
                je OutSoso

                mov al,0
DW2B:           push cx
                push di
                mov cx,6
DW1B:           mov gs:[di],al
                add di,140h
                loop DW1B
      		pop di
                pop cx

                inc di
                loop DW2B

OutSoso:  	popa
		ENDM

;----------------------------------------------------------------
DrawSmallSSFs	Macro Destination:REQ, Source:REQ, Color:REQ
Local EndDraw, ChkTableAgain, MatchSign, D1xyz, D2xyz, ReadNextPat
Local NulPix445, Destination, Source, Color

                pusha
		call Convensions
                mov di,destination
                mov si,Source
ReadNextPat:    mov al,[si]
                cmp al,-1
                je EndDraw

                mov bx,offset SignsTable
ChkTableAgain:  cmp al,[bx]
                je MatchSign
                inc bx
                jmp ChkTableAgain

MatchSign:	sub bx,offset SignsTable
		rol bx,10
                push di

                mov dx,8
D2xyz:          mov cx,8
D1xyz:          mov al,es:[bx]

		cmp al,0
                je NulPix445

                mov al,Color

NulPix445:      mov gs:[di],al
	      	add bx,4
                inc di
                loop D1xyz

                add di,140h-8
                add bx,32*3
                mov cx,dx
                dec dx
                loop D2xyz
                pop di

                add di,8
                inc si
                jmp ReadNextPat

EndDraw:        popa
		ENDM

;----------------------------------------------------------------
FramesExtender 	Macro Destination:REQ, Value:REQ
Local CmpValueToZero, Destination, Value, FramesExtenderOver

                push ax
                push dx
                mov dx,DATA
                mov ds,dx

                mov al,30h
                mov byte PTR Destination,al
                mov byte PTR Destination+1,al

		mov ah,value
CmpValueToZero: cmp ah,0
                je FramesExtenderOver

		dec ah
                inc byte PTR destination+1
		cmp byte PTR destination+1,39h
                jbe CmpValueToZero

                mov al,30h
                mov byte PTR destination+1,al
                inc byte PTR destination
                jmp CmpValueToZero

FramesExtenderOver:
                pop ax
                pop dx

		ENDM

;---------------------------------------------------------------------

HMOUSE 	MACRO
        call CONVENSIONS
	push di
        push ax
        mov al,0
        mov di,offset SHOWMOUSE
        mov [di],al
        pop ax
        pop di
	ENDM

SMOUSE 	MACRO
        call CONVENSIONS
	push di
        push ax
        mov al,1
        mov di,offset SHOWMOUSE
        mov [di],al
        pop ax
        pop di
	ENDM

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;	           This is list of all objets is CS4
;	           Date: July 9th 1994
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------

;00 Blank    Blank
;01 Brick    Brick
;02 cordnst0 Player
;03 lightbul Light Bulb
;04 Orb      Orb
;05 Chest    Chest
;06 Diamond  Diamond
;07 Neckless Neckless
;08 Prope    Rope
;09 tnt      Tnt
;0A Flower   Flower
;0B bottle   Bottle of Oxygen
;0C triforce TriForce
;0D shield   Shield
;0E Ladder   Ladder
;0F 2rollex  Rope <- Poulie
;10 Rollx2   Poulie
;11 2rollop  Rope    Poulie
;12 Rollx    Poulie
;13 Rollexr2 Poulie -> Rope
;14 Rollrop2 Poulie    Rope
;15 elswup   ELectric SWitch UP
;16 elswdn   ELectric SWitch DN
;17 deascrew Deadly Screw XXX
;18 lightscr Light Bulb in screw
;19 screw    Unpowed Screw
;1A lightulg UNLighted Bulb in screw
;1B sbox     Magic Box
;1C !rollx2  Right Poulie with rope
;1D !rollx   Left Poulie with rope
;1E HKey     HeartKey
;1F HDoor    HeartDoor
;20 WKey     WaterKey
;21 WDoor    WaterDoor
;22 SKey     SKey
;23 SDoor    SDoor
;24 BKey     BKey
;25 BDoor    BDoor
;26 Gwall    GreenWall
;27 pattern5 Pattern
;28 RockWa93 Rockwall93
;29 Rockwall Rockwall
;2A Mix3Rock Rockwall UP
;2B Mix2Rock Rockwall DN
;2C Newpat!  NewPattern
;2D Bluepat  BluePattern
;2E pintree  Pine Tree
;2F statue   Statue
;30 rock     Rock
;31 rock2    Rock #2
;32 rock3    Rock #3
;33 planrock ROck & NewPlant
;34 newplan  New Plant
;35 xroot    Brokable ROOT
;36 root     ROOT
;37 broot    BRIDGE & ROOT
;38 bridge   BRIDGE #0
;39 br01     BRIDGE #1
;3A br02     BRIDGE #2
;3B br03     BRIDGE #3
;3C br04     BRIDGE #4
;3D br05     BRIDGE #5
;3E br06     BRIDGE #6
;3F br07     BRIDGE #7
;40 br08     BRIDGE #8
;41 br09     BRIDGE #9
;42 br10     BRIDGE #10
;43 br11     BRIDGE #11
;44 forcefi2 Force Field
;45 stop     Stop
;46 x        Energy Drain Trap
;47 freeze   Freeze Trap
;48 trans    Transporter
;49 transb   Transporter's destination
;4A deadplan Deadly Plant
;4B fish     Fish
;4C chglnk0  Change Link
;4D bworm    Boby of the worm
;4E magicpup Magic Platforme UP/DN
;4F magicplf Magic Platforme LF/RG
;50 $1dummy  Dummy
;51 #dumbr   Dummy on bridge
;52 #dumla   Dummy on ladder
;53 $1gobbli Gobblin
;54 #gobbr   Gobblin on bridge
;55 #gobla   Gobblin on ladder
;56 $1teddy  Teddy
;57 #tedbr   Teddy on bridge
;58 #tedla   Teddy on ladder
;59 $1octop  Octopus
;5A #octbrb  Octopus on bridge
;5B #octla   Octopus on ladder

;--------------------------------------------------------------------------------
;	CREEPSPREAD IV (C) 1994 FRANCOIS BLANCHETTE
;--------------------------------------------------------------------------------

;1.0 	The construction kit:
;	Items identifcation code for Creepspread IV

;Bits	Description.............................................................

;0..1	Background objects
;	1- Water, 2- Lava, 3- Slime
;2	0- UP	1-DOWN
;3..7	Type of idetifier drawn by the falowing values
;	1 	Stop
;	2..31 	0 to 29

;1.1	Signfiant content of CS4ANI.MCG for CS4LEVEL.EXE

;	00 &wateru1
;	01 &wateru2
;	02 water2
;	03 &lavaup1
;	04 &lavaup2
;	05 lavadn
;	06 slime
;	07 slime2
;	08 slimedn

;2.0	Game Module (CS4)

;	09 !trans
;	0A !trans2
;	0B $1deadpl
;	0C $2deadpl
;	0D magicpla
;	0E rfish
;	0F lfish
;	10 $1dummy
;	11 $1gobbli
;	12 $1teddy
;	13 $1octop
;	14 chglnk0
;	15 x
;	16 x
;	17 $2dummy
;	18 $2gobbli
;	19 $2teddy
;	1A $2octop
;	1B chglnk0
;	1C x
;	1D x

;--------------------------------------------------------------
;--------------------------------------------------------------

PUBLIC CONVENSIONS,PATH
PUBLIC ROOM_NAMES

EXTERN WBUT:PROC
EXTERN CLS:PROC
EXTERN VIDEOSWITCH:PROC
EXTERN LOADOLD:PROC
EXTERN LOADNEW:PROC
EXTERN LOADROOM:PROC
EXTERN GETAX:PROC
EXTERN MAKEPATH:PROC
EXTERN QUIT:PROC
EXTERN NOT_FOUND:PROC
EXTERN MELO_PAINT:PROC
EXTERN DRAW_SCREEN:PROC
EXTERN REDRAW_SCREEN:PROC
EXTERN OLD_VIDEO_MODE:WORD
EXTERN MOUSE_DOWN:WORD
EXTERN FILENAME:BYTE
EXTERN SENDERRORMESSAGE:PROC

EXTERN LDX:WORD
EXTERN STATUS_TABLE:PROC
EXTERN DRAWSOMESCREEN:PROC
EXTERN ERASESCREEN:PROC
EXTERN PAUSE:PROC

EXTERN SCRIPTDATA:BYTE
EXTERN SCRIPT_COMPILER:PROC
EXTERN MX:BYTE

EXTERN SHOWMOUSE:BYTE
EXTERN DRAWMOUSE:PROC
EXTERN DRAWMOUSE2:PROC
EXTERN DRAWMOUSEX:PROC
EXTERN ICONS:BYTE

;----------------------------------------------------------------
STACK     SEGMENT STACK
	  DB 600H DUP  (0)
STACK     ENDS
;----------------------------------------------------------------

;----------------------------------------------------------------
DATA      SEGMENT PUBLIC 'DATA'

COPYRIGHT      	db "CREEPSPREAD IV: (C) 1994 FRANCOIS BLANCHETTE"
PATH		db 0
SIGNSTABLE	db "#abcdefghijklmnopqrstuvwxyz!._: '0123456789[]",0
NoPlayerInMaze	db "Fatal: No player in maze.$"
NoCreatureInMaze db "Fatal: No creature will result in crash!$"
TDestination	db "Fatal: No destination located.$"
DiamondTxt	db "diamonds 00",-1
RopeTxt		db "ropes 00",-1
BulbTxt		db "bulbs 00",-1

CS4SIGNS_SSF	db "CS4SIGNS.SSF",0
USERS_SSF	db "USERS.SSF",0
USERS_MCG	db "USERS.MCG",0
MOUSE_MCG	db "MOUSE.MCG",0
CS4GRAPH_MCG	db "CS4GRAPH.MCG",0
CS4ANI_MCG	db "CS4ANI.MCG",0
EASY_MSS	db "CS4A.DAT",0
ADVANCE_MSS	db "CS4B.DAT",0
EXPERT_MSS	db "CS4C.DAT",0
EASY_SCO	db "CS4A.SCO",0
ADVANCE_SCO	db "CS4B.SCO",0
EXPERT_SCO	db "CS4C.SCO",0

INTSEQ1		db "reep",0
INTSEQ2		db "pread",0

ROOM_NAMES	db "INTRO",0
		db "SELECT",0
LEVXX           db "LEV01",0

LEVXX_CS4	db "LEV01.CS4",0
LEVELXX         db "level 01",0
CURRENT_LEVEL	db 0
AtLevel		db 0
MOUSE_CTRL	db 1
ESCORES		db 1
PShape		db 0
MY		db 0
Pv		db 0
HPv		db 0

GameModulator	db 0
MoveFlag	db 0
JumpFlag	db 0
AIMFLAG		db 0
FRAMEFLAG	db 0
FALLFLAG	db 0
GAMEOVERFLAG	db 0
PlayerFlash	db 0
ScreenFlash	db 0
FreezeFlag	db 0
FreezeFlagDelay db 0
RedrawMode	db 0
GameMode	db 0
GameModeBase	db 0

CAnimation	db 0
CAniDelay	db 0
SCORE	       	db 9 DUP (-1)

LIFEFORCE	db 0
OXYGEN		db 0
Tnt		db 0
Rope		db 0
LightBulb	db 0
Diamond		db 0

align 2
ACTORSI		dw 0
ACTORNUM	dw 0
NOA		dw 0
CS4GRAPH	db 32768 DUP (0)
CS4ANI		db 8192  DUP (0)
LEVELDATA	db 16384 DUP (0)
AHCOLORS	db 01,02,04,42,33,06,43,34
KeySequence	db 1eh,20h,22h,24h
KeyStatus	db 0,0,0,0

COSTABLE       db 2,4,1,3
               db 3,1,2,4
               db 4,2,3,1
               db 1,3,4,2

align 4
ForceFi2	dd 4 DUP (0)
NameOffset	dw 0
NameDest	dw 0
LineNum		dw 0
TriForceFlag    dw 0

DATA   ENDS
;----------------------------------------------------------------

SCREEN SEGMENT PUBLIC 'SCREEN'
SCREEN ENDS

LIBRAIRY SEGMENT PUBLIC 'LIBRAIRY'
LIBRAIRY ENDS

STATICS SEGMENT PUBLIC 'STATICS'
STATICS ENDS

FONTS SEGMENT PUBLIC 'FONTS'
FONTS ENDS

SIGNSEG SEGMENT PUBLIC 'SIGNSEG'
             	DB 45056+8192   DUP (0)
PLAYERFRAMES 	DB 20*256  DUP (0)
CCX		db 256 DUP (0)
CCY		db 256 DUP (0)
CCA		db 256 DUP (0)
CCF		db 256 DUP (0)
SignSeg		EndS

;----------------------------------------------------------------
Assume DS:Data, CS:Code

CSPOS 	 	EQU 0a00h*4+24
CSPOS2	 	EQU CSPOS+32*140h
CSINV    	EQU 51h
LineSize 	EQU 20
RowSize	 	EQU 11

Level 		EQU LevelXX+6
Level_cs4	EQU LevXX_CS4+3
ActualTop	EQU 0a00h
LevelNameSize   EQU 2048
GameOverDi	EQU ActualTop+(((RowSize*2)-8)/2)*0a00h

;----------------------------------------------------------------
TextSeg	Segment Public "TextSeg"
		   ;01234567890123456789
NameTxt         db LevelNameSize DUP (0)
Selectdif	db " select difficulty  ",0
f1text		db " f1: easy",0
f2text		db " f2: advanced",0
f3text		db " f3: expert",0
HighScoreTxt	db " highs scores board",0
SorryTxt	db "sorry you didn't play well enough!",-1
WriteTxt	db "write name and [enter] when done!",-1
Choose1		db "move the hand arround with your mouse",-1
Choose2		db "and click on the desired character.",-1
                ;   0000000000111111111122222222222333333333
		;   0123456789012345678901234567890123456789
PauseTxt	db " game paused... press [space] to resume!",-1
FbTxt		db "00000000 01                             ",-1
EraseTxt	db "   erase highs scores: [y]es or [n]o    ",-1
GameOverTxt	db "game over!",-1
HiScores	db 800 DUP (0)

CS4txt		db 10,13
		db "CREEPSPREAD IV",13,10
                db "(C) 1994 FRANCOIS BLANCHETTE.",13,10,13,10
                db "/k disable mouse control",13,10
                db "/s disable erase scores",13,10
                db "/? show help.",13,10,"$"

TextSeg ENDS

;----------------------------------------------------------------
CODE SEGMENT READONLY PUBLIC 'CODE'
CS4  PROC NEAR
;----------------------------------------------------------------
.386
		mov bl,es:[80h]
		cmp bl,0
		je GIVE_CM_LINE

		mov cl,bl
		mov ch,0
		inc cx

		mov si,80h

XTRSN:		mov al,es:[si]
                cmp al,"k"
                je KeyBoardCtrlEnabled
                cmp al,"K"
                je KeyBoardCtrlEnabled
                cmp al,"s"
                je EScoreEQU0
                cmp al,"S"
                je EScoreEQU0

		cmp al,"?"
                je ShowHelp

ContinueScan:   inc si
		loop XTRSN


GIVE_CM_LINE:   jmp MOUSEDRIVERSCAN


EScoreEQU0:	mov dx,Data
		mov ds,dx
                mov byte ptr EScores,0
                jmp ContinueScan

KeyboardCtrlEnabled:
		mov dx,Data
                mov ds,dx
                mov byte ptr Mouse_ctrl,0
       		jmp ContinueScan


ShowHelp:	mov dx,TextSeg
		mov ds,dx
                mov dx,offset CS4txt
                mov ah,9
                int 21h
                mov al,0
                mov ah,4ch
                int 21h

MOUSEDRIVERSCAN:

		call Convensions
                cmp byte ptr Mouse_ctrl,0
                je Commun

               mov ah,35h
	       int 21h
	       cmp byte ptr es:[bx],0
	       jne YOU_GOT_DRIVER

NO_DRIVER:     mov dx,data
	       mov ds,dx
	       mov dx,offset MOUSE_DOWN
	       mov ah,9
	       int 21h
	       mov ah,4ch
	       int 21h

YOU_GOT_DRIVER:mov ax,0			; Initialize mouse driver
	       int 33h
	       cmp ax,-1
	       jne NO_DRIVER

Commun:	       call VIDEOSWITCH		; Switch to VGA 180x320


                ; {*************************************************}
                ; THIS WILL BEGIN THE INTRODUCTION MODULE THAT I
                ; ATTEMPTED TO PLACE AWAY IN ANOTHER FILE. THE
                ; TRANSFER APPARENTLY FAILED SO IT'S STILL HERE.
                ; I'VE STILL TO DEAL WITH IT
		; {*************************************************}


                ; Chargement de MOUSE.MCG
                mov dx,DATA
                mov ds,dx
                mov es,dx
                mov dx,offset MOUSE_MCG
                mov bx,offset ICONS
                mov cx,256
                call LOADOLD

                ; Chargement de CS4SIGNS.SSF
                mov dx,DATA
                mov ds,dx
                mov dx,SIGNSEG
                mov es,dx
                mov dx,offset CS4SIGNS_SSF
                mov bx,0
                mov cx,45056+8192
                call LOADNEW

                ; Chargement de CS4GRAPH.MCG
                mov dx,DATA
                mov ds,dx
                mov es,dx
		mov dx,offset CS4GRAPH_MCG
                mov bx,offset CS4GRAPH
                mov cx,32768
                call LOADOLD

                ; Chargement de CS4ANI.MCG
                mov dx,DATA
                mov ds,dx
                mov es,dx
                mov dx,offset CS4ANI_MCG
                mov bx,offset CS4ANI
                mov cx,8192
                call LOADOLD


LOADINTROLIB:	mov cx,0
		call LOADROOM

		call CONVENSIONS
                mov di,offset STATUS_TABLE+1
                mov al,1
                mov [di],al

                mov di,offset SCRIPTDATA+3*4+2
                mov al,[di]
                add al,80
                mov [di],al

                mov al,[di+4]
                add al,80
                mov [di+4],al

                mov al,[di+8]
                add al,80
                mov [di+8],al


                call DRAW_SCREEN

                call CONVENSIONS
                call DRAWCREEPSPREADIV

                call DRAWSOMESCREEN
                call REDRAW_SCREEN

                call CONVENSIONS

                mov si,offset STATUS_TABLE+1
                mov al,0
                mov [si],al

	        mov cx,80+40
DOWRAPAROUND:  	push cx

                mov di,offset SCRIPTDATA+3*4+2
                mov al,[di]
                dec al
                mov [di],al

                mov al,[di+4]
                dec al
                mov [di+4],al

                mov al,[di+8]
                dec al
                mov [di+8],al

                call SCRIPT_COMPILER
                call DRAW_SCREEN
                call DRAWCREEPSPREADIV
                call REDRAW_SCREEN

                push ds
                call Getax
                pop ds
                cmp ax,0
                jne RestartProgram

                pop cx
                loop DOWRAPAROUND

                mov cx,10
                call PAUSE

              	;-----------------------------------------------
                ; Load Select.Lib & Select.Scr
                mov cx,1
                call LoadRoom
                call Draw_Screen

                mov dx,0a000h
                mov gs,dx
                mov dx,Screen
                mov fs,dx
		mov cx,65536
		mov di,0

CVideoToBuf:    mov al,gs:[di]
                cmp al,0
                je NulPixIgnore
                mov fs:[di],al
NulPixIgnore:   inc di
                loop CVideoToBuf
		call DrawSomeScreen
                call Redraw_Screen

RestartProgram: mov cx,1
                call LOADROOM
                call DRAW_SCREEN

                ; CHARGEMENT DE USERS_SSF
		mov dx,DATA
                mov ds,dx
                mov dx,SIGNSEG
                mov es,dx
                mov dx,offset USERS_SSF
                mov bx,0
                mov cx,1024
                call LOADNEW

                ; CHARGEMENT DE USERS_MCG
                mov dx,DATA
                mov ds,dx
                mov dx,STATICS
                mov es,dx
                mov dx,offset USERS_MCG
                mov bx,0
                mov cx,61447
                call LOADOLD

                call CONVENSIONS
                mov si,0
                mov bx,offset AHCOLORS
                mov di,8+20*8*140h

                mov cx,8
                mov al,4
DRAWNEXT:       mov ah,[bx]
                inc bx
		call CONDSSFSDRAW

                mov si,bx
                sub si,offset AHCOLORS
                push ax
                mov ax,si
                mov ah,20
                mul ah  		; AX=ACTOR *20
                mov si,ax		; SI=ACTOR *20
                rol si,8		; SI=ACTOR *1400h
                add si,500h		; SI=ACTOR *1400h + 500h

                push bx
                push cx
                push di

                mov dx,STATICS
                mov es,dx
                mov dx,SCREEN
                mov gs,dx

                add di,8*140h+8

                mov bx,16
DOLOOPB:        mov cx,16

DOLOOPA:        mov al,es:[si]
                cmp al,0
                jne DRAWNOW

                cmp al,es:[si-1]
                je NULPIXAAAH


DRAWNOW:        mov gs:[di],al
NULPIXAAAH:	inc si
		inc di
                loop DOLOOPA

                add di,140h-16
		mov cx,bx
                dec bx
		loop DOLOOPB

                pop di
                pop cx
                pop bx
                pop ax

                mov si,0
                add di,32+8
                loop DRAWNEXT

                call Convensions

                mov di,0
                mov si,offset Choose1
                mov ah,14
                call PrintLine

                add di,0a00h
                mov si,offset Choose2
                mov ah,14
                call PrintLine

                call Convensions
                cmp byte ptr Mouse_ctrl,0
                je XXXmouse

		;call DrawCreepSpreadIV
                call DRAWSOMESCREEN
                call REDRAW_SCREEN

                call Convensions
                mov word ptr LDX,-1

                SMOUSE

                ; Cette routine à pour but d'amorcer
                ; la selection d'un personnage sur un choix
                ; maximum de huit.


SELECT_LOOP:    call GETAX
		call DRAWMOUSE

                call WBUT
                and bx,1
                cmp bx,1
                jne SELECT_LOOP

                cmp dx,20
                jb SELECT_LOOP

		cmp dx,23
                ja SELECT_LOOP

                ; At this point we know that the player has clicked
                ; on one of the VLAMITS. But which one? We must
                ; player the character in an investigation throught
                ; a location process.

                mov dx,cx

                mov ax,1
                mov bx,8
LOOKAGAINXX2:   mov cx,4
LOOKAGAINXXX:

		cmp ax,dx
                je CLICKON
                inc ax
                loop LOOKAGAINXXX

                inc ax
                mov cx,bx
                dec bx
                loop LOOKAGAINXX2
                jmp SELECT_LOOP

		; The player has just clicked on one of the VLAMITS
                ; like character. Now a check control routine is taking
                ; effect to initiate the last phase of the intro.

CLICKON:        call CONVENSIONS
		mov ax,7
                dec bx
		sub ax,bx
		inc ax

                mov di,offset ACTORNUM
                mov [di],al

                mov ah,20
                mul ah
                rol ax,8
                mov di,offset ACTORSI
                mov [di],ax

                ; "Begin tranfering the player's frames into a secure
                ; buffer for futhre uses. I know that we'll need those
                ; data later. That is why, that I must preserve their
                ; integrity." - FRANCOIS BLANCHETTE


BEWELCOMED:	mov dx,STATICS
		mov es,dx
                mov dx,SIGNSEG
                mov fs,dx
                mov cx,20*256/4

                mov si,offset ACTORSI
                mov si,[si]
                mov di,offset PLAYERFRAMES

TRANSPLY:       mov eax,es:[si]
                mov fs:[di],eax
                add si,4
                add di,4
                loop TRANSPLY

                ;-------------------------------------------------

xxxMouse2:
                mov dx,Screen
                mov gs,dx
                call Cls

                mov dx,TextSeg
                mov fs,dx

                ;mov di,0a00h*3
                ;mov si,offset SelectDif
                ;call JulieJean94

                mov di,0a00h*3
                mov si,offset SelectDif

                Print16x16Sign -1,-1,35,24

                mov cx,3
DrawFx:         add di,0a00h*4
                Print16x16Sign -1,-1,36,39
              	;call JulieJean94
                loop JmpDrawFx
                jmp NotDrawFx

JmpDrawFx:	jmp DrawFx

NotDrawFx:
                call DrawSomeScreen
D1Xx:           call Getax
		call Convensions

		cmp al,0
                jne D1Xx
                mov al,ah

                cmp al,59	; F1
                je SetEasyMode
                cmp al,60
                je SetAdvanceMode; F2
                cmp al,61
                je SetExpertMode; F3
                jmp D1Xx

SetEasyMode:	mov ah,"e"
                jmp SetMode

SetAdvanceMode:	mov ah,"a"
		jmp SetMode

SetExpertMode:  mov ah,"v"
SetMode:	sub al,59
		mov byte ptr GameMode,al
                mov byte ptr GameModeBase,al
                mov di,offset LEVXX_CS4+2
                mov [di],ah
                mov di,offset LEVXX
                mov [di+2],ah


                ;--------------------------------------------------------
                ; Loading a ScoreBoard from disk. The one that goes with
                ; the game mode you selected. If it is easy, then you get
                ; an easy game board. If it is hard, you'll get the
                ; hard game board.
                ;--------------------------------------------------------

                mov al,byte ptr GameModeBase
                cmp al,0
                je LoadEasyBoard
                cmp al,1
                je LoadAdvanceBoard

                mov bp,offset Expert_SCO
          	jmp LoadBoard

LoadEasyBoard:  mov bp,offset Easy_SCO
		jmp LoadBoard

LoadAdvanceBoard:
		mov bp,offset Advance_SCO

LoadBoard:
                ; CHARGEMENT DE EASY.SCO
                mov dx,Data
                mov ds,dx
                mov dx,TextSeg
                mov es,dx
                mov dx,bp
                mov bx,offset HiScores
                mov cx,800
                call LoadNew

                call Convensions
                mov word Ptr NameOffset,offset NameTxt

                ;------------------------------------------------------
                ; We'll load the most important thing in a game, the
                ; levels' names. This is a bit stupid you'll say. I
                ; know but I fell names are important because level
                ; are like people. They have different humours and
                ; tempers.
                ;------------------------------------------------------

			; Chargement de Easy.Mss

                        mov dx,data
                        mov ds,dx
                        mov dx,TextSeg
                        mov es,dx
                        mov bx,offset NameTxt
                        mov cx,LevelNameSize

                        mov al,byte ptr GameMode
                        cmp al,0
                        je LoadEasyTxt
                        cmp al,1
                        je LoadAdvanceTxt
                        mov dx,offset EXPERT_MSS
                        jmp LoadItNow

LoadEasyTxt:		mov dx,offset EASY_MSS
			jmp LoadItNow

LoadAdvanceTxt:		mov dx,offset Advance_mss

LoadITNow:              call LoadNew
                        call RecriptLevelName
                        call Convensions

		;--------------------------------------------------------
                ; I'm loading a new room. We call those room because
                ; the statics librairies where suppose to make room
                ; efficient to insure that the game would setup proprely.
                ; In fact, that refers to LEV01.LIB & LEV01.SCR that must
                ; be loaded to bring the screen to life.
                ;---------------------------------------------------------

                FramesExtender LevXX+3,1
                mov cx,2
                call LOADROOM
                HMOUSE

                call CONVENSIONS
                call DRAW_SCREEN

                ; Some routine will be used, here and there, but the
                ; most important is that they must do write everything
                ; like: "LEVEL 01 GRAB THE DIAMONDS AH! AH!AH! AH!!!"

                FramesExtender LEVEL,1
                call DRAWLEVELXXSIGN

                mov dx,TextSeg
                mov fs,dx

                mov si,word ptr NameOffset
                mov di,140h*32+12*0a00h
                call JulieJean94

                mov di,140h*64+12*0a00h
                call JulieJean94

                mov word ptr NameOffset,si

                ; Draw the selected character onto the screen
                ; just in front of the giant killing plant who
                ; came from the grounded green grass.

ENDINTSEQ2b:
                call Convensions
                cmp GameMode,0
                jne NoPlyOnScreenHAHA

		mov di,CSPOS2+20*8-8*140h+3*0a00h
		mov si,offset PLAYERFRAMES+3*5*256+3*256

                mov dx,SIGNSEG
                mov es,dx
                mov dx,SCREEN
                mov gs,dx

                mov bx,16
DOVERTISCAN:    mov cx,16
DOHORIZSCAN:    mov al,es:[si]
                cmp al,0
                je XNULPENUT

                mov gs:[di],al
XNULPENUT:	inc si
		inc di
                loop DOHORIZSCAN

                add di,140h-16
                mov cx,bx
                dec bx
                loop DOVERTISCAN

NoPlyOnScreenHAHA:
		call DRAWSOMESCREEN
                call REDRAW_SCREEN

                mov cx,75
                call PAUSE
                jmp SetupGame
















		;------------------------------------------------------
                ; Draw onto the screen the fallowing line
                ; of dysplay:"LEVEL XX" when it applicable.
                ; Maybe I will come to change to routine later but
                ; until then it will stay there intact.

DRAWLEVELXXSIGN:mov si,offset LEVELXX
		mov di,32+16*140h
DRAW_BIGXX:   	mov al,[si]
                cmp al,0
                je ENDLEVXX
		call DDSIGNS
                add di,32
		inc si
                jmp DRAW_BIGXX
ENDLEVXX:	ret


		; This small routine dysplay a piece of text starting
                ; at DS:[SI] to a location GS:[DI] where GS is pointing
                ; the SCREEN segment.

JULIEJEAN:      mov al,[si]
                cmp al,0
                je SKIPDBSIGNS
                call DBSIGNS
                inc si
                add di,16
                jmp JULIEJEAN
SKIPDBSIGNS:	ret

		; Stretch a 32x64 font to the size of a 16x16 MGC format
                ; to print it onto the screen. This version of the routine
                ; will draw the characters in light & dark green only.
                ; Another routine will takeover the task of multicolor
                ; font drawing.

DBSIGNS:        cmp al," "
		je DOQUIT
		pusha

                mov si,offset SIGNSTABLE
XCHKAGAINXYZB:	cmp al,[si]
                je XIDSIGNSMATCHB
                inc si
                jmp XCHKAGAINXYZB

XIDSIGNSMATCHB:	sub si,offset SIGNSTABLE
		rol si,10

		mov dx,SIGNSEG
                mov es,dx
                mov dx,SCREEN
                mov gs,dx

                mov bx,16
LOOPDB2:        mov cx,16

LOOPDB1:        mov al,es:[si]
                cmp al,0
                je XDBNULPIX

                cmp al,5*8+2
                jne LIGHTGREEN
                mov al,2
                jmp PLACECOLOR
LIGHTGREEN:	mov al,10

PLACECOLOR:     mov gs:[di],al

XDBNULPIX:      inc di
	       	inc si
                inc si
		loop LOOPDB1

                add di,140h-16
                add si,32
                mov cx,bx
                dec bx
                loop LOOPDB2

		popa
DOQUIT:         ret


		; CONDSSFSDRAW -- Draw a frame for the SSFS stored
                ; in USERS.SSF, it uses AL & AH to change colors
                ; for customization purposes. Why are these frames
                ; usefull? They have a use only in the introduction
                ; where they are drawn on the "SELECT SCREEN".

CONDSSFSDRAW:	pusha

                mov dx,SIGNSEG
                mov es,dx
                mov dx,SCREEN
                mov gs,dx

		mov bx,32
DRAWNEXTROWXX:  mov cx,32
STILLDRAWLINE:  mov dl,es:[si]
                cmp dl,al
                jne XDOCHNGE

                mov dl,ah
XDOCHNGE:       cmp dl,0
                je DONOTDRAWBLK

                mov gs:[di],dl
DONOTDRAWBLK:	inc si
                inc di
		loop STILLDRAWLINE

		add di,140h-32
                mov cx,bx
                dec bx
                loop DRAWNEXTROWXX

                popa
                ret


                ; DRAWCREEPSPREADIV -- Maybe it ovious what this is
                ; purpose to draw but I will mention it anyways. That
                ; will dysplay "CREEPSPREAD IV" onto the screen on the
                ; first SEQUENCE OF THE INTRO. Where it will be used with
                ; the "INTRO SCREEN".


DRAWCREEPSPREADIV:mov al,"c"
                mov di,CSPOS
                call DDSIGNS

		mov si,offset INTSEQ1
                mov di,32+32*140h+CSPOS
DOSEQ1:         mov al,[si]
                cmp al,0
                je ENDINTSEQ1
		call DWSIGNS
                add di,16
                inc si
                jmp DOSEQ1

ENDINTSEQ1:     mov al,"s"
                mov di,CSPOS+16*5+32*140h+4*2
                call DDSIGNS

		mov si,offset INTSEQ2
                mov di,32+2*32*140h+5*16+CSPOS+4*2
DOSEQ2:         mov al,[si]
                cmp al,0
                je ENDINTSEQ2
		call DWSIGNS
                add di,16
                inc si
                jmp DOSEQ2

ENDINTSEQ2:     mov al,"i"
		mov di,CSPOS+16*13+32*140h
                call DDSIGNS
                mov al,"v"
                mov di,CSPOS+16*13+32+32*140h
                call DDSIGNS
		ret


                ; DWSIGNS-- Draw fonts at a size of 16x32, it is used to
                ; draw the little letters of CreepSpread onto the
                ; "INTRO SCREEN" to make it cute.


DWSIGNS:	pusha
		mov dx,SCREEN			; Setup the vidéo segment
                mov gs,dx
                mov dx,SIGNSEG			; Setup the data segment
                mov es,dx

                mov si,offset SIGNSTABLE
CHKAGAINXYZ:	cmp al,[si]
                je IDSIGNSMATCH
                inc si
                jmp CHKAGAINXYZ

IDSIGNSMATCH:	sub si,offset SIGNSTABLE
		rol si,10

                mov dx,32
OLEXZ2:         mov cx,16
OLEXZ:          mov al,es:[si]
                cmp al,0
                je XPNULPIXEL
                xor al,CSINV

XXD:            mov gs:[di],al

XPNULPIXEL:	inc si
                inc si
		inc di
                loop OLEXZ

                mov cx,dx
                dec dx
                add di,140h-32/2
                loop OLEXZ2
                popa
                ret


                ; DDSIGNS -- Draw a FONT from SIGNSEG at a size of
                ; 32x64. The font will print in dark green only since
                ; this routine is used by the title introduction as
                ; for printing the "C" & "S" of CREEPSPREAD.


DDSIGNS:	pusha
		mov dx,SCREEN			; Setup the vidéo segment
                mov gs,dx
                mov dx,SIGNSEG			; Setup the data segment
                mov es,dx

                mov si,offset SIGNSTABLE
CHKAGAINXYZB:	cmp al,[si]
                je IDSIGNSMATCHB
                inc si
                jmp CHKAGAINXYZB

IDSIGNSMATCHB:	sub si,offset SIGNSTABLE
		rol si,10

                mov dx,32
OLEXZ2B:         mov cx,32
OLEXZB:          mov al,es:[si]
                cmp al,0
                je XPNULPIXELB
                xor al,CSINV
                mov gs:[di],al
                mov gs:[di+140h],al

XPNULPIXELB:	inc si
		inc di
                loop OLEXZB

                mov cx,dx
                dec dx
                add di,(140h*2)-32
                loop OLEXZ2B
                popa
                ret


CONVENSIONS PROC NEAR
		push dx
		mov dx,DATA
		mov ds,dx
                mov dx,SIGNSEG
                mov es,dx
		;mov dx,SCREEN
		;mov gs,dx

                mov dx,TextSeg
                mov fs,dx

		pop dx
		ret
CONVENSIONS ENDP

































;----------------------------------------------------------------------
; SetupGame
;----------------------------------------------------------------------

SetupGame:              call Convensions
 			mov di,offset SCORE
 			mov al,30h
                        mov cx,8
ZeroScore:              mov [di],al
                        inc di
                        loop ZeroScore

                        ; Restore original state of
                        ; 1) LifeForce
                        ; 2) Oxygen

                        mov byte Ptr LifeForce,   64
                        mov byte Ptr Oxygen,      32
                        mov byte PTR Current_Level,0
                        mov byte ptr AtLevel,	   0

       			call Convensions
			Inc byte PTR Current_Level
                        inc byte ptr AtLevel
			FramesExtender Level_cs4, byte PTR Current_level

                        ;-----------------------------------------------
                        ; LoadAData File containing the name of each
                        ; and every level. The file for CS4 is
                        ; "EASY.MSS".
                        ;-----------------------------------------------


EntryToNextLevel:       ; Loading LEVXX_CS4
                        mov dx,DATA
                        mov ds,dx
                        mov es,dx
                        mov dx,offset LEVXX_CS4
                        mov bx,offset LevelData
                        mov cx,16384
                        call LoadNew

PrepareForLevel:
			call Convensions

                        ; Restore all Game Flags & main Registrers

                        mov byte Ptr JumpFlag,    0
                        mov byte Ptr AimFlag, 	  1
                        mov byte Ptr FrameFlag,   0
                        mov byte Ptr MoveFlag,    0
                        mov byte Ptr GameOverFlag,0
                        mov byte Ptr PlayerFlash, 1
                        mov byte Ptr ScreenFlash, 0

                        mov byte Ptr Noa,         0
			mov byte Ptr Tnt,	  0
                        mov byte Ptr Rope,	  0
			mov byte Ptr LightBulb,   0
                        mov byte Ptr RedrawMode,  1
                        mov byte Ptr CAnimation,  0
                        mov byte Ptr CAniDelay,   0

                        mov byte Ptr Pv,          0
                        mov byte Ptr HPv,         0

                        mov byte Ptr KeyStatus+0, 0
                        mov byte Ptr KeyStatus+1, 0
                        mov byte Ptr KeyStatus+2, 0
                        mov byte Ptr KeyStatus+3, 0

                        mov byte Ptr FreezeFlag,      0
                        mov byte Ptr FreezeFlagDelay, 0
                        mov byte Ptr TriForceFlag,    0

		; Identify the player position and setup the appropriate
                ; MX & MY definitions to match the current position to
                ; ajust the screen proprely.

                mov cx,8192
	    	mov bx,offset LevelData
ScanMoreXyz:    mov al,[bx]
                cmp al,2
                je FoundPlayerInMaze
                inc bx
		loop ScanMoreXyz

                mov dx,offset NoPlayerInMaze
                jmp SendErrorMessage

FoundPlayerInMaze:

                mov al,0
                mov [bx],al
		sub bx,offset LevelData

                mov ax,127		; MX
                and ax,bx
                shr bx,7                ; MY

                sub ax,LineSize/2
                sub bx,RowSize/2

                mov byte Ptr MX, al
                mov byte Ptr MY, bl

                ;-------------------------------------------------------
		; A will be loading a small Routine, part of all
                ; COS x.0 based system, it purpose to find any creature
                ; and report it in the table of creature. Then the
                ; routine removes the creature from the maze.
		;-------------------------------------------------------
                call FindCreatures

		cmp byte Ptr NOA,0
                jne OkAtLessOneDetected

                mov dx,offset NoCreatureInMaze
                jmp SendErrorMessage

OkAtLessOneDetected:

                ;-------------------------------------------------------

		mov dx,Screen
                mov gs,dx
                call CLS


















;---------------------------------------------------------------------
           	;=====================================================
		;-----------------------------------------------------
                ; This is the magical routine imported from
                ; CS4LEVEL that I wrote yesterday. It will draw the
                ; Screen at lightening speed with all new features
                ; with ease to add such as animation.
		;-----------------------------------------------------
                ;=====================================================
;---------------------------------------------------------------------

DrawScreen:
                call CONVENSIONS

                ;--------------------------------------------------
		; It is time to make the creature fall when they
                ; should do so. Don't worry, this routine will as
                ; easy as the one I wrote to make the player fall
                ; a few lines below this one.
                ;---------------------------------------------------

                mov cl,byte ptr NOA
                mov ch,0

		mov bx,offset CCX

ScanFallCC:     ReadXyForCreature
               	GetSi

		mov al,es:[bx+256+512]
                cmp al,4
                je HappyInWater
                cmp al,5
                je HappyInWater

                mov al,[si+8192]
                and al,3
                cmp al,0
                jne DeadCreature

HappyInWater:   mov al,es:[bx+512+256]
		cmp al,6
                je NextCreatureForFall
                cmp al,7
                je NextCreatureForFall

		call IsFalling
                cmp al,1
                jne NextCreatureForFall

                inc dh
                call IsCreatureThere
                cmp al,0
                jne NextCreatureForFall

                ;inc dh
                mov es:[bx+256],dh

NextCreatureForFall:
		inc bx
                loop ScanFallCC
                jmp DoneWithTask

DeadCreature:   mov al,-1
		mov es:[bx+256+512],al
                jmp NextCreatureForFall

DoneWithTask:


		;-----------------------------------------------
                ; Do the clean-up, remove any dead creature from
                ; the level. Creature can die by falling in Acid,
                ; Water or Slime. Those creatures must be removed
                ; to prevent infection.
                ;-------------------------------------------------

                mov cl,byte ptr NOA
                mov ch,0
                mov si,offset CCX
                mov di,offset CCX

SeeIfNextOneIsDead:
                mov al,es:[si+512+256]
                cmp al,-1
                jne CCOk

                dec byte ptr NOA
                jmp ThisOneIsDead

CCOk:           cmp di,si
                je NoGarbageCollection

                mov al,es:[si]
                mov es:[di],al

                mov al,es:[si+256]
                mov es:[di+256],al

                mov al,es:[si+512]
                mov es:[di+512],al

		mov al,es:[si+512+256]
                mov es:[di+512+256],al

NoGarbageCollection:
                inc di
ThisOneIsDead:	inc si
		loop SeeIfNextOneIsDead

                ;--------------------------------------------------
		; Get Si for Player Position:
                ; This short part of the program, just a few lines
                ; below, is needed to setup the player's fall when
                ; he is requiered to be falling.
                ;--------------------------------------------------

		cmp byte ptr JumpFlag,1
                je IgnoreGravityForPly

                mov byte Ptr FallFlag,0

                mov dl,byte ptr MX
                mov dh,byte ptr MY

                mov al,dh
                mov ah,0
                add ax,RowSize/2
                shl ax,7
                or al,dl
                add ax,LineSize/2
		add ax,offset LevelData
                mov si,ax

		call IsFalling
                cmp al,0
                je PlyIsNotFalling

                add dl,LineSize/2
                add dh,RowSize/2
                inc dh

                call IsCreatureThere
                cmp al,1
                je PlyIsNotFalling

                inc byte Ptr MY
               	mov byte Ptr FallFlag,1

PlyIsNotFalling:
IgnoreGravityForPly:

		;-------------------------------------------------

                cmp byte ptr lifeforce,0
                jne IgnoreLF
            	mov byte Ptr Gameoverflag,1

IgnoreLF:       cmp Byte Ptr GameOverFlag,1
                jne IgnoreGOF

          	mov al,0
                mov byte ptr LifeForce,0
                mov byte ptr Oxygen,0

IgnoreGOF:
                mov dx,SCREEN
		mov gs,dx

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

                mov di,ActualTop
                mov dx,RowSize

R0to10:         push di
                push dx
                mov cx,LineSize

L0to20:         push cx
                mov bp,di

                mov bx,offset CS4GRAPH
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

                cmp byte Ptr CAnimation,1
                jne DrawBackGround
                mov al,[si+8192]
                and al,4
                cmp al,4
                je DrawBackGround
		add bx,100h

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

                mov bh,0
                mov bl,[si]
                cmp bl,128
                jb NOINVPROC
                mov bl,0

NOINVPROC:
                cmp bx,0
		je OUT222

                ;-----------------------------------

		cmp bl,48h
                jne NotTrans

                cmp byte ptr CAnimation,1
                jne NotTrans

                mov bx,offset CS4ANI+0ah*256
                jmp AltTransAni


		;-----------------------------------


NotTrans:	;and bl,127
                rol bx,8
                add bx,offset CS4GRAPH

AltTransAni:

		;***********************************************
                ; ** DRAW OBJ ON SCREEN SEQUENCE            ***
                ;***********************************************

                mov dx,16
DOBJ2:          mov cx,16/4
DOBJ1:

		mov eax,[bx]
                or ax,ax
                je _Seq1AX

                or al,al
                jne _Seq1AL
                mov al,gs:[di]

_Seq1AL:

                or ah,ah
                jne _Seq1AH
                mov ah,gs:[di+1]

_Seq1AH:	mov gs:[di],ax

_Seq1AX:	shr eax,16
                add di,2


                or ax,ax
                je _Seq2AX

                or al,al
                jne _Seq2AL
                mov al,gs:[di]

_Seq2AL:

                or ah,ah
                jne _Seq2AH
                mov ah,gs:[di+1]

_Seq2AH:	mov gs:[di],ax

_Seq2AX:        add di,2

FORGET0PIX:     add bx,4

                loop DOBJ1

                add di,140h-16
                mov cx,dx
                dec dx
                loop DOBJ2

                ;***************************************************
                ;
                ;***************************************************



OUT222:         mov di,bp
                pop cx
                inc si
                add di,16
                loop L0to20X

                pop dx
                pop di
                add di,0a00h*2
                add si,128-LineSize
                mov cx,dx
                dec dx
                loop R0to10X
		jmp DMRET

L0to20X:        jmp L0to20
R0to10X:        jmp R0to10

DMRET:

		; The computer must check if the player has moved.
                ; How is that done? This is done by checking the
                ; MoveFlag.

                cmp byte Ptr MoveFlag,1
                jne HasNotMove

                mov byte Ptr MoveFlag,0
                inc byte Ptr FrameFlag
                cmp byte Ptr FrameFlag,5
                jne HasNotMove
                mov byte Ptr FrameFlag,0

HasNotMove:

		; Lets draw the player onto the screen so we could see
                ; him. It will make him visible since his object
                ; counterpart has been erase by the handeling routine.


                mov dx,SIGNSEG
                mov es,dx
                mov dx,SCREEN
                mov gs,dx

                mov al,5
                mov ah,byte Ptr AimFlag
                mul ah
                add al,byte Ptr FrameFlag
                shl ax,8
                mov si,ax
                add si,offset PlayerFrames
                mov di,16*(LineSize/2)+ 2*0a00h*(RowSize/2)+ActualTop

                cmp byte ptr JumpFlag,1
                jne NotJumpingXyz
                sub di,0a00h/2

NotJumpingXyz:

		;cmp byte ptr FreezeFlag,1
                ;je WhitePly

                mov ah,0
                cmp CAnimation,1
                jne FlashingPly

                mov ah,255
                cmp PlayerFlash,1
                je FlashingPly
		mov ah,0
FlashingPly:
		mov dx,16
PlyLine2:       mov cx,16

PlyLine:        mov al,es:[si]
                cmp al,0
                je NulPixForPly
                xor al,ah
                mov gs:[di],al
NulPixForPly:	inc si
                inc di
                loop PlyLine

		add di,140h-16
                mov cx,dx
                dec dx
                loop PlyLine2
                jmp DiamScanRoutine

                ; Before providing the informations on screen about
                ; how many diamonds are left, I should first of all
                ; start counting them. So It's what I shall do.


DiamScanRoutine:
                mov si,offset LevelData
                mov cx,8192
                mov byte ptr Diamond,0

ScanMazeForDiam:mov al,[si]
                cmp al,6
                jne NoIncDiamondCount

                inc byte ptr Diamond
NoIncDiamondCount:inc si
		loop ScanMazeForDiam

                ; I belive that now, it is time to add a few new option
                ; to creat a wonderfull information about the game's
                ; status. I will the fallowing add-in.

                FramesExtender DiamondTxt+9, byte ptr Diamond
                FramesExtender RopeTxt+6,byte ptr Rope
                FramesExtender BulbTxt+6,byte Ptr Lightbulb

                ; Write "00000000" at GS:0000
                DrawSmallSSfs 0, offset Score, 14
                ; Write "Diamond Left" at GS:10*8
                DrawSmallSSfs 9*8, offset DiamondTxt, 7
                ; Write "Ropes 00" at GS: *8
                DrawSmallSSfs (9+12)*8, offset RopeTxt,15
                ; Write "Bulbs 00" at GS: ???
                DrawSmallSSfs (9+9+12)*8, offset BulbTxt,12

                ; Draw the color bar for Energy and Oxygen. These
                ; lines will be updated automaticaly. They are very
                ; usefull because they need to be looked at oftenly.

                cmp word ptr TriForceFlag,0
                jne Else123

                cmp byte ptr FreezeFlag,1
                je ElseAbc

                DrawLine 23*0a00h,byte Ptr LifeForce,2
                jmp ElseXyz

ElseAbc:	DrawLine 23*0a00h,byte ptr LifeForce,15
                DecMem FreezeFlagDelay,1
                cmp byte ptr FreezeFlagDelay,0
		jne ElseXyz
                mov byte ptr FreezeFlag,0

ElseXyz:        DrawLine 24*0a00h,byte Ptr Oxygen,7
		jmp Else456

Else123:	DrawLine 23*0a00h,byte Ptr LifeForce,13
                dec word ptr TriForceFlag
		jmp ElseXyz
Else456:


                ; ColorFulAnimation
                ColorFlow offset CS4GRAPH+ 6*256
                ColorFlow offset CS4GRAPH+ 0ch*256
                ColorFlow offset CS4GRAPH+ 0dh*256
                MoveUP	  offset CS4GRAPH+ 44h*256

                ; DysplayKeys when needed. This system is in need of
                ; being added that is why I will be adding it to the
                ; system. Right Here a few lines below:
		; DrawKey Destination,Source,Frame

                DrawKey 23*0a00h+32*8,KeyStatus,offset CS4GRAPH+1eh*256
                DrawKey 23*0a00h+32*8+16,KeyStatus+1,offset CS4GRAPH+20h*256
                DrawKey 23*0a00h+32*8+32,KeyStatus+2,offset CS4GRAPH+22h*256
                DrawKey 23*0a00h+32*8+48,KeyStatus+3,offset CS4GRAPH+24h*256

                ; When the game is over, because the game is usually
                ; over we must draw the game over sign onto the screen
                ; to make it official.

                cmp byte ptr GameOverFlag,1
                jne NotGameOver

                call DrawGameOverSign



NotGameOver:

		; Now I will be taking care of any jumping folk
                ; how will need to get back down on his feets.
                ; That Procedure is crutial to make everything ok
                ; when jumping.

                cmp byte Ptr JumpFlag,1
                jne NotJumpingOk

                mov byte ptr JumpFlag,0
                cmp byte ptr AimFlag,3
                je AimingRg

                dec byte Ptr Mx
                jmp NotJumpingOk

AimingRg:	inc byte Ptr Mx
NotJumpingOk:

		;------------------------------------------------------
		; It is about time to draw the creature onto the screen
                ; but I'm not sure whether or not, I should do so right
                ; now. The creatures' module along with all creatures
                ; related routines are always the hardest to write and
                ; to debug.
		;-----------------------------------------------------

                call Convensions
                mov dx,Screen
                mov gs,dx
                mov dx,SignSeg
                mov es,dx

             	mov al,byte ptr NOA
                mov ah,0
                add ax,offset CCX
                mov bp,ax

                mov si,offset CCX
DrawIfNeeded:   mov al,es:[si]
                sub al,byte Ptr MX
                cmp al,LineSize
                jae NotOnScreen
                mov ah,0
                mov di,ax
                rol di,4		; DI=CCX*16

                mov al,es:[si+256]
                sub al,byte Ptr MY
                cmp al,RowSize
                jae NotOnScreen
                mov ah,0ah*2
                mul ah
                rol ax,8
                add di,ax		; DI= CCX*16+CCY*0a00h*2

                mov al,es:[si+256+512]
                cmp al,3
                jbe BXCos1_Creatures

                cmp al,4
                je BXLFish
                cmp al,5
                je BXRFish
                cmp al,6
                je BXPlatForm
                cmp al,7
                je BXPlatForm
                cmp al,8
                je BXDeadlyPlant
                cmp al,9
                je BXChangeLink9

BXCos1_Creatures:
		mov bx,offset CS4ANI+10h*256
                mov ah,0
                rol ax,8
                add bx,ax
BXaddOn:        cmp byte Ptr CAnimation,1
                jne DisplayActor
                add bx,7*256
                jmp DisplayActor

BXLFish:	mov bx,offset CS4ANI+0eh*256
		jmp DisplayActor

BXRFish:	mov bx,offset CS4ANI+0fh*256
		jmp DisplayActor

BXPlatForm:	mov bx,offset CS4ANI+0dh*256
		jmp DisplayActor

BXChangeLink9:	mov bx,offset CS4ANI+14h*256
		jmp BXaddOn

BXDeadlyPlant:  mov bx,offset CS4ANI+0bh*256
		cmp byte ptr CAnimation,1
                jne DisplayActor
                add bx,256
                jmp DisplayActor

DisplayActor:   add di,0a00h
		mov dx,16
DA2:		mov cx,16
DA1:            mov al,[bx]
                cmp al,0
                je NulPixelForDA
                mov gs:[di],al

NulPixelForDa:	inc bx
                inc di
		loop DA1

                add di,140h-16
    		mov cx,dx
                dec dx
                loop DA2

NotOnScreen:    inc si
		cmp si,bp
                jne DrawIfNeeded

                ;----------------------------------------------------
		; The fallowing sequence of lines redraws the screen
                ; from the buffer to the video memory. It is the
                ; routine that makes all the modifications visible
                ; after they have been done.
                ;-----------------------------------------------------

                call Convensions
                cmp byte Ptr RedrawMode,0
                je NormalRedraw

                dec byte Ptr RedrawMode
                call DrawSomeScreen
                call Convensions
                jmp ToMainLoop

NormalRedraw:   cmp byte Ptr ScreenFlash,1
		je FlashRedraw
NormalRedraw2:	call Redraw_Screen
                jmp ToMainLoop

FlashRedraw:    cmp byte ptr GameOverFlag,1
		je NormalRedraw2

		mov dx,SCREEN
		mov fs,dx
                mov dx,0a000h
                mov gs,dx

		mov byte Ptr ScreenFlash,0
		mov cx,(0a00h*22)/4
		mov di,0a00h
FRedraw:	mov eax,fs:[di]
                xor eax,0f0f0f0fh
                mov gs:[di],eax
                add di,4
                loop FRedraw

		mov cx,(0a00h*2)/4
NRedrawForF:	mov eax,fs:[di]
		mov gs:[di],eax
                add di,4
                loop NRedrawForF

		mov cx,(0a00h)/4
		mov di,0
NRedrawForF2:	mov eax,fs:[di]
		mov gs:[di],eax
                add di,4
                loop NRedrawForF2




ToMainLoop:
		;----------------------------------------------------
                ; Did you pickup all the diamonds? If so, your up
                ; for the next level. If not, then you'll stay
                ; here a bit longer.
		;----------------------------------------------------

                call Convensions
                cmp byte Ptr Diamond,0
                je MoveupToNextLevel

		;-------------------------------------------------------
		; This is the main loop for the Game Module. This small
                ; sequence is the coordinator upon wich this module is
                ; syncronise. That is an invention that I alwayed use
                ; but never to this extend before CS3.
                ;-------------------------------------------------------

MainLoop:       inc byte Ptr GameModulator
		cmp byte Ptr GameModulator,5
                jne NoNeedToRedraw
                mov byte Ptr GameModulator,0
                jmp DrawScreen

NoNeedToRedraw:
                mov al,byte Ptr GameModulator
                cmp al,2
                je CreatureModule
                cmp al,1
                je PlayerModule
                jmp MainLoop

CreatureModule:	inc byte Ptr CAniDelay
		cmp byte Ptr CAniDelay,3
                jne NoCAniChange
                mov byte Ptr CAniDelay,0

		mov al,byte Ptr CAnimation
		xor al,1
                mov byte Ptr CAnimation,al
                call COS3_0

NoCAniChange:
		jmp MainLoop


PlayerModule:   call Getax
                call Convensions

	 	cmp byte Ptr GameOverFlag,1
		je GameOverHandler

                mov dl,byte PTR MX
                mov dh,byte PTR MY

                mov bp,ax
                mov al,dh
                mov ah,0
                add ax,RowSize/2
                shl ax,7
                or al,dl
                add ax,LineSize/2
		add ax,offset LevelData
                mov si,ax

                ; Experimental Solution
                cmp byte Ptr JumpFlag,1
                je ByPassSolution
                mov al,[si]
                mov byte Ptr PV,al
                mov al,[si+8192]
                mov byte Ptr Hpv,al

ByPassSolution: mov al,byte Ptr HPv
                and al,3
                cmp al,0
                je NoWaterSlimeOrLava

                cmp al,2
                jae SlimeOrLava
                mov al,byte Ptr HPv
                and al,4
                cmp al,4
		jne NoWaterSlimeOrLava

                cmp byte ptr CAniDelay,1
                jne NoWaterSlimeOrLava

		DecMem Oxygen,1
                cmp byte ptr Oxygen,0
                jne NoWaterSlimeOrLava

                DecMem LifeForce,1
		mov byte Ptr ScreenFlash,1
                jmp NoWaterSlimeOrLava

SlimeOrLava:	mov byte Ptr GameOverFlag,1

NoWaterSlimeOrLava:
		mov al,byte ptr [si+8192]
		and al,7
                cmp al,1
                ja NoOxygenAdd

                cmp byte ptr CAnimation,1
                jne NoOxygenAdd

                cmp byte ptr Oxygen,32
                jae NoOxygenAdd
                IncMem Oxygen,1

NoOxygenAdd:


                ; If PV>127 then Ignore trigger attributes
		mov al,byte Ptr Pv
                cmp al,128
                jae NoAttributes
                cmp al,48h
                je NoAttributes
                cmp al,49h
                je NoAttributes

                cmp al,0eh
                jb Trigger
                cmp al,1bh
                je Trigger
                jmp below15h


Trigger:        ; Load the Trigger attributes in AL
                mov al,byte Ptr HPv
                shr al,3
                cmp al,1
                jbe NoAttributes
                shl al,3

                call AttributeHandlers

below15h:
NoAttributes:

		; Generic Objects Handlers

		mov al,byte PTR PV
                cmp al,03
                je LightBulbHandler
                cmp al,05
                je ChestHandler
                cmp al,06
                je DiamondHandler
                cmp al,07
                je NecklessHandler
                cmp al,08
                je RopeHandler
                cmp al,0ah
		je FlowerHandler
                cmp al,0bh
                je BottleHandler
                cmp al,0ch
                je TriForceHandler


                cmp al,17h
                je OnScrewHandler
                cmp al,19h
                je OffScrewHandler

                cmp al,1bh
		je MagicBoxHandler

                cmp al,1eh
                je KeyHandler
                cmp al,20h
                je KeyHandler
                cmp al,22h
                je KeyHandler
                cmp al,24h
                je KeyHandler

                cmp al,39h		; Breakable Bridge Handler
                jb Xyz94a
                cmp al,43h
                ja Xyz94a
		jmp BBridgeHandler

Xyz94a:
                cmp al,46h
                je DrainTrapHandler
                cmp al,47h
                je FreezeTrapHandler
                cmp al,48h
                je TransporterHandler
                jmp PlyMoveModule

;------------------------------------------------------------

TransporterHandler:
                mov cx,8192

                mov ah,byte ptr HPV
                and ah,255-7

                mov si,offset LevelData

ScanNextLocation:
		mov al,[si]
                cmp al,49h
                jne NotDestination

                mov al,[si+8192]
                and al,255-7
                cmp al,ah
		je FoundDestination

NotDestination: inc si
		loop ScanNextLocation

                mov dx,offset TDestination
                jmp SendErrorMessage

FoundDestination:
                sub si,offset LevelData
		mov ax,si
                and ax,127
                sub ax,LineSize/2
                mov byte ptr MX,al

                mov ax,si
                shr ax,7
                sub ax,RowSize/2
                mov byte ptr MY,al
		jmp ExtraHandlers

;------------------------------------------------------------

TriForceHandler:AddToScore 250
		IncMem LifeForce, 20
                mov word ptr TriforceFlag,250
                BlankObj
                jmp ExtraHandlers

;-------------------------------------------------------------

DrainTrapHandler:
                BlankObj
                ; This will enable temporate invisibility
                cmp word ptr TriForceFlag,0
                jne ExtraHandlers

                mov byte ptr ScreenFlash,1
		DecMem Lifeforce, 12
                jmp ExtraHandlers


FreezeTrapHandler:
                BlankObj
                ; This will enable temporate invisibility
                cmp word ptr TriforceFlag,0
                jne ExtraHandlers

                mov byte ptr ScreenFlash,1
		mov byte ptr FreezeFlag,1
                mov byte ptr FreezeFlagDelay,100
		jmp ExtraHandlers

;-----------------------------------------------------------

MagicBoxHandler:AddToScore 50
                BlankObj
                jmp ExtraHandlers

;------------------------------------------------------------
BBridgeHandler: inc al
		cmp al,44h
                jne NotBlankBridge
                mov al,0
NotBlankBridge: mov [si],al
                mov byte ptr PV,al
                jmp ExtraHandlers

;-------------------------------------------------------------
OnScrewHandler: cmp byte ptr LightBulb,0
		je DeadlyXyz
                jmp offScrewHandler
DeadlyXyz:      mov byte ptr GameOverFlag,1
		jmp MainLoop

OffScrewHandler:cmp byte ptr LightBulb,0
		je ExtraHandlers
                dec byte ptr LightBulb

		inc al
		mov [si],al
                jmp ExtraHandlers

KeyHandler:     AddToScore 25
		sub al,1eh
		shr al,1
                mov ah,0

                mov di,offset KeyStatus
                add di,ax
                mov al,1
                mov [di],al

                BlankObj
                jmp ExtraHandlers


DiamondHandler:	AddToScore 10
		IncMem LifeForce, 3
                BlankObj
                jmp ExtraHandlers

ChestHandler:	AddToScore 50
		BlankObj
                jmp ExtraHandlers

NecklessHandler:AddToScore 15
		IncMem LifeForce, 8
                BlankObj
                jmp ExtraHandlers

FlowerHandler:  AddToScore 5
		IncMem LifeForce, 2
                BlankObj
                jmp ExtraHandlers

BottleHandler:  AddToScore 5
		IncMem Oxygen, 32
                BlankObj
                jmp ExtraHandlers

LightBulbHandler: AddToScore 20
		Inc byte Ptr LightBulb
                BlankObj
                jmp ExtraHandlers

RopeHandler:	AddToScore 20
		Inc byte Ptr Rope
                BlankObj
                jmp ExtraHandlers

;------------------------------------------------------------
ExtraHandlers:
;------------------------------------------------------------

PlyMoveModule:	mov ax,bp
                cmp al," "
                je PauseHandler
                cmp ah,61
                je EraseHighs

                cmp byte ptr FreezeFlag,1
                je PlyCtrlOut

MoveHandler:	cmp al,"8"
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

                cmp al,"q"
                je JumpLeft
                cmp al,"w"
                je JumpRight

                cmp al,"7"
                je JumpLeft
                cmp al,"9"
                je JumpRight

                cmp al,"z"
                je ManualTrigger
PlyCtrlOut:    	cmp al,"`"
               	je SETGAMEOVER
                cmp al,"!"
                je MoveUpToNextLevel
		cmp al,"r"
                jne MainLoop

                call Convensions
                mov byte Ptr MX,0
                mov byte Ptr MY,0
                jmp LoadIntroLib

                ;------------------------------------------------

ManualTrigger:	mov al,byte Ptr Pv
		cmp al,15h
                je ElectricSwitch; UP

                cmp al,16h
                je ElectricSwitch; DN

                cmp al,10h
                je LeftPoulie
                cmp al,12h
                je RightPoulie

		cmp al,1ch
                je Left2
                cmp al,1dh
                je Right2
                jmp MainLoop

;--------------------------------------------------------------------
Left2:          inc byte Ptr Rope
		mov al,10h
		mov [si],al

                mov bx,si
                dec bx

                mov al,[bx]
                cmp al,0fh
                jne MainLoop
                mov al,0
                mov [bx],al

AL2:            add bx,128
                mov al,[bx]
                cmp al,11h
                jne MainLoop
                mov al,0
                mov [bx],al
                jmp AL2

Right2:
		inc byte Ptr Rope
		mov al,12h
		mov [si],al

                mov bx,si
                inc bx

                mov al,[bx]
                cmp al,13h
                jne MainLoop
                mov al,0
                mov [bx],al

AR2:            add bx,128
                mov al,[bx]
                cmp al,14h
                jne MainLoop
                mov al,0
                mov [bx],al
                jmp AR2

                ;------------------------------------------------------
LeftPoulie:	cmp byte ptr Rope,0
		je MainLoop

		dec byte Ptr Rope
		mov al,1ch	; Left & Rope
		mov [si],al
		mov bx,si
		dec bx

                mov al,[bx]
                cmp al,0
                jne MainLoop

		mov al,0fh	; Rope <- Poulie
                mov [bx],al

lower_lf:       add bx,128
                mov al,[bx]
                cmp al,0
                jne MainLoop

                mov al,11h
                mov [bx],al
                jmp Lower_LF

RightPoulie:	cmp byte ptr Rope,0
		je MainLoop

		dec byte Ptr Rope
		mov al,1dh	; Left & Rope
		mov [si],al
		mov bx,si
		inc bx

                mov al,[bx]
                cmp al,0
                jne MainLoop

		mov al,13h	; Rope <- Poulie
                mov [bx],al

lower_rg:       add bx,128
                mov al,[bx]
                cmp al,0
                jne MainLoop

                mov al,14h
                mov [bx],al
                jmp Lower_RG

                jmp MainLoop



ElectricSwitch: cmp al,15h
		jne HighNumXyz
                inc al
                jmp PushOrPull
HighNumXyz:	dec al
PushOrPull:	mov [si],al
		mov byte ptr PV,al

                mov al,[si+8192]
                and al,255-7
                call AttributeHandlers
                jmp MainLoop

UP:             mov bl,0
		dec dh
		sub si,128
                jmp TryWalking

DN:             mov bl,0
		inc dh
		add si,128
		jmp TryWalking

LF:             mov bl,2
		dec dl
		dec si
                jmp TryWalking

RG:             mov bl,3
		inc dl
		inc si
                jmp TryWalking

TryWalking:	call CommonHalts
                cmp al,1
                je MainLoop

                call DoorsHalts
		cmp al,1
                je MainLoop

                push dx
                add dl,LineSize/2
                add dh,RowSize/2
                call IsCreatureThere
                cmp al,1
                je CreatureThere
		pop dx

                mov byte PTR MX,dl
                mov byte PTR MY,dh
                mov byte PTR AimFlag,bl
                mov byte Ptr MoveFlag,1
                and byte ptr PlayerFlash,0

                mov al,[si]
                mov byte Ptr Pv,al
                mov al,[si+8192]
                mov byte Ptr HPv,al
		jmp MainLoop

CreatureThere:	pop dx
		jmp MainLoop

                ;--------------------------------------------
                ; AL=0 can Walk
                ; AL=1 cannotWalk

CommonHalts:	mov al,1
		mov ah,[si]

                cmp ah,1
                je CannotX
                cmp ah,44h
                je CannotX

                cmp ah,26h
                jb N1aX
                cmp ah,2fh
                ja N1aX
                jmp Cannotx

N1aX:		mov al,0
Cannotx:	ret

DoorsHalts:	mov al,[si]
                cmp al,1fh
                je IsDoor
                cmp al,21h
                je IsDoor
                cmp al,23h
                je IsDoor
                cmp al,25h
                je IsDoor
                jmp N1aX

IsDoor:         push bx
		sub al,1fh
		mov ah,0
                shr ax,1
                add ax,offset KeyStatus
                mov bx,ax
                mov al,[bx]
                xor al,1
                pop bx
                ret




		;-----------------------------------------

AttributeHandlers:
		pusha
                and al,255-7
                cmp al,1
                jbe OutAH

                mov cx,8192
		mov si,offset LevelData
ScanNextAttrib: mov ah,[si+8192]
                and ah,255-7
                cmp al,ah
                je AttributeAplication

GoToNext:       inc si
                loop ScanNextAttrib
                ; Check If creatures have appeared...
                call FindCreatures
OutAH:          popa
                ret

AttributeAplication:
		mov ah,[si]
                cmp ah,byte Ptr Pv
		je GotoNext

                cmp ah,128
                jae ActivateItem

                cmp ah,15h
                je InvBit0
                cmp ah,16h
                je InvBit0

                cmp ah,17h
                je OnXX1
                cmp ah,18h
                je OnXX1

                cmp ah,19h
                je OffXX1
                cmp ah,1ah
                je offXX1
XX1:

		cmp ah,44h
                je HandleForceFieldTrigger

		mov ah,0
		mov [si],ah
                mov ah,[si+8192]
                and ah,7
                mov [si+8192],ah

                jmp GoToNext

HandleForceFieldTrigger:
		or ah,128
HFFT:           mov [si],ah
                jmp GotoNext

ActivateItem:	and ah,127
                cmp ah,44h
                je HFFT
		mov [si],ah
                mov ah,[si+8192]
                and ah,7
                mov [si+8192],ah
                jmp GoToNext

InvBit0:	cmp ah,15h
		jne IA
                inc ah
                jmp IB
IA:		dec ah
IB:		mov [si],ah
                jmp GoToNext

OnXX1:		add ah,2
		mov [si],ah
                jmp GoToNext

OffXX1:		sub ah,2
		mov [si],ah
                jmp GotoNext


;--------------------------------------------------------

		; AL=0 -> Isn't Falling
		; AL=1 -> Is falling

IsFalling:	mov al,0
        	mov ah,[si+128]

                cmp ah,1	; Brick
                je NotFalling
                cmp ah,6	; Diamond
                je NotFalling
                cmp ah,0eh   	; Ladder
                je NotFalling
                cmp ah,15h	; Switch
                je NotFalling
                cmp ah,16h  	; Switch
                je NotFalling

		cmp ah,1fh	; Doors
                je NotFalling
                cmp ah,21h
                je NotFalling
                cmp ah,23h
                je NotFalling
                cmp ah,25h
                je NotFalling

                cmp ah,26h	; Custom Bricks
                jb XIF1
                cmp ah,2fh
                ja XIF1
                jmp NotFalling

XIF1:		cmp ah,35h	; Root
		je NotFalling
                cmp ah,36
                je NotFalling

                mov ah,[si]
                cmp ah,128
                jae ByPassNF
                cmp ah,45h
                je ByPassNF
                cmp ah,49h
                je ByPassNF


                cmp ah,0
		jne NotFalling
ByPassNF:

                mov ah,[si+8192] ; In water
                and ah,3
                cmp ah,0
                jne NotFalling

                mov ah,[si+128+8192]
                and ah,7
                cmp ah,1+4
                je NotFalling

                mov al,1
NotFalling:     ret


SetGameOver:	mov byte Ptr GameOverFlag,1
                mov byte Ptr LifeForce,0
                mov byte Ptr Oxygen,0
		jmp MainLoop


GameOverHandler:cmp ax,0
		je MainLoop
                jmp HighScores

		;----------------------------------------------------
                ;----------------------------------------------------

MoveUpToNextLevel:
		call Convensions
		Inc byte PTR Current_Level
                Inc byte ptr AtLevel
		FramesExtender Level_cs4, byte PTR Current_level
                FramesExtender LEVEL     ,byte ptr AtLevel
                cmp byte Ptr LifeForce,64
                jae NoProblemXyz
                mov byte Ptr lifeforce,64
NoProblemXyz:

		AddToScore 900

JumpToLevel:    mov dx,TextSeg
                mov fs,dx
                mov bx,word ptr NameOffset
                mov al,fs:[bx]
                cmp al,-1
		je DDManager

                mov byte ptr MX,0
                FramesExtender LevXX+3,byte ptr Current_level
                mov cx,2
                call LoadRoom
		call Draw_Screen
                call Convensions

                mov dx,TextSeg
                mov fs,dx

                mov bx,word ptr NameOffset
ScanString:     mov al,fs:[bx]
                cmp al,-1
                je DDManager
                cmp al,0
                je EndOfString
                inc bx
		jmp ScanString

EndOfString:    mov si,word ptr NameOffset
		inc bx
                mov word ptr NameOffset,bx

                mov di,140h*32+12*0a00h
                add di,cx
                call JULIEJEAN94

                mov bx,word ptr NameOffset
ScanString2:    mov al,fs:[bx]
                cmp al,-1
                je DDManager
                cmp al,0
                je EndOfString2
                inc bx
		jmp ScanString2

EndOfString2:   mov si,word ptr NameOffset
		inc bx
                mov word ptr NameOffset,bx

                mov di,64*140h+12*0a00h
		call JULIEJEAN94

                call DRAWLEVELXXSIGN
                call DrawSomeScreen
                mov cx,75
                call Pause

		jmp EntryToNextLevel

JULIEJEAN94:    push cx
		push di
JulieJean94x:	mov al,fs:[si]
                cmp al,0
                je SKIPDBSIGNS2
                call DBSIGNS
                inc si
                add di,16
                jmp JULIEJEAN94x
SKIPDBSIGNS2:   inc si
		pop di
                pop cx
		ret

                ;---------------------------------------------------

DDManager:	call Convensions
		cmp byte ptr GameMode,2
                jae HighScores

		inc byte ptr GameMode
                cmp byte ptr GameMode,1
                je DDAdvance

                mov al,"v"
		jmp SetNewMode

DDAdvance:	mov al,"a"

SetNewMode:	mov byte ptr LevXX+2,al
                mov byte ptr LevXX_cs4+2,al

                mov byte ptr LifeForce,64
                mov byte ptr Current_Level,1
                ;inc byte ptr AtLevel
                mov word ptr NameOffset,offset NameTxt

		FramesExtender Level_cs4, byte PTR Current_level
                FramesExtender LEVEL     ,byte ptr AtLevel

                ; Chargement de Easy.Mss
                mov dx,data
                mov ds,dx
                mov dx,TextSeg
                mov es,dx
                mov bx,offset NameTxt
                mov cx,LevelNameSize

                mov al,byte ptr GameMode
                cmp al,0
                je LoadEasyTxt2
                cmp al,1
                je LoadAdvanceTxt2
                mov dx,offset EXPERT_MSS
                jmp LoadItNow2

LoadEasyTxt2:	mov dx,offset EASY_MSS
		jmp LoadItNow2

LoadAdvanceTxt2:mov dx,offset Advance_mss

LoadITNow2:     call LoadNew
		call RecriptLevelName
                call Convensions
                jmp JumpToLevel

		;---------------------------------------------------

RecriptLevelName:

		pusha
		mov dx,TextSeg
                mov es,dx

		mov si,offset NameTxt
                mov di,offset NameTxt

ScanToCript:    mov al,es:[si]
                cmp al,"*"
                je EndToRecript
                cmp al,13
                je PassTwo

                cmp si,di
		je NoNeedToCopy

Copy:           mov es:[di],al

NoNeedToCopy:   inc si
                inc di
                jmp ScanToCript

PassTwo:	mov al,0
		inc si
                jmp Copy


EndToRecript:   mov al,-1
		mov es:[di],al
                popa
		ret
















;----------------------------------------------------------------------
;**********************************************************************
;----------------------------------------------------------------------

JumpLeft:       mov al,"4"
		cmp byte Ptr FallFlag,1
		je MoveHandler

		mov bx,si
                dec si
		call CommonHalts
                cmp al,1
                je MainLoop
                call DoorsHalts
                cmp al,1
                je MainLoop

                dec si
		call CommonHalts
                cmp al,1
                je WalkLeft
                call DoorsHalts
                cmp al,1
                je WalkLeft

		mov byte Ptr JumpFlag,1
WalkLeft:       dec byte Ptr MX
                mov byte Ptr MoveFlag,1
                mov byte Ptr PlayerFlash,0
                mov byte Ptr AimFlag,2
                jmp MainLoop

                ;----------------------------------------------
                ;----------------------------------------------
JumpRight:      mov al,"6"
		cmp byte Ptr FallFlag,1
		je MoveHandler

		mov bx,si
                inc si
		call CommonHalts
                cmp al,1
                je MainLoop
                call DoorsHalts
                cmp al,1
                je MainLoop

                inc si
		call CommonHalts
                cmp al,1
                je WalkRight
                call DoorsHalts
                cmp al,1
                je WalkRight

		mov byte Ptr JumpFlag,1
WalkRight:      Inc byte Ptr MX
                mov byte Ptr MoveFlag,1
                mov byte Ptr PlayerFlash,0
                mov byte Ptr AimFlag,3
                jmp MainLoop

		;-------------------------------------------

FindCreatures:  pusha
                call Convensions
		mov dx,SIGNSEG
		mov es,dx

		mov al,byte ptr NOA
                mov ah,0
                add ax,offset CCX
                mov di,ax

                mov cx,8192
		mov si,offset LevelData
ScanTheEntireMaze:
		mov al,[si]
                cmp al,4ah
                jae MaybeCreature
NextCrea:       inc si
                loop ScanTheEntireMaze
                popa
                ret

MaybeCreature:

		; Deadly Plant [8]
		mov ah,8
		cmp al,4ah
		je AddCreature

                ; Jelly Fish [4]
                mov ah,4
                cmp al,4bh
                je AddCreature

                ; Change Link [9]
                mov ah,9
                cmp al,4ch
                je AddCreature

                ; Routine To handle Worm to be added

                ; Platform UP/DN [7]
                mov ah,7
                cmp al,4eh
                je AddCreature

                ; Platform LF/RG [6]
                mov ah,6
                cmp al,4fh
                je AddCreature

                ; .IF value>5bh then NotACreature
                cmp al,5bh
                ja NextCrea

                mov ah,0
                sub al,50h
ChkForMatch:    cmp al,2
                jbe Match
                inc ah
		sub al,3
                jmp ChkForMatch

AddCreature:    ;Delete Creature From Maze
		mov al,0
AddC:		mov [si],al

                ;Check Table (To chk if not filled)
                cmp di,offset CCX+256
                jae NextCrea

                Inc byte Ptr NOA
                mov bx,si
                sub bx,offset LevelData
                and bx,127
                mov es:[di],bl			; CCX
                mov bx,si
                sub bx,offset LevelData
                shr bx,7
                mov es:[di+256],bl		; CCY
                mov al,1
                mov es:[di+512],al		; CCA
                mov es:[di+512+256],ah		; CCF
                inc di
                jmp NextCrea

Match:		cmp al,0
		je AddCreature
                cmp al,1
                je WithABridge
		mov al,0eh
                jmp AddC

WithABridge:	mov al,38h
		jmp AddC


                ;--------------------------------------------------
                ;--------------------------------------------------
		;--------------------------------------------------
                ; COS 3.0
                ; This routine will handle all the creatures along
                ; with a mouvements and special features belonging
                ; to them.
                ;--------------------------------------------------
                ;--------------------------------------------------
                ;--------------------------------------------------

COS3_0:         call Convensions
		mov dx,SignSeg
                mov es,dx

		mov al,byte Ptr NOA
		mov ah,0
                add ax,offset CCX
                mov bp,ax

                mov bx,offset CCX
DoNextOne:      mov dl,es:[bx]		; dl=CCX
                mov dh,es:[bx+256]	; dh=CCY

                mov al,es:[bx+512]
		mov ah,0
                dec al
                shl ax,2
                mov si,ax
                add si,offset COSTABLE

                mov al,es:[bx+256+512]
                cmp al,3
                jbe EmulateCOS1_0
                cmp al,5
                jbe FishFromCOS2_0

                cmp al,6
                je PlatformLRCOS2_0
                cmp al,7
                je PlatformUDCOS2_0

                cmp al,8
                je DeadlyPlantFromCOS1_0

                cmp al,9
                je ChgLink9COS3

                jmp EmulateCOS1_0

		;----------------------------------------------------
;--------------------------------------------------------------------

ChgLink9COS3:	mov al,byte ptr MX
		add al,LineSize/2
                mov ah,byte ptr MY
                add ah,RowSize/2

                mov ch,1
                cmp al,dl		; ChgLink9 XPOS= MX+LineSize/2
                je C9CCXMX

                mov ch,2
                cmp ah,dh 		; ChkLink9 YPOS= MY+RowSize/2
                je C9CCYMY
                jmp EmulateCOS1_0	; NoMatchFound

		;--------------------------
C9CCXMX:	sub ah,dh
                cmp ah,127
                ja C9DeeperY

                mov cl,3
RegisterC9Y:    mov es:[bx+512],cl
                call ChkDirForCC
                cmp al,1
                jne EmulateCOS1_0
                jmp NextCreatureToMove

C9DeeperY:	mov cl,1
		jmp RegisterC9Y

                ;----------------------------
C9CCYMY:	sub al,dl
                cmp al,127
                ja C9DeeperX

                mov cl,2
RegisterC9X:    mov es:[bx+512],cl
                call ChkDirForCC
                cmp al,1
                jne EmulateCOS1_0
                jmp NextCreatureToMove

C9DeeperX:	mov cl,4
		jmp RegisterC9X
		;----------------------------



;---------------------------------------------------------------------

		;------------------------------------------
                ;------------------------------------------
                ; BX -> CCX
                ; Dl,Dh X,Y
                ;------------------------------------------
                ;------------------------------------------

;------------------------------------------------------------------------
EmulateCOS1_0:  mov cx,4
ChkNextDir:     push cx
		mov cl,[si]
		call ChkDirForCC
                pop cx
                cmp al,1
                je XXX94
		inc si
		loop ChkNextDir

XXX94:		call EnergyDrainHandler
		jmp NextCreatureToMove

		;-----------------------------------------
                ;*****************************************
                ;-----------------------------------------

PlatFormUDCOS2_0:

		mov cl,es:[bx+512]		; Cl= Aim
                cmp cl,1			; .If Up then
                je PlatUpHandler		;  goto a special hanlder

                call ChkDirForCC
                cmp al,1
                je TestMovingDown

BetterLuckNextTime:
                xor cl,2
                mov es:[bx+512],cl
                jmp NextCreatureToMove

TestMovingDown:	mov al,byte ptr MX
                add al,LineSize/2
		mov ah,byte ptr MY
		add ah,(RowSize/2)+1

                cmp al,dl
                jne PlyNotOnTop1
                cmp ah,dh
                jne PlyNotOnTop1

                inc byte ptr MY
PlyNotOnTop1:   jmp NextCreatureToMove

PlatUpHandler:  call ChkDirForCC
		cmp al,1
                jne BetterLuckNextTime

		mov al,byte ptr MX
		add al,LineSize/2
                mov ah,byte ptr MY
                add ah,(RowSize/2)+1

                cmp al,dl
                jne PlyNotOnTop1
                cmp ah,dh
                jne PlyNotOnTop1

                ; Correction to Jumping Bug on LEV01.CS4
                cmp byte ptr JumpFlag,0
                jne PlyNotOnTop1

		mov al,dh
                sub al,2
                mov ah,0
                shl ax,7		; (dh-2)*128
                or al,dl		; (dh-2)*128+dl
                mov si,ax
                add si,offset LevelData
                call CommonHalts
                cmp al,1
                je PlyNotMovingUp

                sub dh,2
                call IsCreatureThere
                cmp al,1
                je PlyNotMovingUp

                dec byte ptr MY
                jmp NextCreatureToMove

PlyNotMovingUp:	mov al,byte ptr es:[bx+256]
                inc al
                mov byte ptr es:[bx+256],al
		jmp BetterLuckNextTime
		;----------------------------------------------------
                ;----------------------------------------------------



                ;----------------------------------------------------
		;----------------------------------------------------

PlatFormLRCOS2_0:

                mov al,es:[bx+512]
                and al,1
                cmp al,1
                jne DirOkPLF

                mov al,2
                mov es:[bx+512],al

DirOkPLF:	mov cl,es:[bx+512]
		call ChkDirForCC
                cmp al,1
                je MoveAlong1

                xor cl,6
                mov es:[bx+512],cl
                ;call ChkDirForCC
                ;cmp al,1
                ;je MoveAlong1
                jmp NextCreatureToMove

MoveAlong1:	mov al,byte ptr MX
		add al,linesize/2
                mov ah,byte ptr MY
                add ah,RowSize/2

                inc ah
                cmp al,dl
                jne NextCreatureToMove
                cmp ah,dh
                jne NextCreatureToMove

                ; Correction to Jumping bug on LEV01.CS4
                cmp byte ptr JumpFlag,0
                jne NextCreatureToMove

                mov al,es:[bx]
                sub al,LineSize/2
                mov byte ptr MX,al
		jmp NextCreatureToMove

		;--------------------------------------------------------

DeadlyPlantFromCOS1_0:
                call EnergyDrainHandler
		jmp NextCreatureToMove

FishFromCOS2_0: mov cx,4
ChkNextDir2:    push cx
		mov cl,[si]
		call ChkDirForCC
                cmp al,1
                je FishMoveHandler
                pop cx
		inc si
		loop ChkNextDir2
	        jmp XXX94

FishMoveHandler:
		cmp cl,4
                je FishRg
                cmp cl,2
                je FishLf
SameDir:	pop cx
		jmp XXX94

FishRg:		mov al,5
		mov es:[bx+512+256],al
                jmp SameDir

FishLf:		mov al,4
		mov es:[bx+512+256],al
                jmp SameDir

NextCreatureToMove:inc bx
                 cmp bx,bp
                 jne DoNextOne
                 ret





















		;----------------------------------------------------
                ;****************************************************
                ;----------------------------------------------------
ChkDirForCC:
		push dx
                push si

		cmp cl,1
                je UP_
                cmp cl,2
                je RG_
                cmp cl,3
                je DN_

LF_:		dec dl
		jmp TryMovingCC
UP_:		dec dh
		jmp TrymovingCC
RG_:		inc dl
		jmp TryMovingCC
DN_:		inc dh
		jmp TryMovingCC

TryMovingCC:    mov al,dh
                mov ah,0
                shl ax,7		; AX=CCY*128
                or al,dl		; AX=CCY*128+CCX
                mov si,ax		; SI=CCY*128+CCX
                add si,offset LevelData

                call CommonHalts
                cmp al,0
                jne CannotMoveThereCC

                call IsDoorCC
                cmp al,1
                je CannotMoveThereCC

                call RespectStops
		cmp al,0
                je CannotMoveThereCC

                mov ah,es:[bx+256+512]
                cmp ah,6
                je PlatFormsCannotFall
                cmp ah,7
                je PlatFormsCannotFall

                call IsFalling
                cmp al,1
                je CannotMoveThereCC
                jmp OthersFall
PlatFormsCannotFall:

		cmp ah,7
                jne OthersFall

                mov ah,es:[bx+512]
                cmp ah,1
                je IgnorePly

OthersFall:     call IsPlayerThere
                cmp al,1
                je CannotMoveThereCC

IgnorePly:      call IsCreatureThere
                cmp al,1
                je CannotMoveThereCC

                mov al,es:[bx+512+256]
                cmp al,4
                je FishLikeWater
                cmp al,5
                je FishLikeWater

                mov al,[si+8192]
                and al,1
                cmp al,1
                je CannotMoveThereCC
                jmp NotFish_

FishLikeWater:  mov al,[si+8192]
		and al,1
                cmp al,0
                je CannotMoveThereCC
		jmp AllowedToMove
NotFish_:

AllowedToMove:  mov es:[bx],dl
                mov es:[bx+256],dh
		mov es:[bx+512],cl

                mov al,1
                pop si
                pop dx
                ret

CannotMoveThereCC:
		mov al,0
		pop si
		pop dx
                ret

;----------------------------------------------------------------
;----------------------------------------------------------------
		; AL=0 cannot Move
                ; AL=1 Can move

RespectStops:	mov al,0
		mov ah,[si]
                cmp ah,45h
                je RSPassP

                mov ah,[si+8192]
                shr ah,3
                cmp ah,1
                je RSPassP

                mov ah,[si+8192]
                and ah,3
                cmp ah,2
                jae RSPassP

                mov al,1
RSPassP:	ret


;-----------------------------------------------------------------

		; AL=0 No
                ; AL=1 Yes

IsPlayerThere:	push bx
                mov al,0
		mov bl,byte Ptr MX
                add bl,LineSize/2
                mov bh,byte Ptr MY
                add bh,RowSize/2

                cmp bl,dl
                jne NoSir
                cmp bh,dh
                jne NoSIr

                mov al,1
NoSir:		pop bx
		ret

;-------------------------------------------------------------------

		; AL=0 No
                ; AL=1 Yes

IsCreatureThere:push bx
		push si
                mov al,0
                mov ah,byte ptr NOA
                mov si,offset CCX

ChkNextPossibility:
		mov bl,es:[si]
                mov bh,es:[si+256]

                cmp bl,dl
                jne No1
                cmp bh,dh
		jne No1
       		mov al,1
                jmp OutICT

No1:		dec ah
		cmp ah,0
                je OutICT
                inc si
                jmp ChkNextPossibility

OutICT:         pop si
                pop bx
                ret

;------------------------------------------------------------------

		; al=0 Isn't door
                ; al=1 Is door

IsDoorCC:	mov al,1
		mov ah,[si]
                cmp ah,1fh
                je IsD
                cmp ah,21h
                je IsD
                cmp ah,23h
                je IsD
                cmp ah,25h
                je IsD
                mov al,0
IsD:            ret

;----------------------------------------------------------------------

EnergyDrainHandler:     push ax
			push bx
                        push dx
			mov bl,byte ptr MX
                        add bl,LineSize/2
                        mov bh,byte ptr MY
			add bh,RowSize/2

                        call DoYouMatchPly
                        cmp al,1
                        je PleaseDrain

                        dec dh
                        call DoYouMatchPly
                        cmp al,1
                        je PleaseDrain

                        add dh,2
                        call DoYouMatchPly
                        cmp al,1
                        je PleaseDrain

                        dec dh
                        dec dl
                        call DoYouMatchPly
                        cmp al,1
                        je PleaseDrain

                        add dl,2
                        call DoYouMatchPly
			cmp al,1
                        je PleaseDrain
                        jmp EDH

PleaseDrain:            cmp word ptr TriForceFlag,0
			jne DoNotDrain
			DecMem LifeForce,6
			mov byte ptr ScreenFlash,1
DoNotDrain:
EDH:                    pop dx
                        pop bx
                        pop ax
                        ret

			; AL=0 Not Matching
                        ; AL=1 Matching


DoYouMatchPly:          mov al,0
			cmp bl,dl
                        jne NotMatching
                        cmp bh,dh
                        jne NotMatching

                        mov al,1
NotMatching:		ret

;------------------------------------------------------------------
;******************************************************************
;------------------------------------------------------------------
; 		    High-Scores Dysplay System
;------------------------------------------------------------------
;******************************************************************
;------------------------------------------------------------------

HighScores:	mov dx,Data
		mov ds,dx
                mov dx,SignSeg
                mov es,dx
                mov dx,TextSeg
                mov fs,dx
                mov dx,Screen
                mov gs,dx
                call Cls

                ;mov si,offset HighScoreTxt
                ;mov di,0
                ;call JulieJean94

                Print16x16Sign 0,offset HighScoreTxt,15,4

                mov cx,18
                mov si,offset Score
                mov di,offset HiScores+17*40

MaybeNextPos:   mov bx,0
ChkAFrame:	mov al,[si+bx]
                cmp al,fs:[di+bx]
                ja ProcedeWithTransfer
                jb EndClass
                cmp bx,7
                je EndClass
                inc bx
                jmp ChkAFrame

ProcedeWithTransfer:
		mov bx,0
CopyANum:       mov al,fs:[di+bx]
                mov fs:[di+bx+40],al
                inc bx
                cmp bx,40
                jne CopyANum

                mov bx,0
CopyBNum:       mov al,[si+bx]
                mov fs:[di+bx],al
                inc bx
                cmp bx,8
                jne CopyBNum

		sub di,40
                loop MaybeNextPos

EndClass:	mov bp,cx
                cmp cx,18
                jne AddEntry

                mov di,(17+2+3)*0a00h
                mov si,offset SorryTxt
                mov ah,14
                call PrintLine
		jmp NoAddLine

AddEntry:

                mov word ptr LineNum,bp
                mov ax,bp
                mov ah,40
                mul ah

                add ax,offset HiScores+10+2
                mov di,ax
                mov word ptr NameDest,di

                sub di,3
                ;mov si,offset LEVXX_CS4+3
                mov si,offset LevelXX+6
                mov al,[si]
                mov fs:[di],al
                mov al,[si+1]
                mov fs:[di+1],al
                add di,3

                mov cx,30-2
                mov al,0
ClrName:        mov fs:[di],al
                inc di
                loop ClrName

                mov di,(17+5)*0a00h
                mov si,offset WriteTxt
                mov ah,14
                call PrintLine

NoAddline:
		;-------------------------------------------------
		;*************************************************
		;-------------------------------------------------

                ; BP will hold the line that will be highlighted.
		mov cx,18
                sub cx,bp
		mov bp,cx

                ; PrintHighScoresOnScreen!!!
                mov cx,18
                mov si,offset HiScores
                mov di,3*0a00h
PrintNL:
                cmp cx,bp
                jne TryColoring
                mov ah,14
                jmp ISok

TryColoring:	mov ah,cl
                inc ah
		and ah,2
                or ah,1

                cmp ah,1
                jne ISnot1
       		mov ah,2
		jmp ISok
ISnot1:		mov ah,13

ISok:		call PrintLine

                add si,40
                add di,0a00h
                loop PrintNL


                ; Warning: DrawSomeScreen doesn't preserves some
                ;	   registers such as segment registers
                ;	   and bp.

                push bp
                call DrawSomeScreen
                call Convensions
                pop bp

                cmp bp,0
                je NoNameWritting

                ; Setup a new GS segment
		mov dx,0a000h
                mov gs,dx

		mov ax,word ptr LineNum
		add ax,3
                mov ah,0ah
                mul ah
                rol ax,8
                add ax,12*8

                ;===============================================
                ;===============================================
                mov di,ax
                mov si,word ptr NameDest
                mov bp,0

                ; DrawCursor
DrawCursorSoso:	push di
                mov eax,0e0e0e0eh

		mov cx,8
DC1:            mov gs:[di],eax
                mov gs:[di+4],eax

                add di,140h
		loop DC1
     		pop di


                ;----------------------------------------------
                ; This will allow the player to write his name.
		;----------------------------------------------
ReadAgain:      call GETAX
                call Convensions
                cmp al,13
                je DoneWithName
                cmp al,8
                je BackSpace

                ;cmp ah,0
                ;jne ReadAgain
                cmp al,0
                je ReadAgain

                cmp bp,40-13
                jae ReadAgain

		mov bx,offset SignsTable
LookAgainXYZ:   mov ah,[bx]
                cmp ah,0
                je ReadAgain
                cmp ah,al
                je FoundAMatchXYZ
                inc bx
                jmp LookAgainXYZ

FoundAMatchXYZ:	sub bx,offset SignsTable
		rol bx,10

                push di
                mov ah,14
                mov fs:[si],al

                ;<<<<<<<<<<>>>>>>>>>>>>

                mov dx,8
PLNextLine2:    mov cx,8
PLNextPix2:     mov al,es:[bx]
                cmp al,0
                jne PLNulPix4

PLNulPix3:	mov gs:[di],al
		jmp PLNulPix2
PLNulPix4:	mov gs:[di],ah
PLNulPix2:      add bx,4
                inc di
                loop PLNextPix2

                add di,140h-8
                add bx,32*3
                mov cx,dx
                dec dx
                loop PLNextLine2

                ;<<<<<<<<<<<>>>>>>>>>>>>>

		pop di

                add di,8
                inc si
                inc bp
                jmp DrawCursorSoso

BackSpace:      cmp bp,0
		je ReadAgain
                mov al,0
                mov fs:[si],al
		push di
		mov cx,8
		mov eax,0
BSP:            mov gs:[di],eax
                mov gs:[di+4],eax
                add di,140h
                loop BSP
       		pop di
                sub di,8
                dec si
                dec bp
		jmp DrawCursorSoso

DoneWithName:	mov cx,8
		mov eax,0
DWN:            mov gs:[di],eax
                mov gs:[di+4],eax
                add di,140h
                loop DWN

                mov cx,0a00h/4
                mov di,(17+2+3)*0a00h
DWN2:           mov gs:[di],eax
                add di,4
                loop DWN2

 		call Convensions

                mov al,byte ptr GameModeBase
                cmp al,0
                je SaveEasyBoard
                cmp al,1
                je SaveAdvanceBoard

                mov bp,offset Expert_SCO
          	jmp SaveBoard

SaveEasyBoard:  mov bp,offset Easy_SCO
		jmp SaveBoard

SaveAdvanceBoard:
		mov bp,offset Advance_SCO

SaveBoard:
                ; CHARGEMENT DE EASY.SCO
                mov dx,Data
                mov ds,dx
                mov dx,bp
                call MakePath

                mov dx,offset Filename
		mov cx,0
                mov ah,3ch		       ; Crée un fichier
                int 21h
                jc Not_Found

                call Convensions
		mov bp,ax
                mov bx,ax
                mov dx,TextSeg
                mov ds,dx
                mov dx,offset Hiscores
                mov ah,40h			; Écriture
                mov cx,800
                int 21h
		jc Not_Found

                mov bx,bp
                mov ah,3eh			; Fermeture
                int 21h
                jc Not_Found

		;----------------------------------------------------
		;----------------------------------------------------
		;----------------------------------------------------
NoNameWritting:

X1ax:          	call Getax
                cmp ax,0
                je X1ax

                call Convensions
                mov byte Ptr MX,0

                mov dx,0a000h
                mov gs,dx
                call Cls

                mov cx,0
                call LOADROOM

		call CONVENSIONS
                mov di,offset STATUS_TABLE+1
                mov al,1
                mov [di],al

                mov di,offset SCRIPTDATA+3*4+2
                mov al,[di]
                add al,80
                mov [di],al

                mov al,[di+4]
                add al,80
                mov [di+4],al

                mov al,[di+8]
                add al,80
                mov [di+8],al

		call Script_Compiler
		call Draw_Screen
                call DrawCreepSpreadIV
		call DrawSomeScreen

                mov cx,20
                call Pause
		jmp RestartProgram

                ;---------------------------------------------------
                ;---------------------------------------------------
		;---------------------------------------------------

PrintLine:      push ax
                push bx
                push cx
                push dx
		push di
                push si

		mov cx,40
PLGrabAL:	mov al,fs:[si]
		cmp al,-1
		je PLEndOfLine

                cmp al,0
                jne NotANul
                add di,8
                inc si
                loop PLGrabAL
                jmp PLEndOfLine

NotANul:
                push cx
                push di

                mov bx,offset SignsTable
PLTestMatch:    cmp al,[bx]
                je PLMatch
                inc bx
                jmp PLTestMatch

PLMatch:	sub bx,offset SignsTable
		rol bx,10

                mov dx,8
PLNextLine:     mov cx,8
PLNextPix:      mov al,es:[bx]
                cmp al,0
                je PLNulPix

		mov gs:[di],ah
PLNulPix:       add bx,4
                inc di
                loop PLNextPix

                add di,140h-8
                add bx,32*3
                mov cx,dx
                dec dx
                loop PLNextLine

                pop di
                add di,8
                pop cx
                inc si
                loop PLGrabAL

PLEndOfLine:    pop si
		pop di
                pop dx
		pop cx
                pop bx
                pop ax
		ret

                ;-----------------------------------------------------
                ;-----------------------------------------------------
PauseHandler:	call Convensions
		mov dx,0a000h
                mov gs,dx

                mov di,0
                mov eax,0

                mov cx,0a00h/4
ErasePT2:       mov gs:[di],eax
                add di,4
                loop ErasePT2

                mov ah,38
		mov si,offset PauseTxt
		mov di,0
                call PrintLine

PH:             call Getax
                cmp ax,0
                je PH

                call Convensions
		mov di,0
                mov eax,0

                mov cx,0a00h/4
ErasePT:        mov gs:[di],eax
                add di,4
                loop ErasePT
                jmp MainLoop


                ;-----------------------------------------------------


DrawGameOverSign:
                call Convensions
                cmp byte ptr CAnimation,1
                je InvGOsign
		PrintBigOne GameOverDi,offset GameOverTxt,45,58
                ret
InvGoSign:	PrintBigOne GameOverDi,offset GameOverTxt,58,45
                ret

                ;-----------------------------------------------------

EraseHighs:     ; if /s on command line then no erase scores
		mov dx,DATA
		mov ds,dx
                cmp byte ptr Escores,0
                je MainLoop

		mov dx,0a000h
		mov gs,dx
                mov cx,0a00h/4
                mov eax,0
                mov di,0

EraseT94a:      mov gs:[di],eax
                add di,4
                loop EraseT94a

                call Convensions
                mov ah,6
                mov si,offset EraseTxt
                mov di,0
                call PrintLine

Looping:	call Getax
                cmp al,"y"
                je ActErase
                cmp ax,0
                je Looping

BackToGame:     mov dx,0a000h
		mov gs,dx
                mov cx,0a00h/4
                mov eax,0
                mov di,0

EraseT94b:      mov gs:[di],eax
                add di,4
                loop EraseT94b
                jmp MainLoop

ActErase:	call Convensions
		mov dx,offset Easy_Sco
                call CreatBlankFile

                call Convensions
		mov dx,offset Advance_Sco
                call CreatBlankFile

                call Convensions
		mov dx,offset Expert_Sco
                call CreatBlankFile

                mov dx,TextSeg
                mov fs,dx
                mov bp,18

                mov di,offset HiScores

Escore2:        mov cx,40
	        mov si,offset FbTxt
Escore:         mov al,fs:[si]
                mov fs:[di],al
                inc si
                inc di
                loop Escore

		mov cx,bp
                dec bp
                loop EScore2


		jmp BackToGame

CreatBlankFile: call Convensions
		mov cx,0
		mov ah,3ch	; Open
                int 21h
                jc Not_Found

                mov bp,18
                mov bx,ax
WriteAgain:	push bx

                mov dx,TextSeg
                mov ds,dx
                mov dx,offset FBtxt
                mov ah,40h    	; Write
                mov cx,40
                int 21h
                jc Not_Found

                pop bx
		mov cx,bp
		dec bp
                loop WriteAgain

                mov ah,3eh    	; Close
                int 21h
		jc Not_Found
                ret

xxxMouse:	mov dx,Data
		mov ds,dx
                mov dx,Statics
                mov es,dx
                mov dx,offset Users_mcg
                mov bx,0
                mov cx,20*256*8
                call LoadOld

                call Convensions
                mov al,byte ptr PShape
                inc byte ptr PShape
                cmp byte ptr PShape,8
                jb OkNotToBeNul
                mov bl,0
                mov byte ptr PShape,bl
OkNotToBeNul:

                mov ah,20
                mul ah
                shl ax,8

                mov si,ax
                mov di,offset PlayerFrames

                mov dx,Statics
                mov es,dx
                mov dx,SignSeg
                mov fs,dx

                mov cx,20*256/4
TShape:         mov eax,es:[si]
                mov fs:[di],eax
                add di,4
                add si,4
                loop TShape
                jmp xxxMouse2




;---------------------------------------------------------------
; -----------------------FIN DU PROGRAMME-----------------------
CS4    ENDP                              ; Fin de la procedure
CODE ENDS                                ; Fin du programme
END     CS4                              ; Point d'entree
;---------------------------------------------------------------
