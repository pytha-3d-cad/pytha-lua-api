--Corner cabinet, both left and right sided door

function recreate_corner(general_data, specific_data)
	if specific_data.cur_elements ~= nil then
		pytha.delete_element(specific_data.cur_elements)
	end
	specific_data.cur_elements = {}
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local door_height = specific_data.height - general_data.top_gap - specific_data.drawer_height
	if specific_data.drawer_height > 0 then
		door_height = door_height - general_data.gap
	end
	
	local loc_origin= {}
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
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth - groove_dist_back_off, general_data.thickness, loc_origin)
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
	for i=1, specific_data.shelf_count, 1 do
		loc_origin[2] = general_data.setback_shelves
		loc_origin[3] = base_height + i * (specific_data.height - general_data.thickness) / (specific_data.shelf_count + 1)
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
	
	
	--This section is influenced by "door right"
	
	--Corner angle

	if specific_data.door_rh == true then
		local p_array = {{0, 0, 0}, 
						{0, -100 + general_data.gap, 0},
						{general_data.thickness, -100 + general_data.gap, 0}, 
						{general_data.thickness, -general_data.thickness, 0}, 
						{100 - general_data.gap, -general_data.thickness, 0}, 
						{100 - general_data.gap, 0, 0}}
		local corner_face = pytha.create_polygon(p_array)
		local corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap)[1]
		table.insert(specific_data.cur_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.width - specific_data.door_width  - 100
		loc_origin[2] = 0
		loc_origin[3] = base_height 
		pytha.move_element(corner_angle, loc_origin)
	else
		local p_array = {{0, 0, 0}, 
						{0, -general_data.thickness, 0}, 
						{100 - general_data.gap - general_data.thickness, -general_data.thickness, 0}, 
						{100 - general_data.gap - general_data.thickness, -100 + general_data.gap, 0},
						{100 - general_data.gap, -100 + general_data.gap, 0},
						{100 - general_data.gap, 0, 0}}
		local corner_face = pytha.create_polygon(p_array)
		local corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap)[1]
		table.insert(specific_data.cur_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.door_width + general_data.gap
		loc_origin[2] = 0
		loc_origin[3] = base_height
		pytha.move_element(corner_angle, loc_origin)
	end
	if specific_data.door_rh == true then
		loc_origin[1] = specific_data.width - specific_data.door_width - 100 - general_data.thickness
	else
		loc_origin[1] = specific_data.door_width + 100
	end
	loc_origin[2] = loc_origin[2] - 100
	new_elem = pytha.create_block(general_data.thickness, 100, specific_data.height, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)
	
	
	--Door
	if specific_data.door_width - 2 * general_data.gap > 0 then
		if specific_data.door_rh == true then
			loc_origin[1] = specific_data.width - specific_data.door_width + general_data.gap
		else
			loc_origin[1] = general_data.gap
		end
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = base_height
		
		create_door(general_data, specific_data, specific_data.door_width - 2 * general_data.gap, door_height, loc_origin, not specific_data.door_rh, coordinate_system)
			
		
		--Drawer
		if specific_data.drawer_height > 0 then
			loc_origin[3] = base_height + specific_data.height - general_data.top_gap - specific_data.drawer_height
			new_elem = pytha.create_block(specific_data.door_width - 2 * general_data.gap, general_data.thickness, specific_data.drawer_height, loc_origin)
			table.insert(specific_data.cur_elements, new_elem)
			create_handle(general_data, specific_data, loc_origin, specific_data.door_width - 2 * general_data.gap, specific_data.drawer_height, false, coordinate_system, 'center', 'center')
		end
	end
	
	local z = general_data.benchtop_height - general_data.benchtop_thickness
	local poly_array = {}
	if specific_data.door_rh == true then
		specific_data.right_connection_point = {specific_data.width, 0, 0}
		specific_data.left_connection_point = {specific_data.width - specific_data.door_width - 100,-100,0}
		specific_data.right_direction = 0
		specific_data.left_direction = 90
		poly_array = {{specific_data.width - specific_data.door_width - 100 + general_data.top_over, -100, z}, 
						{specific_data.width - specific_data.door_width - 100 + general_data.top_over, - general_data.top_over, z}, 
						{specific_data.width, - general_data.top_over, z}, 
						{specific_data.width, general_data.depth, z}, 
						{specific_data.width - specific_data.door_width - 100 - general_data.depth, general_data.depth, z},
						{specific_data.width - specific_data.door_width - 100 - general_data.depth, -100, z}}
	else
		specific_data.right_connection_point = {specific_data.door_width + 100, -100, 0}
		specific_data.left_connection_point = {0,0,0}
		specific_data.right_direction = -90
		specific_data.left_direction = 0
		poly_array = {{0, -general_data.top_over, z}, 
						{specific_data.door_width + 100 - general_data.top_over, -general_data.top_over, z}, 
						{specific_data.door_width + 100 - general_data.top_over, -100, z}, 
						{specific_data.door_width + 100 + general_data.depth, -100, z}, 
						{specific_data.door_width + 100 + general_data.depth, general_data.depth, z}, 
						{0, general_data.depth, z}}
	end
	
	specific_data.main_group = pytha.group_elements(specific_data.cur_elements)
	
	specific_data.elem_handle_for_top = pytha.create_polygon(poly_array)
	
	return specific_data.main_group
end

