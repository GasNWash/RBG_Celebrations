SafariZoneGate_Script:
	call EnableAutoTextBoxDrawing
	ld hl, SafariZoneGate_ScriptPointers
	ld a, [wSafariZoneGateCurScript]
	jp CallFunctionInTable

SafariZoneGate_ScriptPointers:
	def_script_pointers
	dw_const SafariZoneGateDefaultScript,                SCRIPT_SAFARIZONEGATE_DEFAULT
	dw_const SafariZoneGatePlayerMovingRightScript,      SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_RIGHT
	dw_const SafariZoneGateWouldYouLikeToJoinScript,     SCRIPT_SAFARIZONEGATE_WOULD_YOU_LIKE_TO_JOIN
	dw_const SafariZoneGatePlayerMovingUpScript,         SCRIPT_SAFARIZONEGATE_PLAYER_MOVING
	dw_const SafariZoneGatePlayerMovingDownScript,       SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_DOWN
	dw_const SafariZoneGateLeavingSafariScript,          SCRIPT_SAFARIZONEGATE_LEAVING_SAFARI
	dw_const SafariZoneGateSetScriptAfterMoveScript,     SCRIPT_SAFARIZONEGATE_SET_SCRIPT_AFTER_MOVE
	dw_const SafariZoneGateScript7,                      SCRIPT_SAFARIZONEGATE_7
	EXPORT SCRIPT_SAFARIZONEGATE_LEAVING_SAFARI ; used by engine/events/hidden_objects/safari_game.asm

SafariZoneGateDefaultScript:
	ld hl, .PlayerNextToSafariZoneWorker1CoordsArray
	call ArePlayerCoordsInArray
	ret nc
	ld a, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_1
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, A_BUTTON | B_BUTTON | SELECT | START | D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	xor a
	ldh [hJoyHeld], a
	ld a, SPRITE_FACING_RIGHT
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, [wCoordIndex]
	cp 1 ; index of second, lower entry in .PlayerNextToSafariZoneWorker1CoordsArray
	jr z, .player_not_next_to_worker
	ld a, SCRIPT_SAFARIZONEGATE_WOULD_YOU_LIKE_TO_JOIN
	ld [wSafariZoneGateCurScript], a
	ret
.player_not_next_to_worker
	ld a, D_RIGHT
	ld c, 1
	call SafariZoneEntranceAutoWalk
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_RIGHT
	ld [wSafariZoneGateCurScript], a
	ret

.PlayerNextToSafariZoneWorker1CoordsArray:
	dbmapcoord  3,  2
	dbmapcoord  4,  2
	db -1 ; end

SafariZoneGatePlayerMovingRightScript:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
SafariZoneGateWouldYouLikeToJoinScript:
	xor a
	ldh [hJoyHeld], a
	ld [wJoyIgnore], a
	call UpdateSprites
	ld a, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_WOULD_YOU_LIKE_TO_JOIN
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, A_BUTTON | B_BUTTON | SELECT | START | D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ret

SafariZoneGatePlayerMovingUpScript:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, SCRIPT_SAFARIZONEGATE_LEAVING_SAFARI
	ld [wSafariZoneGateCurScript], a
	ret

SafariZoneGateLeavingSafariScript:
	ld a, PLAYER_DIR_DOWN
	ld [wPlayerMovingDirection], a
	CheckAndResetEvent EVENT_SAFARI_GAME_OVER
	jr z, .leaving_early
	ResetEventReuseHL EVENT_IN_SAFARI_ZONE
	call UpdateSprites
	ld a, D_RIGHT | D_LEFT | D_UP | D_DOWN
	ld [wJoyIgnore], a
	ld a, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_GOOD_HAUL_COME_AGAIN
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	xor a
	ld [wNumSafariBalls], a
	ld a, D_DOWN
	ld c, 3
	call SafariZoneEntranceAutoWalk
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_DOWN
	ld [wSafariZoneGateCurScript], a
	jr .return
.leaving_early
	ld a, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_LEAVING_EARLY
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
.return
	ret

SafariZoneGatePlayerMovingDownScript:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
	xor a
	ld [wJoyIgnore], a
	ld a, SCRIPT_SAFARIZONEGATE_DEFAULT
	ld [wSafariZoneGateCurScript], a
	ret

SafariZoneGateSetScriptAfterMoveScript:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
	call Delay3
	ld a, [wNextSafariZoneGateScript]
	ld [wSafariZoneGateCurScript], a
	ret

SafariZoneGateScript7:
	call SafariZoneGateReturnSimulatedJoypadStateScript
	ret nz
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, $9
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld a, D_DOWN
	ld c, $1
	call SafariZoneEntranceAutoWalk
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_DOWN
	ld [wSafariZoneGateCurScript], a
	ret

SafariZoneEntranceAutoWalk:
	push af
	ld b, 0
	ld a, c
	ld [wSimulatedJoypadStatesIndex], a
	ld hl, wSimulatedJoypadStatesEnd
	pop af
	call FillMemory
	jp StartSimulatingJoypadStates

SafariZoneGateReturnSimulatedJoypadStateScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret

SafariZoneGate_TextPointers:
	def_text_pointers
	dw_const SafariZoneGateSafariZoneWorker1Text,                   TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1
	dw_const SafariZoneGateSafariZoneWorker2Text,                   TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER2
	dw_const SafariZoneGateSafariZoneWorker1Text,                   TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_1
	dw_const SafariZoneGateSafariZoneWorker1WouldYouLikeToJoinText, TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_WOULD_YOU_LIKE_TO_JOIN
	dw_const SafariZoneGateSafariZoneWorker1LeavingEarlyText,       TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_LEAVING_EARLY
	dw_const SafariZoneGateSafariZoneWorker1GoodHaulComeAgainText,  TEXT_SAFARIZONEGATE_SAFARI_ZONE_WORKER1_GOOD_HAUL_COME_AGAIN

SafariZoneGateSafariZoneWorker1Text:
	text_far _SafariZoneGateSafariZoneWorker1Text
	text_end

SafariZoneGateSafariZoneWorker1WouldYouLikeToJoinText:
	text_far _SafariZoneGateSafariZoneWorker1WouldYouLikeToJoinText
	text_asm
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .PleaseComeAgain
	xor a
	ldh [hMoney], a
	ldh [hMoney + 2], a
	ld a, 5
	ldh [hMoney + 1], a
	call HasEnoughMoney
	jr nc, .success
	ld hl, .NotEnoughMoneyText
	rst _PrintText
	jr .CantPayWalkDown

.success
	xor a
	ld [wPriceTemp], a
	ld [wPriceTemp + 2], a
	ld a, 5
	ld [wPriceTemp + 1], a
	ld hl, wPriceTemp + 2
	ld de, wPlayerMoney + 2
	ld c, 3
	predef SubBCDPredef
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID
	ld hl, .MakePaymentText
	rst _PrintText
	call AskGameType
	jr c, .PleaseComeAgain
	ld a, D_UP
	ld c, 3
	call SafariZoneEntranceAutoWalk
	SetEvent EVENT_IN_SAFARI_ZONE
	ResetEventReuseHL EVENT_SAFARI_GAME_OVER
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING
	ld [wSafariZoneGateCurScript], a
	jr .done

.PleaseComeAgain
	ld hl, .PleaseComeAgainText
	rst _PrintText
.CantPayWalkDown
	ld a, D_DOWN
	ld c, 1
	call SafariZoneEntranceAutoWalk
	ld a, SCRIPT_SAFARIZONEGATE_PLAYER_MOVING_DOWN
	ld [wSafariZoneGateCurScript], a
.done
	rst TextScriptEnd

.MakePaymentText
	text_far _SafariZoneGateSafariZoneWorker1ThatllBe500PleaseText
;	sound_get_item_1
;	text_far _SafariZoneGateSafariZoneWorker1CallYouOnThePAText
	text_end

.PleaseComeAgainText
	text_far _SafariZoneGateSafariZoneWorker1PleaseComeAgainText
	text_end

.NotEnoughMoneyText
	text_far _SafariZoneGateSafariZoneWorker1NotEnoughMoneyText
	text_end

SafariZoneGateSafariZoneWorker1LeavingEarlyText:
	text_far _SafariZoneGateSafariZoneWorker1LeavingEarlyText
	text_asm
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr nz, .not_ready_to_leave
	ld hl, .ReturnSafariBallsText
	rst _PrintText
	xor a
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, D_DOWN
	ld c, 3
	call SafariZoneEntranceAutoWalk
	ResetEvents EVENT_SAFARI_GAME_OVER, EVENT_IN_SAFARI_ZONE
	ld a, SCRIPT_SAFARIZONEGATE_DEFAULT
	ld [wNextSafariZoneGateScript], a
	jr .set_current_script
.not_ready_to_leave
	ld hl, .GoodLuckText
	rst _PrintText
	ld a, SPRITE_FACING_UP
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, D_UP
	ld c, 1
	call SafariZoneEntranceAutoWalk
	ld a, SCRIPT_SAFARIZONEGATE_LEAVING_SAFARI
	ld [wNextSafariZoneGateScript], a
.set_current_script
	ld a, SCRIPT_SAFARIZONEGATE_SET_SCRIPT_AFTER_MOVE
	ld [wSafariZoneGateCurScript], a
	rst TextScriptEnd

.ReturnSafariBallsText
	text_far _SafariZoneGateSafariZoneWorker1ReturnSafariBallsText
	text_end

.GoodLuckText
	text_far _SafariZoneGateSafariZoneWorker1GoodLuckText
	text_end

PleaseComeAgainText:
	text_far _SafariZoneGateSafariZoneWorker1PleaseComeAgainText
	text_end

SafariZoneGateSafariZoneWorker1GoodHaulComeAgainText:
	text_far _SafariZoneGateSafariZoneWorker1GoodHaulComeAgainText
	text_end

SafariZoneGateSafariZoneWorker2Text:
	text_asm
	ld hl, .FirstTimeHereText
	rst _PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ld hl, .YoureARegularHereText
	jr nz, .print_text
	call AskGameTypeExplanation
	jr c, .noSelection
	rst TextScriptEnd
.noSelection
	ld hl, .YoureARegularHereText
.print_text
	rst _PrintText
	rst TextScriptEnd

.FirstTimeHereText
	text_far _SafariZoneGateSafariZoneWorker2FirstTimeHereText
	text_end

.SafariZoneExplanationText
	text_far _SafariZoneGateSafariZoneWorker2SafariZoneExplanationText
	text_end

.YoureARegularHereText
	text_far _SafariZoneGateSafariZoneWorker2YoureARegularHereText
	text_end

SafariZoneEntranceConvertBCDtoNumber:
	push hl
	ld c, a
	and $f
	ld l, a
	ld h, $0
	ld a, c
	and $f0
	swap a
	ld bc, 10
	call AddNTimes
	ld a, l
	pop hl
	ret

AskGameType:
	ld hl, SafariZoneEntranceWhatGame
	rst _PrintText
	ld hl, SafariTypeOptions
	ld b, A_BUTTON | B_BUTTON
	call DisplayMultiChoiceTextBox
	jr nz, .goodbye
	ld hl, TextPointers_SafariGames
	ld a, [wCurrentMenuItem]
	call GetAddressFromPointerArray
	rst _PrintText
	and a
	ret
.goodbye
	; give back the 500 that was just deducted
	ld de, wPlayerMoney + 2
	ld hl, hMoney + 2 ; total price of items
	ld c, 3 ; length of money in bytes
	predef AddBCDPredef ; add total price to money
	ld a, MONEY_BOX
	ld [wTextBoxID], a
	call DisplayTextBoxID ; redraw money text box
	scf
	ret

TextPointers_SafariGames:
	dw SafariClassicPaidInfo
	dw SafariFreeRoamPaidInfo

SafariZoneEntranceWhatGame:
	text_far _SafariZoneEntranceWhatGame
	text_end

SafariZoneEntranceSafariBallsReceived:
	text_far _SafariZoneEntranceSafariBallsReceived
	sound_get_item_1
	text_end

SafariZonePAText:
	text_far _SafariZoneEntranceText_75360
	text_end

SafariClassicPaidInfo:
	text_asm
	ld hl, SafariZoneClassicText
	rst _PrintText
	ld hl, SafariZoneEntranceSafariBallsReceived
	rst _PrintText
	ld hl, SafariZonePAText
	rst _PrintText
	ld a, 30
	ld [wNumSafariBalls], a
	ld a, HIGH(502)
	ld [wSafariSteps], a
	ld a, LOW(502)
	ld [wSafariSteps + 1], a
	ld a, SAFARI_TYPE_CLASSIC
	ld [wSafariType], a
	rst TextScriptEnd


SafariFreeRoamPaidInfo:
	text_asm
	ld hl, SafariZoneFreeRoam
	rst _PrintText
	xor a
	ld [wNumSafariBalls], a
	ld a, SAFARI_TYPE_FREE_ROAM
	ld [wSafariType], a
	rst TextScriptEnd

SafariZoneClassicText:
	text_far _SafariZoneClassic
	text_end

SafariZoneFreeRoam:
	text_far _SafariZoneFreeRoam
	text_end

AskGameTypeExplanation:
	ld hl, SafariZoneHelp
	rst _PrintText
	ld hl, SafariTypeOptions
	ld b, A_BUTTON | B_BUTTON
	call DisplayMultiChoiceTextBox
	jr nz, .goodbye
	ld hl, TextPointers_SafariExplanations
	ld a, [wCurrentMenuItem]
	call GetAddressFromPointerArray
	rst _PrintText
	and a
	ret
.goodbye
	scf
	ret

TextPointers_SafariExplanations:
	dw ExplanationText
	dw SafariZoneFreeRoam

SafariZoneHelp:
	text_far _SafariZoneHelp
	text_end

ExplanationText:
	text_far _SafariZoneGateSafariZoneWorker2SafariZoneExplanationText
	text_end
