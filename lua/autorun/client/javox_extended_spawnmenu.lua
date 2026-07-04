hook.Add("AddToolMenuTabs", "JaVoxExtendedCutTab", function()
    spawnmenu.AddToolTab("JaVox_ExtendedCut", "JaVox Extended Cut", "icon16/cup.png")
end)
hook.Add("AddToolMenuCategories", "JaVoxExtendedCutCategories", function()
    spawnmenu.AddToolCategory("JaVox_ExtendedCut", "JaVox_ExtendedCut_Settings", "Extended Settings")
end)

hook.Add("PopulateToolMenu", "JaVoxExtendedCutOptions", function()
    local function CreateJaVoxExtendedCutPanel(panel)
        panel:Clear()
        panel:Help("Configure JaVox Extended Cut features.")

        -- javox_extended_spawn_enabled
        panel:CheckBox("Enable Extended Spawn", "javox_extended_spawn_enabled")

        -- javox_modern_reload_enabled
        panel:CheckBox("Modern Reload Enabled", "javox_modern_reload_enabled")

        -- javox_modern_no_ammo_left_action_enabled
        panel:CheckBox("Modern No Ammo Action Enabled", "javox_modern_no_ammo_left_action_enabled")

        -- javox_grenade_detector
        panel:CheckBox("Grenade Detector", "javox_grenade_detector")

        -- javox_enable_die_action
        panel:CheckBox("Enable Die Action", "javox_enable_die_action")

        -- javox_inactivity_hook_enabled
        panel:CheckBox("Inactivity Hook Enabled", "javox_inactivity_hook_enabled")

        -- javox_inactivity_hook_threshold
        -- Using DNumSlider directly from the panel (which is a DForm in this context)
        panel:NumSlider("Inactivity Hook Threshold (seconds)", "javox_inactivity_hook_threshold", 0, 600, 1) -- Set decimals to 1 as per your example

        -- javox_falling_threshold
        panel:NumSlider("Falling Threshold (units/sec)", "javox_falling_threshold", 10, 500, 1) -- Set decimals to 1 as per your example

        -- javox_falling_enabled
        panel:CheckBox("Enable Falling Action", "javox_falling_enabled")
    end

    spawnmenu.AddToolMenuOption("JaVox_ExtendedCut", "JaVox_ExtendedCut_Settings", "JaVox_ExtendedCut_MainSettings",
        "Main Settings", "", "",
        CreateJaVoxExtendedCutPanel)
end)

-- It's crucial to also have the tab and category definitions for this to work correctly.
-- If you don't have them, here they are:
hook.Add("AddToolMenuTabs", "JaVoxExtendedCutTab", function()
    spawnmenu.AddToolTab("JaVox_ExtendedCut", "JaVox Extended Cut", "icon16/cup.png") -- You can choose a different icon if you prefer
end)

hook.Add("AddToolMenuCategories", "JaVoxExtendedCutCategories", function()
    spawnmenu.AddToolCategory("JaVox_ExtendedCut", "JaVox_ExtendedCut_Settings", "Extended Settings")
end)
