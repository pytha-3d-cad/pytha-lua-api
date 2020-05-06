--Straight Cabinet


function recreate_straight(general_data, specific_data)
	if specific_data.cur_elements ~= nil then
		pytha.delete_element(specific_data.cur_elements)
	end
	specific_data.cur_elements = {}
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	local loc_origin= {}
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local door_height = specific_data.height - general_data.top_gap - specific_data.drawer_height
	if specific_data.drawer_height > 0 then
		door_height = door_height - general_data.gap
	end

	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)
	--Bottom
	loc_origin[1] = general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth- groove_dist_back_off, general_data.thickness, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)
	--Front rail
	loc_origin[3] = base_height + specific_data.height - general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)
	--Back rail
	loc_origin[2] = general_data.depth - general_data.width_rail - groove_dist_back_off
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)
	--Shelves
	for i = 1, specific_data.shelf_count, 1 do
		loc_origin[2] = general_data.setback_shelves
		loc_origin[3] = base_height + i * door_height / (specific_data.shelf_count + 1)
		local shelf_depth = general_data.depth - general_data.setback_shelves - groove_dist_back_off
		new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, shelf_depth, general_data.thickness, loc_origin)
		table.insert(specific_data.cur_elements, new_elem)
	end
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, specific_data.height, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)
		

	--Door
	if specific_data.width - 2 * general_data.gap > 0 then
	
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = base_height
		if specific_data.width > specific_data.door_width then	--create two doors
			local door_width = specific_data.width / 2 - 2 * general_data.gap
		--left handed door
			loc_origin[1] = general_data.gap
			create_door(general_data, specific_data, door_width, door_height, loc_origin, false, coordinate_system)
		--right handed door
			loc_origin[1] = specific_data.width - door_width - general_data.gap
			create_door(general_data, specific_data, door_width, door_height, loc_origin, true, coordinate_system)
		else
		--only one door 
			loc_origin[1] = general_data.gap
			create_door(general_data, specific_data, specific_data.width - 2 * general_data.gap, door_height, loc_origin, specific_data.door_rh, coordinate_system)
		end
		
		--Drawer
		if specific_data.drawer_height > 0 then
			loc_origin[1] = general_data.gap
			loc_origin[3] = base_height + specific_data.height - general_data.top_gap - specific_data.drawer_height
			new_elem = pytha.create_block(specific_data.width - 2 * general_data.gap, general_data.thickness, specific_data.drawer_height, loc_origin)
			table.insert(specific_data.cur_elements, new_elem)
			create_handle(general_data, specific_data, loc_origin, specific_data.width - 2 * general_data.gap, specific_data.drawer_height, false, coordinate_system, 'center', 'center')
		end
	end
	specific_data.right_connection_point = {specific_data.width,0,0}
	specific_data.left_connection_point = {0,0,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
	specific_data.main_group = pytha.group_elements(specific_data.cur_elements)
	
	specific_data.elem_handle_for_top = pytha.create_rectangle_face(specific_data.width, general_data.top_over + general_data.depth, {0, -general_data.top_over, general_data.benchtop_height - general_data.benchtop_thickness})
	
	return specific_data.main_group
end



