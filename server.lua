-- server.lua
local cooldowns = {
    heal = {},
    armour = {}
}

local COOLDOWN_TIME = 120000 -- 2 minutes in milliseconds

-- Function to check if player is on cooldown
local function isOnCooldown(playerId, commandType)
    local currentTime = GetGameTimer()
    local lastUsed = cooldowns[commandType][playerId]
    
    if lastUsed and (currentTime - lastUsed) < COOLDOWN_TIME then
        return true, math.ceil((COOLDOWN_TIME - (currentTime - lastUsed)) / 1000)
    end
    
    return false, 0
end

-- Function to set cooldown for player
local function setCooldown(playerId, commandType)
    cooldowns[commandType][playerId] = GetGameTimer()
end

-- Function to clear cooldowns for a player
local function clearCooldowns(playerId)
    cooldowns.heal[playerId] = nil
    cooldowns.armour[playerId] = nil
end

-- Function to format time
local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%d:%02d", minutes, remainingSeconds)
end

-- Heal command
RegisterCommand('heal', function(source, args, rawCommand)
    local playerId = source
    
    local onCooldown, remainingTime = isOnCooldown(playerId, 'heal')
    
    if onCooldown then
        return
    end
    
    setCooldown(playerId, 'heal')
    TriggerClientEvent('healarmour:heal', playerId)
end, false)

-- Armour command
RegisterCommand('armour', function(source, args, rawCommand)
    local playerId = source
    
    local onCooldown, remainingTime = isOnCooldown(playerId, 'armour')
    
    if onCooldown then
        return
    end
    
    setCooldown(playerId, 'armour')
    TriggerClientEvent('healarmour:armour', playerId)
end, false)

-- Handle player death to reset cooldowns
RegisterNetEvent('healarmour:playerDied')
AddEventHandler('healarmour:playerDied', function()
    local playerId = source
    clearCooldowns(playerId)
    print("DEBUG: Cooldowns cleared for player " .. playerId .. " due to death")
end)

-- Debug command to manually reset cooldowns (remove this in production)
RegisterCommand('resetcooldown', function(source, args, rawCommand)
    local playerId = source
    clearCooldowns(playerId)
    print("DEBUG: Cooldowns manually reset for player " .. playerId)
end, false)

-- Clean up when player leaves
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    clearCooldowns(playerId)
end)