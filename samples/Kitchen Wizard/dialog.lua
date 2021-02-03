--User Interface generation and update

controls = {} --those are globals for the ui update functions in the specific cabinet files
function wizard_dialog(dialog, data)
	
	dialog:set_window_title(pyloc "Kitchen Wizard")
	
	dialog:create_label(1, pyloc "General settings")
	
	local button_ori = dialog:create_button({2,3}, pyloc "Pick origin and direction")
	local button_ori_left = dialog:create_check_box(4, pyloc "Orient leftwards")
	button_ori_left:set_control_checked(data.orient_leftwards)
	
	dialog:create_label(1, pyloc "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(data.benchtop_height))
	dialog:create_label(1, pyloc "Benchtop thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(data.benchtop_thickness))
	dialog:create_label(1, pyloc "Base cabinet height")
	local general_height_base = dialog:create_text_box(2, pyui.format_length(data.general_height_base))
	dialog:create_label(1, pyloc "Wall cabinet height")
	local general_height_top = dialog:create_text_box(2, pyui.format_length(data.general_height_top))
	dialog:create_label(1, pyloc "Benchtop wall spacing")
	local wall_to_base_spacing = dialog:create_text_box(2, pyui.format_length(data.wall_to_base_spacing))
	dialog:create_label(3, pyloc "Depth")
	local depth = dialog:create_text_box(4, pyui.format_length(data.depth))
	dialog:create_label(3, pyloc "Depth Wall")
	local depth_wall = dialog:create_text_box(4, pyui.format_length(data.depth_wall))
	dialog:create_label(3, pyloc "Handle length")
	local handle_length = dialog:create_text_box(4, pyui.format_length(data.handle_length))
	dialog:create_label(3, pyloc "Board thickness")
	local thickness = dialog:create_text_box(4, pyui.format_length(data.thickness))
	
	dialog:create_label({1,4}, pyloc "This cabinet")
	controls.typecombo_label = dialog:create_label(1, pyloc "Type")
	controls.typecombo = dialog:create_drop_list(2)
	controls.subtypecombo_label = dialog:create_label(3, pyloc "Organization")
	controls.subtypecombo = dialog:create_drop_list(4)
	
	dialog:create_align({1,4}) 
	
	controls.label_width = dialog:create_label(1, pyloc "Width")
	controls.width = dialog:create_text_box(2, pyui.format_length(data.cabinet_list[data.current_cabinet].width))
	controls.label_width2 = dialog:create_label(1, pyloc "Right width")
	controls.width2 = dialog:create_text_box(2, pyui.format_length(data.cabinet_list[data.current_cabinet].width2))
	controls.height_label = dialog:create_label(1, pyloc "Height")
	controls.height = dialog:create_text_box(2, pyui.format_length(data.cabinet_list[data.current_cabinet].height))
	controls.height_top_label = dialog:create_label(1, pyloc "OA Height")
	controls.height_top = dialog:create_text_box(2, pyui.format_length(data.cabinet_list[data.current_cabinet].height_top))
	controls.appliance_model_label = dialog:create_label(1, pyloc "Sink model")
	controls.appliance_model = dialog:create_drop_list(2)
	controls.label6 = dialog:create_label(3, pyloc "Number of shelves")
	controls.shelf_count = dialog:create_text_spin(4, pyui.format_length(data.cabinet_list[data.current_cabinet].shelf_count), {0,10})	
	controls.label_door_width = dialog:create_label(3, pyloc "Door width")
	controls.door_width = dialog:create_text_box(4, pyui.format_length(data.cabinet_list[data.current_cabinet].door_width))
	controls.drawer_height_list_label = dialog:create_label(3, pyloc "Drawer height")
	controls.drawer_height_list = dialog:create_combo_box(4)
	controls.door_side = dialog:create_check_box({3, 4}, pyloc "Door right side")
	controls.sink_orientation_label = dialog:create_label(3, pyloc "Sink orientation")
	controls.sink_orientation = dialog:create_drop_list(4)
	
	dialog:create_align({1,4})
	dialog:create_label({1,4}, pyloc "Navigate in cabinets")
	
	controls.button_up = dialog:create_button(1, "\u{21D1}")
	controls.insert_top_left = dialog:create_button(2, pyloc "Insert top left")
	controls.insert_top = dialog:create_button(3, pyloc "Insert on top")
	controls.button_down = dialog:create_button(4, "\u{21D3}")
	
	local button_left = dialog:create_button(1, "\u{21D0}")
	local insert_left = dialog:create_button(2, pyloc "Insert on left")
	local insert_right = dialog:create_button(3, pyloc "Insert on right")
	local button_right = dialog:create_button(4, "\u{21D2}")
	
	dialog:create_align({1,4}) -- So that OK and Cancel will be in the same row
	local button_select = dialog:create_button(1, pyloc "Select Cabinet")
	
	controls.button_delete = dialog:create_button(2, pyloc "Delete This")
	
	dialog:create_ok_button(3)
	dialog:create_cancel_button(4)
	
	dialog:equalize_column_widths({1,2,3,4})
	
-------------------------------------------------------------------------------------------------------
--Here we set the dialog handlers
-------------------------------------------------------------------------------------------------------

	
	button_ori:set_on_click_handler(function()
		-- Pick in graphics
		button_ori:disable_control()
		local ret_wert = pyux.select_coordinate(false, pyloc "Pick origin")
		if ret_wert ~= nil then
			data.origin = ret_wert
			pyux.highlight_coordinate(ret_wert)
		end
		
		local ret_wert = pyux.select_coordinate(false, pyloc "Pick direction along wall")
		if ret_wert ~= nil then
			pyux.highlight_coordinate(ret_wert)
			data.direction = {ret_wert[1] - data.origin[1], ret_wert[2] - data.origin[2], ret_wert[3] - data.origin[3]}
			local dir_length = PYTHAGORAS(data.direction[1], data.direction[2], data.direction[3])
			data.direction[1] = data.direction[1] / dir_length
			data.direction[2] = data.direction[2] / dir_length
			data.direction[3] = data.direction[3] / dir_length
		end
		button_ori:enable_control()
		pyux.clear_highlights()
		recreate_all(data, true)
	end)
	
	
	button_ori_left:set_on_click_handler(function(state)
		data.orient_leftwards = state
		recreate_all(data, true)
	end)
	
	bt_height:set_on_change_handler(function(text)
		data.benchtop_height = math.max(pyui.parse_length(text) or data.benchtop_height, 0)
		recreate_all(data, true)
	end)
	bt_thick:set_on_change_handler(function(text)
		data.benchtop_thickness = math.max(pyui.parse_length(text) or data.benchtop_thickness, 0)
		recreate_all(data, true)
	end)
	general_height_top:set_on_change_handler(function(text)
		local old_general_height_top = data.general_height_top
		data.general_height_top = math.max(pyui.parse_length(text) or data.general_height_top, 0)
		for i,spec_data in pairs(data.cabinet_list) do
			if spec_data.row ~= 0x1 and spec_data.height_top == old_general_height_top then
				spec_data.height_top = data.general_height_top
			end
		end
		recreate_all(data, true)
	end)
	general_height_base:set_on_change_handler(function(text)
		local old_general_height_base = data.general_height_base
		data.general_height_base = math.max(pyui.parse_length(text) or data.general_height_base, 0)
		for i,spec_data in pairs(data.cabinet_list) do
			if spec_data.row ~= 0x2 and spec_data.height == old_general_height_base then
				spec_data.height = data.general_height_base
			end
		end
		recreate_all(data, true)
	end)
	
	wall_to_base_spacing:set_on_change_handler(function(text)
		data.wall_to_base_spacing = math.max(pyui.parse_length(text) or data.wall_to_base_spacing, 0)
		recreate_all(data, true)
	end)
	
	depth:set_on_change_handler(function(text)
		data.depth = math.max(pyui.parse_length(text) or data.depth, 0)
		recreate_all(data, true)
	end)
	
	depth_wall:set_on_change_handler(function(text)
		data.depth_wall = math.max(pyui.parse_length(text) or data.depth_wall, 0)
		recreate_all(data, true)
	end)
	
	handle_length:set_on_change_handler(function(text)
		data.handle_length = math.max(pyui.parse_length(text) or data.handle_length, 0)
		recreate_all(data, true)
	end)
	
	thickness:set_on_change_handler(function(text)
		data.thickness = math.max(pyui.parse_length(text) or data.thickness, 0)
		recreate_all(data, true)
	end)
	
	controls.width:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].width = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].width, 0)
		recreate_all(data, true)
	end)
	
	controls.width2:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].width2 = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].width2, 0)
		recreate_all(data, true)
	end)
	
	controls.height:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].height = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].height, 0)
		recreate_all(data, true)
	end)
	
	controls.height_top:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].height_top = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].height_top, 0)
		recreate_all(data, true)
	end)
	
	controls.shelf_count:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].shelf_count = math.max(pyui.parse_number(text) or data.cabinet_list[data.current_cabinet].shelf_count, 0)
		recreate_all(data, true)
	end)
	
	controls.door_width:set_on_change_handler(function(text)
		data.cabinet_list[data.current_cabinet].door_width = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].door_width, 0)
		recreate_all(data, true)
	end)
	
	controls.door_side:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].door_rh = state
		recreate_all(data, true)
	end)
	
	controls.typecombo:set_on_change_handler(function(text, new_index)
		local cab_type = typecombolist[data.cabinet_list[data.current_cabinet].row][new_index]
		assign_cabinet_type(data, data.current_cabinet, cab_type)
		recreate_all(data, false)
	end)
	
	controls.subtypecombo:set_on_change_handler(function(text, new_index)
		local spec_type_info = cabinet_typelist[data.cabinet_list[data.current_cabinet].this_type]
		local front_style = spec_type_info.organization_styles[new_index]
		data.cabinet_list[data.current_cabinet].front_style = front_style
		recreate_all(data, false)
	end)
	
	controls.drawer_height_list:set_on_change_handler(function(text, new_index)

		data.cabinet_list[data.current_cabinet].drawer_height_list = text 
		recreate_all(data, true)
	end)
	
	controls.sink_orientation:set_on_change_handler(function(text, new_index)
		data.cabinet_list[data.current_cabinet].sink_position = (new_index - 1) % 3 + 1
		data.cabinet_list[data.current_cabinet].sink_flipped = math.floor((new_index - 1) / 3)
		recreate_all(data, true)
	end)
	
	controls.appliance_model:set_on_change_handler(function(text, new_index)
		data.cabinet_list[data.current_cabinet].sink_file = get_appliance_from_current_selection(data, data.cabinet_list[data.current_cabinet], new_index)
		recreate_all(data, true)
	end)
	
	
	button_select:set_on_click_handler(function()
		if data.current_cabinet == 1 and #data.cabinet_list == 1 then
			return
		end
		button_select:disable_control()
		local sel_part = pyux.select_part(false)
		pyux.clear_highlights()	
		if sel_part ~= nil then
			for i,spec_data in pairs(data.cabinet_list) do 
				local all_parts = pytha.get_group_descendants(spec_data.main_group)
				for j, part in pairs(all_parts) do
					if sel_part[1] == part then
						data.current_cabinet = i
						button_select:enable_control()
						recreate_all(data, false)
						return
					end
				end
			end			
		end
		button_select:enable_control()
		recreate_all(data, false)
	end)
	controls.button_delete:set_on_click_handler(function() delete_element(data) end)
	
	button_left:set_on_click_handler(function(state) 
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			if data.cabinet_list[data.current_cabinet].left_top_element == nil then
				local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
				data.cabinet_list[data.current_cabinet].left_top_element = new_element
				data.cabinet_list[new_element].right_top_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].left_top_element
		else
			if data.cabinet_list[data.current_cabinet].left_element == nil then
				local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
				data.cabinet_list[data.current_cabinet].left_element = new_element
				data.cabinet_list[new_element].right_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].left_element
		end
		recreate_all(data, false)
	end)
	button_right:set_on_click_handler(function(state)
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			if data.cabinet_list[data.current_cabinet].right_top_element == nil then
				local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
				data.cabinet_list[data.current_cabinet].right_top_element = new_element
				data.cabinet_list[new_element].left_top_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].right_top_element
		else
			if data.cabinet_list[data.current_cabinet].right_element == nil then
				local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
				data.cabinet_list[data.current_cabinet].right_element = new_element
				data.cabinet_list[new_element].left_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].right_element
		end
		recreate_all(data, false)
	end)
	insert_left:set_on_click_handler(function(state)
		local left_element = data.cabinet_list[data.current_cabinet].left_element
		local left_top_element = data.cabinet_list[data.current_cabinet].left_top_element
		local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			data.cabinet_list[new_element].right_top_element = data.current_cabinet
			data.cabinet_list[new_element].left_top_element = data.cabinet_list[data.current_cabinet].left_top_element
			if left_top_element ~= nil then
				data.cabinet_list[left_top_element].right_top_element = new_element
			end
			data.cabinet_list[data.current_cabinet].left_top_element = new_element
		else
			data.cabinet_list[new_element].right_element = data.current_cabinet
			data.cabinet_list[new_element].left_element = data.cabinet_list[data.current_cabinet].left_element
			if left_element ~= nil then
				data.cabinet_list[left_element].right_element = new_element
			end
			data.cabinet_list[data.current_cabinet].left_element = new_element
		end
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	insert_right:set_on_click_handler(function(state)
		local right_element = data.cabinet_list[data.current_cabinet].right_element
		local right_top_element = data.cabinet_list[data.current_cabinet].right_top_element
		local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			data.cabinet_list[new_element].left_top_element = data.current_cabinet
			data.cabinet_list[new_element].right_top_element = data.cabinet_list[data.current_cabinet].right_top_element
			if right_top_element ~= nil then
				data.cabinet_list[right_top_element].left_top_element = new_element
			end
			data.cabinet_list[data.current_cabinet].right_top_element = new_element
		else
			data.cabinet_list[new_element].left_element = data.current_cabinet
			data.cabinet_list[new_element].right_element = data.cabinet_list[data.current_cabinet].right_element
			if right_element ~= nil then
				data.cabinet_list[right_element].left_element = new_element
			end
			data.cabinet_list[data.current_cabinet].right_element = new_element
		end
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	
	controls.button_up:set_on_click_handler(function() move_up(data) end)
	
	controls.button_down:set_on_click_handler(function() move_down(data) end)
	
	controls.insert_top:set_on_click_handler(function(state)
		local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
		if data.cabinet_list[data.current_cabinet].row == 0x3 then 
			data.cabinet_list[new_element].left_top_element = data.current_cabinet
			data.cabinet_list[data.current_cabinet].right_top_element = new_element
		else
			data.cabinet_list[new_element].bottom_element = data.current_cabinet
			data.cabinet_list[data.current_cabinet].top_element = new_element
		end
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	controls.insert_top_left:set_on_click_handler(function(state)
		local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
		data.cabinet_list[new_element].right_top_element = data.current_cabinet
		data.cabinet_list[data.current_cabinet].left_top_element = new_element
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	
	recreate_all(data, false)
end

function recreate_all(data, soft_update)
	update_ui(data, soft_update)
	recreate_geometry(data, false)
end

function update_ui(data, soft_update)
	local specific_data = data.cabinet_list[data.current_cabinet]
	
	local spec_type_info = cabinet_typelist[specific_data.this_type]
	local front_style_info = nil
	if specific_data.front_style then 
		front_style_info = organization_style_list[specific_data.front_style]
	end

--just update the front controls state. This will be modified with the individual fronts.
	if soft_update == true then 
		spec_type_info.ui_update_function(data, soft_update)
		if front_style_info then 
			front_style_info.ui_update_function(data, soft_update) 
		end
		return
	end
	
--set default texts
	controls.label_door_width:set_control_text(pyloc "Max door width")
	controls.label6:set_control_text(pyloc "Number of shelves")
	controls.door_side:set_control_text(pyloc "Door RH")
	controls.label_width:set_control_text(pyloc "Width")
	controls.subtypecombo_label:set_control_text(pyloc "Organization")
	
--disable all controls and then just enable necessary ones
	for i, contr in pairs(controls) do
		contr:hide_control()
	end
	
	spec_type_info.ui_update_function(data, soft_update)
	if front_style_info then 
		front_style_info.ui_update_function(data, soft_update) 
	end
	
	
	
	
--show the right arrow and insert buttons
	if specific_data.row == 0x3 then 
		controls.button_up:set_control_text(pyloc "Top \u{21D0}")
		controls.button_down:set_control_text(pyloc "Top \u{21D2}")
		controls.insert_top:set_control_text(pyloc "Insert top right")
		controls.insert_top_left:set_control_text(pyloc "Insert top left")
	else 
		controls.button_up:set_control_text("\u{21D1}")
		controls.button_down:set_control_text(pyloc "\u{21D3}")
		controls.insert_top:set_control_text(pyloc "Insert top")
	end 
	if specific_data.row ~= 0x2 then
		controls.button_up:show_control()
	end
	
	if specific_data.row & 0x1 ~= 0 and specific_data.top_element == nil then
		controls.insert_top:show_control()
	end
	if specific_data.row == 0x3 then
		controls.insert_top_left:show_control()
		controls.button_down:show_control()
	end
	if specific_data.row & 0x1 == 0 then 
		controls.button_down:show_control()
	end
	
--Cabinet type combo 	
	controls.typecombo:show_control()
	controls.typecombo_label:show_control()
	controls.typecombo:reset_content()
	local current_number = 0
	for i, k in pairs(typecombolist[specific_data.row]) do
		controls.typecombo:insert_control_item(cabinet_typelist[k].name)
		if k == specific_data.this_type then 
			current_number = i
		end 
	end
	controls.typecombo:set_control_selection(current_number)
	
-- Front subtype combo 	
	if #spec_type_info.organization_styles > 0 then 
		controls.subtypecombo:show_control()
		controls.subtypecombo_label:show_control()
		
		controls.subtypecombo:reset_content()
		local current_front = 0
		for i, k in pairs(spec_type_info.organization_styles) do
			controls.subtypecombo:insert_control_item(organization_style_list[k].name)
			if k == specific_data.front_style then 
				current_front = i
			end 
		end
		controls.subtypecombo:set_control_selection(current_front)
	end
	
	
	
	if not (data.current_cabinet == 1 and specific_data.left_element == nil and specific_data.right_element == nil) then
		controls.button_delete:show_control()
	end
	--here dialog values are set
	controls.width:set_control_text(pyui.format_length(specific_data.width))
	controls.width2:set_control_text(pyui.format_length(specific_data.width2))
	
	controls.height:set_control_text(pyui.format_length(specific_data.height))
	controls.height_top:set_control_text(pyui.format_length(specific_data.height_top))
	controls.shelf_count:set_control_text(pyui.format_number(specific_data.shelf_count))
	controls.door_width:set_control_text(pyui.format_length(specific_data.door_width))
	controls.door_side:set_control_checked(specific_data.door_rh)
end


function move_up(data)
	local specific_data = data.cabinet_list[data.current_cabinet]
	if specific_data.row == 0x3 then 
		if specific_data.left_top_element == nil then
			local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
			specific_data.left_top_element = new_element
			data.cabinet_list[new_element].right_top_element = data.current_cabinet
		end
		data.current_cabinet = specific_data.left_top_element
	else
		if specific_data.top_element ~= nil then
			data.current_cabinet = specific_data.top_element
		else
		--first check for existing nearby top element, otherwise add new 
			local next_base = specific_data.right_element
			local steps = 1
			local found = nil
			while next_base ~= nil do
				if data.cabinet_list[next_base].top_element ~= nil or data.cabinet_list[next_base].row == 0x3 then
					local next_top = nil
					if data.cabinet_list[next_base].top_element ~= nil then 
						next_top = data.cabinet_list[next_base].top_element
					else 
						next_top = next_base
					end
					for i = 1, steps, 1 do
						if data.cabinet_list[next_top].left_top_element == nil then 
							break
						end
						next_top = data.cabinet_list[next_top].left_top_element
					end
					data.current_cabinet = next_top
					found = 1
					break
				end
				next_base = data.cabinet_list[next_base].right_element
				steps = steps + 1
			end
			if found == nil then 
				steps = 1
				next_base = specific_data.left_element
				while next_base ~= nil do
					if data.cabinet_list[next_base].top_element ~= nil or data.cabinet_list[next_base].row == 0x3 then
						local next_top = nil
						if data.cabinet_list[next_base].top_element ~= nil then 
							next_top = data.cabinet_list[next_base].top_element
						else 
							next_top = next_base
						end
						for i = 1, steps, 1 do
							if data.cabinet_list[next_top].right_top_element == nil then 
								break
							end
							next_top = data.cabinet_list[next_top].right_top_element
						end
						data.current_cabinet = next_top
						found = 1
						break
					end
					next_base = data.cabinet_list[next_base].left_element
					steps = steps + 1
				end
			end
			if found == nil then 
				local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
				specific_data.top_element = new_element
				data.cabinet_list[new_element].bottom_element = data.current_cabinet
				data.current_cabinet = specific_data.top_element
			end
		end
	end
	recreate_all(data, false)
end
function move_down(data)
	local specific_data = data.cabinet_list[data.current_cabinet]
	if specific_data.row == 0x3 then 
		if specific_data.right_top_element == nil then
			local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
			specific_data.right_top_element = new_element
			data.cabinet_list[new_element].left_top_element = data.current_cabinet
		end
		data.current_cabinet = specific_data.right_top_element
	else
		if specific_data.bottom_element ~= nil then
			data.current_cabinet = specific_data.bottom_element
		else
			local next_top = specific_data.right_top_element
			local steps = 1
			while next_top ~= nil do
				if data.cabinet_list[next_top].bottom_element ~= nil or data.cabinet_list[next_top].row == 0x3 then
					local next_bottom = nil
					if data.cabinet_list[next_top].bottom_element ~= nil then 
						next_bottom = data.cabinet_list[next_top].bottom_element
					else 
						next_bottom = next_top
					end
					for i = 1, steps, 1 do
						if data.cabinet_list[next_bottom].left_element == nil then 
							break
						end
						next_bottom = data.cabinet_list[next_bottom].left_element
					end
					data.current_cabinet = next_bottom
					break
				end
				next_top = data.cabinet_list[next_top].right_top_element
				steps = steps + 1
			end
			steps = 1
			next_top = specific_data.left_top_element
			while next_top ~= nil do
				if data.cabinet_list[next_top].bottom_element ~= nil or data.cabinet_list[next_top].row == 0x3 then
					local next_bottom = nil
					if data.cabinet_list[next_top].bottom_element ~= nil then 
						next_bottom = data.cabinet_list[next_top].bottom_element
					else 
						next_bottom = next_top
					end
					for i = 1, steps, 1 do
						if data.cabinet_list[next_bottom].right_element == nil then 
							break
						end
						next_bottom = data.cabinet_list[next_bottom].right_element
					end
					data.current_cabinet = next_bottom
					break
				end
				next_top = data.cabinet_list[next_top].left_top_element
				steps = steps + 1
			end	
		end
	end
	recreate_all(data, false)
end

function delete_element(data)
	local specific_data = data.cabinet_list[data.current_cabinet]
	if data.current_cabinet == 1 and #data.cabinet_list == 1 then
		return
	end
	if data.current_cabinet == 1 and specific_data.left_element == nil and specific_data.right_element == nil then
		return
	end
	
	local left_element = specific_data.left_element
	local right_element = specific_data.right_element
	local left_top_element = specific_data.left_top_element
	local right_top_element = specific_data.right_top_element
	local top_element = specific_data.top_element
	local bottom_element = specific_data.bottom_element

	--first treat the top rows. 
	if specific_data.row == 0x3 then 
		local bottom_defined = nil
		if left_element ~= nil then
			data.cabinet_list[left_element].top_element = left_top_element
			if left_top_element ~= nil then
				data.cabinet_list[left_top_element].bottom_element = left_element
				bottom_defined = 1
			end
		end
		if right_element ~= nil then
			data.cabinet_list[right_element].top_element = right_top_element
			if right_top_element ~= nil and bottom_defined == nil then
				data.cabinet_list[right_top_element].bottom_element = right_element
			end
		end 
		if left_top_element ~= nil then
			data.cabinet_list[left_top_element].right_top_element = right_top_element
		end
		if right_top_element ~= nil then
			data.cabinet_list[right_top_element].left_top_element = left_top_element
		end
	elseif specific_data.row == 0x2 then 
		if left_top_element ~= nil then
			if bottom_element ~= nil then
			data.cabinet_list[left_top_element].bottom_element = bottom_element
			data.cabinet_list[bottom_element].top_element = left_top_element
			end
		elseif right_top_element ~= nil then
			if bottom_element ~= nil then
				data.cabinet_list[right_top_element].bottom_element = bottom_element
				data.cabinet_list[bottom_element].top_element = right_top_element
			end
		else 
			if bottom_element ~= nil then
				data.cabinet_list[bottom_element].top_element = nil
			end
		end 
		if left_top_element ~= nil then
			data.cabinet_list[left_top_element].right_top_element = right_top_element
		end
		if right_top_element ~= nil then
			data.cabinet_list[right_top_element].left_top_element = left_top_element
		end		
	else 
		if top_element ~= nil then
			if left_element ~= nil then
				if data.cabinet_list[left_element].row == 0x3 then 
					data.cabinet_list[left_element].right_top_element = top_element
					data.cabinet_list[top_element].left_top_element = left_element
					data.cabinet_list[top_element].bottom_element = nil
				elseif data.cabinet_list[left_element].top_element ~= nil then
					data.cabinet_list[data.cabinet_list[left_element].top_element].right_top_element = top_element
					data.cabinet_list[top_element].left_top_element = data.cabinet_list[left_element].top_element
					data.cabinet_list[top_element].bottom_element = nil
				else
					data.cabinet_list[left_element].top_element = top_element
					data.cabinet_list[top_element].bottom_element = left_element
				end
			elseif right_element ~= nil then
				if data.cabinet_list[right_element].row == 0x3 then 
					data.cabinet_list[right_element].left_top_element = top_element
					data.cabinet_list[top_element].right_top_element = right_element
					data.cabinet_list[top_element].bottom_element = nil
				elseif data.cabinet_list[right_element].top_element ~= nil then
					data.cabinet_list[data.cabinet_list[right_element].top_element].left_top_element = top_element
					data.cabinet_list[top_element].right_top_element = data.cabinet_list[right_element].top_element
					data.cabinet_list[top_element].bottom_element = nil
				else
					data.cabinet_list[right_element].top_element = top_element
					data.cabinet_list[top_element].bottom_element = right_element
				end
			end
		end
	end
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
	if specific_data.row == 0x2 then
		--0x2 never has a left or right element, so we set the next current caabinet either to the bottom, topleft or topright
		if bottom_element ~= nil then
			data.current_cabinet = bottom_element
		elseif left_top_element ~= nil then
			data.current_cabinet = left_top_element
		elseif right_top_element ~= nil then
			data.current_cabinet = right_top_element
		else 
			data.current_cabinet = 1	--fallback never to be reached
		end 
	else
		if left_element ~= nil then
		data.cabinet_list[left_element].right_element = right_element
		end
		if right_element ~= nil then
		data.cabinet_list[right_element].left_element = left_element
		end
	end 
	--we randomly prioritize the left element 
	if left_element ~= nil then
		data.current_cabinet = left_element
	elseif right_element ~= nil then
		data.current_cabinet = right_element
	end 
	recreate_all(data, false)
end