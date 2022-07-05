local VorpCore = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)


RegisterServerEvent("xakra_teleports:setcoords_enter")
AddEventHandler("xakra_teleports:setcoords_enter", function(x,y,z, id)
    local _source = source
    local _x, _y, _z = x,y,z
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
            SetEntityCoords(GetPlayerPed(_source), x, y, z)
        end
    else
        SetEntityCoords(GetPlayerPed(_source), x, y, z)
    end
end)

RegisterServerEvent("xakra_teleports:setcoords_exit")
AddEventHandler("xakra_teleports:setcoords_exit", function(x,y,z)
    local _source = source
    local _x, _y, _z = x,y,z
    SetEntityCoords(GetPlayerPed(_source), x, y, z-0.5)
end)

