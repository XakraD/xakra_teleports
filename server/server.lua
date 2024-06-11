local VORPcore = exports.vorp_core:GetCore()

RegisterServerEvent("xakra_teleports:setcoords_enter")
AddEventHandler("xakra_teleports:setcoords_enter", function(coords, jobs)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter

    if jobs then
        local hasjob = false

        for _, v in pairs(jobs or {}) do 
            if v == job then 
                hasjob = true
                break
            end
        end

        if not hasjob then
            VORPcore.NotifyObjective(_source, Config.JobMessage, 6000)
            return
        end
    end

    TriggerClientEvent('xakra_teleports:Teleport', _source, coords)
end)

