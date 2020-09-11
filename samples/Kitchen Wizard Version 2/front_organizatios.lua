--This file includes some particular front styles for straight doors

if organization_style_list == nil then			
	organization_style_list = {}
end

local function ui_update_straight_open_front(general_data, soft_update)
	controls.label6:enable_control()
	controls.shelf_count:enable_control()
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




local function ui_update_straight_intelli_doors(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  > specific_data.door_width then
			controls.door_side:disable_control()
		else
			controls.door_side:enable_control()
		end
	else 
		controls.door_side:enable_control()
	end
	if soft_update == true then return end
	
	controls.label6:enable_control()
	controls.shelf_count:enable_control()
	controls.door_width:enable_control()
	controls.label_door_width:enable_control()
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
			controls.door_side:disable_control()
		else
			controls.door_side:enable_control()
		end
	else 
		controls.door_side:enable_control()
	end
	if soft_update == true then return end
	
	controls.label5:enable_control()
	controls.drawer_height:enable_control()
	controls.label6:enable_control()
	controls.shelf_count:enable_control()
	controls.door_width:enable_control()
	controls.label_door_width:enable_control()
end
local function create_straight_intelli_doors_drawer(general_data, specific_data, width, height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	local loc_origin = {origin[1], origin[2], origin[3]}	
	local door_height = height - top_gap - specific_data.drawer_height
	if specific_data.drawer_height > 0 then
		door_height = door_height - general_data.gap
	end
	
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
		
		--Drawer
		if specific_data.drawer_height > 0 then
			loc_origin[1] = origin[1] + general_data.gap
			loc_origin[3] = origin[3] + height - top_gap - specific_data.drawer_height
			local new_elem = create_drawer(general_data, specific_data, width - 2 * general_data.gap, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
			table.insert(cur_elements, new_elem)
		end
	end
end

organization_style_list.straight_intelli_doors_and_drawer = {
	name = pyloc "1/2 doors + 1 drawer",
	geometry_function = create_straight_intelli_doors_drawer,
	ui_update_function = ui_straight_update_intelli_doors_drawer,
}




local function ui_update_straight_intelli_doors_drawers(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  > specific_data.door_width then
			controls.door_side:disable_control()
		else
			controls.door_side:enable_control()
		end
	else 
		controls.door_side:enable_control()
	end
	if soft_update == true then return end
	
	controls.label5:enable_control()
	controls.drawer_height:enable_control()
	controls.label6:enable_control()
	controls.shelf_count:enable_control()
	controls.door_width:enable_control()
	controls.label_door_width:enable_control()
end
local function create_straight_intelli_doors_drawers(general_data, specific_data, width, height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	local loc_origin = {origin[1], origin[2], origin[3]}	
	local door_height = height - top_gap - specific_data.drawer_height
	if specific_data.drawer_height > 0 then
		door_height = door_height - general_data.gap
	end
	
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
			--Drawer
			if specific_data.drawer_height > 0 then
				loc_origin[3] = origin[3] + height - top_gap - specific_data.drawer_height
				new_elem = create_drawer(general_data, specific_data, door_width, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
		--right handed door
			loc_origin[1] = origin[1] + width - door_width - general_data.gap
			loc_origin[3] = origin[3]
			door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, true, coordinate_system)
			table.insert(cur_elements, door_group)
			
			--Drawer
			if specific_data.drawer_height > 0 then
				loc_origin[3] = origin[3] + height - top_gap - specific_data.drawer_height
				new_elem = create_drawer(general_data, specific_data, door_width, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
		else
		--only one door 
			loc_origin[1] = origin[1] + general_data.gap
			local door_group = create_door(general_data, specific_data, width - 2 * general_data.gap, door_height, loc_origin, specific_data.door_rh, coordinate_system)
			table.insert(cur_elements, door_group)
			
			--Drawer
			if specific_data.drawer_height > 0 then
				loc_origin[3] = origin[3] + height - top_gap - specific_data.drawer_height
				new_elem = create_drawer(general_data, specific_data, width - 2 * general_data.gap, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
		end
		
	end
end

organization_style_list.straight_intelli_doors_and_intelli_drawers = {
	name = pyloc "1/2 doors + 1/2 drawers",
	geometry_function = create_straight_intelli_doors_drawers,
	ui_update_function = ui_update_straight_intelli_doors_drawers,
}



local function ui_update_straight_intelli_drawers(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  > specific_data.door_width then
			controls.door_side:disable_control()
		else
			controls.door_side:enable_control()
		end
	else 
		controls.door_side:enable_control()
	end
	if soft_update == true then return end
	
	controls.label5:enable_control()
	controls.drawer_height:enable_control()
	controls.label6:enable_control()
	controls.shelf_count:enable_control()
	controls.door_width:enable_control()
	controls.label_door_width:enable_control()
end
local function create_straight_intelli_drawers(general_data, specific_data, width, height, shelf_depth, top_gap, origin, coordinate_system, cur_elements)
	local loc_origin = {origin[1], origin[2], origin[3]}	
	local door_height = height - top_gap - specific_data.drawer_height
	if specific_data.drawer_height > 0 then
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
			if specific_data.drawer_height > 0 then
				loc_origin[3] = origin[3] + height - top_gap - specific_data.drawer_height
				new_elem = create_drawer(general_data, specific_data, door_width, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
		--right handed door
			loc_origin[1] = origin[1] + width - door_width - general_data.gap
			loc_origin[3] = origin[3]
			door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, true, coordinate_system)
			table.insert(cur_elements, door_group)
			
			--Drawer
			if specific_data.drawer_height > 0 then
				loc_origin[3] = origin[3] + height - top_gap - specific_data.drawer_height
				new_elem = create_drawer(general_data, specific_data, door_width, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
		else
		--only one door 
			loc_origin[1] = origin[1] + general_data.gap
			
			for i = 1, specific_data.shelf_count, 1 do
				loc_origin[3] = origin[3] + (i-1) * (door_height + general_data.gap) / (specific_data.shelf_count)
				new_elem = create_drawer(general_data, specific_data, width - 2 * general_data.gap, 
										(door_height + general_data.gap) / (specific_data.shelf_count) - general_data.gap, 
										loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
						
			--Drawer
			if specific_data.drawer_height > 0 then
				loc_origin[3] = origin[3] + height - top_gap - specific_data.drawer_height
				new_elem = create_drawer(general_data, specific_data, width - 2 * general_data.gap, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
				table.insert(cur_elements, new_elem)
			end
		end
		
	end
end

organization_style_list.straight_intelli_drawers = {
	name = pyloc "1/2 drawers",
	geometry_function = create_straight_intelli_drawers,
	ui_update_function = ui_update_straight_intelli_drawers,
}