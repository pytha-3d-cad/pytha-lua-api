--Straight cabinet with a variable number of shelves
function straight_cabinet_solo()
	local general_data = _G["general_data"]
	local spec_index = initialize_cabinet_values(general_data)
	local loaded_data = pyio.load_values("straight_dimensions")
	if loaded_data ~= nil then 
		merge_data(loaded_data, general_data)
	end
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	specific_data.individual_call = true
	
	general_data.own_direction = 0
	recreate_straight(general_data, general_data.cabinet_list[#general_data.cabinet_list])
	
	pyui.run_modal_dialog(straight_cabinet_solo_dialog, general_data)
	
	pyio.save_values("straight_dimensions", general_data)
end

function straight_cabinet_solo_dialog(dialog, general_data)
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	
	dialog:set_window_title(pyloc "Straight Cabinet")
	
	local label_benchtop = dialog:create_label(1, pyloc "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_height))
	local label_bt_thick = dialog:create_label(1, pyloc "Benchtop thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_thickness))
	local label1 = dialog:create_label(1, pyloc "Width")
	local width = dialog:create_text_box(2, pyui.format_length(specific_data.width))
	local label2 = dialog:create_label(1, pyloc "Height")
	local height = dialog:create_text_box(2, pyui.format_length(specific_data.height))
	local label3 = dialog:create_label(1, pyloc "Depth")
	local depth = dialog:create_text_box(2, pyui.format_length(general_data.depth))
	local label4 = dialog:create_label(1, pyloc "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(general_data.thickness))
	local label5 = dialog:create_label(1, pyloc "Drawer height")
	local drawer_height = dialog:create_text_box(2, pyui.format_length(specific_data.drawer_height))
	local label6 = dialog:create_label(1, pyloc "Number of shelves")
	local shelf_count = dialog:create_text_spin(2, pyui.format_length(specific_data.shelf_count), {0,10})
	
	general_data.door_side = dialog:create_check_box({1, 2}, pyloc "Door right side")
	general_data.door_side:set_control_checked(specific_data.door_rh)

	local align1 = dialog:create_align({1,2}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
--	dialog:equalize_column_widths({1,2,4})
	
	bt_height:set_on_change_handler(function(text)
		general_data.benchtop_height = pyui.parse_length(text)
		recreate_straight_cabinet_solo(general_data, specific_data)
	end)
	bt_thick:set_on_change_handler(function(text)
		specific_data.benchtop_thickness = pyui.parse_length(text)
		recreate_straight_cabinet_solo(general_data, specific_data)
	end)
	
	width:set_on_change_handler(function(text)
		specific_data.width = pyui.parse_length(text)
		recreate_straight_cabinet_solo(general_data, specific_data)
	end)
	
	height:set_on_change_handler(function(text)
		specific_data.height = pyui.parse_length(text)
		recreate_straight_cabinet_solo(general_data, specific_data)
	end)
	
	depth:set_on_change_handler(function(text)
		general_data.depth = pyui.parse_length(text)
		recreate_straight_cabinet_solo(general_data, specific_data)
	end)
	
	
	thickness:set_on_change_handler(function(text)
		general_data.thickness = pyui.parse_length(text)
		recreate_straight_cabinet_solo(general_data, specific_data)
	end)
	
	drawer_height:set_on_change_handler(function(text)
		specific_data.drawer_height = pyui.parse_length(text)
		recreate_straight_cabinet_solo(general_data, specific_data)
	end)
	
	shelf_count:set_on_change_handler(function(text)
		specific_data.shelf_count = pyui.parse_length(text)
		recreate_straight_cabinet_solo(general_data, specific_data)
	end)
	
	general_data.door_side:set_on_click_handler(function(state)
		specific_data.door_rh = state
		recreate_straight_cabinet_solo(general_data, specific_data)
	end)
	
	update_straight_cabinet_solo_ui(general_data, specific_data)
end

function recreate_straight_cabinet_solo(general_data, specific_data)
	update_straight_cabinet_solo_ui(general_data, specific_data)
	if specific_data.main_group ~= nil then
		pytha.delete_element(specific_data.main_group)
	end
	recreate_straight(general_data, specific_data)
end

function update_straight_cabinet_solo_ui(general_data, specific_data)
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  > specific_data.door_width then
			general_data.door_side:disable_control()
		else
			general_data.door_side:enable_control()
		end
	else 
		general_data.door_side:disable_control()
	end
end



function recreate_straight(general_data, specific_data)
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
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End LH"})
	table.insert(specific_data.cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End RH"})
	table.insert(specific_data.cur_elements, new_elem)
	--Bottom
	loc_origin[1] = general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth- groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Bottom"})
	table.insert(specific_data.cur_elements, new_elem)
	--Front rail
	loc_origin[3] = base_height + specific_data.height - general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin, {name = pyloc "CR Front"})
	table.insert(specific_data.cur_elements, new_elem)
	--Back rail
	loc_origin[2] = general_data.depth - general_data.width_rail - groove_dist_back_off
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin, {name = pyloc "CR Back"})
	table.insert(specific_data.cur_elements, new_elem)
	--Shelves
	for i = 1, specific_data.shelf_count, 1 do
		loc_origin[2] = general_data.setback_shelves
		loc_origin[3] = base_height + i * (door_height - general_data.thickness) / (specific_data.shelf_count + 1)
		local shelf_depth = general_data.depth - general_data.setback_shelves - groove_dist_back_off
		new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, shelf_depth, general_data.thickness, loc_origin, {name = pyloc "Adjustable shelf"})
		table.insert(specific_data.cur_elements, new_elem)
	end
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, specific_data.height, loc_origin, {name = pyloc "Back"})
	table.insert(specific_data.cur_elements, new_elem)
		

	--Door
	if specific_data.width - 2 * general_data.gap > 0 then
	
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = base_height
		if specific_data.width > specific_data.door_width then	--create two doors
			local door_width = specific_data.width / 2 - 2 * general_data.gap
		--left handed door
			loc_origin[1] = general_data.gap
			local door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, false, coordinate_system)
			table.insert(specific_data.cur_elements, door_group)
		--right handed door
			loc_origin[1] = specific_data.width - door_width - general_data.gap
			door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, true, coordinate_system)
			table.insert(specific_data.cur_elements, door_group)
		else
		--only one door 
			loc_origin[1] = general_data.gap
			local door_group = create_door(general_data, specific_data, specific_data.width - 2 * general_data.gap, door_height, loc_origin, specific_data.door_rh, coordinate_system)
			table.insert(specific_data.cur_elements, door_group)
		end
		
		--Drawer
		if specific_data.drawer_height > 0 then
			loc_origin[1] = general_data.gap
			loc_origin[3] = base_height + specific_data.height - general_data.top_gap - specific_data.drawer_height
			new_elem = create_drawer(general_data, specific_data, specific_data.width - 2 * general_data.gap, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
			table.insert(specific_data.cur_elements, new_elem)
		end
	end
	--Kickboard
	specific_data.kickboard_handle_left = pytha.create_block(specific_data.width, general_data.kickboard_thickness, base_height - general_data.kickboard_margin, {0, general_data.kickboard_setback, general_data.kickboard_margin}, {name = pyloc "Kickboard"})
	table.insert(specific_data.cur_elements, specific_data.kickboard_handle_left)
	specific_data.kickboard_handle_right = specific_data.kickboard_handle_left
	
	
	specific_data.right_connection_point = {specific_data.width, general_data.depth,0}
	specific_data.left_connection_point = {0, general_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
	specific_data.main_group = pytha.create_group(specific_data.cur_elements, {name = pyloc "Straight cabinet"})
	
	if specific_data.individual_call == nil then
		local benchtop = pytha.create_rectangle(specific_data.width, general_data.top_over + general_data.depth, {0, -general_data.top_over, general_data.benchtop_height - general_data.benchtop_thickness})
		specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness, {name = pyloc "Benchtop"})[1]
		pytha.delete_element(benchtop)
	end
	
	return specific_data.main_group
end



