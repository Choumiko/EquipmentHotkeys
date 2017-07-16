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
		for _, equipment in pairs(grid.equipment) do
			if equipment.valid and supported_types[equipment.type] then
				if not disabled_types[equipment.type] and equipment.name:sub(1, 12) == "pr-disabled-" then
					local new_equipment_name = equipment.name:sub(13)
					replace_equipment(grid, equipment, new_equipment_name)
				elseif disabled_types[equipment.type] and equipment.name:sub(1,12) ~= "pr-disabled-" then
					replace_equipment(grid, equipment, "pr-disabled-"..equipment.name)
				end
			end
		end
	end
end

local function check_player(player)
	global.equipment_settings = global.equipment_settings or {}
	global.equipment_settings[player.index] = global.equipment_settings[player.index] or {}
	local armor = player.get_inventory(defines.inventory.player_armor)[1]
	if armor and armor.valid and armor.valid_for_read then
		check_grid(armor.grid, global.equipment_settings[player.index])
	end
end

local function toggle_setting(player_index, type)
	local player = game.players[player_index]
	global.equipment_settings = global.equipment_settings or {}
	global.equipment_settings[player.index] = global.equipment_settings[player.index] or {}
	local new_setting = not global.equipment_settings[player.index][type]
	if new_setting then
		player.print({"equipment-disabled-"..type})
	else
		player.print({"equipment-enabled-"..type})
	end
	global.equipment_settings[player.index][type] = new_setting
	check_player(player)
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

local function event_to_check(event)
	check_player(game.players[event.player_index])
end

script.on_event(defines.events.on_player_armor_inventory_changed, event_to_check)
script.on_event(defines.events.on_player_placed_equipment, event_to_check)
script.on_event(defines.events.on_player_removed_equipment, event_to_check)
