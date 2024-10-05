DisplayStartMenu::
	ld a, BANK(StartMenu_Pokedex)
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	ld a, [wWalkBikeSurfState] ; walking/biking/surfing
	ld [wWalkBikeSurfStateCopy], a
	ld a, SFX_START_MENU
	call PlaySound

RedisplayStartMenu::
	farcall DrawStartMenu
	farcall PrintSafariZoneSteps ; print Safari Zone info, if in Safari Zone
	call UpdateSprites
.loop
	call HandleMenuInput
	ld b, a
.checkIfUpPressed
	bit BIT_D_UP, a
	jr z, .checkIfDownPressed
	ld a, [wCurrentMenuItem] ; menu selection
	and a
	jr nz, .loop
	ld a, [wLastMenuItem]
	and a
	jr nz, .loop
; if the player pressed tried to go past the top item, wrap around to the bottom
	CheckEvent EVENT_GOT_POKEDEX
	ld a, 7 ; there are 8 menu items with the pokedex, so the max index is 6
	jr nz, .wrapMenuItemId
	ld a, 5 ; there are only 5 menu items without the pokedex + portable pc
.wrapMenuItemId
	ld [wCurrentMenuItem], a
	call EraseMenuCursor
	jr .loop
.checkIfDownPressed
	bit BIT_D_DOWN, a
	jr z, .buttonPressed
; if the player pressed tried to go past the bottom item, wrap around to the top
	CheckEvent EVENT_GOT_POKEDEX
	ld a, [wCurrentMenuItem]
	ld c, 8 ; there are 8 menu items with the pokedex + portablepc
	jr nz, .checkIfPastBottom
	ld c, 6 ; edited, there are only 6 menu items without the pokedex
.checkIfPastBottom
	cp c
	jr nz, .loop
; the player went past the bottom, so wrap to the top
	xor a
	ld [wCurrentMenuItem], a
	call EraseMenuCursor
	jr .loop
.buttonPressed ; A, B, or Start button pressed
	call PlaceUnfilledArrowMenuCursor
	ld a, [wCurrentMenuItem]
	ld [wBattleAndStartSavedMenuItem], a ; save current menu selection
	ld a, b
	and B_BUTTON | START ; was the Start button or B button pressed?
	jp nz, CloseStartMenu
	call SaveScreenTilesToBuffer2 ; copy background from wTileMap to wTileMapBackup2
	CheckEvent EVENT_GOT_POKEDEX
	ld a, [wCurrentMenuItem]
	jr nz, .displayMenuItem
	inc a ; adjust position to account for missing pokedex menu item; from my understanding and testings this can stay the same, but please check
.displayMenuItem
	cp 0
	jp z, StartMenu_Pokedex
	cp 1
	jp z, StartMenu_Pokemon
	cp 2
	jp z, StartMenu_Item
	cp 3
	jp z, StartMenu_TrainerInfo
	cp 4
	jp z, StartMenu_SaveReset
	cp 5
	jp z, StartMenu_Option
; new/edited
	cp 6
	jp z, .exitOrPortablePC
	jr CloseStartMenu

.exitOrPortablePC
	CheckEvent EVENT_GOT_POKEDEX
	jr z, CloseStartMenu
	jp StartMenu_PortablePC
; back to vanilla

; EXIT falls through to here
CloseStartMenu::
	call Joypad
	ldh a, [hJoyPressed]
	bit BIT_A_BUTTON, a
	jr nz, CloseStartMenu
	call LoadTextBoxTilePatterns
	jp CloseTextDisplay