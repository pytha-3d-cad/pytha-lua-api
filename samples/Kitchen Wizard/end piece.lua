--Blind End Side

function recreate_endpiece(general_data, specific_data)
	specific_data.cur_elements = {}
	
	local loc_origin= {}

	loc_origin[1] = 0
	loc_origin[2] = 0 - general_data.thickness
	loc_origin[3] = 0
	local height = general_data.benchtop_height - general_data.benchtop_thickness 
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth + general_data.thickness, height, loc_origin)
	table.insert(specific_data.cur_elements, new_elem)

	specific_data.kickboard_handle_right = nil
	specific_data.kickboard_handle_left = nil
	specific_data.right_connection_point = {general_data.thickness, general_data.depth,0}
	specific_data.left_connection_point = {0, general_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
	specific_data.main_group = pytha.create_group(specific_data.cur_elements, {name = pyloc "End piece"})
	
	local benchtop = pytha.create_rectangle(general_data.thickness, general_data.top_over + general_data.depth, {0, -general_data.top_over, general_data.benchtop_height - general_data.benchtop_thickness})
	specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness, {name = pyloc "Benchtop"})[1]
	pytha.delete_element(benchtop)
	
	return specific_data.main_group
end


