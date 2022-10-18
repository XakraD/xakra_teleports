local pcoords = nil
local pdead = nil
local EnterPrompt
local InteriorPrompts = GetRandomIntInRange(0, 0xffffff)
local prompts = {}


local ExitPrompt
local InteriorExitPrompts = GetRandomIntInRange(0, 0xffffff)

function InteriorExitPromptset()
    local str = Config.PromptExit
    ExitPrompt = PromptRegisterBegin()
    PromptSetControlAction(ExitPrompt, Config.KeyEnter)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ExitPrompt, str)
    PromptSetEnabled(ExitPrompt, 1)
    PromptSetVisible(ExitPrompt, 1)
	PromptSetStandardMode(ExitPrompt,1)
	PromptSetGroup(ExitPrompt, InteriorExitPrompts)
	Citizen.InvokeNative(0xC5F428EE08FA7F2C,ExitPrompt,true)
	PromptRegisterEnd(ExitPrompt)

    local str2 = Config.PromptEnter
    EnterPrompt = PromptRegisterBegin()
    PromptSetControlAction(EnterPrompt, Config.keyExit)
    str2 = CreateVarString(10, 'LITERAL_STRING', str2)
    PromptSetText(EnterPrompt, str2)
    PromptSetEnabled(EnterPrompt, 1)
    PromptSetVisible(EnterPrompt, 1)
	PromptSetStandardMode(EnterPrompt,1)
	PromptSetGroup(EnterPrompt, InteriorPrompts)
	Citizen.InvokeNative(0xC5F428EE08FA7F2C,EnterPrompt,true)
	PromptRegisterEnd(EnterPrompt)
end
Citizen.CreateThread(function()
    InteriorExitPromptset()
	while true do
		Citizen.Wait(500)
        pcoords = GetEntityCoords(PlayerPedId())
        pdead = IsEntityDead(PlayerPedId())
    end
end)

Citizen.CreateThread(function()
    for _, location in pairs(Config.Locations) do
        if location.blip.enable == true then
            local blip = N_0x554d9d53f696d002(1664425300, location.enterPos.x, location.enterPos.y,location.enterPos.z)
            SetBlipSprite(blip, location.blip.sprite, 1)
            SetBlipScale(blip, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, location.name)
            local prompt = PromptRegisterBegin()
            prompts[#prompts+1] = prompt
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		local t = 4
        if pcoords ~= nil and (pdead ~= nil and pdead ~= 1) then 
            for i,v in pairs(Config.Locations) do 
                local dist = GetDistanceBetweenCoords(pcoords, v.enterPos, 1)
                local dist2 = nil
                if v.exitPos ~= false then 
                    dist2 = GetDistanceBetweenCoords(pcoords, v.exitPos, 1)
                end
                if v.showentercircle then
                    if dist < 4.0 then
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, v.enterPos.x, v.enterPos.y, v.enterPos.z-1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.4, 0, 128, 0, 20, 0, 0, 2, 0, 0, 0, 0)
                    end
                end
                if v.showexitcircle then
                    if dist2 ~= nil and dist2 < 4.0 and v.exit == true then 
                        Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, v.exitPos.x, v.exitPos.y, v.exitPos.z-1 , 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.4, 0, 128, 0, 20, 0, 0, 2, 0, 0, 0, 0)
                    end
                end
                if dist < 1.2 then 
                    local label  = CreateVarString(10, 'LITERAL_STRING', Config.VarStringEnter..v.name)
                    PromptSetActiveGroupThisFrame(InteriorPrompts, label)
                    if Citizen.InvokeNative(0xC92AC953F0A982AE,EnterPrompt) then
                        TriggerServerEvent("xakra_teleports:setcoords_enter", vector3(v.exitPos.x, v.exitPos.y, v.exitPos.z-1), i, PlayerPedId())
                        Citizen.Wait(2000)
                    end
                end
                if dist2 ~= nil and dist2 < 1.2 and v.exit == true then 
                    local label  = CreateVarString(10, 'LITERAL_STRING', Config.VarStringExit..v.name)
                    PromptSetActiveGroupThisFrame(InteriorExitPrompts, label)
                    if Citizen.InvokeNative(0xC92AC953F0A982AE,ExitPrompt) then
                        TriggerEvent('xakra_teleports:Teleport', vector3(v.enterPos.x, v.enterPos.y, v.enterPos.z-1))
                        Citizen.Wait(2000)
                    end
                end
            end
        else
            t = 2000
        end
        Citizen.Wait(t)
    end
end)

RegisterNetEvent('xakra_teleports:Teleport')
AddEventHandler('xakra_teleports:Teleport', function(coords)
    SetEntityCoords(PlayerPedId(), coords)
end)