-- Remove the original hook first to prevent conflicts
hook.Remove("KeyPress", "JaVox_KeyPress_Reload")

local javox_reload_action_enabled = CreateConVar(
    "javox_modern_reload_enabled",
    "1",
    { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable JaVox reload action"
)

local javox_no_ammo_left_action_enabled = CreateConVar(
    "javox_modern_no_ammo_left_action_enabled",
    "1",
    { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable JaVox no ammo left action"
)

hook.Add("KeyPress", "JaVox_KeyPress_Reload_Enhanced", function(ply, key)
    if key ~= IN_RELOAD then return end
    if not IsValid(ply) or not ply:Alive() or ply:InVehicle() then
        return
    end

    local activeWeapon = ply:GetActiveWeapon()
    if not IsValid(activeWeapon) then return end

    if type(activeWeapon.Clip1) ~= "function" or type(activeWeapon.GetMaxClip1) ~= "function" then
        return
    end

    local clip1 = activeWeapon:Clip1() or 0
    local maxclip1 = activeWeapon:GetMaxClip1() or 0

    if clip1 >= maxclip1 then return end



    local ammoType = activeWeapon.GetPrimaryAmmoType and activeWeapon:GetPrimaryAmmoType() or -1
    local reserveAmmo = ammoType ~= -1 and ply:GetAmmoCount(ammoType) or 0

    if ammoType == -1 then return end
    if reserveAmmo <= 0 then
        if not javox_no_ammo_left_action_enabled:GetBool() then return end
        JaVox.Director:emitActionFromPlayer(ply, "weaponry.out_of_ammo")
        return
    end

    if not javox_reload_action_enabled:GetBool() then return end

    local velocity = ply:GetVelocity()
    local isMoving = velocity:Length() > 0.1

    local viewpoint = {
        origin = ply:GetShootPos(),
        angle = ply:GetAimVector(),
        range = 2000,
        fov_degrees = 90
    }

    local FOV_angle_cosine = math.cos(math.rad(viewpoint.fov_degrees / 2))
    local nearbyEntities = ents.FindInCone(viewpoint.origin, viewpoint.angle, viewpoint.range, FOV_angle_cosine)
    local viewingEnemy = false

    for _, ent in ipairs(nearbyEntities) do
        if IsValid(ent) and ent:IsNPC() and ent:Disposition(ply) == D_HT then
            viewingEnemy = true
            break
        end
    end

    local preset = ply:GetNWString(JAVOX_PRESET, "")
    if JaVox.vox[preset] and JaVox.vox[preset].tags and table.HasValue(JaVox.vox[preset].tags, "tfa_vox") then
        JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload")
        return
    end

    if isMoving then
        if viewingEnemy then
            JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload.moving_while_viewing_enemy")
        else
            JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload.moving")
        end
    else -- Player is standing
        if viewingEnemy then
            JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload.standing_while_viewing_enemy")
        else
            JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload.standing")
        end
    end
end)
