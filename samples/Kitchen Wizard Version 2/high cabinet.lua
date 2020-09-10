--High cabinet with two doors
function high_cabinet_solo()
	local general_data = _G["general_default_data"]
	local spec_index = initialize_cabinet_values(general_data)
	local loaded_data = pyio.load_values("high_dimensions")
	if loaded_data ~= nil then 
		merge_data(loaded_data, general_data)
	end
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	specific_data.this_type = "high"
	specific_data.width = 600
	specific_data.row = 0x3
	specific_data.individual_call = true
	
	general_data.own_direction = 0
	recreate_high(general_data, general_data.cabinet_list[#general_data.cabinet_list])
	
	pyui.run_modal_dialog(high_cabinet_solo_dialog, general_data)
	
	pyio.save_values("high_dimensions", general_data)
end

local function high_cabinet_solo_dialog(dialog, general_data)
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	
	dialog:set_window_title("High Cabinet")
	
	local label_benchtop = dialog:create_label(1, pyloc "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_height))
	local label_bt_thick = dialog:create_label(1, pyloc "Benchtop thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_thickness))
	local label1 = dialog:create_label(1, pyloc "Width")
	local width = dialog:create_text_box(2, pyui.format_length(specific_data.width))
	local label2 = dialog:create_label(1, pyloc "Height")
	local height = dialog:create_text_box(2, pyui.format_length(specific_data.height_top))
	local label3 = dialog:create_label(1, pyloc "Depth")
	local depth = dialog:create_text_box(2, pyui.format_length(general_data.depth))
	local label4 = dialog:create_label(1, pyloc "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(general_data.thickness))
--	local label5 = dialog:create_label(1, "Drawer height")
--	local drawer_height = dialog:create_text_box(2, pyui.format_length(specific_data.drawer_height))
--	local label6 = dialog:create_label(1, "Number of shelves")
--	local shelf_count = dialog:create_text_spin(2, pyui.format_length(specific_data.shelf_count), {0,10})
	
	general_data.door_side = dialog:create_check_box({1, 2}, pyloc "Door right side")
	general_data.door_side:set_control_checked(specific_data.door_rh)

	local align1 = dialog:create_align({1,2}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
--	dialog:equalize_column_widths({1,2,4})
	
	bt_height:set_on_change_handler(function(text)
		general_data.benchtop_height = math.max(pyui.parse_length(text), 0)
		recreate_high_cabinet_solo(general_data, specific_data)
	end)
	bt_thick:set_on_change_handler(function(text)
		specific_data.benchtop_thickness = math.max(pyui.parse_length(text), 0)
		recreate_high_cabinet_solo(general_data, specific_data)
	end)
	
	width:set_on_change_handler(function(text)
		specific_data.width = math.max(pyui.parse_length(text), 0)
		recreate_high_cabinet_solo(general_data, specific_data)
	end)
	
	height:set_on_change_handler(function(text)
		specific_data.height_top = math.max(pyui.parse_length(text), 0)
		recreate_high_cabinet_solo(general_data, specific_data)
	end)
	
	depth:set_on_change_handler(function(text)
		general_data.depth = math.max(pyui.parse_length(text), 0)
		recreate_high_cabinet_solo(general_data, specific_data)
	end)
	
	
	thickness:set_on_change_handler(function(text)
		general_data.thickness = math.max(pyui.parse_length(text), 0)
		recreate_high_cabinet_solo(general_data, specific_data)
	end)
	
	general_data.door_side:set_on_click_handler(function(state)
		specific_data.door_rh = state
		recreate_high_cabinet_solo(general_data, specific_data)
	end)
	
	update_high_cabinet_solo_ui(general_data, specific_data)
end

local function recreate_high_cabinet_solo(general_data, specific_data)
	update_high_cabinet_solo_ui(general_data, specific_data)
	if specific_data.main_group ~= nil then
		pytha.delete_element(specific_data.main_group)
	end
	recreate_high(general_data, specific_data)
end

local function update_high_cabinet_solo_ui(general_data, specific_data)
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



local function recreate_high(general_data, specific_data)
	local cur_elements = {}
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	local loc_origin= {}
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	
	local door_height1 = specific_data.height - general_data.top_gap
	local door_height2 = specific_data.height_top - door_height1 - general_data.gap - base_height

	
	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height_top - base_height, loc_origin, {name = pyloc "End LH"})
	table.insert(cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height_top - base_height, loc_origin, {name = pyloc "End RH"})
	table.insert(cur_elements, new_elem)
	--Bottom
	loc_origin[1] = general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth- groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Bottom"})
	table.insert(cur_elements, new_elem)
	--Top
	loc_origin[3] = base_height + specific_data.height_top - general_data.thickness - base_height
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Top"})
	table.insert(cur_elements, new_elem)
	--Fixed shelf between doors
	loc_origin[3] = general_data.benchtop_height - general_data.benchtop_thickness - general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Fixed shelf"})
	table.insert(cur_elements, new_elem)
	--Shelves
	for i = 1, specific_data.shelf_count, 1 do
		loc_origin[2] = general_data.setback_shelves
		loc_origin[3] = base_height + i * (door_height1 - general_data.thickness) / (specific_data.shelf_count + 1)
		local shelf_depth = general_data.depth - general_data.setback_shelves - groove_dist_back_off
		new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, shelf_depth, general_data.thickness, loc_origin, {name = pyloc "Adjustable shelf"})
		table.insert(cur_elements, new_elem)
	end
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, specific_data.height_top - base_height, loc_origin, {name = pyloc "Back"})
	table.insert(cur_elements, new_elem)
		

	--Doors
	if specific_data.width - 2 * general_data.gap > 0 then
		
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = base_height
		--only one door 
		loc_origin[1] = general_data.gap
		local door_group = create_door(general_data, specific_data, specific_data.width - 2 * general_data.gap, door_height1, loc_origin, specific_data.door_rh, coordinate_system)
		table.insert(cur_elements, door_group)
		
		loc_origin[3] = general_data.benchtop_height - general_data.benchtop_thickness - general_data.top_gap + general_data.gap
		door_group = create_door(general_data, specific_data, specific_data.width - 2 * general_data.gap, door_height2, loc_origin, specific_data.door_rh, coordinate_system, 'bottom')
		table.insert(cur_elements, door_group)
	end
	specific_data.kickboard_handle_left = pytha.create_block(specific_data.width, general_data.kickboard_thickness, base_height - general_data.kickboard_margin, {0, general_data.kickboard_setback, general_data.kickboard_margin}, {name = pyloc "Kickboard"})
	table.insert(cur_elements, specific_data.kickboard_handle_left)
	specific_data.kickboard_handle_right = specific_data.kickboard_handle_left
		
	specific_data.main_group = pytha.create_group(cur_elements)
	
	specific_data.elem_handle_for_top = nil

	return specific_data.main_group
end

local function placement_high(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, general_data.depth,0}
	specific_data.left_connection_point = {0, general_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end

local function ui_update_high(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  > specific_data.door_width then
			controls.door_side:disable_control()
		else
			controls.door_side:enable_control()
		end
	else 
		controls.door_side:enable_control()
	end
	
	if soft_update == true then return end

	controls.label_width:enable_control()
	controls.width:enable_control()
	controls.height_label:enable_control()
	controls.height:enable_control()
	controls.height_top_label:enable_control()
	controls.height_top:enable_control()
	controls.label6:enable_control()
	controls.shelf_count:enable_control()
	controls.door_width:enable_control()
	controls.label_door_width:enable_control()
	
	controls.door_side:set_control_text(pyloc "Door RH")
	controls.label_width:set_control_text(pyloc "Width")
	controls.label_door_width:set_control_text(pyloc "Max door width")		
	
end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.high = 				
{									
	name = pyloc "High cabinet",
	row = 0x3,
	default_data = {width = 600,},
	geometry_function = recreate_high,
	placement_function = placement_high, 	
	ui_update_function = ui_update_high,
	organization_styles = {},
}



