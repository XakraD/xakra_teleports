local VorpCore = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)


RegisterServerEvent("xakra_teleports:setcoords_enter")
AddEventHandler("xakra_teleports:setcoords_enter", function(coords, id)
    local _source = source
    local _id = tonumber(id)
    if Config.Locations[_id].job ~= false then 
        local job = nil
        local Character = VorpCore.getUser(_source).getUsedCharacter
        job = Character.job

        while job == nil do 
            Citizen.Wait(200)
        end
        local hasjob = false
        for i,v in pairs(Config.Locations[_id].job) do 
            if v == job then 
                hasjob = true
                break
            end
        end
        if hasjob == false then 
            TriggerClientEvent("vorp:TipRight", _source, Config.JobMessage, 6000) 
        elseif hasjob == true then 
            TriggerClientEvent('xakra_teleports:Teleport', _source, coords)
        end
    else
        TriggerClientEvent('xakra_teleports:Teleport', _source, coords)
    end
end)

