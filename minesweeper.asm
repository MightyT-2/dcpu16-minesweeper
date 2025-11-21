; DISPLAY MINEFIELD ****
; TOGGLE SPRITES ****
; PLAYER MOVEMENT ****
; PLAYER ACTIONS
; WIN-LOSE CONDITIONS
; WIN-LOSE SCREENS
; MENU
; GENERATE MINEFIELD
; PRNG

:mainLoop
   JSR displayMinefield
   SET PC, gameLoop

:menuLoop

:gameLoop
   JSR toggleSprites
   :gameLoopback
   JSR displayMinefield
   :waitUserInput
   JSR getKeyboardInput
   IFE A, 0x0000
   SET PC, waitUserInput
   JSR controllerHandler
   SET PC, gameLoopback

:toggleSprites
   SET PUSH, A
   SET PUSH, B
   SET PUSH, C
   
   SET A, customSprites
   SET B, 0
   SET C, [startCust]
   :loopChar
   SET B, [C]
   SET [C], [A]
   SET [A], B
   ADD A, 1
   ADD C, 1
   IFL A, clockIndex
   SET PC, loopChar
   
   SET C, POP
   SET B, POP
   SET A, POP
   SET PC, POP

; Shows the minefield in the 
:displayMinefield
   SET PUSH, A
   SET PUSH, C
   SET PUSH, X
   SET PUSH, Y

   SET C, [startScreen]
   SET X, minefield
   SET PC, enterPrintLoop

   :printLoop
   ADD C, 1
   ADD X, 1
   :enterPrintLoop
   SET Y, 0x0006
   AND Y, [X]
   IFE Y, 0x0002
   SET PC, displayPlayerTile
   IFE Y, 0x0006
   SET PC, displayPlayerGrass
   SET Y, 0x000C
   AND Y, [X]
   IFE Y, 0x000C
   SET PC, displayTileFlag
   IFE Y, 0x0004
   SET PC, displayTileCovered
   SET Y, 0x0001
   AND Y, [X]
   IFE Y, 0x0001
   SET PC, displayTileMine
   SET Y, 0x0010
   AND Y, [X]
   IFE Y, 0x0010
   SET PC, displayBombs1
   SET Y, 0x0020
   AND Y, [X]
   IFE Y, 0x0020
   SET PC, displayBombs2
   SET Y, 0x0040
   AND Y, [X]
   IFE Y, 0x0040
   SET PC, displayBombs3
   SET Y, 0x0080
   AND Y, [X]
   IFE Y, 0x0080
   SET PC, displayBombs4
   SET Y, 0x0100
   AND Y, [X]
   IFE Y, 0x0100
   SET PC, displayBombs5
   SET Y, 0x0200
   AND Y, [X]
   IFE Y, 0x0200
   SET PC, displayBombs6
   SET Y, 0x0400
   AND Y, [X]
   IFE Y, 0x0400
   SET PC, displayBombs7
   SET Y, 0x0800
   AND Y, [X]
   IFE Y, 0x0800
   SET PC, displayBombs8
   SET Y, 0xFFFF
   AND Y, [X]
   IFN Y, 0x0000
   SET PC, displayTileUnknown

   SET A, bombs0
   SET PC, display
   :displayBombs1
   SET A, bombs1
   SET PC, display
   :displayBombs2
   SET A, bombs2
   SET PC, display
   :displayBombs3
   SET A, bombs3
   SET PC, display
   :displayBombs4
   SET A, bombs4
   SET PC, display
   :displayBombs5
   SET A, bombs5
   SET PC, display
   :displayBombs6
   SET A, bombs6
   SET PC, display
   :displayBombs7
   SET A, bombs7
   SET PC, display
   :displayBombs8
   SET A, bombs8
   SET PC, display
   :displayTileCovered
   SET A, tileCovered
   SET PC, display
   :displayTileFlag
   SET A, tileFlag
   SET PC, display
   :displayTileUnknown
   SET A, tileUnknown
   SET PC, display
   :displayTileMine
   SET A, tileMine
   SET PC, display
   :displayPlayerGrass
   SET A, playerGrass
   SET PC, display
   :displayPlayerTile
   SET A, playerTile

   :display
   SET [C], [A]
   ADD C, 1
   ADD A, 1
   SET [C], [A]

   IFL C, [startCust]
   SET PC, printLoop

   SET Y, POP
   SET X, POP
   SET C, POP
   SET A, POP
   SET PC, POP

:getKeyboardInput
   SET PUSH, C
   SET A, 1
   HWI 1
   SET A, C
   SET C, POP
   SET PC, POP

; Initializes the Clock
:initializeClock
   SET PUSH, A
   SET PUSH, B
   SET A, 0
   SET B, 1
   HWI 2
   SET B, POP
   SET A, POP
   SET PC, POP

; Returns the current time
:getTime
   SET PUSH, C
   SET A, 1
   HWI 2
   SET A, C
   SET C, POP
   SET PC, POP

; Requires the A register to hold the pressed key
:controllerHandler
   IFE A, 0x80
   JSR movePlayerUp
   IFE A, 0x81
   JSR movePlayerDown
   IFE A, 0x82
   JSR movePlayerLeft
   IFE A, 0x83
   JSR movePlayerRight
   SET PC, POP

; Moves the Player up one space
:movePlayerUp
   IFL [playerLocation], 0x0010
   SET PC, POP
   SET PUSH, C
   SET C, minefield
   ADD C, [playerLocation]
   XOR [C], 0x0002
   SUB [playerLocation], 0x0010
   SUB C, 0x0010
   XOR [C], 0x0002
   SET C, POP
   SET PC, POP

; Moves the Player down one space
:movePlayerDown
   IFG [playerLocation], 0x00AF
   SET PC, POP
   SET PUSH, C
   SET C, minefield
   ADD C, [playerLocation]
   XOR [C], 0x0002
   ADD [playerLocation], 0x0010
   ADD C, 0x0010
   XOR [C], 0x0002
   SET C, POP
   SET PC, POP

; Moves the Player left one space
:movePlayerLeft
   SET PUSH, A
   SET A, [playerLocation]
   MOD A, 0x0010
   IFE A, 0x0000
   SET PC, exitMovePlayerLeft
   SET PUSH, C
   SET C, minefield
   ADD C, [playerLocation]
   XOR [C], 0x0002
   SUB [playerLocation], 0x0001
   SUB C, 0x0001
   XOR [C], 0x0002
   SET C, POP
   :exitMovePlayerLeft
   SET A, POP
   SET PC, POP

; Moves the Player right one space
:movePlayerRight
   SET PUSH, A
   SET A, [playerLocation]
   MOD A, 0x0010
   SET modResults, A
   IFE A, 0x000F
   SET PC, exitMovePlayerRight
   SET PUSH, C
   SET C, minefield
   ADD C, [playerLocation]
   XOR [C], 0x0002
   ADD [playerLocation], 0x0001
   ADD C, 0x0001
   XOR [C], 0x0002
   SET C, POP
   :exitMovePlayerRight
   SET A, POP
   SET PC, POP

:digDown
   SET PUSH, A
   SET PUSH, C
   SET C, minefield
   SET C, [playerLocation]
   SET A, [C]
   AND A, 0x0004
   IFE A, 0x0000
   SET PC, exitDigDown
   XOR [C], 0x0004
   :exitDigDown
   SET C, POP
   SET A, POP
   SET PC, POP

:digNorth
   SET PUSH, A
   SET PUSH, C
   SET C, [playerLocation]
   IFL C, 0x0010
   SET PC, exitDigNorth
   SUB C, 0x0010
   SET A, [C]
   AND A, 0x0004
   IFE A, 0x0000
   SET PC, exitDigNorth
   XOR [C], 0x0004
   :exitDigNorth
   SET C, POP
   SET A, POP
   SET PC, POP

:digNorthEast
   SET PUSH, A
   SET PUSH, C
   SET C, [playerLocation]
   IFL C, 0x0010
   SET PC, exitDigNorthEast
   SET A, C
   MOD A, 0x0010
   IFE A, 0x0000
   SET PC, exitDigNorthEast
   SUB C, 0x000F
   SET A, [C]
   AND A, 0x0004
   IFE A, 0x0000
   SET PC, exitDigNorthEast
   XOR [C], 0x0004
   :exitDigNorthEast
   SET C, POP
   SET A, POP
   SET PC, POP

:digEast
   SET PUSH, A
   SET PUSH, C
   :exitDigEast
   SET C, POP
   SET A, POP
   SET PC, POP

:digSouthEast
   SET PUSH, A
   SET PUSH, C
   :exitDigSouthEast
   SET C, POP
   SET A, POP
   SET PC, POP

:digSouth
   SET PUSH, A
   SET PUSH, C
   :exitDigSouth
   SET C, POP
   SET A, POP
   SET PC, POP

:digSouthWest
   SET PUSH, A
   SET PUSH, C
   :exitDigSouthWest
   SET C, POP
   SET A, POP
   SET PC, POP

:digWest
   SET PUSH, A
   SET PUSH, C
   :exitDigWest
   SET C, POP
   SET A, POP
   SET PC, POP

:digNorthWest
   SET PUSH, A
   SET PUSH, C
   :exitDigNorthWest
   SET C, POP
   SET A, POP
   SET PC, POP

:mineCount

:generateMinefield


; Breakdown of minefield values
; first four bits - null
; next eight bits - numberOfBombs
; next bit        - isFlagged
; next bit        - isCovered
; next bit        - isPlayer
; next bit        - isBomb
; 0000000000000000
; 0000nnnnnnnnfcpb

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                          Menu Functions                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                          Game Functions                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





:minefield                                                         ; Row Nos.    Player Location
DAT 0x0002, 0x0000, 0x0004, 0x000C, 0x0010, 0x0020, 0x0040, 0x0080 ; Row 1A  -- 0x0000 - 0x0007
DAT 0x0004, 0x0004, 0x0100, 0x0200, 0x0400, 0x0800, 0x0004, 0x0004 ; Row 1B  -- 0x0008 - 0x000F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 2A  -- 0x0010 - 0x0017
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 2B  -- 0x0018 - 0x001F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 3A  -- 0x0020 - 0x0027
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 3B  -- 0x0028 - 0x002F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 4A  -- 0x0030 - 0x0037
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 4B  -- 0x0038 - 0x003F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 5A  -- 0x0040 - 0x0047
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 5B  -- 0x0048 - 0x004F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 6A  -- 0x0050 - 0x0057
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 6B  -- 0x0058 - 0x005F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 7A  -- 0x0060 - 0x0067
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 7B  -- 0x0068 - 0x006F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 8A  -- 0x0070 - 0x0077
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 8B  -- 0x0078 - 0x007F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 9A  -- 0x0080 - 0x0087
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 9B  -- 0x0088 - 0x008F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 10A -- 0x0090 - 0x0097
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 10B -- 0x0098 - 0x009F
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 11A -- 0x00A0 - 0x00A7
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 11B -- 0x00A8 - 0x00AF
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 12A -- 0x00B0 - 0x00B7
DAT 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004 ; Row 12B -- 0x00B8 - 0x00BF

; Sprite Characters
:bombs0      DAT 0x0720, 0x0720
:bombs1      DAT 0x9700, 0x9701
:bombs2      DAT 0x2702, 0x2703
:bombs3      DAT 0xC704, 0xC705
:bombs4      DAT 0x1706, 0x1707
:bombs5      DAT 0x5708, 0x5709
:bombs6      DAT 0x370A, 0x370B
:bombs7      DAT 0x670C, 0x670D
:bombs8      DAT 0x870E, 0x870F
:tileCovered DAT 0x0A20, 0x0A20
:tileFlag    DAT 0x0A10, 0xCA11
:tileUnknown DAT 0x0A12, 0x0A13
:tileMine    DAT 0x0714, 0x0715
:playerGrass DAT 0x0A16, 0x0A17
:playerTile  DAT 0x0716, 0x0717

:customSprites
DAT 0x0000, 0x0044, 0x7E40, 0x0000 ; bombs1
DAT 0x0000, 0x4462, 0x524C, 0x0000 ; bombs2
DAT 0x0000, 0x2442, 0x522C, 0x0000 ; bombs3
DAT 0x0000, 0x0E08, 0x7E08, 0x0000 ; bombs4
DAT 0x0000, 0x2E4A, 0x4A32, 0x0000 ; bombs5
DAT 0x0000, 0x3C4A, 0x4A30, 0x0000 ; bombs6
DAT 0x0000, 0x0262, 0x1A06, 0x0000 ; bombs7
DAT 0x0000, 0x2C52, 0x522C, 0x0000 ; bombs8
DAT 0x0000, 0x007E, 0x0E04, 0x0000 ; tileFlag
DAT 0x0000, 0x0402, 0x520C, 0x0000 ; tileUnknonw
DAT 0x005C, 0x3A76, 0x7E3C, 0x5A00 ; tileMine
DAT 0x20FE, 0xFF7B, 0x7FFB, 0xFD20 ; player

:clockIndex     DAT 0xFFFF
:startScreen    DAT 0x8000
:startCust      DAT 0x8180
:endCust        DAT 0x81B0
:playerLocation DAT 0x0000
:modResults     DAT 0x0000