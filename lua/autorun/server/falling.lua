---@diagnostic disable: undefined-global

local FALL_THRESHOLD = CreateConVar(
    "javox_falling_threshold",
    "3.0",
    { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Maximum time (in seconds) a player can fall before triggering an action."
)

local FALL_ENABLED = CreateConVar(
    "javox_falling_enabled",
    "1",
    { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enables or disables the JaVox falling action hook."
)

local playerFallStartTime = {}
local playerFallingActionTriggered = {}

hook.Add("Think", "CheckPlayerFalling", function()
    if ! FALL_ENABLED:GetBool() then
        return
    end

    for _, ply in pairs(player.GetAll()) do
        if not IsValid(ply) or ply:IsNPC() then return end

        local currentTime = CurTime()
        local plyIndex = ply:UserID()

        if ply:OnGround() then
            playerFallStartTime[plyIndex] = nil
            playerFallingActionTriggered[plyIndex] = false
            continue
        end

        if not playerFallStartTime[plyIndex] then
            playerFallStartTime[plyIndex] = currentTime
            playerFallingActionTriggered[plyIndex] = false
        end

        local startTime = playerFallStartTime[plyIndex]
        local fallDuration = currentTime - startTime
        local threshold = FALL_THRESHOLD:GetFloat()

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

print("JaVox Falling Action Hook Initialized")
