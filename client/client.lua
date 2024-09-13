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
    for _, v in pairs(Config.Locations) do
        if v.blip.enable then
            v.BlipHandle = BlipAddForCoords(1664425300, v.enterPos)
            SetBlipSprite(v.BlipHandle, v.blip.sprite, 1)
            SetBlipName(v.BlipHandle, v.name)
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
                        TriggerServerEvent("xakra_teleports:setcoords_enter", v, vector3(v.exitPos.x, v.exitPos.y, v.exitPos.z - 1), v.job)
                        Wait(2000)
                    end

                elseif dist2 and v.exit and dist2 < 2 then 
                    local label = CreateVarString(10, 'LITERAL_STRING', Config.VarStringExit..v.name)
                    UiPromptSetActiveGroupThisFrame(InteriorExitPrompts, label)

                    if UiPromptHasHoldModeCompleted(ExitPrompt) then
                        TriggerEvent('xakra_teleports:Teleport', v, vector3(v.enterPos.x, v.enterPos.y, v.enterPos.z - 1))
                        Wait(2000)
                    end
                end
            end
        end

        Wait(t)
    end
end)

RegisterNetEvent('xakra_teleports:Teleport')
AddEventHandler('xakra_teleports:Teleport', function(DataLocation, coords)
    FreezeEntityPosition(PlayerPedId(), true)
    TaskStandStill(PlayerPedId(), -1)

    DoScreenFadeOut(2000)
    repeat Wait(2000) until IsScreenFadedOut()

    SetEntityCoords(PlayerPedId(), coords)
    Wait(DataLocation.Wait or 1000)

    ClearPedTasks(PlayerPedId())
    TaskStandStill(PlayerPedId(), -1)

    DoScreenFadeIn(2000)
	repeat Wait(500) until IsScreenFadedIn()

    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    for _, v in pairs(Config.Locations) do
        if DoesBlipExist(v.BlipHandle) then
            RemoveBlip(v.BlipHandle)
        end
    end
end)