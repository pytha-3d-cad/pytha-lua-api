--wall cabinet with two doors
function wall_cabinet_solo()
	local general_data = _G["general_data"]
	local spec_index = initialize_cabinet_values(general_data)
	local loaded_data = pyio.load_values("wall_dimensions")
	if loaded_data ~= nil then 
		merge_data(loaded_data, general_data)
	end
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	specific_data.this_type = "wall"
	specific_data.width = 600
	specific_data.row = 0x2
	specific_data.individual_call = true
	
	general_data.own_direction = 0
	recreate_wall(general_data, general_data.cabinet_list[#general_data.cabinet_list])
	
	pyui.run_modal_dialog(wall_cabinet_solo_dialog, general_data)
	
	pyio.save_values("wall_dimensions", general_data)
end

function wall_cabinet_solo_dialog(dialog, general_data)
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	
	dialog:set_window_title("Wall Cabinet")
	
	local label_benchtop = dialog:create_label(1, pyloc "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_height))
	local label2 = dialog:create_label(1, pyloc "Spacing to top")
	local wall_to_base = dialog:create_text_box(2, pyui.format_length(general_data.wall_to_base_spacing))
	local label1 = dialog:create_label(1, pyloc "Width")
	local width = dialog:create_text_box(2, pyui.format_length(specific_data.width))
	local label5 = dialog:create_label(1, pyloc "Top Height")
	local height = dialog:create_text_box(2, pyui.format_length(specific_data.height_top))
	local label3 = dialog:create_label(1, pyloc "Depth")
	local depth = dialog:create_text_box(2, pyui.format_length(general_data.depth_wall))
	local label4 = dialog:create_label(1, pyloc "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(general_data.thickness))
	
	general_data.door_side = dialog:create_check_box({1, 2}, pyloc "Door right side")
	general_data.door_side:set_control_checked(specific_data.door_rh)

	local align1 = dialog:create_align({1,2})
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
--	dialog:equalize_column_widths({1,2,4})
	
	bt_height:set_on_change_handler(function(text)
		general_data.benchtop_height = math.max(pyui.parse_length(text), 0)
		recreate_wall_cabinet_solo(general_data, specific_data)
	end)
	width:set_on_change_handler(function(text)
		specific_data.width = math.max(pyui.parse_length(text), 0)
		recreate_wall_cabinet_solo(general_data, specific_data)
	end)
	
	height:set_on_change_handler(function(text)
		specific_data.height_top = math.max(pyui.parse_length(text), 0)
		recreate_wall_cabinet_solo(general_data, specific_data)
	end)
	
	wall_to_base:set_on_change_handler(function(text)
		general_data.wall_to_base_spacing = math.max(pyui.parse_length(text), 0)
		recreate_wall_cabinet_solo(general_data, specific_data)
	end)
	
	depth:set_on_change_handler(function(text)
		general_data.depth_wall = math.max(pyui.parse_length(text), 0)
		recreate_wall_cabinet_solo(general_data, specific_data)
	end)
	
	
	thickness:set_on_change_handler(function(text)
		general_data.thickness = math.max(pyui.parse_length(text), 0)
		recreate_wall_cabinet_solo(general_data, specific_data)
	end)
	
	general_data.door_side:set_on_click_handler(function(state)
		specific_data.door_rh = state
		recreate_wall_cabinet_solo(general_data, specific_data)
	end)
	
	update_wall_cabinet_solo_ui(general_data, specific_data)
end

function recreate_wall_cabinet_solo(general_data, specific_data)
	update_wall_cabinet_solo_ui(general_data, specific_data)
	if specific_data.main_group ~= nil then
		pytha.delete_element(specific_data.main_group)
	end
	recreate_wall(general_data, specific_data)
end

function update_wall_cabinet_solo_ui(general_data, specific_data)
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



function recreate_wall(general_data, specific_data)
	specific_data.cur_elements = {}
	
	local base_height = general_data.wall_to_base_spacing + general_data.benchtop_height
	local door_height = specific_data.height_top - base_height
	
	local loc_origin= {}
	
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	

	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth_wall, door_height, loc_origin, {name = pyloc "End LH"})
	table.insert(specific_data.cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth_wall, door_height, loc_origin, {name = pyloc "End RH"})
	table.insert(specific_data.cur_elements, new_elem)
	--Bottom
	loc_origin[1] = general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth_wall - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Bottom"})
	table.insert(specific_data.cur_elements, new_elem)
	--Top
	loc_origin[3] = base_height + door_height - general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth_wall - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Top"})
	table.insert(specific_data.cur_elements, new_elem)
	--Shelves
	for i = 1, specific_data.shelf_count, 1 do
		loc_origin[2] = general_data.setback_shelves
		loc_origin[3] = base_height + i * (door_height - general_data.thickness) / (specific_data.shelf_count + 1)
		local shelf_depth = general_data.depth_wall - general_data.setback_shelves - groove_dist_back_off
		new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, shelf_depth, general_data.thickness, loc_origin, {name = pyloc "Adjustable shelf"})
		table.insert(specific_data.cur_elements, new_elem)
	end
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth_wall - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, door_height, loc_origin, {name = pyloc "Back"})
	table.insert(specific_data.cur_elements, new_elem)
		
	--Doors
	if specific_data.width - 2 * general_data.gap > 0 then
		
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = base_height
		if specific_data.width > specific_data.door_width then	--create two doors
			local door_width = specific_data.width / 2 - 2 * general_data.gap
		--left handed door
			loc_origin[1] = general_data.gap
			local door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, false, coordinate_system, 'bottom')
			table.insert(specific_data.cur_elements, door_group)
		--right handed door
			loc_origin[1] = specific_data.width - door_width - general_data.gap
			door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, true, coordinate_system, 'bottom')
			table.insert(specific_data.cur_elements, door_group)
		else
		--only one door 
			loc_origin[1] = general_data.gap
			local door_group = create_door(general_data, specific_data, specific_data.width - 2 * general_data.gap, door_height, loc_origin, specific_data.door_rh, coordinate_system, 'bottom')
			table.insert(specific_data.cur_elements, door_group)
		end
	end
	
	--Downlight
	--we need to flip the face light source uside down, so we simply use the -z direction. 
	new_elem = pytha.create_rectangle(50, 50, {specific_data.width / 2 + 25, math.max(general_data.depth_wall - 150, general_data.depth_wall / 2) - 25, base_height - 10}, {w_axis = "-z", name = "light_375"})
	table.insert(specific_data.cur_elements, new_elem)
	
	
	
	specific_data.right_connection_point = {specific_data.width, general_data.depth_wall,0}
	specific_data.left_connection_point = {0, general_data.depth_wall,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
	specific_data.main_group = pytha.create_group(specific_data.cur_elements, {name = pyloc "Wall cabinet"})
	
	return specific_data.main_group
end



