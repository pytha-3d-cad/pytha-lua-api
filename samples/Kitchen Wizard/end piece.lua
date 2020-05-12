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


	specific_data.right_connection_point = {general_data.thickness,0,0}
	specific_data.left_connection_point = {0,0,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
	specific_data.main_group = pytha.group_elements(specific_data.cur_elements)
	
	specific_data.elem_handle_for_top = pytha.create_rectangle(general_data.thickness, general_data.top_over + general_data.depth, {0, -general_data.top_over, general_data.benchtop_height - general_data.benchtop_thickness})
	
	return specific_data.main_group
end



