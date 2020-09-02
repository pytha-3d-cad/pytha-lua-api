
function create_drawer(general_data, specific_data, width, drawer_height, origin, coordinate_system, h_posi_code, v_posi_code)
	local loc_origin = {origin[1], origin[2], origin[3]} 	--tables are by reference, so you could overwrite the origin in the calling function. Therefore we assign by value.
	local axes = {u_axis = coordinate_system[1], v_axis = coordinate_system[2], w_axis = coordinate_system[3], name = pyloc "Drawer"}
	--Drawer Front
	local drawer_front = pytha.create_block(width, general_data.thickness, drawer_height, loc_origin, axes)
	
	--Drawer Box: values are max values to allow for replacement with drawer box with runners
	local drawer_box_collection = {}
	local depth = general_data.depth - general_data.groove_dist - general_data.thickness_back
	if specific_data.row == 0x2 then
		depth = general_data.depth_wall - general_data.groove_dist - general_data.thickness_back
	end
	local token = pytha.push_local_coordinates(loc_origin, axes)
	new_elem = pytha.create_block(width - 4 * general_data.thickness + 2 * general_data.gap, depth - 2 * general_data.thickness, general_data.thickness, {2 * general_data.thickness - general_data.gap, 2 * general_data.thickness, 0}, {name = pyloc "Bottom"})
	table.insert(drawer_box_collection, new_elem)
	new_elem = pytha.create_block(width - 4 * general_data.thickness + 2 * general_data.gap, general_data.thickness, drawer_height - general_data.thickness + general_data.top_gap, {2 * general_data.thickness - general_data.gap, general_data.thickness, 0}, {name = pyloc "Front"})
	table.insert(drawer_box_collection, new_elem)
	new_elem = pytha.create_block(general_data.thickness, depth - general_data.thickness, drawer_height - general_data.thickness + general_data.top_gap, {general_data.thickness - general_data.gap, general_data.thickness, 0}, {name = pyloc "Left Side"})
	table.insert(drawer_box_collection, new_elem)
	new_elem = pytha.create_block(general_data.thickness, depth - general_data.thickness, drawer_height - general_data.thickness + general_data.top_gap, {width - 2 * general_data.thickness + general_data.gap, general_data.thickness, 0}, {name = pyloc "Right Side"})
	table.insert(drawer_box_collection, new_elem)
	new_elem = pytha.create_block(width - 2 * general_data.thickness + 2 * general_data.gap, general_data.thickness, drawer_height - general_data.thickness + general_data.top_gap, {general_data.thickness - general_data.gap, depth, 0}, {name = pyloc "Back"})
	table.insert(drawer_box_collection, new_elem)
	
	
	pytha.pop_local_coordinates(token)
	
	local drawer_box = pytha.create_group(drawer_box_collection, {name = pyloc "Drawer box"})
	
	loc_origin = {origin[1], origin[2], origin[3]} 
	local handle = create_handle(general_data, specific_data, loc_origin, width, drawer_height, false, coordinate_system, h_posi_code, v_posi_code)
	local drawer_group = pytha.create_group({handle, drawer_front, drawer_box}, {name = pyloc "Drawer"})
	drawer_group:set_element_attributes({action_string = "MOVE(-0,-" .. 0.75*depth .. ",-0S34)"})
	return drawer_group
end

function create_door(general_data, specific_data, width, door_height, origin, door_rh, coordinate_system, v_posi_code)
	local loc_origin = {origin[1], origin[2], origin[3]} 	--tables are by reference, so you could overwrite the origin in the calling function. Therefore we assign by value.
	local door_name = ""
	if door_rh == false then
		door_name = pyloc "Door LH"
	else 
		door_name = pyloc "Door RH"
	end
	
	local axes = {u_axis = coordinate_system[1], v_axis = coordinate_system[2], w_axis = coordinate_system[3], name = door_name}
	
	new_elem = pytha.create_block(width, general_data.thickness, door_height, loc_origin, axes)

	local h_posi_code = ''
	if v_posi_code == nil then
		v_posi_code = 'top'
	end
	if door_rh == false then	
		h_posi_code = 'right'
	else 
		h_posi_code = 'left'
	end
	local handle = create_handle(general_data, specific_data, loc_origin, width, door_height, true, coordinate_system, h_posi_code, v_posi_code)
	local door_group = pytha.create_group({handle, new_elem}, {name = door_name})
	local rp_pos1 = {loc_origin[1], loc_origin[2], loc_origin[3]} 
	if door_rh == true then
		rp_pos1[1] = rp_pos1[1] + width * coordinate_system[1][1]
		rp_pos1[2] = rp_pos1[2] + width * coordinate_system[1][2]
	end
	pytha.create_element_ref_point(door_group, rp_pos1)
	rp_pos1[3] = rp_pos1[3] + door_height
	pytha.create_element_ref_point(door_group, rp_pos1)
	if door_rh == true then
		door_group:set_element_attributes({action_string = "ROTATE(70,R1R2,R1S30)"})
	else
		door_group:set_element_attributes({action_string = "ROTATE(-70,R1R2,R1S30)"})
	end
	return door_group
end

--origin, width and height are for the whole door. The handle then is positioned according to the posi codes
function create_handle(general_data, specific_data, origin, width, height, vert, coordinate_system, h_posi_code, v_posi_code)
	local loc_origin = {origin[1], origin[2], origin[3]} 	--tables are by reference, so you could overwrite the origin in the calling function. Therefore we assign by value.
	local handle_over = 12.5
	local handle_length = general_data.handle_length
	local total_length = handle_length + 2 * handle_over
	local diameter = 12
	local block_length = 23
	local block_height = 10
	local depth = 38 - diameter / 2
	local left_rp = {0,0,0}
	local right_rp = {0,0,0}
	local hori_off = 32
	local vert_off = 32
	
	local perp_dir = coordinate_system[2]	--its just shorter
	
	-- handle offset to front, this is independent of handle position
	loc_origin[1] = loc_origin[1] - depth * (perp_dir[1])
	loc_origin[2] = loc_origin[2] - depth * (perp_dir[2])
	
	local reference_coordinate = {loc_origin[1], loc_origin[2], loc_origin[3]}
	--handle offset position dependent
	if h_posi_code == 'right' then
		reference_coordinate[1] = loc_origin[1] + (width - hori_off) * coordinate_system[1][1]
		reference_coordinate[2] = loc_origin[2] + (width - hori_off) * coordinate_system[1][2]
		if vert == false then
			left_rp[1] = reference_coordinate[1] - handle_length * coordinate_system[1][1]
			left_rp[2] = reference_coordinate[2] - handle_length * coordinate_system[1][2]
			right_rp[1] = reference_coordinate[1]
			right_rp[2] = reference_coordinate[2]
		end
	elseif h_posi_code == 'center' then
		reference_coordinate[1] = loc_origin[1] + 0.5 * width * coordinate_system[1][1]
		reference_coordinate[2] = loc_origin[2] + 0.5 * width * coordinate_system[1][2]
		if vert == false then
			left_rp[1] = reference_coordinate[1] - 0.5 * handle_length * coordinate_system[1][1]
			left_rp[2] = reference_coordinate[2] - 0.5 * handle_length * coordinate_system[1][2]
			right_rp[1] = reference_coordinate[1] + 0.5 * handle_length * coordinate_system[1][1]
			right_rp[2] = reference_coordinate[2] + 0.5 * handle_length * coordinate_system[1][2]
		end
	else 
		reference_coordinate[1] = loc_origin[1] + hori_off * coordinate_system[1][1]
		reference_coordinate[2] = loc_origin[2] + hori_off * coordinate_system[1][2]
		if vert == false then
			left_rp[1] = reference_coordinate[1]
			left_rp[2] = reference_coordinate[2]
			right_rp[1] = reference_coordinate[1] + handle_length * coordinate_system[1][1]
			right_rp[2] = reference_coordinate[2] + handle_length * coordinate_system[1][2]
		end
	end
	if vert == true then 
		left_rp[1] = reference_coordinate[1]
		left_rp[2] = reference_coordinate[2]
		right_rp[1] = reference_coordinate[1]
		right_rp[2] = reference_coordinate[2]
	end
	
	if v_posi_code == 'top' then
		reference_coordinate[3] = loc_origin[3] + height - vert_off
		if vert == true then
			left_rp[3] = reference_coordinate[3]
			right_rp[3] = reference_coordinate[3] - handle_length 
		end
	elseif v_posi_code == 'center' then
		reference_coordinate[3] = loc_origin[3] + 0.5 * height
		if vert == true then
			left_rp[3] = reference_coordinate[3] + 0.5 * handle_length 
			right_rp[3] = reference_coordinate[3] - 0.5 * handle_length 
		end
	else 
		reference_coordinate[3] = loc_origin[3] + vert_off
		if vert == true then
			left_rp[3] = reference_coordinate[3] + handle_length 
			right_rp[3] = reference_coordinate[3]
		end
	end
	if vert == false then 
		left_rp[3] = reference_coordinate[3]
		right_rp[3] = reference_coordinate[3]
	end
		
	
	
	--this is so we do not have to treat any different cases  
	local main_dir = {right_rp[1] - left_rp[1], right_rp[2] - left_rp[2], right_rp[3] - left_rp[3]}
	main_dir[1] = main_dir[1] / handle_length
	main_dir[2] = main_dir[2] / handle_length
	main_dir[3] = main_dir[3] / handle_length
	

	local third_dir =  {main_dir[2] * perp_dir[3] - main_dir[3] * perp_dir[2], 
								main_dir[3] * perp_dir[1] - main_dir[1] * perp_dir[3], 
								main_dir[1] * perp_dir[2] - main_dir[2] * perp_dir[1]}
	
	--cylinder doesnt directly start at reference point, but shifted along main dir
	local cylinder_origin = {left_rp[1] - handle_over * main_dir[1], 
							left_rp[2] - handle_over * main_dir[2], 
							left_rp[3] - handle_over * main_dir[3]}
	
	local options = {u_axis = perp_dir, v_axis = third_dir, w_axis = main_dir}
	handle_cyl = pytha.create_cylinder(total_length, diameter / 2, cylinder_origin, options)
	pytha.delete_element_ref_point(handle_cyl)
		
	local block_origin = {	left_rp[1] - 0.5 * block_length * main_dir[1] - 0.5 * block_height * third_dir[1], 
							left_rp[2] - 0.5 * block_length * main_dir[2] - 0.5 * block_height * third_dir[2], 
							left_rp[3] - 0.5 * block_length * main_dir[3] - 0.5 * block_height * third_dir[3]}
	handle_block1 = pytha.create_block(depth, block_height, block_length, block_origin, options)
	block_origin[1] = block_origin[1] + handle_length * main_dir[1]
	block_origin[2] = block_origin[2] + handle_length * main_dir[2]
	block_origin[3] = block_origin[3] + handle_length * main_dir[3]
	handle_block2 = pytha.create_block(depth, block_height, block_length, block_origin, options)
	
	local grouping_table = {handle_cyl, handle_block1, handle_block2}
	local handle_group = pytha.create_group(grouping_table, {name = pyloc "Handle"})
	
	left_rp[1] = left_rp[1] + depth * (perp_dir[1])
	left_rp[2] = left_rp[2] + depth * (perp_dir[2])
	right_rp[1] = right_rp[1] + depth * (perp_dir[1])
	right_rp[2] = right_rp[2] + depth * (perp_dir[2])
	pytha.create_element_ref_point(handle_group, left_rp)
	pytha.create_element_ref_point(handle_group, right_rp)
	
	return handle_group
end



