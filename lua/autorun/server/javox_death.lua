local JAVOX_DIE_ACTION_ENABLED = CreateConVar("javox_enable_die_action", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Enables/Disables the JaVox die action on player death.")

hook.Add("PlayerDeath", "FireJaVoxDieAction", function(ply, attacker, reasons)
    if JAVOX_DIE_ACTION_ENABLED:GetBool() then
        if IsValid(ply) and ply:IsPlayer() then
            if JaVox and JaVox.Director and JaVox.Director.emitActionFromPlayer then
                JaVox.Director:emitActionFromPlayer(ply, "self.die")
            else
                print("JaVox or JaVox.Director.emitActionFromPlayer not found. Cannot fire die action.")
            end
        else
            print("PlayerDeath hook triggered but 'ply' was not a valid player. Data received: ", ply)
        end
    end
end)

print("JaVox Player Death Hook Initialized.")
