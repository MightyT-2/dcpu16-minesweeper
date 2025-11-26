; Minesweeper for the DCPU-16
; 11/25/2025
; Timothy Powell
; 148413

; This assignment is my original work for CS 321, created and completed during
; the Fall 2025 semester.  I have neither copied this work nor had another
; person or AI do any of my work for me.
; -- Timothy Powell

; Loop the program
:mainLoop
   JSR menuLoop
   JSR gameLoop

   SET PC, mainLoop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                              System Functions                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Alternate whether the default font or custom sprites will display
:sysToggleSprites
   SET PUSH, A
   SET PUSH, B
   SET PUSH, C
   
   SET A, datCustomSprites
   SET B, 0
   SET C, [datStartCust]
   :sysLoopChar
   SET B, [C]
   SET [C], [A]
   SET [A], B
   ADD A, 1
   ADD C, 1
   IFL A, datClockIndex
   SET PC, sysLoopChar
   
   SET C, POP
   SET B, POP
   SET A, POP
   SET PC, POP

; Get keyboard input from the user
:sysGetKeyboardInput
   SET PUSH, C
   SET PUSH, B
   SET A, 2
   SET B, 0x90
   HWI 1
   SET [datIsShifted], C
   SET B, 0x91
   HWI 1
   SET [datIsCTRL], C
   SET A, 1
   :sysGetNextKey
   HWI 1
   IFE C, 0x90
   SET PC, sysGetNextKey
   IFE C, 0x91
   SET PC, sysGetNextKey
   SET A, C
   SET B, POP
   SET C, POP
   SET PC, POP

; Initialize the clock
:sysInitializeClock
   SET PUSH, A
   SET PUSH, B
   SET A, 0
   SET B, 1
   HWI 2
   SET B, POP
   SET A, POP
   SET PC, POP

; Return the current time
:sysGetTime
   SET PUSH, C
   SET A, 1
   HWI 2
   SET A, C
   SET C, POP
   SET PC, POP

; Remove all values from the screen
:sysClearScreen
   SET PUSH, C
   SET C, 0x8000
   :sysClearLoop
   SET [C], 0x0000
   ADD C, 0x0001
   IFL C, 0x8180
   SET PC, sysClearLoop
   SET C, POP
   SET PC, POP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Menu Functions                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Loop until the user starts the game
:menuLoop
   JSR sysInitializeClock                  
   :menuLoopback
   JSR menuPrintMainMenu

   :menuWaitUserInput
   JSR sysGetKeyboardInput
   IFE A, 0x0000
   SET PC, menuWaitUserInput
   SET [datQuitMenu], 0x0000
   SET [datPrintInstructions], 0x0000
   JSR menuControllerHandler
   
   IFE [datQuitMenu], 0x0001
   SET PC, POP
   IFE [datPrintInstructions], 0x0001
   JSR menuPrintInstructions
   SET PC, menuLoopback

; Print a string to the menu screen
; Pass the screen location in the C register
; Pass the string pointer in the B register
; Pass the style value in the A register
:menuPrintString
   SET [C], [B]
   XOR [C], A
   ADD C, 1
   ADD B, 1
   IFE [B], 0x0000
   SET PC, POP
   SET PC, menuPrintString

; Print the main menu
:menuPrintMainMenu
   SET PUSH, A
   SET PUSH, B
   SET PUSH, C
   SET PUSH, X
   JSR sysClearScreen

   SET A, 0xF000
   SET B, datHeader
   SET C, 0x8009
   JSR menuPrintString

   SET X, 0x0000
   SET A, 0xF000
   IFE X, [datMenuOption]
   SET A, 0x0F00
   SET B, datPlayGame
   SET C, 0x8040
   JSR menuPrintString

   ADD X, 1
   SET A, 0xF000
   IFE X, [datMenuOption]
   SET A, 0x0F00
   SET B, datInstructions
   SET C, 0x8060
   JSR menuPrintString

   ADD X, 1
   SET A, 0xF000
   IFE X, [datMenuOption]
   SET A, 0x0F00
   SET B, datQuitGame
   SET C, 0x8080
   JSR menuPrintString

   SET X, POP
   SET C, POP
   SET B, POP
   SET A, POP
   SET PC, POP

; Control user input in the menu loop
; Pass the pressed key through the A register
:menuControllerHandler
   IFE A, 0x80 ; Up Arrow
   JSR menuMoveCursorUp
   IFE A, 0x81 ; Down Arrow
   JSR menuMoveCursorDown

   IFE A, 0x11 ; Return
   SET PC, menuReturnKey
   SET PC, POP

   :menuReturnKey
   IFE [datMenuOption], 0x0000
   SET [datQuitMenu], 0x0001
   IFE [datMenuOption], 0x0001
   SET [datPrintInstructions], 0x0001
   IFE [datMenuOption], 0x0002
   SET [datQuitGame], 0x0001
   SET PC, POP

; Move the selection up
:menuMoveCursorUp
   IFN [datMenuOption], 0
   SUB [datMenuOption], 1
   SET PC, POP

; Move the selection down
:menuMoveCursorDown
   IFN [datMenuOption], 2
   ADD [datMenuOption], 1
   SET PC, POP

; Quit the game (WIP)
:menuQuitGame
   SET PC, datQuitGame

; Print the instructions for the game
:menuPrintInstructions
   JSR sysClearScreen
   SET A, 0xF000
   SET B, datMoveInstructions
   SET C, 0x8000
   JSR menuPrintString
   :menuWaitUserInputInstr0
   JSR sysGetKeyboardInput
   IFE A, 0x0000
   SET PC, menuWaitUserInputInstr0

   JSR sysClearScreen
   SET A, 0xF000
   SET B, datDigInstructions
   SET C, 0x8000
   JSR menuPrintString
   :menuWaitUserInputInstr1
   JSR sysGetKeyboardInput
   IFE A, 0x0000
   SET PC, menuWaitUserInputInstr1

   JSR sysClearScreen
   SET A, 0xF000
   SET B, datFlagInstructions
   SET C, 0x8000
   JSR menuPrintString
   :menuWaitUserInputInstr3
   JSR sysGetKeyboardInput
   IFE A, 0x0000
   SET PC, menuWaitUserInputInstr3

   SET PC, POP

; Leave the menu
:menuQuitMenu
   SET [datQuitMenu], 0x0001
   SET PC, POP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                    Game Functions                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Control gameplay until the user wins or loses
:gameLoop
   JSR sysGetTime
   XOR [datRandX], A
   JSR sysToggleSprites
   SET [datWin], 0x0000
   SET [datLose], 0x0000
   JSR gameGenerateMinefield
   SET [datPlayerLocation], 0x0000
   :gameLoopback
   JSR gameDisplayMinefield
   :gameWaitUserInput
   JSR sysGetKeyboardInput
   IFE A, 0x0000
   SET PC, gameWaitUserInput
   JSR gameControllerHandler
   IFE [datWin], 1
   SET PC, gameWin
   IFE [datLose], 1
   SET PC, gameLose
   SET PC, gameLoopback

; Show the minefield in the screen
:gameDisplayMinefield
   SET PUSH, A
   SET PUSH, C
   SET PUSH, X
   SET PUSH, Y

   SET C, [datStartScreen]
   SET X, datMinefield
   SET PC, gameEnterPrintLoop

   :gamePrintLoop
   ADD C, 1
   ADD X, 1
   :gameEnterPrintLoop
   SET Y, 0x0006
   AND Y, [X]
   IFE Y, 0x0002
   SET PC, gameDisplayPlayerTile
   IFE Y, 0x0006
   SET PC, gameDisplayPlayerGrass
   SET Y, 0x100C
   AND Y, [X]
   IFE Y, 0x1004
   SET PC, gameDisplayWinFlag
   IFE Y, 0x000C
   SET PC, gameDisplayTileFlag
   IFE Y, 0x0004
   SET PC, gameDisplayTileCovered
   SET Y, 0x0001
   AND Y, [X]
   IFE Y, 0x0001
   SET PC, gameDisplayTileMine
   SET Y, 0x0010
   AND Y, [X]
   IFE Y, 0x0010
   SET PC, gameDisplayBombs1
   SET Y, 0x0020
   AND Y, [X]
   IFE Y, 0x0020
   SET PC, gameDisplayBombs2
   SET Y, 0x0040
   AND Y, [X]
   IFE Y, 0x0040
   SET PC, gameDisplayBombs3
   SET Y, 0x0080
   AND Y, [X]
   IFE Y, 0x0080
   SET PC, gameDisplayBombs4
   SET Y, 0x0100
   AND Y, [X]
   IFE Y, 0x0100
   SET PC, gameDisplayBombs5
   SET Y, 0x0200
   AND Y, [X]
   IFE Y, 0x0200
   SET PC, gameDisplayBombs6
   SET Y, 0x0400
   AND Y, [X]
   IFE Y, 0x0400
   SET PC, gameDisplayBombs7
   SET Y, 0x0800
   AND Y, [X]
   IFE Y, 0x0800
   SET PC, gameDisplayBombs8
   SET Y, 0xFFFF
   AND Y, [X]
   IFN Y, 0x0000
   SET PC, gameDisplayTileUnknown

   SET A, datBombs0
   SET PC, gameDisplay
   :gameDisplayBombs1
   SET A, datBombs1
   SET PC, gameDisplay
   :gameDisplayBombs2
   SET A, datBombs2
   SET PC, gameDisplay
   :gameDisplayBombs3
   SET A, datBombs3
   SET PC, gameDisplay
   :gameDisplayBombs4
   SET A, datBombs4
   SET PC, gameDisplay
   :gameDisplayBombs5
   SET A, datBombs5
   SET PC, gameDisplay
   :gameDisplayBombs6
   SET A, datBombs6
   SET PC, gameDisplay
   :gameDisplayBombs7
   SET A, datBombs7
   SET PC, gameDisplay
   :gameDisplayBombs8
   SET A, datBombs8
   SET PC, gameDisplay
   :gameDisplayTileCovered
   SET A, datTileCovered
   SET PC, gameDisplay
   :gameDisplayTileFlag
   SET A, datTileFlag
   SET PC, gameDisplay
   :gameDisplayWinFlag
   SET A, datWinFlag
   SET PC, gameDisplay
   :gameDisplayTileUnknown
   SET A, datTileUnknown
   SET PC, gameDisplay
   :gameDisplayTileMine
   SET A, datTileMine
   SET PC, gameDisplay
   :gameDisplayPlayerGrass
   SET A, datPlayerGrass
   SET PC, gameDisplay
   :gameDisplayPlayerTile
   SET A, datPlayerTile

   :gameDisplay
   SET [C], [A]
   ADD C, 1
   ADD A, 1
   SET [C], [A]

   IFL C, [datEndScreen]
   SET PC, gamePrintLoop

   SET Y, POP
   SET X, POP
   SET C, POP
   SET A, POP
   SET PC, POP

; Handle the user's input during gameplay
; Pass the pressed key through the A register
:gameControllerHandler
   IFE A, 0x80 ; Up Arrow
   JSR gameMovePlayerUp
   IFE A, 0x81 ; Down Arrow
   JSR gameMovePlayerDown
   IFE A, 0x82 ; Left Arrow
   JSR gameMovePlayerLeft
   IFE A, 0x83 ; Right Arrow
   JSR gameMovePlayerRight
   
   IFE [datIsShifted], 1
   SET PC, gameFlagControls

   SET C, [datPlayerLocation]
   IFE A, 0x73 ; 's' Key
   JSR gameDig
   IFE A, 0x77 ; 'w' Key
   JSR gameDigNorth
   IFE A, 0x65 ; 'e' Key
   JSR gameDigNorthEast
   IFE A, 0x64 ; 'd' Key
   JSR gameDigEast
   IFE A, 0x63 ; 'c' Key
   JSR gameDigSouthEast
   IFE A, 0x78 ; 'x' Key
   JSR gameDigSouth
   IFE A, 0x7A ; 'z' Key
   JSR gameDigSouthWest
   IFE A, 0x61 ; 'a' Key
   JSR gameDigWest
   IFE A, 0x71 ; 'q' Key
   JSR gameDigNorthWest
   SET PC, gameDigControls

   :gameFlagControls
   SET C, [datPlayerLocation]
   IFE A, 0x53 ; 'S' Key
   JSR gameFlag
   IFE A, 0x57 ; 'W' Key
   JSR gameFlagNorth
   IFE A, 0x45 ; 'E' Key
   JSR gameFlagNorthEast
   IFE A, 0x44 ; 'D' Key
   JSR gameFlagEast
   IFE A, 0x43 ; 'C' Key
   JSR gameFlagSouthEast
   IFE A, 0x58 ; 'X' Key
   JSR gameFlagSouth
   IFE A, 0x5A ; 'Z' Key
   JSR gameFlagSouthWest
   IFE A, 0x41 ; 'A' Key
   JSR gameFlagWest
   IFE A, 0x51 ; 'Q' Key
   JSR gameFlagNorthWest
   :gameDigControls
   SET PC, POP

; Move the player up one space
:gameMovePlayerUp
   IFL [datPlayerLocation], 0x0010
   SET PC, POP
   SET PUSH, A
   SET PUSH, C
   SET C, datMinefield
   ADD C, [datPlayerLocation]
   XOR [C], 0x0002
   SUB [datPlayerLocation], 0x0010
   SUB C, 0x0010
   XOR [C], 0x0002
   SET A, [C]
   AND A, 0x0001
   IFE A, 0x0001
   SET [datLose], 0x0001
   SET A, [C]
   AND A, 0x1000
   IFE A, 0x1000
   SET [datWin], 0x0001
   SET C, POP
   SET A, POP
   SET PC, POP

; Move the player down one space
:gameMovePlayerDown
   IFG [datPlayerLocation], 0x00AF
   SET PC, POP
   SET PUSH, A
   SET PUSH, C
   SET C, datMinefield
   ADD C, [datPlayerLocation]
   XOR [C], 0x0002
   ADD [datPlayerLocation], 0x0010
   ADD C, 0x0010
   XOR [C], 0x0002
   SET A, [C]
   AND A, 0x0001
   IFE A, 0x0001
   SET [datLose], 0x0001
   SET A, [C]
   AND A, 0x1000
   IFE A, 0x1000
   SET [datWin], 0x0001
   SET C, POP
   SET A, POP
   SET PC, POP

; Move the player left one space
:gameMovePlayerLeft
   SET PUSH, A
   SET A, [datPlayerLocation]
   MOD A, 0x0010
   IFE A, 0x0000
   SET PC, gameExitMovePlayerLeft
   SET PUSH, C
   SET C, datMinefield
   ADD C, [datPlayerLocation]
   XOR [C], 0x0002
   SUB [datPlayerLocation], 0x0001
   SUB C, 0x0001
   XOR [C], 0x0002
   SET A, [C]
   AND A, 0x0001
   IFE A, 0x0001
   SET [datLose], 0x0001
   SET A, [C]
   AND A, 0x1000
   IFE A, 0x1000
   SET [datWin], 0x0001
   SET C, POP
   :gameExitMovePlayerLeft
   SET A, POP
   SET PC, POP

; Move the player right one space
:gameMovePlayerRight
   SET PUSH, A
   SET A, [datPlayerLocation]
   MOD A, 0x0010
   IFE A, 0x000F
   SET PC, gameExitMovePlayerRight
   SET PUSH, C
   SET C, datMinefield
   ADD C, [datPlayerLocation]
   XOR [C], 0x0002
   ADD [datPlayerLocation], 0x0001
   ADD C, 0x0001
   XOR [C], 0x0002
   SET A, [C]
   AND A, 0x0001
   IFE A, 0x0001
   SET [datLose], 0x0001
   SET A, [C]
   AND A, 0x1000
   IFE A, 0x1000
   SET [datWin], 0x0001
   SET C, POP
   :gameExitMovePlayerRight
   SET A, POP
   SET PC, POP

; Dig a tile
; Pass the dig coordinate in the C register
:gameDig
   SET PUSH, A
   SET PUSH, B
   SET B, C
   ADD B, datMinefield
   SET A, [B]
   AND A, 0x100C
   IFN A, 0x0004
   SET PC, gameExitDig
   AND [B], 0xFFFB
   SET A, [B]
   AND A, 0x0001
   IFE A, 0x0001
   SET [datLose], 1
   SET A, [B]
   AND A, 0x0FF0
   IFE A, 0x0000
   JSR gameDigBlankTile
   :gameExitDig
   SET B, POP
   SET A, POP
   SET PC, POP

; Dig all the tiles around a blank tile
:gameDigBlankTile
   JSR gameDigNorth
   JSR gameDigNorthEast
   JSR gameDigEast
   JSR gameDigSouthEast
   JSR gameDigSouth
   JSR gameDigSouthWest
   JSR gameDigWest
   JSR gameDigNorthWest
   SET PC, POP

; Check if the north tile can be dug and dig
:gameDigNorth
   SET PUSH, A
   IFL C, 0x0010
   SET PC, gameExitDigNorth
   SET PUSH, C
   SUB C, 0x0010
   JSR gameDig
   SET C, POP
   :gameExitDigNorth
   SET A, POP
   SET PC, POP

; Check if the northeast tile can be dug and dig
:gameDigNorthEast
   SET PUSH, A
   IFL C, 0x0010
   SET PC, gameExitDigNorthEast
   SET A, C
   MOD A, 0x0010
   IFE A, 0x000F
   SET PC, gameExitDigNorthEast
   SET PUSH, C
   SUB C, 0x000F
   JSR gameDig
   SET C, POP
   :gameExitDigNorthEast
   SET A, POP
   SET PC, POP

; Check if the east tile can be dug and dig
:gameDigEast
   SET PUSH, A
   SET A, C
   MOD A, 0x0010
   IFE A, 0x000F
   SET PC, gameExitDigEast
   SET PUSH, C
   ADD C, 0x0001
   JSR gameDig
   SET C, POP
   :gameExitDigEast
   SET A, POP
   SET PC, POP

; Check if the southeast tile can be dug and dig
:gameDigSouthEast
   SET PUSH, A
   IFG C, 0x00AF
   SET PC, gameExitDigNorthEast
   SET A, C
   MOD A, 0x0010
   IFE A, 0x000F
   SET PC, gameExitDigNorthEast
   SET PUSH, C
   ADD C, 0x0011
   JSR gameDig
   SET C, POP
   :gameExitDigSouthEast
   SET A, POP
   SET PC, POP

; Check if the south tile can be dug and dig
:gameDigSouth
   IFG C, 0x00AF
   SET PC, gameExitDigNorth
   SET PUSH, C
   ADD C, 0x0010
   JSR gameDig
   SET C, POP
   :gameExitDigSouth
   SET PC, POP

; Check if the southwest tile can be dug and dig
:gameDigSouthWest
   SET PUSH, A
   IFG C, 0x00AF
   SET PC, gameExitDigNorthEast
   SET A, C
   MOD A, 0x0010
   IFE A, 0x0000
   SET PC, gameExitDigNorthEast
   SET PUSH, C
   ADD C, 0x000F
   JSR gameDig
   SET C, POP
   :gameExitDigSouthWest
   SET A, POP
   SET PC, POP

; Check if the west tile can be dug and dig
:gameDigWest
   SET PUSH, A
   SET A, C
   MOD A, 0x0010
   IFE A, 0x0000
   SET PC, gameExitDigWest
   SET PUSH, C
   SUB C, 0x0001
   JSR gameDig
   SET C, POP
   :gameExitDigWest
   SET A, POP
   SET PC, POP

; Check if the northwest tile can be dug and dig
:gameDigNorthWest
   SET PUSH, A
   IFL C, 0x0010
   SET PC, gameExitDigNorthWest
   SET A, C
   MOD A, 0x0010
   IFE A, 0x0000
   SET PC, gameExitDigNorthWest
   SET PUSH, C
   SUB C, 0x0011
   JSR gameDig
   SET C, POP
   :gameExitDigNorthWest
   SET A, POP
   SET PC, POP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       Placing Flags                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Flag a tile.
; Pass the flag coordinate in the C register.
:gameFlag
   SET PUSH, A
   SET PUSH, B
   SET B, C
   ADD B, datMinefield
   SET A, [B]
   AND A, 0x0004
   IFN A, 0x0004
   SET PC, gameExitFlag
   XOR [B], 0x0008
   :gameExitFlag
   SET B, POP
   SET A, POP
   SET PC, POP

; Check if the north tile can be flagged and flag
:gameFlagNorth
   SET PUSH, A
   IFL C, 0x0010
   SET PC, gameExitFlagNorth
   SET PUSH, C
   SUB C, 0x0010
   JSR gameFlag
   SET C, POP
   :gameExitFlagNorth
   SET A, POP
   SET PC, POP

; Check if the northeast tile can be flagged and flag
:gameFlagNorthEast
   SET PUSH, A
   IFL C, 0x0010
   SET PC, gameExitFlagNorthEast
   SET A, C
   MOD A, 0x0010
   IFE A, 0x000F
   SET PC, gameExitFlagNorthEast
   SET PUSH, C
   SUB C, 0x000F
   JSR gameFlag
   SET C, POP
   :gameExitFlagNorthEast
   SET A, POP
   SET PC, POP

; Check if the east tile can be flagged and flag
:gameFlagEast
   SET PUSH, A
   SET A, C
   MOD A, 0x0010
   IFE A, 0x000F
   SET PC, gameExitFlagEast
   SET PUSH, C
   ADD C, 0x0001
   JSR gameFlag
   SET C, POP
   :gameExitFlagEast
   SET A, POP
   SET PC, POP

; Check if the southeast tile can be flagged and flag
:gameFlagSouthEast
   SET PUSH, A
   IFG C, 0x00AF
   SET PC, gameExitFlagNorthEast
   SET A, C
   MOD A, 0x0010
   IFE A, 0x000F
   SET PC, gameExitFlagNorthEast
   SET PUSH, C
   ADD C, 0x0011
   JSR gameFlag
   SET C, POP
   :gameExitFlagSouthEast
   SET A, POP
   SET PC, POP

; Check if the south tile can be flagged and flag
:gameFlagSouth
   IFG C, 0x00AF
   SET PC, gameExitFlagNorth
   SET PUSH, C
   ADD C, 0x0010
   JSR gameFlag
   SET C, POP
   :gameExitFlagSouth
   SET PC, POP

; Check if the southwest tile can be flagged and flag
:gameFlagSouthWest
   SET PUSH, A
   IFG C, 0x00AF
   SET PC, gameExitFlagNorthEast
   SET A, C
   MOD A, 0x0010
   IFE A, 0x0000
   SET PC, gameExitFlagNorthEast
   SET PUSH, C
   ADD C, 0x000F
   JSR gameFlag
   SET C, POP
   :gameExitFlagSouthWest
   SET A, POP
   SET PC, POP

; Check if the west tile can be flagged and flag
:gameFlagWest
   SET PUSH, A
   SET A, C
   MOD A, 0x0010
   IFE A, 0x0000
   SET PC, gameExitFlagWest
   SET PUSH, C
   SUB C, 0x0001
   JSR gameFlag
   SET C, POP
   :gameExitFlagWest
   SET A, POP
   SET PC, POP

; Check if the northwest tile can be flagged and flag
:gameFlagNorthWest
   SET PUSH, A
   IFL C, 0x0010
   SET PC, gameExitFlagNorthWest
   SET A, C
   MOD A, 0x0010
   IFE A, 0x0000
   SET PC, gameExitFlagNorthWest
   SET PUSH, C
   SUB C, 0x0011
   JSR gameFlag
   SET C, POP
   :gameExitFlagNorthWest
   SET A, POP
   SET PC, POP

; Generate a fresh minefield for a game
:gameGenerateMinefield
   SET PUSH, A
   SET PUSH, C
   JSR gameClearField           ; Clear the field
   SET C, datMinefield
   :gameRandomBombsLoop         ; Set bombs
   JSR gameRandom
   SET A, [datRandT]
   SHR A, 0x000C
   IFL A, 0x0003
   XOR [C], 0x0001
   ADD C, 0x0001
   IFL C, datEndMinefield
   SET PC, gameRandomBombsLoop
   SET C, datMinefield          ; Set the player
   SET [C], 0x0006
   ADD C, 0x0001
   SET [C], 0x0004
   ADD C, 0x000F
   SET [C], 0x0004
   ADD C, 0x0001
   SET [C], 0x0004
   SET C, datEndMinefield       ; Set the goal
   SUB C, 0x0001
   SET [C], 0x1004
   SUB C, 0x0001
   SET [C], 0x0004
   SUB C, 0x000F
   SET [C], 0x0004
   SUB C, 0x0001
   SET [C], 0x0004
   SET C, 0x0000                ; Set the counts
   SET B, datMinefield
   :gameSetCounts
   SET X, [B]
   AND X, 0x0001
   IFE X, 0x0001
   SET PC, gameSkipCount
   JSR gameMineCount
   SET Z, 0x0008
   SHL Z, X
   IFG Z, 0x000F
   XOR [B], Z
   :gameSkipCount
   ADD C, 0x0001
   ADD B, 0x0001
   IFL B, datEndMinefield
   SET PC, gameSetCounts
   SET C, POP
   SET A, POP
   SET PC, POP

; Count the number of mines around a tile
; Pass the location through the C register
; Receive the count through the X register
:gameMineCount
   SET PUSH, B
   SET PUSH, Y
   SET X, 0x0000
   IFL C, 0x0010  ; Check North
   SET PC, gameSkipNorth
   SET B, C
   ADD B, datMinefield
   SUB B, 0x0010
   SET Y, [B]
   AND Y, 0x0001
   IFE Y, 0x0000
   SET PC, gameSkipNorth
   ADD X, 0x0001
   :gameSkipNorth
   IFG C, 0x00AF  ; Check South
   SET PC, gameSkipSouth
   SET B, C
   ADD B, datMinefield
   ADD B, 0x0010
   SET Y, [B]
   AND Y, 0x0001
   IFE Y, 0x0000
   SET PC, gameSkipSouth
   ADD X, 0x0001
   :gameSkipSouth
   SET B, C       ; Check South
   MOD B, 0x0010
   IFE B, 0x0000
   SET PC, gameSkipWest
   IFL C, 0x0010  ; Check NorthWest
   SET PC, gameSkipNorthWest
   SET B, C
   ADD B, datMinefield
   SUB B, 0x0011
   SET Y, [B]
   AND Y, 0x0001
   IFE Y, 0x0000
   SET PC, gameSkipNorthWest
   ADD X, 0x0001
   :gameSkipNorthWest
   IFG C, 0x00AF  ; Check SouthEast
   SET PC, gameSkipSouthWest
   SET B, C
   ADD B, datMinefield
   ADD B, 0x000F
   SET Y, [B]
   AND Y, 0x0001
   IFE Y, 0x0000
   SET PC, gameSkipSouthWest
   ADD X, 0x0001
   :gameSkipSouthWest
   SET B, C
   ADD B, datMinefield
   SUB B, 0x0001
   SET Y, [B]
   AND Y, 0x0001
   IFE Y, 0x0000
   SET PC, gameSkipWest
   ADD X, 0x0001
   :gameSkipWest
   SET B, C       ; Check East
   MOD B, 0x0010
   IFE B, 0x000F
   SET PC, gameSkipEast
   IFL C, 0x0010  ; Check NorthEast
   SET PC, gameSkipNorthEast
   SET B, C
   ADD B, datMinefield
   SUB B, 0x000F
   SET Y, [B]
   AND Y, 0x0001
   IFE Y, 0x0000
   SET PC, gameSkipNorthEast
   ADD X, 0x0001
   :gameSkipNorthEast
   IFG C, 0x00AF  ; Check SouthEast
   SET PC, gameSkipSouthEast
   SET B, C
   ADD B, datMinefield
   ADD B, 0x0011
   SET Y, [B]
   AND Y, 0x0001
   IFE Y, 0x0000
   SET PC, gameSkipSouthEast
   ADD X, 0x0001
   :gameSkipSouthEast
   SET B, C
   ADD B, datMinefield
   ADD B, 0x0001
   SET Y, [B]
   AND Y, 0x0001
   IFE Y, 0x0000
   SET PC, gameSkipEast
   ADD X, 0x0001
   :gameSkipEast
   SET Y, POP
   SET B, POP
   SET PC, POP


; This algorithm is not my own design
; It can be found here: https://github.com/edrosten/8bit_rng
;  t = x ^ (x << 4);
;  x=y;
;  y=z;
;  z=a;
;  a = z ^ t ^ ( z >> 1) ^ (t << 1);
:gameRandom
   SET PUSH, A
   SET [datRandT], [datRandX]
   SHL [datRandT], 0x0004
   XOR [datRandT], [datRandX]
   SET [datRandX], [datRandY]
   SET [datRandY], [datRandZ]
   SET [datRandZ], [datRandA]
   SET [datRandA], [datRandZ]
   SHL [datRandA], 0x0001
   XOR [datRandA], [datRandT]
   XOR [datRandA], [datRandZ]
   SET A, [datRandT]
   SHL A, 0x0001
   XOR [datRandA], A
   SET A, POP
   SET PC, POP

; Resets the minefield to a blank field
:gameClearField
   SET PUSH, C
   SET C, datMinefield
   :gameClearLoop
   SET [C], 0x0004
   ADD C, 0x0001
   IFL C, datEndMinefield
   SET PC, gameClearLoop
   SET C, POP
   SET PC, POP

; Trigger if the user reaches the win flag
:gameWin
   JSR sysClearScreen
   JSR sysToggleSprites
   SET A, 0xF000
   SET B, datWinHeader
   SET C, 0x8040
   JSR menuPrintString
   :gameWinWait0
   JSR sysGetKeyboardInput
   IFE A, 0x0000
   SET PC, gameWinWait0
   SET A, 0xF000
   SET B, datWinText
   SET C, 0x8080
   JSR menuPrintString
   :gameWinWait1
   JSR sysGetKeyboardInput
   IFE A, 0x0000
   SET PC, gameWinWait1
   SET PC, POP

; Trigger if the user triggers a mine
:gameLose
   JSR sysClearScreen
   JSR sysToggleSprites
   SET A, 0xF000
   SET B, datLoseHeader
   SET C, 0x8040
   JSR menuPrintString
   :gameLoseWait0
   JSR sysGetKeyboardInput
   IFE A, 0x0000
   SET PC, gameLoseWait0
   SET A, 0xF000
   SET B, datLoseText
   SET C, 0x8080
   JSR menuPrintString
   :gameLoseWait1
   JSR sysGetKeyboardInput
   IFE A, 0x0000
   SET PC, gameLoseWait1
   SET PC, POP

; Breakdown of datMinefield values
; first four bits - null
; next bit        - win
; next eight bits - numberOfBombs
; next bit        - isFlagged
; next bit        - isCovered
; next bit        - isPlayer
; next bit        - isBomb
; 0000000000000000
; 000wnnnnnnnnfcpb

; The strings to print to the main menu
:datHeader       DAT "MINESWEEPER", 0
:datPlayGame     DAT "    PLAY GAME     ", 0
:datInstructions DAT "   INSTRUCTIONS   ", 0
:datQuitGame     DAT " QUIT GAME (WIP)  ", 0

; The strings to show the instructions for the game
:datMoveInstructions
DAT "MOVING  [arrows]                "
DAT "                                "
DAT "                                "
DAT "              [up]              "
DAT "                                "
DAT "    [left]   [down]  [right]    "
DAT "                                "
DAT "                                "
DAT " Press any key to continue...   ", 0

:datDigInstructions
DAT "DIGGING  [direction]            "
DAT "                                "
DAT "      [q]      [w]      [e]     "
DAT "   NORTHWEST  NORTH  NORTHEAST  "
DAT "                                "
DAT "      [a]      [s]      [d]     "
DAT "      WEST     DOWN     EAST    "
DAT "                                "
DAT "      [z]      [x]      [c]     "
DAT "   SOUTHWEST  SOUTH  SOUTHEAST  ", 0

:datFlagInstructions
DAT "FLAGGING  [shift] + [direction] "
DAT "                                "
DAT "      [Q]      [W]      [E]     "
DAT "   NORTHWEST  NORTH  NORTHEAST  "
DAT "                                "
DAT "      [A]      [S]      [D]     "
DAT "      WEST     DOWN     EAST    "
DAT "                                "
DAT "      [Z]      [X]      [C]     "
DAT "   SOUTHWEST  SOUTH  SOUTHEAST  ", 0

; The strings for the win-lose screens
:datWinHeader  DAT "YOU WIN", 0
:datWinText    DAT "You arrived at the flag", 0
:datLoseHeader DAT "YOU LOSE", 0
:datLoseText   DAT "You triggered a mine", 0

; All the data for the minefield
:datMinefield                                                      ; Row Nos.   Player Location
DAT 0x0002, 0x0000, 0x0004, 0x000C, 0x0010, 0x0020, 0x0040, 0x0080 ; Row 1A  -- 0x0000 - 0x0007
DAT 0x0004, 0x0004, 0x0100, 0x0200, 0x0400, 0x0800, 0x0014, 0x0005 ; Row 1B  -- 0x0008 - 0x000F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 2A  -- 0x0010 - 0x0017
DAT 0x0004, 0x0004, 0x0104, 0x0104, 0x0104, 0x0004, 0x0014, 0x0004 ; Row 2B  -- 0x0018 - 0x001F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 3A  -- 0x0020 - 0x0027
DAT 0x0004, 0x0004, 0x0104, 0x0004, 0x0104, 0x0004, 0x0014, 0x0004 ; Row 3B  -- 0x0028 - 0x002F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 4A  -- 0x0030 - 0x0037
DAT 0x0004, 0x0004, 0x0104, 0x0104, 0x0104, 0x0004, 0x0014, 0x0004 ; Row 4B  -- 0x0038 - 0x003F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 5A  -- 0x0040 - 0x0047
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0014, 0x0004 ; Row 5B  -- 0x0048 - 0x004F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 6A  -- 0x0050 - 0x0057
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0014, 0x0004 ; Row 6B  -- 0x0058 - 0x005F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 7A  -- 0x0060 - 0x0067
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0014, 0x0004 ; Row 7B  -- 0x0068 - 0x006F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 8A  -- 0x0070 - 0x0077
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0014, 0x0004 ; Row 8B  -- 0x0078 - 0x007F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 9A  -- 0x0080 - 0x0087
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0014, 0x0004 ; Row 9B  -- 0x0088 - 0x008F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 10A -- 0x0090 - 0x0097
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0014, 0x0004 ; Row 10B -- 0x0098 - 0x009F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 11A -- 0x00A0 - 0x00A7
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0014, 0x0004 ; Row 11B -- 0x00A8 - 0x00AF
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 12A -- 0x00B0 - 0x00B7
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0014, 0x1004 ; Row 12B -- 0x00B8 - 0x00BF
:datEndMinefield

; The characters to print for each tile
:datBombs0      DAT 0x0720, 0x0720
:datBombs1      DAT 0x9700, 0x9701
:datBombs2      DAT 0x2702, 0x2703
:datBombs3      DAT 0xC704, 0xC705
:datBombs4      DAT 0x1706, 0x1707
:datBombs5      DAT 0x5708, 0x5709
:datBombs6      DAT 0x370A, 0x370B
:datBombs7      DAT 0x670C, 0x670D
:datBombs8      DAT 0x870E, 0x870F
:datTileCovered DAT 0x0A20, 0x0A20
:datTileFlag    DAT 0x0A10, 0xCA11
:datWinFlag     DAT 0x0A10, 0x5A11
:datTileUnknown DAT 0x0A12, 0x0A13
:datTileMine    DAT 0x0714, 0x0715
:datPlayerGrass DAT 0x0A16, 0x0A17
:datPlayerTile  DAT 0x0716, 0x0717

; The sprite customizations
:datCustomSprites
DAT 0x0000, 0x0044, 0x7E40, 0x0000 ; datBombs1
DAT 0x0000, 0x4462, 0x524C, 0x0000 ; datBombs2
DAT 0x0000, 0x2442, 0x522C, 0x0000 ; datBombs3
DAT 0x0000, 0x0E08, 0x7E08, 0x0000 ; datBombs4
DAT 0x0000, 0x2E4A, 0x4A32, 0x0000 ; datBombs5
DAT 0x0000, 0x3C4A, 0x4A30, 0x0000 ; datBombs6
DAT 0x0000, 0x0262, 0x1A06, 0x0000 ; datBombs7
DAT 0x0000, 0x2C52, 0x522C, 0x0000 ; datBombs8
DAT 0x0000, 0x007E, 0x0E04, 0x0000 ; datTileFlag
DAT 0x0000, 0x0402, 0x520C, 0x0000 ; datTileUnknown
DAT 0x005C, 0x3A76, 0x7E3C, 0x5A00 ; datTileMine
DAT 0x20FE, 0xFF7B, 0x7FFB, 0xFD20 ; datPlayer

; The program's variables
:datClockIndex        DAT 0xFFFF
:datStartScreen       DAT 0x8000
:datEndScreen         DAT 0x817F
:datStartCust         DAT 0x8180
:datEndCust           DAT 0x81B0
:datPlayerLocation    DAT 0x0000
:datIsShifted         DAT 0x0000
:datIsCTRL            DAT 0x0000
:datLose              DAT 0x0000
:datWin               DAT 0x0000
:datMenuOption        DAT 0x0000
:datPrintInstructions DAT 0x0000
:datQuitMenu          DAT 0x0000
:datRandA             DAT 0x3D8A
:datRandT             DAT 0x0000
:datRandX             DAT 0x428F
:datRandY             DAT 0xA327
:datRandZ             DAT 0x4D5D
:quitGame             DAT 0x0000