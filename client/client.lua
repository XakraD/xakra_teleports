local pcoords = nil
local pdead = nil

local EnterPrompt
local InteriorPrompts = GetRandomIntInRange(0, 0xffffff)

local ExitPrompt
local InteriorExitPrompts = GetRandomIntInRange(0, 0xffffff)

CreateThread(function()
    ExitPrompt = PromptRegisterBegin()
    UiPromptSetControlAction(ExitPrompt, Config.KeyEnter)
    local VarString = CreateVarString(10, 'LITERAL_STRING', Config.PromptExit)
    UiPromptSetText(ExitPrompt, VarString)
    UiPromptSetEnabled(ExitPrompt, true)
    UiPromptSetVisible(ExitPrompt, true)
	UiPromptSetHoldMode(ExitPrompt, 1000)
	UiPromptSetGroup(ExitPrompt, InteriorExitPrompts)
	UiPromptRegisterEnd(ExitPrompt)

    EnterPrompt = PromptRegisterBegin()
    UiPromptSetControlAction(EnterPrompt, Config.KeyExit)
    local VarString = CreateVarString(10, 'LITERAL_STRING', Config.PromptEnter)
    UiPromptSetText(EnterPrompt, VarString)
    UiPromptSetEnabled(EnterPrompt, true)
    UiPromptSetVisible(EnterPrompt, true)
	UiPromptSetHoldMode(EnterPrompt, 1000)
	UiPromptSetGroup(EnterPrompt, InteriorPrompts)
	UiPromptRegisterEnd(EnterPrompt)
end)

CreateThread(function()
	while true do
        pcoords = GetEntityCoords(PlayerPedId())
        pdead = IsEntityDead(PlayerPedId())
        Wait(500)
    end
end)

CreateThread(function()
    for _, location in pairs(Config.Locations) do
        if location.blip.enable == true then
            local blip = BlipAddForCoords(1664425300, location.enterPos)
            SetBlipSprite(blip, location.blip.sprite, 1)
            SetBlipName(blip, location.name)
        end
    end

	while true do
		local t = 500

        if pcoords and not pdead then 
            for _, v in pairs(Config.Locations) do 
                local dist = GetDistanceBetweenCoords(pcoords, v.enterPos, true)
                local dist2

                if v.exit then 
                    dist2 = GetDistanceBetweenCoords(pcoords, v.exitPos, true)
                end

                if dist < 4 or (dist2 and dist2 < 4) then
                    t = 0
                end

                if v.showentercircle then
                    if dist < 4 then
                        DrawMarker(0x94FDAE17, v.enterPos.x, v.enterPos.y, v.enterPos.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.4, 
                        Config.DrawMarkerColor.r, Config.DrawMarkerColor.g, Config.DrawMarkerColor.b, 20, 0, 0, 2, 0, 0, 0, 0)
                    end
                end

                if v.showexitcircle then
                    if v.exit and dist2 < 4 then 
                        DrawMarker(0x94FDAE17, v.exitPos.x, v.exitPos.y, v.exitPos.z - 1 , 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.4, 
                        Config.DrawMarkerColor.r, Config.DrawMarkerColor.g, Config.DrawMarkerColor.b, 20, 0, 0, 2, 0, 0, 0, 0)
                    end
                end

                if dist < 2 then 
                    local label = CreateVarString(10, 'LITERAL_STRING', Config.VarStringEnter..v.name)
                    UiPromptSetActiveGroupThisFrame(InteriorPrompts, label)

                    if UiPromptHasHoldModeCompleted(EnterPrompt) then
                        TriggerServerEvent("xakra_teleports:setcoords_enter", vector3(v.exitPos.x, v.exitPos.y, v.exitPos.z - 1), v.job)
                        Wait(2000)
                    end

                elseif dist2 and v.exit and dist2 < 2 then 
                    local label = CreateVarString(10, 'LITERAL_STRING', Config.VarStringExit..v.name)
                    UiPromptSetActiveGroupThisFrame(InteriorExitPrompts, label)

                    if UiPromptHasHoldModeCompleted(ExitPrompt) then
                        TriggerEvent('xakra_teleports:Teleport', vector3(v.enterPos.x, v.enterPos.y, v.enterPos.z - 1))
                        Wait(2000)
                    end
                end
            end
        end

        Wait(t)
    end
end)

RegisterNetEvent('xakra_teleports:Teleport')
AddEventHandler('xakra_teleports:Teleport', function(coords)
    DoScreenFadeOut(2000)
    repeat Wait(2000) until IsScreenFadedOut()

    SetEntityCoords(PlayerPedId(), coords)
    Wait(1000)

    DoScreenFadeIn(2000)
	repeat Wait(500) until IsScreenFadedIn()
end)