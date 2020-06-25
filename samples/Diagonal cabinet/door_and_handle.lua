
function create_door(data, width, door_height, origin, door_rh, coordinate_system)
	local loc_origin = {origin[1], origin[2], origin[3]} 	--tables are by reference, so you could overwrite the origin in the calling function. Therefore we assign by value.
	local axes = {u_axis = coordinate_system[1], v_axis = coordinate_system[2], w_axis = coordinate_system[3]}
	
	new_elem = pytha.create_block(width, data.thickness, door_height, loc_origin, axes)
	table.insert(data.cur_elements, new_elem)
	local h_posi_code = ''
	local v_posi_code = 'top'
	if door_rh == false then	
		h_posi_code = 'right'
	else 
		h_posi_code = 'left'
	end
	create_handle(data, loc_origin, width, door_height, true, coordinate_system, h_posi_code, v_posi_code)
end

--origin, width and height are for the whole door. The handle then is positioned according to the posi codes
function create_handle(data, origin, width, height, vert, coordinate_system, h_posi_code, v_posi_code)
	local loc_origin = {origin[1], origin[2], origin[3]} 	--tables are by reference, so you could overwrite the origin in the calling function. Therefore we assign by value.
	local handle_over = 12.5
	local total_length = data.handle_length + 2 * handle_over
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
			left_rp[1] = reference_coordinate[1] - data.handle_length * coordinate_system[1][1]
			left_rp[2] = reference_coordinate[2] - data.handle_length * coordinate_system[1][2]
			right_rp[1] = reference_coordinate[1]
			right_rp[2] = reference_coordinate[2]
		end
	elseif h_posi_code == 'center' then
		reference_coordinate[1] = loc_origin[1] + 0.5 * width * coordinate_system[1][1]
		reference_coordinate[2] = loc_origin[2] + 0.5 * width * coordinate_system[1][2]
		if vert == false then
			left_rp[1] = reference_coordinate[1] - 0.5 * data.handle_length * coordinate_system[1][1]
			left_rp[2] = reference_coordinate[2] - 0.5 * data.handle_length * coordinate_system[1][2]
			right_rp[1] = reference_coordinate[1] + 0.5 * data.handle_length * coordinate_system[1][1]
			right_rp[2] = reference_coordinate[2] + 0.5 * data.handle_length * coordinate_system[1][2]
		end
	else 
		reference_coordinate[1] = loc_origin[1] + hori_off * coordinate_system[1][1]
		reference_coordinate[2] = loc_origin[2] + hori_off * coordinate_system[1][2]
		if vert == false then
			left_rp[1] = reference_coordinate[1]
			left_rp[2] = reference_coordinate[2]
			right_rp[1] = reference_coordinate[1] + data.handle_length * coordinate_system[1][1]
			right_rp[2] = reference_coordinate[2] + data.handle_length * coordinate_system[1][2]
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
			right_rp[3] = reference_coordinate[3] - data.handle_length 
		end
	elseif v_posi_code == 'center' then
		reference_coordinate[3] = loc_origin[3] + 0.5 * height
		if vert == true then
			left_rp[3] = reference_coordinate[3] + 0.5 * data.handle_length 
			right_rp[3] = reference_coordinate[3] - 0.5 * data.handle_length 
		end
	else 
		reference_coordinate[3] = loc_origin[3] + vert_off
		if vert == true then
			left_rp[3] = reference_coordinate[3] + data.handle_length 
			right_rp[3] = reference_coordinate[3]
		end
	end
	if vert == false then 
		left_rp[3] = reference_coordinate[3]
		right_rp[3] = reference_coordinate[3]
	end
		
	
	
	--this is so we do not have to treat any different cases  
	local main_dir = {right_rp[1] - left_rp[1], right_rp[2] - left_rp[2], right_rp[3] - left_rp[3]}
	main_dir[1] = main_dir[1] / data.handle_length
	main_dir[2] = main_dir[2] / data.handle_length
	main_dir[3] = main_dir[3] / data.handle_length
	

	local third_dir =  {main_dir[2] * perp_dir[3] - main_dir[3] * perp_dir[2], 
								main_dir[3] * perp_dir[1] - main_dir[1] * perp_dir[3], 
								main_dir[1] * perp_dir[2] - main_dir[2] * perp_dir[1]}
	
	--cylinder doesnt directly start at reference point, but shifted along main dir
	local cylinder_origin = {left_rp[1] - handle_over * main_dir[1], 
							left_rp[2] - handle_over * main_dir[2], 
							left_rp[3] - handle_over * main_dir[3]}
	
	local options = {u_axis = perp_dir, v_axis = third_dir, w_axis = main_dir}
	handle_cyl = pytha.create_cylinder(total_length, diameter / 2, cylinder_origin, options)
		
	local block_origin = {	left_rp[1] - 0.5 * block_length * main_dir[1] - 0.5 * block_height * third_dir[1], 
							left_rp[2] - 0.5 * block_length * main_dir[2] - 0.5 * block_height * third_dir[2], 
							left_rp[3] - 0.5 * block_length * main_dir[3] - 0.5 * block_height * third_dir[3]}
	handle_block1 = pytha.create_block(depth, block_height, block_length, block_origin, options)
	block_origin[1] = block_origin[1] + data.handle_length * main_dir[1]
	block_origin[2] = block_origin[2] + data.handle_length * main_dir[2]
	block_origin[3] = block_origin[3] + data.handle_length * main_dir[3]
	handle_block2 = pytha.create_block(depth, block_height, block_length, block_origin, options)
	
	local grouping_table = {handle_cyl, handle_block1, handle_block2}
	local handle_group = pytha.create_group(grouping_table)
	table.insert(data.cur_elements, handle_group)
end



