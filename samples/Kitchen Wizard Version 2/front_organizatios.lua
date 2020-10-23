--This file includes some particular front styles for straight doors


local single_drawer_setup_list = {{125}, {75}, {100}, {150},}

local multi_drawer_setup_list = {				-- I guess for the kitchen its better to count the drawers from the top...
							{125,-1,-1},
							{125,125,-1,-1},
							{125,250,-1},
							{-1,-1,-1},}

if organization_style_list == nil then			
	organization_style_list = {}
end


function fill_drawer_height_list(general_data, specific_data)

	controls.drawer_height_list_label:show_control()
	controls.drawer_height_list:show_control()
	
	local current_selection = 0
	if #organization_style_list[specific_data.front_style].drawer_list > 0 then 
		controls.drawer_height_list:reset_content()
		for i, k in pairs(organization_style_list[specific_data.front_style].drawer_list) do
			local text = ""
			for j,l in pairs(k) do
				if l > 0 then 
					text = text .. pyui.format_length(l)
				else 
					text = text .. pyui.format_number(l)
				end
				if j ~= #k then
					text = text .. ","
				end
			end
			controls.drawer_height_list:insert_control_item(text)
			if text == specific_data.drawer_height_list then 
				current_selection = i
			end 
		end
		if current_selection == 0 then 
			controls.drawer_height_list:set_control_text(specific_data.drawer_height_list)
		else
			controls.drawer_height_list:set_control_selection(current_selection)
		end
--		local text = ""
--		for j,l in pairs(organization_style_list[specific_data.front_style].drawer_list[current_selection]) do
--			if l > 0 then 
--				text = text .. pyui.format_length(l)
--			else 
--				text = text .. pyui.format_number(l)
--			end
--			if j ~= #organization_style_list[specific_data.front_style].drawer_list[current_selection] then
--				text = text .. ","
--			end
--			
--		end
--		specific_data.drawer_height_list = text
	end

	controls.drawer_height_list_label:set_control_text(pyloc "Drawer heights")
end




local function ui_update_straight_open_front(general_data, soft_update)
	controls.label6:show_control()
	controls.shelf_count:show_control()
end



local function create_straight_open_front(general_data, specific_data, width, height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	local loc_origin = {origin[1], origin[2], origin[3]}

	for i = 1, specific_data.shelf_count, 1 do
		loc_origin[1] = origin[1] + general_data.thickness
		loc_origin[2] = general_data.setback_shelves
		loc_origin[3] = origin[3] + i * (height - general_data.thickness) / (specific_data.shelf_count + 1)
		local new_elem = pytha.create_block(width - 2 * general_data.thickness, shelf_depth, general_data.thickness, loc_origin, {name = pyloc "Adjustable shelf"})
		table.insert(cur_elements, new_elem)
	end
end
organization_style_list.straight_no_front = {
	name = pyloc "Open shelf",
	geometry_function = create_straight_open_front,
	ui_update_function = ui_update_straight_open_front,
}




function ui_update_straight_intelli_doors(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  > specific_data.door_width then
--			controls.door_side:disable_control()
		else
			controls.door_side:show_control()
		end
	else 
		controls.door_side:show_control()
	end
	if soft_update == true then return end
	
	controls.label6:show_control()
	controls.shelf_count:show_control()
	controls.door_width:show_control()
	controls.label_door_width:show_control()
end
local function create_straight_intelli_doors(general_data, specific_data, width, height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	local loc_origin = {origin[1], origin[2], origin[3]}	
	local door_height = height - top_gap

	create_straight_open_front(general_data, specific_data, width, height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	
	--Door
	if width - 2 * general_data.gap > 0 then
		loc_origin[1] = origin[1]
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = origin[3]
		if width > specific_data.door_width then	--create two doors
			local door_width = width / 2 - 2 * general_data.gap
		--left handed door
			loc_origin[1] = origin[1] + general_data.gap
			local door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, false, coordinate_system)
			table.insert(cur_elements, door_group)
		--right handed door
			loc_origin[1] = origin[1] + width - door_width - general_data.gap
			door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, true, coordinate_system)
			table.insert(cur_elements, door_group)
		else
		--only one door 
			loc_origin[1] = origin[1] + general_data.gap
			local door_group = create_door(general_data, specific_data, width - 2 * general_data.gap, door_height, loc_origin, specific_data.door_rh, coordinate_system)
			table.insert(cur_elements, door_group)
		end
	end
end

organization_style_list.straight_intelli_doors = {
	name = pyloc "1/2 doors",
	geometry_function = create_straight_intelli_doors,
	ui_update_function = ui_update_straight_intelli_doors,
}




local function ui_straight_update_intelli_doors_drawer(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  > specific_data.door_width then
--			controls.door_side:disable_control()
		else
			controls.door_side:show_control()
		end
	else 
		controls.door_side:show_control()
	end
	if soft_update == true then return end
	
	controls.label6:show_control()
	controls.shelf_count:show_control()
	controls.door_width:show_control()
	controls.label_door_width:show_control()
	
	fill_drawer_height_list(general_data, specific_data)
end
local function create_straight_intelli_doors_drawer(general_data, specific_data, width, height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	local loc_origin = {origin[1], origin[2], origin[3]}	
	local drawer_height = get_drawer_heights(general_data, specific_data)
	local door_height = height - top_gap - drawer_height
	
	
	create_straight_open_front(general_data, specific_data, width, door_height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	--shelves are aligned realtive to the door height plus gap.
	if drawer_height > 0 then
		door_height = door_height - general_data.gap
	end
	--Door
	if width - 2 * general_data.gap > 0 then
		loc_origin[1] = origin[1]
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = origin[3]
		if width > specific_data.door_width then	--create two doors
			local door_width = width / 2 - 2 * general_data.gap
		--left handed door
			loc_origin[1] = origin[1] + general_data.gap
			local door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, false, coordinate_system)
			table.insert(cur_elements, door_group)
		--right handed door
			loc_origin[1] = origin[1] + width - door_width - general_data.gap
			door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, true, coordinate_system)
			table.insert(cur_elements, door_group)
		else
		--only one door 
			loc_origin[1] = origin[1] + general_data.gap
			local door_group = create_door(general_data, specific_data, width - 2 * general_data.gap, door_height, loc_origin, specific_data.door_rh, coordinate_system)
			table.insert(cur_elements, door_group)
		end
		
		--Drawer
		if drawer_height > 0 then
			loc_origin[1] = origin[1] + general_data.gap
			loc_origin[3] = origin[3] + height - top_gap - drawer_height
			local new_elem = create_drawer(general_data, specific_data, width - 2 * general_data.gap, drawer_height, loc_origin, coordinate_system, 'center', 'center')
			table.insert(cur_elements, new_elem)
		end
	end
end

organization_style_list.straight_intelli_doors_and_drawer = {
	name = pyloc "1/2 doors + 1 drawer",
	geometry_function = create_straight_intelli_doors_drawer,
	ui_update_function = ui_straight_update_intelli_doors_drawer,
	drawer_list = single_drawer_setup_list,
}




local function ui_update_straight_intelli_doors_drawers(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  > specific_data.door_width then
--			controls.door_side:disable_control()
		else
			controls.door_side:show_control()
		end
	else 
		controls.door_side:show_control()
	end
	if soft_update == true then return end
	
	controls.label6:show_control()
	controls.shelf_count:show_control()
	controls.door_width:show_control()
	controls.label_door_width:show_control()
end
local function create_straight_intelli_doors_drawers(general_data, specific_data, width, height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	local loc_origin = {origin[1], origin[2], origin[3]}	
	local drawer_height = get_drawer_heights(general_data, specific_data)
	local door_height = height - top_gap - drawer_height

	
	create_straight_open_front(general_data, specific_data, width, door_height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	if drawer_height > 0 then
		door_height = door_height - general_data.gap
	end
	--Door
	if width - 2 * general_data.gap > 0 then
		loc_origin[1] = origin[1]
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = origin[3]
		
		if width > specific_data.door_width then	--create two doors
			local door_width = width / 2 - 2 * general_data.gap
		--left handed door
			loc_origin[1] = origin[1] + general_data.gap
			local door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, false, coordinate_system)
			table.insert(cur_elements, door_group)
			--Drawer
			if drawer_height > 0 then
				loc_origin[3] = origin[3] + height - top_gap - drawer_height
				new_elem = create_drawer(general_data, specific_data, door_width, drawer_height, loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
		--right handed door
			loc_origin[1] = origin[1] + width - door_width - general_data.gap
			loc_origin[3] = origin[3]
			door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, true, coordinate_system)
			table.insert(cur_elements, door_group)
			
			--Drawer
			if drawer_height > 0 then
				loc_origin[3] = origin[3] + height - top_gap - drawer_height
				new_elem = create_drawer(general_data, specific_data, door_width, drawer_height, loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
		else
		--only one door 
			loc_origin[1] = origin[1] + general_data.gap
			local door_group = create_door(general_data, specific_data, width - 2 * general_data.gap, door_height, loc_origin, specific_data.door_rh, coordinate_system)
			table.insert(cur_elements, door_group)
			
			--Drawer
			if drawer_height > 0 then
				loc_origin[3] = origin[3] + height - top_gap - drawer_height
				new_elem = create_drawer(general_data, specific_data, width - 2 * general_data.gap, drawer_height, loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
		end
		
	end
end

organization_style_list.straight_intelli_doors_and_intelli_drawers = {
	name = pyloc "1/2 doors + 1/2 drawers",
	geometry_function = create_straight_intelli_doors_drawers,
	ui_update_function = ui_update_straight_intelli_doors_drawers,
	drawer_list = single_drawer_setup_list,
}


function get_drawer_heights(general_data, specific_data, total_height)
	local total_rel_factor = 0
	local total_abs_length = 0
	local converted_heights = {}
	local drawer_number = 1
	local heights_number = {pyui.parse_number(specific_data.drawer_height_list)}
	local raw_heights_length = {pyui.parse_length(specific_data.drawer_height_list)}
	if total_height == nil then return raw_heights_length[1] or 0 end
	for i,k in pairs(heights_number) do
		if k > 0 then 
			heights_number[i] = raw_heights_length[i]
		end
	end
	for i = 1, specific_data.shelf_count, 1 do
		if heights_number[i] == nil then heights_number[i] = -1 end
		if math.abs(heights_number[i]) < 1e-8 then
			heights_number[i] = -1	--any zero value is set to -1
		end
		if heights_number[i] < 0 then
			total_rel_factor = total_rel_factor + math.abs(heights_number[i])
		else
			if total_abs_length + heights_number[i] >= total_height - (i - 1) * general_data.gap then		--before the total height get too big
				for j = i, #heights_number, 1 do
					heights_number[j] = -1
				end
				total_rel_factor = total_rel_factor + math.abs(heights_number[i])
			else 
				total_abs_length = total_abs_length + heights_number[i]
			end
		end
	end
	if #heights_number == 0 then
		table.insert(converted_heights, total_height)
		return converted_heights
	end
	for i = 1, #heights_number, 1 do
		if heights_number[i] > 0 then 
			table.insert(converted_heights, heights_number[i])
		else 
			table.insert(converted_heights, (total_height - total_abs_length - (#heights_number - 1) * general_data.gap) * math.abs(heights_number[i]) / total_rel_factor)
		end
	end
	return converted_heights
end


local function ui_update_straight_intelli_drawers(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
--	controls.door_side:disable_control()
		
	if soft_update == true then return end
	
	controls.label6:show_control()
	controls.shelf_count:show_control()
	controls.door_width:show_control()
	controls.label_door_width:show_control()
	controls.label6:set_control_text(pyloc "Number of drawers")
	
	fill_drawer_height_list(general_data, specific_data)
	controls.drawer_height_list_label:set_control_text(pyloc "Drawer heights")
	
end

local function create_straight_intelli_drawers(general_data, specific_data, width, height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	local loc_origin = {origin[1], origin[2], origin[3]}	
	local door_height = height - top_gap
	local converted_drawer_height_list = get_drawer_heights(general_data, specific_data, door_height)

	--Door
	if width - 2 * general_data.gap > 0 then
		loc_origin[1] = origin[1]
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = origin[3]
		
		if width > specific_data.door_width and organization_style_list[specific_data.front_style].intelli_doors then	--create two doors
			local door_width = width / 2 - 2 * general_data.gap
			loc_origin[1] = origin[1] + general_data.gap
			
			for i = specific_data.shelf_count, 1, -1 do
				new_elem = create_drawer(general_data, specific_data, door_width, 
										converted_drawer_height_list[i], 
										loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			loc_origin[3] = loc_origin[3] + converted_drawer_height_list[i] + general_data.gap
			end
			loc_origin[1] = origin[1] + width - door_width - general_data.gap
			loc_origin[3] = origin[3]
			
			for i = specific_data.shelf_count, 1, -1 do
				new_elem = create_drawer(general_data, specific_data, door_width, 
										converted_drawer_height_list[i], 
										loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
				loc_origin[3] = loc_origin[3] + converted_drawer_height_list[i] + general_data.gap
			end
		else
		--only one drawer 
			loc_origin[1] = origin[1] + general_data.gap
			
			for i = specific_data.shelf_count, 1, -1 do
				new_elem = create_drawer(general_data, specific_data, width - 2 * general_data.gap, 
										converted_drawer_height_list[i], 
										loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
				loc_origin[3] = loc_origin[3] + converted_drawer_height_list[i] + general_data.gap
			end
						
		end
		
	end
end

organization_style_list.straight_intelli_drawers = {
	name = pyloc "1/2 drawers",
	geometry_function = create_straight_intelli_drawers,
	ui_update_function = ui_update_straight_intelli_drawers,
	intelli_doors = true,
	drawer_list = multi_drawer_setup_list,
}

organization_style_list.straight_drawers = {
	name = pyloc "1 drawer",
	geometry_function = create_straight_intelli_drawers,
	ui_update_function = ui_update_straight_intelli_drawers,
	intelli_doors = false,
	drawer_list = multi_drawer_setup_list,
}



