-- client.lua
-- Handle heal event
RegisterNetEvent('healarmour:heal')
AddEventHandler('healarmour:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200) -- Set to 200 for full health
end)

-- Handle armour event
RegisterNetEvent('healarmour:armour')
AddEventHandler('healarmour:armour', function()
    local ped = PlayerPedId()
    SetPedArmour(ped, 100)
end)

-- Listen for baseevents (most servers have this)
AddEventHandler('baseevents:onPlayerDied', function()
    TriggerServerEvent('healarmour:playerDied')
end)

AddEventHandler('baseevents:onPlayerKilled', function()
    TriggerServerEvent('healarmour:playerDied')
end)

-- Backup death detection method
local wasAlive = true
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- Check every 500ms
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        local isDead = IsEntityDead(ped)
        
        -- If player just died
        if isDead and wasAlive then
            wasAlive = false
            TriggerServerEvent('healarmour:playerDied')
        elseif not isDead and not wasAlive then
            -- Player is alive again
            wasAlive = true
        end
    end
end)