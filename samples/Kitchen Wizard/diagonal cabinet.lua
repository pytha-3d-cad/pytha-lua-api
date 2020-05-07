--Diagonal Corner Cabinet

function recreate_diagonal(general_data, specific_data)
	if specific_data.cur_elements ~= nil then
		pytha.delete_element(specific_data.cur_elements)
	end
	specific_data.cur_elements = {}
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness

	local loc_origin= {}
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local door_height = specific_data.height - general_data.top_gap - specific_data.drawer_height
	if specific_data.drawer_height > 0 then
		door_height = door_height - general_data.gap
	end

	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	
	local slope = (specific_data.width2 - general_data.depth)/(specific_data.width - general_data.depth)
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
		
	local door_diag_offset_y1 = -general_data.gap * slope + general_data.thickness * (1 - PYTHAGORAS(slope, 1))	--distance that door is standing out further than a normal door. We shift by that value to bring all doors to the same height
	local door_diag_offset_x2 = -general_data.gap / slope + general_data.thickness * (1 - PYTHAGORAS(1 / slope, 1))	--distance that door is standing out further than a normal door. We shift by that value to bring all doors to the same height

	--Left side
	local poly_array = {{0, -door_diag_offset_y1,0}, 
						{general_data.thickness, -door_diag_offset_y1 - general_data.thickness * slope, 0}, 
						{general_data.thickness, general_data.depth, 0}, 
						{0, general_data.depth, 0}}
	local fla_handle = pytha.create_polygon(poly_array)
	local profile = pytha.create_profile(fla_handle, specific_data.height)[1]
	pytha.delete_element(fla_handle)
	pytha.move_element(profile, loc_origin)
	table.insert(specific_data.cur_elements, profile)
	
	--Right side
	poly_array = {{specific_data.width, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - general_data.depth - general_data.thickness / slope - door_diag_offset_x2, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - general_data.depth - door_diag_offset_x2, general_data.depth - specific_data.width2, 0}, 
					{specific_data.width, general_data.depth - specific_data.width2, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	profile = pytha.create_profile(fla_handle, specific_data.height)[1]
	pytha.delete_element(fla_handle)
	pytha.move_element(profile, loc_origin)
	table.insert(specific_data.cur_elements, profile)
	
	
	--Bottom
	poly_array = {{general_data.thickness, -general_data.thickness * slope - door_diag_offset_y1, 0}, 
					{specific_data.width - general_data.depth - general_data.thickness / slope - door_diag_offset_x2, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth - groove_dist_back_off, 0},
					{general_data.thickness, general_data.depth - groove_dist_back_off, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	profile = pytha.create_profile(fla_handle, general_data.thickness)[1]
	pytha.move_element(profile, loc_origin)
	table.insert(specific_data.cur_elements, profile)
	
	--We reuse the fla handle for the top and the shelves
	loc_origin[3] = base_height + specific_data.height - general_data.thickness
	profile = pytha.create_profile(fla_handle, general_data.thickness)[1]
	pytha.delete_element(fla_handle)
	pytha.move_element(profile, loc_origin)
	table.insert(specific_data.cur_elements, profile)
	
	--shelf setback needs pythagoras 
	--Shelves
	poly_array = {{general_data.thickness, - general_data.thickness * slope - door_diag_offset_y1 + general_data.setback_shelves * PYTHAGORAS(slope, 1), 0}, 
					{specific_data.width - general_data.depth - general_data.thickness / slope - door_diag_offset_x2 + general_data.setback_shelves * PYTHAGORAS(1 / slope, 1), general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth - groove_dist_back_off, 0},
					{general_data.thickness, general_data.depth - groove_dist_back_off, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	
	for i=1,specific_data.shelf_count,1 do
		loc_origin[3] = base_height + i * door_height / (specific_data.shelf_count + 1)
		profile = pytha.create_profile(fla_handle, general_data.thickness)[1]
		pytha.move_element(profile, loc_origin)
		table.insert(specific_data.cur_elements, profile)
	end
	pytha.delete_element(fla_handle)
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - general_data.thickness + general_data.groove_depth - groove_dist_back_off, general_data.thickness_back, specific_data.height, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)
	loc_origin[1] = specific_data.width - groove_dist_back_off
	loc_origin[2] = general_data.depth - specific_data.width2 +  general_data.thickness - general_data.groove_depth
	loc_origin[3] = base_height 
	new_elem = pytha.create_block(general_data.thickness_back, specific_data.width2 - general_data.thickness + general_data.groove_depth - groove_dist_back_off + general_data.thickness_back, specific_data.height, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)
	

	--here we need to introduce arotated coordinate system for the door
	local main_dir = {specific_data.width - general_data.depth, general_data.depth - specific_data.width2, 0}
	local diag_length = PYTHAGORAS(main_dir[1], main_dir[2], main_dir[3])
	main_dir[1] = main_dir[1] / diag_length
	main_dir[2] = main_dir[2] / diag_length
	main_dir[3] = main_dir[3] / diag_length
	
	local third_dir =  {-main_dir[2], main_dir[1], 0}
	
	local diag_coos = {main_dir, third_dir, {0,0,1}}
	--this point gives a 3mm gap of the door to the side
	loc_origin[1] = general_data.gap
	loc_origin[2] = -general_data.thickness
	loc_origin[3] = base_height
	local door_length = get_diag_door_length(general_data, specific_data)
	
	--Door
	if door_length > 0 then
		
		if door_length > specific_data.door_width then	--create two doors
			local door_width = door_length / 2 - general_data.gap
		--left handed door
			create_door(general_data, specific_data, door_width, door_height, loc_origin, false, diag_coos)
		--right handed door
			loc_origin[1] = loc_origin[1] + (door_width + 2 * general_data.gap) * main_dir[1]
			loc_origin[2] = loc_origin[2] + (door_width + 2 * general_data.gap) * main_dir[2]
			create_door(general_data, specific_data, door_width, door_height, loc_origin, true, diag_coos)
		else
		--only one door 
			create_door(general_data, specific_data, door_length, door_height, loc_origin, specific_data.door_rh, diag_coos)
		end
		
		--Drawer
		if specific_data.drawer_height > 0 then
			loc_origin[1] = general_data.gap
			loc_origin[2] = -general_data.thickness
			loc_origin[3] = base_height + specific_data.height - general_data.top_gap - specific_data.drawer_height
			local axes = {u_axis = diag_coos[1], v_axis = diag_coos[2], w_axis = diag_coos[3]}

			new_elem = pytha.create_block(door_length, general_data.thickness, specific_data.drawer_height, loc_origin, axes)
			table.insert(specific_data.cur_elements, new_elem)
			create_handle(general_data, specific_data, loc_origin, door_length, specific_data.drawer_height, false, diag_coos, 'center', 'center')
		end
	end
	specific_data.right_connection_point = {specific_data.width - general_data.depth, general_data.depth - specific_data.width2, 0}
	specific_data.left_connection_point = {0,0,0}
	specific_data.right_direction = -90
	specific_data.left_direction = 0
	
	specific_data.main_group = pytha.group_elements(specific_data.cur_elements)
	
	local z = general_data.benchtop_height - general_data.benchtop_thickness
	poly_array = {{0, -general_data.top_over,z}, 
						{specific_data.width - general_data.depth - general_data.top_over, general_data.depth - specific_data.width2, z}, 
						{specific_data.width, general_data.depth - specific_data.width2, z}, 
						{specific_data.width, general_data.depth, z}, 
						{0, general_data.depth, z}}
	specific_data.elem_handle_for_top = pytha.create_polygon(poly_array)
	
	return specific_data.main_group
end

function get_diag_door_length(general_data, specific_data)
	local p2 = {specific_data.width - general_data.depth - general_data.thickness, general_data.depth - specific_data.width2 + general_data.gap, 0}
	local door_length = PYTHAGORAS(p2[1] - general_data.gap, p2[2] + general_data.thickness, 0)
	return door_length
end

