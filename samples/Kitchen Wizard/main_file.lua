--Example of a Kitchen wizard generator
--Example of a Kitchen wizard generator
local controls = {}
local in_loop = false
function main()
	
	local general_data = {
		cur_elements = {},
		main_group = nil,
		benchtop_height = 950,
		benchtop_thickness = 38,
		thickness = 19,
		thickness_back = 5,
		groove_dist = 35,
		groove_depth = 5,
		depth = 550,
		setback_shelves = 5,
		width_rail = 126,
		top_gap = 7,
		top_over = 50,
		gap = 3,
		origin = {0,0,0},
		direction = {1,0,0},
		handle_length = 128,
		cabinet_list = {},
		current_cabinet = nil,
		benchtop = nil
	}
	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then general_data = loaded_data end
	
	general_data.current_cabinet = initialize_cabinet_values(general_data)
	
	general_data.own_direction = 0
	recreate_geometry(general_data, false)
	
	pyui.run_modal_dialog(wizard_dialog, general_data)
	recreate_geometry(general_data, true)
	
	pyio.save_values("default_dimensions", general_data)
end

function wizard_dialog(dialog, data)
	dialog:set_window_title("Kitchen Wizard")
	local specific_data = data.cabinet_list[data.current_cabinet]
	
	local label_title = dialog:create_label({1,2}, "General settings")
	
	local button_ori = dialog:create_button(3, "Pick origin")
	local button_dir = dialog:create_button(4, "Pick direction")
	
	local label_benchtop = dialog:create_label(1, "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(data.benchtop_height))
	local label_bt_thick = dialog:create_label(1, "Benchtop thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(data.benchtop_thickness))
	local label4 = dialog:create_label(3, "Board thickness")
	local thickness = dialog:create_text_box(4, pyui.format_length(data.thickness))
	local label3 = dialog:create_label(3, "Depth")
	local depth = dialog:create_text_box(4, pyui.format_length(data.depth))
	local label_handle = dialog:create_label(3, "Handle length")
	local handle_length = dialog:create_text_box(4, pyui.format_length(data.handle_length))
	
	
	dialog:create_label({1,4}, "This cabinet")
	
	
	controls.radio1 = dialog:create_radio_button(1, "Straight")
	controls.radio2 = dialog:create_linked_radio_button(2, "Corner")
	controls.radio3 = dialog:create_linked_radio_button(3, "Diagonal")
	controls.radio4 = dialog:create_linked_radio_button(4, "Blind End")
	dialog:create_align({1,4}) 
	controls.label_width = dialog:create_label(1, "Width")
	controls.width = dialog:create_text_box(2, pyui.format_length(specific_data.width))
	controls.label_width2 = dialog:create_label(3, "Right width")
	controls.width2 = dialog:create_text_box(4, pyui.format_length(specific_data.width2))
	controls.label2 = dialog:create_label(1, "Height")
	controls.height = dialog:create_text_box(2, pyui.format_length(specific_data.height))
	controls.label5 = dialog:create_label(3, "Drawer height")
	controls.drawer_height = dialog:create_text_box(4, pyui.format_length(specific_data.drawer_height))
	controls.label_door_width = dialog:create_label(1, "Door width")
	controls.door_width = dialog:create_text_box(2, pyui.format_length(specific_data.door_width))
	controls.door_side = dialog:create_check_box({3, 4}, "Door right side")
	controls.label6 = dialog:create_label(1, "Number of shelves")
	controls.shelf_count = dialog:create_text_box(2, pyui.format_number(specific_data.shelf_count))
	
	dialog:create_align({1,4})
	label_title = dialog:create_label({1,3}, "Navigate in cabinets")
	controls.button_delete = dialog:create_button(4, "Delete This")
	local button_left = dialog:create_button(1, "\u{21D0}")
	local insert_left = dialog:create_button(2, "Insert on left")
	local insert_right = dialog:create_button(3, "Insert on right")
	local button_right = dialog:create_button(4, "\u{21D2}")
	local align1 = dialog:create_align({1,4}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(3)
	local cancel = dialog:create_cancel_button(4)
	
	dialog:equalize_column_widths({1,2,3,4})

	
	button_ori:set_on_click_handler(function()
		-- Pick in graphics
		button_ori:disable_control()
		local ret_wert = pytha.pick_a_point()
		if ret_wert ~= nil then
			data.origin = ret_wert
		end
		button_ori:enable_control()
		recreate_all(data, true)
	end)
	
	button_dir:set_on_click_handler(function()
		-- Pick in graphics
		button_dir:disable_control()
		local ret_wert = pytha.pick_a_point()
		if ret_wert ~= nil then
			data.direction = {ret_wert[1] - data.origin[1], ret_wert[2] - data.origin[2], ret_wert[3] - data.origin[3]}
			local dir_length = PYTHAGORAS(data.direction[1], data.direction[2], data.direction[3])
			data.direction[1] = data.direction[1] / dir_length
			data.direction[2] = data.direction[2] / dir_length
			data.direction[3] = data.direction[3] / dir_length
		end
		button_dir:enable_control()
		recreate_all(data, true)
	end)
	
	bt_height:set_on_change_handler(function(text)
		data.benchtop_height = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	bt_thick:set_on_change_handler(function(text)
		data.benchtop_thickness = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	depth:set_on_change_handler(function(text)
		data.depth = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	handle_length:set_on_change_handler(function(text)
		data.handle_length = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	thickness:set_on_change_handler(function(text)
		data.thickness = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	controls.width:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].width = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	controls.width2:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].width2 = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	controls.height:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].height = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	
	controls.drawer_height:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].drawer_height = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	controls.shelf_count:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].shelf_count = pyui.parse_number(text)
		recreate_all(data, true)
	end)
	
	controls.door_width:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].door_width = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	controls.door_side:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].door_rh = state
		recreate_all(data, true)
	end)
	controls.radio1:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "straight"
		recreate_all(data, false)
	end)
	controls.radio2:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "corner"
		recreate_all(data, false)
	end)
	controls.radio3:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "diagonal"
		recreate_all(data, false)
	end)
	controls.radio4:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "end"
		recreate_all(data, false)
	end)
	
	controls.button_delete:set_on_click_handler(function(state)
		if data.current_cabinet == 1 and #data.cabinet_list == 1 then
			return
		end
		
		if data.cabinet_list[data.current_cabinet].cur_elements ~= nil then
			pytha.delete_element(data.cabinet_list[data.current_cabinet].cur_elements)
			data.cabinet_list[data.current_cabinet].cur_elements = nil
		end
		local left_element = data.cabinet_list[data.current_cabinet].left_element
		local right_element = data.cabinet_list[data.current_cabinet].right_element
		
		--as we start geometry creation at 1 we need a special treatment for this case
		if data.current_cabinet == 1 then
			if left_element ~= nil then
				data.cabinet_list[1] = data.cabinet_list[left_element]
				left_element = 1
			elseif right_element ~= nil then
				data.cabinet_list[1] = data.cabinet_list[right_element]
				right_element = 1
			end 
		end
			
		if left_element ~= nil then
			data.cabinet_list[left_element].right_element = right_element
		end 
		if right_element ~= nil then
			data.cabinet_list[right_element].left_element = left_element
		end 
		--we randomly prioritize the left element 
		if left_element ~= nil then
			data.current_cabinet = left_element
		elseif right_element ~= nil then
			data.current_cabinet = right_element
		end 
		recreate_all(data, false)
	end)
	
	button_left:set_on_click_handler(function(state)
		if data.cabinet_list[data.current_cabinet].left_element == nil then
			local new_element = initialize_cabinet_values(data)
			data.cabinet_list[data.current_cabinet].left_element = new_element
			data.cabinet_list[new_element].right_element = data.current_cabinet
		end
		data.current_cabinet = data.cabinet_list[data.current_cabinet].left_element
		recreate_all(data, false)
	end)
	button_right:set_on_click_handler(function(state)
		if data.cabinet_list[data.current_cabinet].right_element == nil then
			local new_element = initialize_cabinet_values(data)
			data.cabinet_list[data.current_cabinet].right_element = new_element
			data.cabinet_list[new_element].left_element = data.current_cabinet
		end
		data.current_cabinet = data.cabinet_list[data.current_cabinet].right_element
		recreate_all(data, false)
	end)
	insert_left:set_on_click_handler(function(state)
		local left_element = data.cabinet_list[data.current_cabinet].left_element
		local new_element = initialize_cabinet_values(data)
		data.cabinet_list[new_element].right_element = data.current_cabinet
		data.cabinet_list[new_element].left_element = data.cabinet_list[data.current_cabinet].left_element
		if left_element ~= nil then
			data.cabinet_list[left_element].right_element = new_element
		end
		data.cabinet_list[data.current_cabinet].left_element = new_element
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	insert_right:set_on_click_handler(function(state)
		local right_element = data.cabinet_list[data.current_cabinet].right_element
		local new_element = initialize_cabinet_values(data)
		data.cabinet_list[new_element].left_element = data.current_cabinet
		data.cabinet_list[new_element].right_element = data.cabinet_list[data.current_cabinet].right_element
		if right_element ~= nil then
			data.cabinet_list[right_element].left_element = new_element
		end
		data.cabinet_list[data.current_cabinet].right_element = new_element
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	
	update_ui(data, false)
end

function update_ui(data, soft_update)
	local specific_data = data.cabinet_list[data.current_cabinet]
	
	if specific_data.this_type == "straight" then
		if get_diag_door_length(data, specific_data) - 2 * data.gap > 0 then
			if get_diag_door_length(data, specific_data)  > specific_data.door_width then
				controls.door_side:disable_control()
			else
				controls.door_side:enable_control()
			end
		else 
			controls.door_side:enable_control()
		end
	elseif specific_data.this_type == "corner" then
		controls.door_side:enable_control()
	elseif specific_data.this_type == "diagonal" then
		if get_diag_door_length(data, specific_data) - 2 * data.gap > 0 then
			if get_diag_door_length(data, specific_data)  > specific_data.door_width then
				controls.door_side:disable_control()
			else
				controls.door_side:enable_control()
			end
		else 
			controls.door_side:enable_control()
		end
	elseif specific_data.this_type == "end" then
	end
	if soft_update == true then return end
	
	
	
--disable all controls and then just enable necessary ones
	for i, contr in pairs(controls) do
		contr:disable_control()
	end
	controls.radio1:enable_control()
	controls.radio2:enable_control()
	controls.radio3:enable_control()
	controls.radio4:enable_control()
	if specific_data.this_type == "straight" then
		controls.door_side:set_control_text("Door RH")
		controls.label_width:enable_control()
		controls.label_width:set_control_text("Width")
		controls.width:enable_control()
		controls.label2:enable_control()
		controls.height:enable_control()
		controls.label5:enable_control()
		controls.drawer_height:enable_control()
		controls.label6:enable_control()
		controls.shelf_count:enable_control()
		controls.door_width:enable_control()
		controls.label_door_width:enable_control()
		controls.label_door_width:set_control_text("Max door width")
		controls.label_width:set_control_text("Width")
		
	controls.radio1:set_control_checked(true)
	
	elseif specific_data.this_type == "corner" then
		controls.door_side:set_control_text("Door right side")
		controls.door_side:enable_control()

		controls.label_width:enable_control()
		controls.width:enable_control()
		controls.label2:enable_control()
		controls.height:enable_control()
		controls.label5:enable_control()
		controls.drawer_height:enable_control()
		controls.label6:enable_control()
		controls.shelf_count:enable_control()
		controls.door_width:enable_control()
		controls.label_door_width:enable_control()
		controls.label_door_width:set_control_text("Door width")
		controls.label_width:set_control_text("Width")
		
		controls.radio2:set_control_checked(true)
	
	elseif specific_data.this_type == "diagonal" then
		controls.door_side:set_control_text("Door RH")

		controls.label_width:enable_control()
		controls.width:enable_control()
		controls.label_width2:enable_control()
		controls.width2:enable_control()
		controls.label2:enable_control()
		controls.height:enable_control()
		controls.label5:enable_control()
		controls.drawer_height:enable_control()
		controls.label6:enable_control()
		controls.shelf_count:enable_control()
		controls.door_width:enable_control()
		controls.label_door_width:enable_control()
		controls.label_door_width:set_control_text("Max door width")
		controls.label_width:set_control_text("Left width")
		
		controls.radio3:set_control_checked(true)
	
	
	elseif specific_data.this_type == "end" then
		--nothing to do here
		
	end
	if data.cabinet_list[data.current_cabinet].left_element ~= nil or data.cabinet_list[data.current_cabinet].right_element ~= nil then
		controls.button_delete:enable_control()
	end
	--here dialog values are set
	controls.width:set_control_text(pyui.format_length(specific_data.width))
	controls.width2:set_control_text(pyui.format_length(specific_data.width2))
	controls.height:set_control_text(pyui.format_length(specific_data.height))
	controls.drawer_height:set_control_text(pyui.format_length(specific_data.drawer_height))
	controls.shelf_count:set_control_text(pyui.format_number(specific_data.shelf_count))
	controls.door_width:set_control_text(pyui.format_length(specific_data.door_width))
	if specific_data.door_rh == true then
		controls.door_side:set_control_checked(true)
	else 
		controls.door_side:set_control_checked(false)
	end
end

function recreate_all(data, soft_update)
	if in_loop == true then return end
	in_loop = true
	update_ui(data, soft_update)
	in_loop = false
	recreate_geometry(data, false)
end


function initialize_cabinet_values(data)
	local new_element = #data.cabinet_list + 1
	data.cabinet_list[new_element] = {this_type = "straight",
												width = 1000,
												width2 = 1000,
												height = 838,
												shelf_count = 1,
												door_width = 600,
												drawer_height = 125,
												door_rh = false,
												right_element = nil,
												left_element = nil, 
												right_connection_point = {0,0,0},
												left_connection_point = {0,0,0},
												right_direction = 0,
												left_direction = 0,
												own_direction = 0,
												this_type = "straight",
												cur_elements = {},
												main_group = nil,
												elem_handle_for_top = nil}

return new_element
end


--here we could use metatables to distinguish the geometry functions. The same is true for the user interface. 
function create_geometry_for_element(general_data, element, finalize)
	local origin = {general_data.origin[1], general_data.origin[2], general_data.origin[3]}	--we do not want to overwrite the origin 
	local specific_data = general_data.cabinet_list[element]
	local subgroup = nil
	if specific_data.this_type == "straight" then
		subgroup = recreate_straight(general_data, specific_data)
	elseif specific_data.this_type == "corner" then
		subgroup = recreate_corner(general_data, specific_data)
	elseif specific_data.this_type == "diagonal" then
		subgroup = recreate_diagonal(general_data, specific_data)
	elseif specific_data.this_type == "end" then
		subgroup = recreate_endpiece(general_data, specific_data)
	end
	if element == general_data.current_cabinet and not finalize then 
		pytha.set_element_pen(subgroup,4)
	end
	if specific_data.elem_handle_for_top ~= nil then
		benchtop = pytha.create_profile(specific_data.elem_handle_for_top, general_data.benchtop_thickness)
		pytha.delete_element(specific_data.elem_handle_for_top)
		specific_data.elem_handle_for_top = nil
	end
	return subgroup, benchtop
end


function recreate_geometry(data, finalize)

	if data.main_group ~= nil then
		pytha.delete_element(data.main_group)
	end
	data.cur_elements = {}
	if data.benchtop ~= nil then
		pytha.delete_element(data.benchtop)
	end
	data.benchtop = nil
	local current_cabinet = 1
	local placement_angle = 0
	local bool_group = {}
	local origin = {data.origin[1], data.origin[2], data.origin[3]}
	origin[1] = origin[1] + data.direction[2] * data.depth 
	origin[2] = origin[2] - data.direction[1] * data.depth 
	placement_angle = ATAN(data.direction[2], data.direction[1])
	--iteratively generate cabinets for sub_tree to right side...
	while current_cabinet ~= nil do
		local cur_struct = data.cabinet_list[current_cabinet]
		local subgroup, benchtop = create_geometry_for_element(data, current_cabinet, finalize)
		table.insert(bool_group, benchtop)
		placement_angle = placement_angle - cur_struct.left_direction
		--here rotate and placement_angle
		origin[1] = origin[1] - cur_struct.left_connection_point[1]
		origin[2] = origin[2] - cur_struct.left_connection_point[2]
		origin[3] = origin[3] - cur_struct.left_connection_point[3]
		
		pytha.rotate_element({subgroup, benchtop}, cur_struct.left_connection_point, 'z', placement_angle)
		pytha.move_element({subgroup, benchtop}, origin)
		local rotated_new_coos = rotate_coos_by_angle({cur_struct.right_connection_point[1] - cur_struct.left_connection_point[1], 
														cur_struct.right_connection_point[2] - cur_struct.left_connection_point[2],
														cur_struct.right_connection_point[3] - cur_struct.left_connection_point[3]}, placement_angle)
		origin[1] = origin[1] +  rotated_new_coos[1] + cur_struct.left_connection_point[1]
		origin[2] = origin[2] +  rotated_new_coos[2] + cur_struct.left_connection_point[2]
		origin[3] = origin[3] +  rotated_new_coos[3] + cur_struct.left_connection_point[3]			
		placement_angle = placement_angle + data.cabinet_list[current_cabinet].right_direction
		table.insert(data.cur_elements, subgroup)
		current_cabinet = data.cabinet_list[current_cabinet].right_element
	end
	--...and to left side
	current_cabinet = data.cabinet_list[1].left_element
	if current_cabinet ~= nil then
		placement_angle = data.cabinet_list[1].left_direction
		origin = {data.origin[1], data.origin[2], data.origin[3]}
		origin[1] = origin[1] + data.direction[2] * data.depth 
		origin[2] = origin[2] - data.direction[1] * data.depth 
		placement_angle = ATAN(data.direction[2], data.direction[1])
		origin[1] = origin[1] + data.cabinet_list[current_cabinet].left_connection_point[1]
		origin[2] = origin[2] + data.cabinet_list[current_cabinet].left_connection_point[2]
		origin[3] = origin[3] + data.cabinet_list[current_cabinet].left_connection_point[3]
		while current_cabinet ~= nil do
			local cur_struct = data.cabinet_list[current_cabinet]
			local subgroup, benchtop = create_geometry_for_element(data, current_cabinet, finalize)
			table.insert(bool_group, benchtop)
			placement_angle = placement_angle - cur_struct.right_direction
			--here rotate and placement_angle
			origin[1] = origin[1] - cur_struct.right_connection_point[1]
			origin[2] = origin[2] - cur_struct.right_connection_point[2]
			origin[3] = origin[3] - cur_struct.right_connection_point[3]
			pytha.rotate_element({subgroup, benchtop}, cur_struct.right_connection_point, 'z', placement_angle)
			pytha.move_element({subgroup, benchtop}, origin)
			local rotated_new_coos = rotate_coos_by_angle({cur_struct.left_connection_point[1] - cur_struct.right_connection_point[1], 
															cur_struct.left_connection_point[2] - cur_struct.right_connection_point[2],
															cur_struct.left_connection_point[3] - cur_struct.right_connection_point[3]}, placement_angle)
			origin[1] = origin[1] +  rotated_new_coos[1] + cur_struct.right_connection_point[1]
			origin[2] = origin[2] +  rotated_new_coos[2] + cur_struct.right_connection_point[2]
			origin[3] = origin[3] +  rotated_new_coos[3] + cur_struct.right_connection_point[3]
			placement_angle = placement_angle + data.cabinet_list[current_cabinet].left_direction
			table.insert(data.cur_elements, subgroup)
			current_cabinet = data.cabinet_list[current_cabinet].left_element
		end
	end
	if #bool_group > 1 then
		data.benchtop = pytha.add_parts(bool_group)
	else
		data.benchtop = bool_group[1]
	end
	table.insert(data.cur_elements, data.benchtop)
	data.main_group = pytha.group_elements(data.cur_elements)
	
end

function rotate_coos_by_angle(coos, alpha)
	return {COS(alpha) * coos[1] - SIN(alpha) * coos[2], SIN(alpha) * coos[1] + COS(alpha) * coos[2], coos[3]}
end
