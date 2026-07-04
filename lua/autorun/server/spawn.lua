-- Convar for enabling/disabling the script
local enableConvar = CreateConVar("javox_extended_spawn_enabled", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY },
    "Enables or disables the JaVox action checker script.")

-- Check if the script is enabled
local function IsScriptEnabled()
    return enableConvar:GetBool()
end

hook.Add("PlayerSpawn", "JaVoxActionCheckerGlobalSpawn", function(ply)
    timer.Simple(1, function()
        if not IsScriptEnabled() then
            return
        end

        if not IsValid(ply) then
            return
        end

        local module = ply:GetNWString(JAVOX_PRESET, "")
        local spawnAction = JaVox.Crud:getActionFromModule(module, "self.spawn")
        local talkAction = JaVox.Crud:getActionFromModule(module, "self.talk")

        if spawnAction and spawnAction.audioFiles then
            JaVox.Director:emitActionFromPlayer(ply, "self.spawn")
        elseif talkAction and talkAction.audioFiles then
            JaVox.Director:emitActionFromPlayer(ply, "self.talk")
        end
    end)
end)

print("[JaVox Action Checker] Script loaded. Use 'javox_extended_spawn_enabled' convar to control it.")
