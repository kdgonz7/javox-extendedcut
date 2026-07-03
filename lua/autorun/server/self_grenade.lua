local grenadeDetectorEnabled = CreateConVar("javox_grenade_detector", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Enable/disable the JaVox grenade proximity detector.")

local function CheckGrenadeProximity()
    if grenadeDetectorEnabled:GetBool() == false then return end

    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() then continue end

        local nearbyEnts = ents.FindInSphere(ply:GetPos(), 400)

        for _, ent in ipairs(nearbyEnts) do
            if ent:IsValid() and (ent:GetClass() == "npc_grenade_frag" or ent:GetClass() == "grenade_ar2") then
                local tr = util.TraceLine({
                    start = ply:GetShootPos(),
                    endpos = ent:GetPos(),
                    filter = { ply, ent },
                    mask = MASK_SOLID_BRUSHONLY
                })

                if not tr.Hit then
                    local thrower = ent:GetOwner()

                    if IsValid(thrower) and thrower:IsPlayer() then
                        ent.JaVoxEmitted = ent.JaVoxEmitted or {}

                        if not ent.JaVoxEmitted[ply:UserID()] then
                            ent.JaVoxEmitted[ply:UserID()] = true

                            if thrower == ply then
                                JaVox.Director:emitActionFromPlayer(ply, "self.grenade_self")
                                print("grenade_self")
                            else
                                JaVox.Director:emitActionFromPlayer(ply, "self.grenade_other")
                                print("grenade_other")
                            end
                        end
                    end
                end
            end
        end
    end
end

if not timer.Exists("JaVox_GrenadeDetectorTimer") then
    timer.Create("JaVox_GrenadeDetectorTimer", 0.2, 0, CheckGrenadeProximity)
end
