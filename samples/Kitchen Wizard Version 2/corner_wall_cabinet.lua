--Corner wall cabinet, both left and right sided door
function cornerwall_cabinet_solo()
	local general_data = _G["general_default_data"]
	local spec_index = initialize_cabinet_values(general_data)
	local loaded_data = pyio.load_values("cornerwall_dimensions")
	if loaded_data ~= nil then 
		merge_data(loaded_data, general_data)
	end
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	specific_data.this_type = "cornerwall"
	specific_data.individual_call = true
	general_data.own_direction = 0
	recreate_cornerwall(general_data, general_data.cabinet_list[#general_data.cabinet_list])
	
	pyui.run_modal_dialog(cornerwall_dialog, general_data)
	
	pyio.save_values("cornerwall_dimensions", general_data)
end


local function cornerwall_dialog(dialog, general_data)
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	
	dialog:set_window_title("Corner Wall Cabinet")
	
	local label_benchtop = dialog:create_label(1, pyloc "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_height))
	local label2 = dialog:create_label(1, pyloc "Spacing to top")
	local wall_to_base = dialog:create_text_box(2, pyui.format_length(general_data.wall_to_base_spacing))
	local label1 = dialog:create_label(1, pyloc "Left Width")
	local width = dialog:create_text_box(2, pyui.format_length(specific_data.width))
	local label7 = dialog:create_label(1, pyloc "Right Width")
	local width2 = dialog:create_text_box(2, pyui.format_length(specific_data.width2))
	local label2 = dialog:create_label(1, "Height")
	local height = dialog:create_text_box(2, pyui.format_length(specific_data.height_top))
	local label3 = dialog:create_label(1, "Depth")
	local depth = dialog:create_text_box(2, pyui.format_length(general_data.depth_wall))
	local label4 = dialog:create_label(1, "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(general_data.thickness))
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
		recreate_cornerwall_solo(general_data, specific_data)
	end)
	
	wall_to_base:set_on_change_handler(function(text)
		general_data.wall_to_base_spacing = math.max(pyui.parse_length(text), 0)
		recreate_wall_cabinet_solo(general_data, specific_data)
	end)
	
	width:set_on_change_handler(function(text)
		specific_data.width = math.max(pyui.parse_length(text), 0)
		recreate_cornerwall_solo(general_data, specific_data)
	end)
	
	width2:set_on_change_handler(function(text)
		specific_data.width2 = math.max(pyui.parse_length(text), 0)
		recreate_cornerwall_solo(general_data, specific_data)
	end)
	
	height:set_on_change_handler(function(text)
		specific_data.height_top = math.max(pyui.parse_length(text), 0)
		recreate_cornerwall_solo(general_data, specific_data)
	end)
	
	depth:set_on_change_handler(function(text)
		general_data.depth_wall = math.max(pyui.parse_length(text), 0)
		recreate_cornerwall_solo(general_data, specific_data)
	end)
	
	thickness:set_on_change_handler(function(text)
		general_data.thickness = math.max(pyui.parse_length(text), 0)
		recreate_cornerwall_solo(general_data, specific_data)
	end)
	
	
	shelf_count:set_on_change_handler(function(text)
		specific_data.shelf_count = math.max(pyui.parse_length(text), 0)
		recreate_cornerwall_solo(general_data, specific_data)
	end)
	
	check:set_on_click_handler(function(state)
		specific_data.door_rh = state
		recreate_cornerwall_solo(general_data, specific_data)
	end)
end

local function recreate_cornerwall_solo(general_data, specific_data)
	update_cornerwall_ui(general_data, specific_data)
	
	if specific_data.main_group ~= nil then
		pytha.delete_element(specific_data.main_group)
	end
	recreate_cornerwall(general_data, specific_data)
end

function update_cornerwall_ui(general_data, specific_data)
	--currently empty
	
end

local function recreate_cornerwall(general_data, specific_data)
	local cur_elements = {}
	
	local base_height = general_data.wall_to_base_spacing + general_data.benchtop_height

	local door_height = specific_data.height_top - base_height
	
	if specific_data.individual_top_row_height ~= nil then
		door_height = specific_data.individual_top_row_height - base_height
	end
	
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin= {}
	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth_wall, door_height, loc_origin, {name = pyloc "End LH"})
	table.insert(cur_elements, new_elem)
	
	--Right side
	loc_origin[1] = specific_data.width - general_data.depth_wall
	loc_origin[2] = general_data.depth_wall - specific_data.width2
	new_elem = pytha.create_block(general_data.depth_wall, general_data.thickness, door_height, loc_origin, {name = pyloc "End RH"})
	table.insert(cur_elements, new_elem)
	
	
	loc_origin[1] = 0
	loc_origin[2] = 0
	--Bottom
	poly_array = {{general_data.thickness, 0, 0}, 
					{specific_data.width - general_data.depth_wall, 0, 0}, 
					{specific_data.width - general_data.depth_wall, general_data.depth_wall - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth_wall - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth_wall - groove_dist_back_off, 0},
					{general_data.thickness, general_data.depth_wall - groove_dist_back_off, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	profile = pytha.create_profile(fla_handle, general_data.thickness, {name = pyloc "Bottom"})[1]
	pytha.move_element(profile, loc_origin)
	table.insert(cur_elements, profile)
	
	--We reuse the fla handle for the top and the shelves
	loc_origin[3] = base_height + door_height - general_data.thickness
	profile = pytha.create_profile(fla_handle, general_data.thickness, {name = pyloc "Top"})[1]
	pytha.delete_element(fla_handle)
	pytha.move_element(profile, loc_origin)
	table.insert(cur_elements, profile)
	
	--shelf setback needs pythagoras 
	--Shelves
	poly_array = {{general_data.thickness, general_data.setback_shelves, 0}, 
					{specific_data.width - general_data.depth_wall + general_data.setback_shelves, general_data.setback_shelves, 0}, 
					{specific_data.width - general_data.depth_wall + general_data.setback_shelves, general_data.depth_wall - specific_data.width2 + general_data.thickness + general_data.setback_shelves, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth_wall - specific_data.width2 + general_data.thickness + general_data.setback_shelves, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth_wall - groove_dist_back_off, 0},
					{general_data.thickness, general_data.depth_wall - groove_dist_back_off, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	
	for i=1,specific_data.shelf_count,1 do
		loc_origin[3] = base_height + i * (door_height - general_data.thickness) / (specific_data.shelf_count + 1)
		profile = pytha.create_profile(fla_handle, general_data.thickness, {name = pyloc "Adjustable shelf"})[1]
		pytha.move_element(profile, loc_origin)
		table.insert(cur_elements, profile)
	end
	pytha.delete_element(fla_handle)
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth_wall - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - general_data.thickness + general_data.groove_depth - groove_dist_back_off, general_data.thickness_back, door_height, loc_origin, {name = pyloc "Back"})
	table.insert(cur_elements, new_elem)
	loc_origin[1] = specific_data.width - groove_dist_back_off
	loc_origin[2] = general_data.depth_wall - specific_data.width2 +  general_data.thickness - general_data.groove_depth
	loc_origin[3] = base_height 
	new_elem = pytha.create_block(general_data.thickness_back, specific_data.width2 - general_data.thickness + general_data.groove_depth - groove_dist_back_off + general_data.thickness_back, door_height, loc_origin, {name = pyloc "Back"})
	table.insert(cur_elements, new_elem)
	
	
	--Door
	local door_width_left = specific_data.width - general_data.depth_wall - general_data.thickness - 2 * general_data.gap
	local door_width_right = specific_data.width2 - general_data.depth_wall - 2 * general_data.gap
	local door_name = {name = pyloc "Door RH"}
	if specific_data.door_rh == false then
		door_width_left = specific_data.width - general_data.depth_wall - 2 * general_data.gap
		door_width_right = specific_data.width2 - general_data.depth_wall - general_data.thickness - 2 * general_data.gap
		door_name = {name = pyloc "Door LH"}
	end
	local door_group1 = nil
	local door_group2 = nil
	local rp_pos1 = {}
	if door_width_left > 0 then 
		loc_origin[1] = general_data.gap
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = base_height
		if specific_data.door_rh == false then 
			new_elem = pytha.create_block(door_width_left, general_data.thickness, door_height, loc_origin, door_name)
			door_group1 = pytha.create_group(new_elem, door_name)
			rp_pos1 = {loc_origin[1], loc_origin[2], loc_origin[3]}
		else 
			door_group1 = create_door(general_data, specific_data, door_width_left, door_height, loc_origin, specific_data.door_rh, coordinate_system, 'bottom')
		end
	end
	if door_width_right > 0 then 
		
		loc_origin[1] = specific_data.width - general_data.depth_wall - general_data.thickness
		if specific_data.door_rh == false then
			loc_origin[2] = general_data.depth_wall - specific_data.width2 - general_data.gap - general_data.thickness
		else
			loc_origin[2] = general_data.depth_wall - specific_data.width2 - general_data.gap
		end
		loc_origin[3] = base_height
		coordinate_system = {{0, -1, 0}, {1, 0, 0}, {0,0,1}}
		if specific_data.door_rh == false then 
			loc_origin[2] = - general_data.gap - general_data.thickness
			door_group2 = create_door(general_data, specific_data, door_width_right, door_height, loc_origin, specific_data.door_rh, coordinate_system, 'bottom')
		else 
			loc_origin[2] = general_data.depth_wall - specific_data.width2 + general_data.gap
			new_elem = pytha.create_block(general_data.thickness, door_width_right, door_height, loc_origin, door_name)
			rp_pos1 = {loc_origin[1], loc_origin[2], loc_origin[3]}
			
			door_group2 = pytha.create_group(new_elem, door_name)
		end
	end
	local total_door_group = pytha.create_group({door_group1, door_group2}, door_name)
	pytha.create_element_ref_point(total_door_group, rp_pos1)
	rp_pos1[3] = rp_pos1[3] + door_height
	pytha.create_element_ref_point(total_door_group, rp_pos1)
	if specific_data.door_rh == true then
		total_door_group:set_element_attributes({action_string = "ROTATE(90,R1R2,R1S30)"})
	else
		total_door_group:set_element_attributes({action_string = "ROTATE(-90,R1R2,R1S30)"})
	end
	table.insert(cur_elements, total_door_group)
	
	--Downlight
	--we need to flip the face light source uside down, so we simply use the -z direction. 
	new_elem = pytha.create_rectangle(50, 50, {specific_data.width / 2 + 25, math.max(general_data.depth_wall - 150, general_data.depth_wall / 2) - 25, base_height - 10}, {w_axis = "-z", name = "light_375"})
	table.insert(cur_elements, new_elem)
	new_elem = pytha.create_rectangle(50, 50, {specific_data.width + math.max(- 150, - general_data.depth_wall / 2) + 25, general_data.depth_wall - specific_data.width2 / 2 - 25, base_height - 10}, {w_axis = "-z", name = "light_375"})
	table.insert(cur_elements, new_elem)

	specific_data.left_direction = 0
	
	specific_data.main_group = pytha.create_group(cur_elements)
	

	
	return specific_data.main_group
end

local function placement_cornerwall(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, general_data.depth_wall - specific_data.width2, 0}
	specific_data.left_connection_point = {0, general_data.depth_wall, 0}
	specific_data.origin_point = {specific_data.width, general_data.depth_wall, 0}
	specific_data.right_direction = -90
	specific_data.left_direction = 0
end

local function ui_update_cornerwall(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	controls.door_side:enable_control()
	
	if soft_update == true then return end

	controls.label_width:enable_control()
	controls.width:enable_control()
	controls.label_width2:enable_control()
	controls.width2:enable_control()
	controls.height_top_label:enable_control()
	controls.height_top:enable_control()
	controls.label6:enable_control()
	controls.shelf_count:enable_control()
	controls.door_width:enable_control()
	controls.label_door_width:enable_control()
	
	controls.door_side:set_control_text(pyloc "Door RH")
	controls.label_width:set_control_text(pyloc "Left width")
	controls.label_width2:set_control_text(pyloc "Right width")		
	controls.label_door_width:set_control_text(pyloc "Max door width")	
	
end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.cornerwall = 				
{									
	name = pyloc "Corner wall cabinet",
	row = 0x2,
	default_data = {width = 650,
					width2 = 650,},
	geometry_function = recreate_cornerwall,
	placement_function = placement_cornerwall, 	
	ui_update_function = ui_update_cornerwall,
	organization_styles = {},
}

