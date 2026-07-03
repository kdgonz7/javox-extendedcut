hook.Add("KeyPress", "HandleReloadKey", function(ply, key)
    if key == IN_RELOAD then
        local velocity = ply:GetVelocity()
        local isMoving = velocity:Length() > 0.1

        if isMoving then
            JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload.moving")
        else
            JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload.standing")
        end

        local playerOrigin = ply:GetShootPos()
        local aimVector = ply:GetAimVector()
        local searchRange = 2000
        local FOV_angle_degrees = 90
        local FOV_angle_cosine = math.cos(math.rad(FOV_angle_degrees / 2))

        local nearbyEntities = ents.FindInCone(playerOrigin, aimVector, searchRange, FOV_angle_cosine)

        for _, ent in ipairs(nearbyEntities) do
            if IsValid(ent) and ent:IsNPC() and ent:Disposition(ply) == D_HT then
                JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload.while_viewing_enemy")
                break
            end
        end
    end
end)
