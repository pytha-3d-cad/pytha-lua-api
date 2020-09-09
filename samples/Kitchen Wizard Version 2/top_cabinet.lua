--Top shelf
function top_cabinet_solo()
	local general_data = _G["general_default_data"]
	local spec_index = initialize_cabinet_values(general_data)
	local loaded_data = pyio.load_values("top_dimensions")
	if loaded_data ~= nil then 
		merge_data(loaded_data, general_data)
	end
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	specific_data.this_type = "top"
	specific_data.width = 600
	specific_data.row = 0x3
	specific_data.individual_call = true
	
	general_data.own_direction = 0
	recreate_top(general_data, general_data.cabinet_list[#general_data.cabinet_list])
	
	pyui.run_modal_dialog(top_cabinet_solo_dialog, general_data)
	
	pyio.save_values("top_dimensions", general_data)
end

local function top_cabinet_solo_dialog(dialog, general_data)
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	
	dialog:set_window_title("Top Cabinet")
	
	local label_benchtop = dialog:create_label(1, pyloc "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_height))
	local label1 = dialog:create_label(1, pyloc "Width")
	local width = dialog:create_text_box(2, pyui.format_length(specific_data.width))
	local label2 = dialog:create_label(1, pyloc "Top height")
	local height = dialog:create_text_box(2, pyui.format_length(specific_data.height_top))
	local label3 = dialog:create_label(1, pyloc "Depth")
	local depth = dialog:create_text_box(2, pyui.format_length(general_data.depth_wall))
	local label4 = dialog:create_label(1, pyloc "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(general_data.thickness))
	
	local label6 = dialog:create_label(1, pyloc "Number of shelves")
	local shelf_count = dialog:create_text_spin(2, pyui.format_length(specific_data.shelf_count), {0,10})
	
--	general_data.door_side = dialog:create_check_box({1, 2}, pyloc "Door right side")
--	general_data.door_side:set_control_checked(specific_data.door_rh)

	local align1 = dialog:create_align({1,2}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
--	dialog:equalize_column_widths({1,2,4})
	
	bt_height:set_on_change_handler(function(text)
		general_data.benchtop_height = math.max(pyui.parse_length(text), 0)
		recreate_top_cabinet_solo(general_data, specific_data)
	end)
	
	width:set_on_change_handler(function(text)
		specific_data.width = math.max(pyui.parse_length(text), 0)
		recreate_top_cabinet_solo(general_data, specific_data)
	end)
	
	height:set_on_change_handler(function(text)
		specific_data.height_top = math.max(pyui.parse_length(text), 0)
		recreate_top_cabinet_solo(general_data, specific_data)
	end)
	
	depth:set_on_change_handler(function(text)
		general_data.depth_wall = math.max(pyui.parse_length(text), 0)
		recreate_top_cabinet_solo(general_data, specific_data)
	end)
	
	
	thickness:set_on_change_handler(function(text)
		general_data.thickness = math.max(pyui.parse_length(text), 0)
		recreate_top_cabinet_solo(general_data, specific_data)
	end)
	
	shelf_count:set_on_change_handler(function(text)
		specific_data.shelf_count = math.max(pyui.parse_length(text), 0)
		recreate_top_cabinet_solo(general_data, specific_data)
	end)
	
	update_top_cabinet_solo_ui(general_data, specific_data)
end

local function recreate_top_cabinet_solo(general_data, specific_data)
	update_top_cabinet_solo_ui(general_data, specific_data)
	if specific_data.main_group ~= nil then
		pytha.delete_element(specific_data.main_group)
	end
	recreate_top(general_data, specific_data)
end

local function update_top_cabinet_solo_ui(general_data, specific_data)
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  > specific_data.door_width then
--			general_data.door_side:disable_control()
		else
--			general_data.door_side:enable_control()
		end
	else 
--		general_data.door_side:disable_control()
	end
end



local function recreate_top(general_data, specific_data)

	local cur_elements = {}
	local base_height = general_data.benchtop_height
	local loc_origin= {}
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	
	local height = specific_data.height_top - base_height


	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth_wall, height, loc_origin, {name = pyloc "End LH"})
	table.insert(cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth_wall, height, loc_origin, {name = pyloc "End RH"})
	table.insert(cur_elements, new_elem)
	loc_origin[1] = general_data.thickness
	--Bottom
--	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth_wall - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Bottom"})
--	table.insert(cur_elements, new_elem)
	--Top
	loc_origin[3] = base_height + height - general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth_wall - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Top"})
	table.insert(cur_elements, new_elem)


	local shelf_depth = general_data.depth_wall - general_data.setback_shelves - groove_dist_back_off
	local front_style_info = nil
	if specific_data.front_style then 
		loc_origin[1] = 0
		loc_origin[2] = 0
		loc_origin[3] = base_height
		front_style_info = organization_style_list[specific_data.front_style]
		front_style_info.geometry_function(general_data, specific_data, specific_data.width, height, shelf_depth, 0, loc_origin, coordinate_system, cur_elements) 
	end	
	
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth_wall - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, height, loc_origin, {name = pyloc "Back"})
	table.insert(cur_elements, new_elem)
		
	specific_data.main_group = pytha.create_group(cur_elements)
	
	specific_data.elem_handle_for_top = nil

	return specific_data.main_group
end

local function placement_top(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, general_data.depth_wall,0}
	specific_data.left_connection_point = {0, general_data.depth_wall,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end

local function ui_update_top(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	controls.door_side:disable_control()
	
	if soft_update == true then return end

	controls.label_width:enable_control()
	controls.width:enable_control()
	controls.height_top_label:enable_control()
	controls.height_top:enable_control()
	controls.label6:enable_control()
	controls.shelf_count:enable_control()	
	
	controls.door_side:set_control_text(pyloc "Door RH")
	controls.label_width:set_control_text(pyloc "Width")
end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.top = 				
{									
	name = pyloc "Top cabinet",
	row = 0x2,
	default_data = {width = 600,},
	geometry_function = recreate_top,
	placement_function = placement_top, 
	ui_update_function = ui_update_top,
	organization_styles = {"straight_no_front",},
}



