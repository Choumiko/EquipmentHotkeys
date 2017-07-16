local equipment = { }
local function processEquipment(category, properties)
    for _, v in pairs(data.raw[category]) do
        local t = table.deepcopy(v)
        t.localised_name = t.localised_name or {"equipment-name." .. t.name}
        t.take_result = t.take_result or t.name
        t.name = "pr-disabled-" .. t.name
        for key, value in pairs(properties) do
            t[key] = value
        end
        equipment[#equipment + 1] = t
    end
end
processEquipment("roboport-equipment", {["robot_limit"] = 0, ["construction_radius"] = 0})
processEquipment("movement-bonus-equipment", {["energy_consumption"] = "0kW", ["movement_bonus"] = 0})
processEquipment("night-vision-equipment", {["energy_input"] = "0kW"})
data:extend(equipment)
