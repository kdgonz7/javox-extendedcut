---@diagnostic disable: undefined-global
-- cvars to control the falling threshold
-- You can change this value in the console using:
-- gmod_falling_threshold 5
local FALL_THRESHOLD = CreateConVar(
    "javox_falling_threshold", -- ConVar name
    "3.0",                     -- Default value (seconds)
    { FCVAR_ARCHIVE },         -- Make it save with the user's config
    "Maximum time (in seconds) a player can fall before triggering an action."
)

local playerFallStartTime = {}
local playerFallingActionTriggered = {}

hook.Add("Think", "CheckPlayerFalling", function()
    for _, ply in pairs(player.GetAll()) do
        -- Only proceed if it's a valid player and not an NPC
        if not IsValid(ply) or ply:IsNPC() then return end

        local currentTime = CurTime()
        local plyIndex = ply:UserID() -- Use UserID to uniquely identify players

        if ply:OnGround() then
            playerFallStartTime[plyIndex] = nil
            playerFallingActionTriggered[plyIndex] = false
            return
        end

        if not playerFallStartTime[plyIndex] then
            playerFallStartTime[plyIndex] = currentTime
            playerFallingActionTriggered[plyIndex] = false
        end

        local startTime = playerFallStartTime[plyIndex]
        local fallDuration = currentTime - startTime
        local threshold = FALL_THRESHOLD:GetFloat()

        -- TODO: test this thoroughly through steam inputs, etc.
        if fallDuration > threshold and not playerFallingActionTriggered[plyIndex] then
            if JaVox and JaVox.Director and JaVox.Director.emitActionFromPlayer then
                JaVox.Director:emitActionFromPlayer(ply, "self.falling")
                playerFallingActionTriggered[plyIndex] = true
            else
                print("JaVox.Director.emitActionFromPlayer not found. Is JaVox addon loaded?")
            end
        end
    end
end)

hook.Add("PlayerDisconnected", "CleanUpPlayerFallingData", function(ply)
    local plyIndex = ply:UserID()

    playerFallStartTime[plyIndex] = nil
    playerFallingActionTriggered[plyIndex] = nil
end)

print("Player Fall Hook Initialized")
