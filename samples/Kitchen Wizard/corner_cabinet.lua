--Corner cabinet, both left and right sided door
function corner_cabinet_solo()
	local general_data = _G["general_data"]
	local spec_index = initialize_cabinet_values(general_data)
	local loaded_data = pyio.load_values("corner_dimensions")
	if loaded_data ~= nil then 
		merge_data(loaded_data, general_data)
	end
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	specific_data.this_type = "corner"
	specific_data.individual_call = true
	general_data.own_direction = 0
	recreate_corner(general_data, general_data.cabinet_list[#general_data.cabinet_list])
	
	pyui.run_modal_dialog(corner_dialog, general_data)
	
	pyio.save_values("corner_dimensions", general_data)
end


function corner_dialog(dialog, general_data)
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	
	dialog:set_window_title("Corner Cabinet")
	
	local label_benchtop = dialog:create_label(1, "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_height))
	local label_bt_thick = dialog:create_label(1, "Benchtop thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_thickness))
	local label1 = dialog:create_label(1, "Width")
	local width = dialog:create_text_box(2, pyui.format_length(specific_data.corner_width))
	local label2 = dialog:create_label(1, "Height")
	local height = dialog:create_text_box(2, pyui.format_length(specific_data.height))
	local label3 = dialog:create_label(1, "Depth")
	local depth = dialog:create_text_box(2, pyui.format_length(general_data.depth))
	local label6 = dialog:create_label(1, "Door width")
	local door_width = dialog:create_text_box(2, pyui.format_length(specific_data.door_width))
	local label4 = dialog:create_label(1, "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(general_data.thickness))
	local label5 = dialog:create_label(1, "Drawer height")
	local drawer_height = dialog:create_text_box(2, pyui.format_length(specific_data.drawer_height))
	local label6 = dialog:create_label(1, "Number of shelves")
	local shelf_count = dialog:create_text_box(2, pyui.format_length(specific_data.shelf_count))
	
	local check = dialog:create_check_box({1, 2}, "Door on right side")
	check:set_control_checked(specific_data.door_rh)

	local align1 = dialog:create_align({1,2}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
	dialog:equalize_column_widths({1,2,4})
	
	bt_height:set_on_change_handler(function(text)
		general_data.benchtop_height = math.max(pyui.parse_length(text), 0)
		recreate_corner_solo(general_data, specific_data)
	end)
	bt_thick:set_on_change_handler(function(text)
		general_data.benchtop_thickness = math.max(pyui.parse_length(text), 0)
		recreate_corner_solo(general_data, specific_data)
	end)
	
	width:set_on_change_handler(function(text)
		specific_data.corner_width = math.max(pyui.parse_length(text), 0)
		recreate_corner_solo(general_data, specific_data)
	end)
	
	height:set_on_change_handler(function(text)
		specific_data.height = math.max(pyui.parse_length(text), 0)
		recreate_corner_solo(general_data, specific_data)
	end)
	
	depth:set_on_change_handler(function(text)
		general_data.depth = math.max(pyui.parse_length(text), 0)
		recreate_corner_solo(general_data, specific_data)
	end)
	
	door_width:set_on_change_handler(function(text)
		specific_data.door_width = math.max(pyui.parse_length(text), 0)
		recreate_corner_solo(general_data, specific_data)
	end)
	
	thickness:set_on_change_handler(function(text)
		general_data.thickness = math.max(pyui.parse_length(text), 0)
		recreate_corner_solo(general_data, specific_data)
	end)
	
	drawer_height:set_on_change_handler(function(text)
		specific_data.drawer_height = math.max(pyui.parse_length(text), 0)
		recreate_corner_solo(general_data, specific_data)
	end)
	
	shelf_count:set_on_change_handler(function(text)
		specific_data.shelf_count = math.max(pyui.parse_length(text), 0)
		recreate_corner_solo(general_data, specific_data)
	end)
	
	check:set_on_click_handler(function(state)
		specific_data.door_rh = state
		recreate_corner_solo(general_data, specific_data)
	end)
end

function recreate_corner_solo(general_data, specific_data)
	update_corner_ui(general_data, specific_data)
	
	if specific_data.main_group ~= nil then
		pytha.delete_element(specific_data.main_group)
	end
	recreate_corner(general_data, specific_data)
end

function update_corner_ui(general_data, specific_data)
	--currently empty
	
end

function recreate_corner(general_data, specific_data)
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
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End LH"})
	table.insert(specific_data.cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.corner_width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End RH"})
	table.insert(specific_data.cur_elements, new_elem)
	--Bottom
	loc_origin[1] = general_data.thickness
	new_elem = pytha.create_block(specific_data.corner_width - 2 * general_data.thickness, general_data.depth - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Bottom"})
	table.insert(specific_data.cur_elements, new_elem)
	--Front rail
	loc_origin[3] = base_height + specific_data.height - general_data.thickness
	new_elem = pytha.create_block(specific_data.corner_width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin, {name = pyloc "CR Front"})
	table.insert(specific_data.cur_elements, new_elem)
	--Back rail
	loc_origin[2] = general_data.depth - general_data.width_rail - groove_dist_back_off
	new_elem = pytha.create_block(specific_data.corner_width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin, {name = pyloc "CR Back"})
	table.insert(specific_data.cur_elements, new_elem)
	--Shelves
	for i=1, specific_data.shelf_count, 1 do
		loc_origin[2] = general_data.setback_shelves
		loc_origin[3] = base_height + i * (door_height - general_data.thickness) / (specific_data.shelf_count + 1)
		local shelf_depth = general_data.depth - general_data.setback_shelves - groove_dist_back_off
		new_elem = pytha.create_block(specific_data.corner_width - 2 * general_data.thickness, shelf_depth, general_data.thickness, loc_origin, {name = pyloc "Adjustable shelf"})
		table.insert(specific_data.cur_elements, new_elem)
	end
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.corner_width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, specific_data.height, loc_origin, {name = pyloc "Back"})
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
		local corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap, {name = pyloc "Corner angle"})[1]
		table.insert(specific_data.cur_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.corner_width - specific_data.door_width  - 100
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
		local corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap, {name = pyloc "Corner angle"})[1]
		table.insert(specific_data.cur_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.door_width + general_data.gap
		loc_origin[2] = 0
		loc_origin[3] = base_height
		pytha.move_element(corner_angle, loc_origin)
	end
	if specific_data.door_rh == true then
		loc_origin[1] = specific_data.corner_width - specific_data.door_width - 100 - general_data.thickness
	else
		loc_origin[1] = specific_data.door_width + 100
	end
	loc_origin[2] = - 100
	new_elem = pytha.create_block(general_data.thickness, 100, specific_data.height, loc_origin, {name = pyloc "Corner Blind"})
	table.insert(specific_data.cur_elements, new_elem)
	
	--Kickboard
	loc_origin[2] = general_data.kickboard_setback
	loc_origin[3] = general_data.kickboard_margin
	if specific_data.door_rh == true then
		loc_origin[1] = specific_data.corner_width - specific_data.door_width - 100 - general_data.kickboard_thickness - general_data.kickboard_setback
		specific_data.kickboard_handle_right = pytha.create_block(specific_data.door_width + 100 + general_data.kickboard_thickness + general_data.kickboard_setback, general_data.kickboard_thickness, base_height - general_data.kickboard_margin, loc_origin, {name = pyloc "Kickboard"})
		loc_origin[2] = - 100
		specific_data.kickboard_handle_left = pytha.create_block(general_data.kickboard_thickness, 100 + general_data.kickboard_setback, base_height - general_data.kickboard_margin, loc_origin, {name = pyloc "Kickboard"})
	else
		loc_origin[1] = 0
		loc_origin[2] = general_data.kickboard_setback
		specific_data.kickboard_handle_left = pytha.create_block(specific_data.door_width + 100 + general_data.kickboard_thickness + general_data.kickboard_setback, general_data.kickboard_thickness, base_height - general_data.kickboard_margin, 
																																														loc_origin, {name = pyloc "Kickboard"})
		loc_origin[1] = specific_data.door_width + 100 + general_data.kickboard_setback
		loc_origin[2] = - 100
		specific_data.kickboard_handle_right = pytha.create_block(general_data.kickboard_thickness, 100 + general_data.kickboard_setback, base_height - general_data.kickboard_margin, loc_origin, {name = pyloc "Kickboard"})
	end
	table.insert(specific_data.cur_elements, specific_data.kickboard_handle_left)
	table.insert(specific_data.cur_elements, specific_data.kickboard_handle_right)
		
	
	--Door
	if specific_data.door_width - 2 * general_data.gap > 0 then
		if specific_data.door_rh == true then
			loc_origin[1] = specific_data.corner_width - specific_data.door_width + general_data.gap
		else
			loc_origin[1] = general_data.gap
		end
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = base_height
		
		local door_group = create_door(general_data, specific_data, specific_data.door_width - 2 * general_data.gap, door_height, loc_origin, not specific_data.door_rh, coordinate_system)
		table.insert(specific_data.cur_elements, door_group)
		
		--Drawer
		if specific_data.drawer_height > 0 then
			loc_origin[3] = base_height + specific_data.height - general_data.top_gap - specific_data.drawer_height
			new_elem = create_drawer(general_data, specific_data, specific_data.door_width - 2 * general_data.gap, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
			table.insert(specific_data.cur_elements, new_elem)
		end
	end
	
	local z = general_data.benchtop_height - general_data.benchtop_thickness
	local poly_array = {}
	if specific_data.door_rh == true then
		specific_data.right_connection_point = {specific_data.corner_width, general_data.depth, 0}
		specific_data.left_connection_point = {specific_data.corner_width - specific_data.door_width - 100 - general_data.depth,-100,0}
		specific_data.right_direction = 0
		specific_data.left_direction = 90
		poly_array = {{specific_data.corner_width - specific_data.door_width - 100 + general_data.top_over, -100, z}, 
						{specific_data.corner_width - specific_data.door_width - 100 + general_data.top_over, - general_data.top_over, z}, 
						{specific_data.corner_width, - general_data.top_over, z}, 
						{specific_data.corner_width, general_data.depth, z}, 
						{specific_data.corner_width - specific_data.door_width - 100 - general_data.depth, general_data.depth, z},
						{specific_data.corner_width - specific_data.door_width - 100 - general_data.depth, -100, z}}
	else
		specific_data.right_connection_point = {specific_data.door_width + 100 + general_data.depth, -100, 0}
		specific_data.left_connection_point = {0, general_data.depth,0}
		specific_data.right_direction = -90
		specific_data.left_direction = 0
		poly_array = {{0, -general_data.top_over, z}, 
						{specific_data.door_width + 100 - general_data.top_over, -general_data.top_over, z}, 
						{specific_data.door_width + 100 - general_data.top_over, -100, z}, 
						{specific_data.door_width + 100 + general_data.depth, -100, z}, 
						{specific_data.door_width + 100 + general_data.depth, general_data.depth, z}, 
						{0, general_data.depth, z}}
	end
	
	
	specific_data.main_group = pytha.create_group(specific_data.cur_elements, {name = pyloc "Corner cabinet"})
	
	if specific_data.individual_call == nil then
		local benchtop = pytha.create_polygon(poly_array)
		specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness, {name = pyloc "Benchtop"})[1]
		pytha.delete_element(benchtop)
	end
	
	return specific_data.main_group
end

