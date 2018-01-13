local supported_types = {
    ["roboport-equipment"] = true,
    ["movement-bonus-equipment"] = true,
    ["night-vision-equipment"] = true
}

local function replace_equipment(grid, equipment, new_name)
    local position, energy = equipment.position, equipment.energy
    grid.take(equipment)
    local new_roboport = grid.put{name = new_name, position = position}
    if new_roboport and new_roboport.valid then
        new_roboport.energy = energy
    end
end

local function check_grid(grid, disabled_types)
    if grid and grid.valid then
        local state
        for _, equipment in pairs(grid.equipment) do
            if equipment.valid and supported_types[equipment.type] then
                if not disabled_types[equipment.type] and equipment.name:sub(1, 12) == "pr-disabled-" then
                    local new_equipment_name = equipment.name:sub(13)
                    replace_equipment(grid, equipment, new_equipment_name)
                    state = "enabled"
                elseif disabled_types[equipment.type] and equipment.name:sub(1,12) ~= "pr-disabled-" then
                    replace_equipment(grid, equipment, "pr-disabled-"..equipment.name)
                    state = "disabled"
                end
            end
        end
        return state
    end
end

local function check_player(player)
    global.equipment_settings = global.equipment_settings or {}
    global.equipment_settings[player.index] = global.equipment_settings[player.index] or {}
    local armor = player.get_inventory(defines.inventory.player_armor) and player.get_inventory(defines.inventory.player_armor)[1]
    if armor and armor.valid and armor.valid_for_read then
        return check_grid(armor.grid, global.equipment_settings[player.index])
    end
end

local function toggle_setting(player_index, type)
    local player = game.players[player_index]
    global.equipment_settings = global.equipment_settings or {}
    global.equipment_settings[player.index] = global.equipment_settings[player.index] or {}
    global.equipment_settings[player.index][type] = not global.equipment_settings[player.index][type]
    local status = check_player(player)
    if player.mod_settings.equipment_hotkeys_display_messages.value then
        if status == "disabled" then
            player.print({"equipment-disabled-"..type})
        elseif status == "enabled" then
            player.print({"equipment-enabled-"..type})
        end
    end
end


script.on_event("equipment-toggle-personal-roboport", function(event)
    toggle_setting(event.player_index, "roboport-equipment")
end)
script.on_event("equipment-toggle-night-vision", function(event)
    toggle_setting(event.player_index, "night-vision-equipment")
end)
script.on_event("equipment-toggle-exoskeleton", function(event)
    toggle_setting(event.player_index, "movement-bonus-equipment")
end)

local function set_roboport(player, state)
    if state ~= global.equipment_settings[player.index]["roboport-equipment"] then
        toggle_setting(player.index, "roboport-equipment")
    end
end

local function on_player_driving_changed_state(event)
    local player = game.players[event.player_index]
    if player.valid and player.mod_settings.equipment_hotkeys_auto_disable.value then
        global.equipment_settings = global.equipment_settings or {}
        global.equipment_settings[player.index] = global.equipment_settings[player.index] or {["roboport-equipment"] = false}
        if player.vehicle then
            set_roboport(player, true)
        else
            set_roboport(player, false)
        end
    end
end

script.on_event(defines.events.on_player_driving_changed_state, on_player_driving_changed_state)

local function event_to_check(event)
    check_player(game.players[event.player_index])
end

script.on_event(defines.events.on_player_armor_inventory_changed, event_to_check)
script.on_event(defines.events.on_player_placed_equipment, event_to_check)
script.on_event(defines.events.on_player_removed_equipment, event_to_check)
