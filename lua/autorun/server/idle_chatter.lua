---@diagnostic disable: undefined-global
---@diagnostic disable: inject-field

if ! JaVox then return end

--[[
	Player Inactivity Hook for Garry's Mod

	This script provides a framework to automatically trigger a specified action
	when a player remains inactive for a configurable duration.

	Features:
	- Inactivity detection based on player movement and activity.
	- Configurable inactivity time limit via convar.
	- Enable/disable toggle for the entire system via convar.
	- Data-driven structure for easy management of player states.
	- Placeholder function for the action to be triggered.
]]

-- Configuration Variables
local INACTIVITY_THRESHOLD = 5

-- ConVars
local inactivityEnabledConvar = CreateConVar(
    "javox_inactivity_hook_enabled",
    "1", -- Default to enabled
    { FCVAR_ARCHIVE + FCVAR_REPLICATED },
    "Enables or disables the player inactivity hook."
)

local inactivityThresholdConvar = CreateConVar(
    "javox_inactivity_hook_threshold",
    tostring(INACTIVITY_THRESHOLD),
    { FCVAR_ARCHIVE + FCVAR_REPLICATED },
    "The time in seconds a player must be inactive before triggering the action."
)

-- Data Structure for Player States
-- Stores the last active time for each player.
local playerActivity = {}

local function HandlePlayerInactivityAction(player)
    if IsValid(player) and player:IsPlayer() then
        JaVox.Director:emitActionFromPlayer(player, "self.talk")
    end
end

-- Function to update a player's last active time.
local function UpdatePlayerActivity(player)
    if IsValid(player) and player:IsPlayer() then
        playerActivity[player:SteamID64()] = CurTime()
    end
end

hook.Add("PhysgunPickup", "InactivityHook_PhysgunPickup", function(ply, ent)
    UpdatePlayerActivity(ply)
end)

hook.Add("PlayerButtonDown", "InactivityHook_PlayerButtonDown", function(ply, button)
    UpdatePlayerActivity(ply)
end)

hook.Add("PlayerButtonUp", "InactivityHook_PlayerButtonUp", function(ply, button)
    UpdatePlayerActivity(ply)
end)

hook.Add("PlayerSpawn", "InactivityHook_PlayerSpawn", function(ply)
    UpdatePlayerActivity(ply)
end)

hook.Add("PlayerDeath", "InactivityHook_PlayerDeath", function(ply, attacker, dmginfo)
    UpdatePlayerActivity(ply) -- Consider if death should reset inactivity
end)

hook.Add("PlayerSay", "InactivityHook_PlayerSay", function(ply, text, teamSay)
    UpdatePlayerActivity(ply)
end)

timer.Create("InactivityCheckTimer", 1, 0, function()
    if not inactivityEnabledConvar:GetBool() then
        return
    end

    local threshold = inactivityThresholdConvar:GetFloat()
    local currentTime = CurTime()

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:IsPlayer() then
            local steamID64 = ply:SteamID64()
            local lastActiveTime = playerActivity[steamID64] or currentTime

            if (currentTime - lastActiveTime) > threshold then
                HandlePlayerInactivityAction(ply)
                playerActivity[steamID64] = CurTime() --- restarts
            end
        end
    end
end)

hook.Add("PlayerConnect", "InactivityHook_PlayerConnect", function(ply)
    if IsValid(ply) and ply:IsPlayer() then
        UpdatePlayerActivity(ply)
        ply.inactivityTriggeredThisCycle = false

        -- **steam id is valid here?**
        playerActivity[ply:SteamID64()] = CurTime()
    end
end)

-- Clean up player data when a player disconnects.
hook.Add("PlayerDisconnect", "InactivityHook_PlayerDisconnect", function(ply)
    if IsValid(ply) and ply:IsPlayer() then
        local steamID64 = ply:SteamID64()
        playerActivity[steamID64] = nil
        ply.inactivityTriggeredThisCycle = nil -- Clean up flag
    end
end)

hook.Add("StartCommand", "InactivityHook_TrackTrueMovement", function(ply, cmd)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local buttonsChanged = cmd:GetButtons() ~= 0
    local currentAngles = cmd:GetViewAngles()
    local mouseMoved = false

    if ply.LastTrackedAngles and ply.LastTrackedAngles ~= currentAngles then
        mouseMoved = true
    end

    ply.LastTrackedAngles = currentAngles

    if buttonsChanged or mouseMoved then
        UpdatePlayerActivity(ply)
    end
end)

print("Player Inactivity Hook initialized.")
