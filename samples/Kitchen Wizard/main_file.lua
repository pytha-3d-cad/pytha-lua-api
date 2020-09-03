--Example of a Kitchen wizard generator
local controls = {}
local in_loop = false

function edit_wizard(element)
	general_data = pytha.get_element_history(element, "wizard_history")
	if general_data == nil then
		pyui.alert(pyloc "No data found")
		return 
	end
	recreate_geometry(general_data, false)
	pyui.run_modal_dialog(wizard_dialog, general_data)
	recreate_geometry(general_data, true)
end

function main()
	local general_data = _G["general_data"]
--	local loaded_data = pyio.load_values("default_dimensions")
--	if loaded_data ~= nil then general_data = loaded_data end
	
	general_data.current_cabinet = initialize_cabinet_values(general_data)
	
	general_data.own_direction = 0
	recreate_geometry(general_data, false)
	
	pyui.run_modal_dialog(wizard_dialog, general_data)
	recreate_geometry(general_data, true)
	
--	pyio.save_values("default_dimensions", general_data)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function wizard_dialog(dialog, data)
	dialog:set_window_title(pyloc "Kitchen Wizard")
	local specific_data = data.cabinet_list[data.current_cabinet]
	
	local label_title = dialog:create_label(1, pyloc "General settings")
	
	local button_ori = dialog:create_button(2, pyloc "Pick origin")
	local button_dir = dialog:create_button(3, pyloc "Pick direction")
	local button_ori_left = dialog:create_check_box(4, pyloc "Orient leftwards")
	button_ori_left:set_control_checked(data.orient_leftwards)
	
	local label_benchtop = dialog:create_label(1, pyloc "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(data.benchtop_height))
	local label_bt_thick = dialog:create_label(1, pyloc "Benchtop thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(data.benchtop_thickness))
	local label_general_height_top = dialog:create_label(1, pyloc "Wall cabinet height")
	local general_height_top = dialog:create_text_box(2, pyui.format_length(data.general_height_top))
	local label_wall_to_base = dialog:create_label(1, pyloc "Benchtop wall spacing")
	local wall_to_base_spacing = dialog:create_text_box(2, pyui.format_length(data.wall_to_base_spacing))
	local label3 = dialog:create_label(3, pyloc "Depth")
	local depth = dialog:create_text_box(4, pyui.format_length(data.depth))
	local label_dw = dialog:create_label(3, pyloc "Depth Wall")
	local depth_wall = dialog:create_text_box(4, pyui.format_length(data.depth_wall))
	local label_handle = dialog:create_label(3, pyloc "Handle length")
	local handle_length = dialog:create_text_box(4, pyui.format_length(data.handle_length))
	local label4 = dialog:create_label(3, pyloc "Board thickness")
	local thickness = dialog:create_text_box(4, pyui.format_length(data.thickness))
	
	dialog:create_label({1,4}, pyloc "This cabinet")	
	
	controls.radio1 = dialog:create_radio_button(1, pyloc "Straight")
	controls.radio2 = dialog:create_linked_radio_button(2, pyloc "Corner")
	controls.radio3 = dialog:create_linked_radio_button(3, pyloc "Diagonal")
	controls.radio4 = dialog:create_linked_radio_button(4, pyloc "Blind End")
	controls.radio5 = dialog:create_linked_radio_button(1, pyloc "High")
	controls.radio6 = dialog:create_linked_radio_button(2, pyloc "Wall")
	controls.radio7 = dialog:create_linked_radio_button(3, pyloc "Wall corner")
	controls.radio8 = dialog:create_linked_radio_button(4, pyloc "Top cabinet")
	dialog:create_align({1,4}) 
	controls.label_width = dialog:create_label(1, pyloc "Width")
	controls.width = dialog:create_text_box(2, pyui.format_length(specific_data.width))
	controls.label_width2 = dialog:create_label(3, pyloc "Right width")
	controls.width2 = dialog:create_text_box(4, pyui.format_length(specific_data.width2))
	controls.label2 = dialog:create_label(1, pyloc "Height")
	controls.height = dialog:create_text_box(2, pyui.format_length(specific_data.height))
	controls.label5 = dialog:create_label(3, pyloc "Drawer height")
	controls.drawer_height = dialog:create_text_box(4, pyui.format_length(specific_data.drawer_height))
	controls.label_door_width = dialog:create_label(1, pyloc "Door width")
	controls.door_width = dialog:create_text_box(2, pyui.format_length(specific_data.door_width))
	controls.door_side = dialog:create_check_box({3, 4}, pyloc "Door right side")
	controls.label6 = dialog:create_label(1, pyloc "Number of shelves")
	controls.shelf_count = dialog:create_text_spin(2, pyui.format_length(specific_data.shelf_count), {0,10})
	
	dialog:create_align({1,4})
	label_title = dialog:create_label({1,4}, pyloc "Navigate in cabinets")
	controls.button_up = dialog:create_button(1, "\u{21D1}")
	controls.insert_top_left = dialog:create_button(2, pyloc "Insert top left")
	controls.insert_top = dialog:create_button(3, pyloc "Insert on top")
	controls.button_down = dialog:create_button(4, "\u{21D3}")
	local button_left = dialog:create_button(1, "\u{21D0}")
	local insert_left = dialog:create_button(2, pyloc "Insert on left")
	local insert_right = dialog:create_button(3, pyloc "Insert on right")
	local button_right = dialog:create_button(4, "\u{21D2}")
	local align1 = dialog:create_align({1,4}) -- So that OK and Cancel will be in the same row
	local button_select = dialog:create_button(1, pyloc "Select Cabinet")
	controls.button_delete = dialog:create_button(2, pyloc "Delete This")
	local ok = dialog:create_ok_button(3)
	local cancel = dialog:create_cancel_button(4)
	
	dialog:equalize_column_widths({1,2,3,4})

	
	button_ori:set_on_click_handler(function()
		-- Pick in graphics
		button_ori:disable_control()
		local ret_wert = pyux.select_coordinate()
		if ret_wert ~= nil then
			data.origin = ret_wert
		end
		button_ori:enable_control()
		recreate_all(data, true)
	end)
	
	button_dir:set_on_click_handler(function()
		-- Pick in graphics
		button_dir:disable_control()
		local ret_wert = pyux.select_coordinate()
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
	button_ori_left:set_on_click_handler(function(state)
		general_data.orient_leftwards = state
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
	general_height_top:set_on_change_handler(function(text)
		local old_general_height_top = data.general_height_top
		data.general_height_top = pyui.parse_length(text)
		for i,spec_data in pairs(data.cabinet_list) do
			if spec_data.height_top == old_general_height_top then
				spec_data.height_top = data.general_height_top
			end
		end
		recreate_all(data, true)
	end)
	
	wall_to_base_spacing:set_on_change_handler(function(text)
		data.wall_to_base_spacing = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	depth:set_on_change_handler(function(text)
		data.depth = pyui.parse_length(text)
		recreate_all(data, true)
	end)
	
	depth_wall:set_on_change_handler(function(text)
		data.depth_wall = pyui.parse_length(text)
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
		if data.cabinet_list[data.current_cabinet].this_type == "corner" or data.cabinet_list[data.current_cabinet].this_type == "diagonal" then 
			data.cabinet_list[data.current_cabinet].corner_width = pyui.parse_length(text)
		elseif data.cabinet_list[data.current_cabinet].this_type == "cornerwall" then 
			data.cabinet_list[data.current_cabinet].corner_width_top = pyui.parse_length(text)
		else 
			data.cabinet_list[data.current_cabinet].width = pyui.parse_length(text)
		end
		recreate_all(data, true)
	end)
	
	controls.width2:set_on_change_handler(function(text)
		if data.cabinet_list[data.current_cabinet].this_type == "corner" or data.cabinet_list[data.current_cabinet].this_type == "diagonal" then 
			data.cabinet_list[data.current_cabinet].width2 = pyui.parse_length(text)
		elseif data.cabinet_list[data.current_cabinet].this_type == "cornerwall" then 
			data.cabinet_list[data.current_cabinet].width2_top = pyui.parse_length(text)
		else 
			data.cabinet_list[data.current_cabinet].width2 = pyui.parse_length(text)
		end
		recreate_all(data, true)
	end)
	
	controls.height:set_on_change_handler(function(text)
		if data.cabinet_list[data.current_cabinet].this_type == "cornerwall" or data.cabinet_list[data.current_cabinet].this_type == "wall" or 
			data.cabinet_list[data.current_cabinet].this_type == "high" or data.cabinet_list[data.current_cabinet].this_type == "top" then 
		data.cabinet_list[data.current_cabinet].height_top = pyui.parse_length(text)
		else 
		data.cabinet_list[data.current_cabinet].height = pyui.parse_length(text)
		end
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
		data.cabinet_list[data.current_cabinet].row = 0x1
		recreate_all(data, false)
	end)
	controls.radio2:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "corner"
		data.cabinet_list[data.current_cabinet].row = 0x1
		recreate_all(data, false)
	end)
	controls.radio3:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "diagonal"
		data.cabinet_list[data.current_cabinet].row = 0x1
		recreate_all(data, false)
	end)
	controls.radio4:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "end"
		data.cabinet_list[data.current_cabinet].row = 0x1
		recreate_all(data, false)
	end)
	controls.radio5:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "high"
		data.cabinet_list[data.current_cabinet].row = 0x3
		recreate_all(data, false)
	end)
	controls.radio6:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "wall"
		data.cabinet_list[data.current_cabinet].row = 0x2
		recreate_all(data, false)
	end)
	controls.radio7:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "cornerwall"
		data.cabinet_list[data.current_cabinet].row = 0x2
		recreate_all(data, false)
	end)
	controls.radio8:set_on_click_handler(function(state)
		data.cabinet_list[data.current_cabinet].this_type = "top"
		data.cabinet_list[data.current_cabinet].row = 0x2
		recreate_all(data, false)
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
	controls.button_delete:set_on_click_handler(function(state)
		if data.current_cabinet == 1 and #data.cabinet_list == 1 then
			return
		end
		if data.current_cabinet == 1 and data.cabinet_list[data.current_cabinet].left_element == nil and data.cabinet_list[data.current_cabinet].right_element == nil then
			return
		end
		
		if data.cabinet_list[data.current_cabinet].cur_elements ~= nil then
			pytha.delete_element(data.cabinet_list[data.current_cabinet].cur_elements)
			data.cabinet_list[data.current_cabinet].cur_elements = nil
		end
		
		local left_element = data.cabinet_list[data.current_cabinet].left_element
		local right_element = data.cabinet_list[data.current_cabinet].right_element
		local left_top_element = data.cabinet_list[data.current_cabinet].left_top_element
		local right_top_element = data.cabinet_list[data.current_cabinet].right_top_element
		local top_element = data.cabinet_list[data.current_cabinet].top_element
		local bottom_element = data.cabinet_list[data.current_cabinet].bottom_element
		
		
		
		--first treat the top rows. 
		if data.cabinet_list[data.current_cabinet].row == 0x3 then 
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
		elseif data.cabinet_list[data.current_cabinet].row == 0x2 then 
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
		if data.cabinet_list[data.current_cabinet].row == 0x2 then
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
	end)
	
	button_left:set_on_click_handler(function(state)
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			if data.cabinet_list[data.current_cabinet].left_top_element == nil then
				local new_element = initialize_cabinet_values(data)
				data.cabinet_list[new_element].row = 0x2
				data.cabinet_list[new_element].this_type = data.cabinet_list[data.current_cabinet].this_type
				data.cabinet_list[data.current_cabinet].left_top_element = new_element
				data.cabinet_list[new_element].right_top_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].left_top_element
		else
			if data.cabinet_list[data.current_cabinet].left_element == nil then
				local new_element = initialize_cabinet_values(data)
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
				local new_element = initialize_cabinet_values(data)
				data.cabinet_list[new_element].row = 0x2
				data.cabinet_list[new_element].this_type = data.cabinet_list[data.current_cabinet].this_type
				data.cabinet_list[data.current_cabinet].right_top_element = new_element
				data.cabinet_list[new_element].left_top_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].right_top_element
		else
			if data.cabinet_list[data.current_cabinet].right_element == nil then
				local new_element = initialize_cabinet_values(data)	
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
		local new_element = initialize_cabinet_values(data)
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			data.cabinet_list[new_element].row = 0x2
			data.cabinet_list[new_element].this_type = data.cabinet_list[data.current_cabinet].this_type
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
		local new_element = initialize_cabinet_values(data)
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			data.cabinet_list[new_element].row = 0x2
			data.cabinet_list[new_element].this_type = data.cabinet_list[data.current_cabinet].this_type
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
	
	controls.button_up:set_on_click_handler(function(state)
		if data.cabinet_list[data.current_cabinet].row == 0x3 then 
			if data.cabinet_list[data.current_cabinet].left_top_element == nil then
				local new_element = initialize_cabinet_values(data)
				data.cabinet_list[data.current_cabinet].left_top_element = new_element
				data.cabinet_list[new_element].right_top_element = data.current_cabinet
				data.cabinet_list[new_element].row = 0x2
				data.cabinet_list[new_element].this_type = "wall"
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].left_top_element
		else
			if data.cabinet_list[data.current_cabinet].top_element ~= nil then
				data.current_cabinet = data.cabinet_list[data.current_cabinet].top_element
			else
			--first check for existing nearby top element, otherwise add new 
				local next_base = data.cabinet_list[data.current_cabinet].right_element
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
					next_base = data.cabinet_list[data.current_cabinet].left_element
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
					local new_element = initialize_cabinet_values(data)
					data.cabinet_list[data.current_cabinet].top_element = new_element
					data.cabinet_list[new_element].bottom_element = data.current_cabinet
					data.cabinet_list[new_element].row = 0x2
					data.cabinet_list[new_element].this_type = "wall"
					data.current_cabinet = data.cabinet_list[data.current_cabinet].top_element
				end
			end
		end
		recreate_all(data, false)
	end)
	controls.button_down:set_on_click_handler(function(state)
		if data.cabinet_list[data.current_cabinet].row == 0x3 then 
			if data.cabinet_list[data.current_cabinet].right_top_element == nil then
				local new_element = initialize_cabinet_values(data)
				data.cabinet_list[data.current_cabinet].right_top_element = new_element
				data.cabinet_list[new_element].left_top_element = data.current_cabinet
				data.cabinet_list[new_element].row = 0x2
				data.cabinet_list[new_element].this_type = "wall"
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].right_top_element
		else
			if data.cabinet_list[data.current_cabinet].bottom_element ~= nil then
				data.current_cabinet = data.cabinet_list[data.current_cabinet].bottom_element
			else
				local next_top = data.cabinet_list[data.current_cabinet].right_top_element
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
				next_top = data.cabinet_list[data.current_cabinet].left_top_element
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
	end)
	controls.insert_top:set_on_click_handler(function(state)
		local new_element = initialize_cabinet_values(data)
		data.cabinet_list[new_element].row = 0x2
		data.cabinet_list[new_element].this_type = "wall"
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
		local new_element = initialize_cabinet_values(data)
		data.cabinet_list[new_element].right_top_element = data.current_cabinet
		data.cabinet_list[new_element].row = 0x2
		data.cabinet_list[new_element].this_type = "wall"

		data.cabinet_list[data.current_cabinet].left_top_element = new_element
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	
	update_ui(data, false)
end

function update_ui(data, soft_update)
	local specific_data = data.cabinet_list[data.current_cabinet]
	
	if specific_data.this_type == "straight" or specific_data.this_type == "wall" or specific_data.this_type == "high" then
		if specific_data.width - 2 * data.gap > 0 then
			if specific_data.width  > specific_data.door_width then
				controls.door_side:disable_control()
			else
				controls.door_side:enable_control()
			end
		else 
			controls.door_side:enable_control()
		end
	elseif specific_data.this_type == "corner" or specific_data.this_type == "cornerwall" then
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
	elseif specific_data.this_type == "top" then
		controls.door_side:disable_control()
	end
	if soft_update == true then return end
	
	
--disable all controls and then just enable necessary ones
	for i, contr in pairs(controls) do
		if contr ~= controls.door_side then	--already treated above
			contr:disable_control()
		end
	end
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
		controls.button_up:enable_control()
	end
	
	if specific_data.row & 0x1 ~= 0 and specific_data.top_element == nil then
		controls.insert_top:enable_control()
	end
	if specific_data.row == 0x3 then
		controls.insert_top_left:enable_control()
		controls.button_down:enable_control()
	end
	if specific_data.row & 0x1 == 0 then 
		controls.button_down:enable_control()
	end
	if specific_data.row & 0x1 ~= 0 then
		controls.radio1:enable_control()
		controls.radio2:enable_control()
		controls.radio3:enable_control()
		controls.radio4:enable_control()
		controls.radio5:enable_control()
	end
	if specific_data.row == 0x2 then
		controls.radio6:enable_control()
		controls.radio7:enable_control()
		controls.radio8:enable_control()
	end
	if specific_data.this_type == "straight" then
		controls.door_side:set_control_text(pyloc "Door RH")
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
		controls.label_door_width:set_control_text(pyloc "Max door width")
		controls.label_width:set_control_text(pyloc "Width")
		
		controls.radio1:set_control_checked(true)
	
	elseif specific_data.this_type == "corner" then
		controls.door_side:set_control_text(pyloc "Door right side")

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
		controls.label_door_width:set_control_text(pyloc "Door width")
		controls.label_width:set_control_text(pyloc "Width")
		
		controls.radio2:set_control_checked(true)
	
	elseif specific_data.this_type == "diagonal" then
		controls.door_side:set_control_text(pyloc "Door RH")

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
		controls.label_door_width:set_control_text(pyloc "Max door width")
		controls.label_width:set_control_text(pyloc "Left width")
		
		controls.radio3:set_control_checked(true)
	
	
	elseif specific_data.this_type == "end" then
		--nothing to do here
		
	elseif specific_data.this_type == "high" then
		controls.door_side:set_control_text(pyloc "Door RH")
		controls.label_width:enable_control()
		controls.label_width:set_control_text(pyloc "Width")
		controls.width:enable_control()
		controls.label2:enable_control()
		controls.height:enable_control()
		controls.label6:enable_control()
		controls.shelf_count:enable_control()
		controls.door_width:enable_control()
		controls.label_door_width:enable_control()
		controls.label_door_width:set_control_text(pyloc "Max door width")
		
		controls.radio5:set_control_checked(true)
		
	elseif specific_data.this_type == "wall" then
		controls.door_side:set_control_text(pyloc "Door RH")
		controls.label_width:enable_control()
		controls.label_width:set_control_text(pyloc "Width")
		controls.width:enable_control()
		controls.label2:enable_control()
		controls.height:enable_control()
		controls.label6:enable_control()
		controls.shelf_count:enable_control()
		controls.door_width:enable_control()
		controls.label_door_width:enable_control()
		controls.label_door_width:set_control_text(pyloc "Max door width")
		
		controls.radio6:set_control_checked(true)
		
	elseif specific_data.this_type == "cornerwall" then
		controls.door_side:set_control_text(pyloc "Door RH")
		controls.label_width:enable_control()
		controls.label_width:set_control_text(pyloc "Left width")
		controls.width:enable_control()
		controls.label_width2:enable_control()
		controls.width2:enable_control()
		controls.label2:enable_control()
		controls.height:enable_control()
		controls.label6:enable_control()
		controls.shelf_count:enable_control()
		controls.door_width:enable_control()
		controls.label_door_width:enable_control()
		controls.label_door_width:set_control_text(pyloc "Max door width")
		
		controls.radio7:set_control_checked(true)
		
	elseif specific_data.this_type == "top" then
--		controls.door_side:set_control_text(pyloc "Door RH")
		controls.label_width:enable_control()
		controls.label_width:set_control_text(pyloc "Width")
		controls.width:enable_control()
		controls.label2:enable_control()
		controls.height:enable_control()
		controls.label6:enable_control()
		controls.shelf_count:enable_control()
--		controls.door_width:enable_control()
--		controls.label_door_width:enable_control()
--		controls.label_door_width:set_control_text(pyloc "Max door width")
		
		controls.radio8:set_control_checked(true)
	
	end
	
	if not (data.current_cabinet == 1 and data.cabinet_list[data.current_cabinet].left_element == nil and data.cabinet_list[data.current_cabinet].right_element == nil) then
		controls.button_delete:enable_control()
	end
	--here dialog values are set
	
	
	if data.cabinet_list[data.current_cabinet].this_type == "corner" or data.cabinet_list[data.current_cabinet].this_type == "diagonal" then 
		controls.width:set_control_text(pyui.format_length(specific_data.corner_width))
		controls.width2:set_control_text(pyui.format_length(specific_data.width2))
	elseif data.cabinet_list[data.current_cabinet].this_type == "cornerwall" then 
		controls.width:set_control_text(pyui.format_length(specific_data.corner_width_top))
		controls.width2:set_control_text(pyui.format_length(specific_data.width2_top))
	else 
		controls.width:set_control_text(pyui.format_length(specific_data.width))
		controls.width2:set_control_text(pyui.format_length(specific_data.width2))
	end
		
		
	
	if data.cabinet_list[data.current_cabinet].this_type == "cornerwall" or data.cabinet_list[data.current_cabinet].this_type == "wall" or 
		data.cabinet_list[data.current_cabinet].this_type == "high" or data.cabinet_list[data.current_cabinet].this_type == "top" then 
		controls.height:set_control_text(pyui.format_length(specific_data.height_top))
	else 
	controls.height:set_control_text(pyui.format_length(specific_data.height))
	end
	controls.drawer_height:set_control_text(pyui.format_length(specific_data.drawer_height))
	controls.shelf_count:set_control_text(pyui.format_number(specific_data.shelf_count))
	controls.door_width:set_control_text(pyui.format_length(specific_data.door_width))
	controls.door_side:set_control_checked(specific_data.door_rh)

end

function recreate_all(data, soft_update)
	if in_loop == true then return end
	in_loop = true
	update_ui(data, soft_update)
	in_loop = false
	recreate_geometry(data, false)
end


--here we could use metatables to distinguish the geometry functions. The same is true for the user interface. 
function create_geometry_for_element(general_data, element, finalize, direction, bool_group_benchtop, bool_group_kickboards)
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
	elseif specific_data.this_type == "high" then
		subgroup = recreate_high(general_data, specific_data)
	elseif specific_data.this_type == "wall" then
		subgroup = recreate_wall(general_data, specific_data)
	elseif specific_data.this_type == "cornerwall" then
		subgroup = recreate_cornerwall(general_data, specific_data)
	elseif specific_data.this_type == "top" then
		subgroup = recreate_top(general_data, specific_data)
	end
	if element == general_data.current_cabinet and not finalize then 
		pytha.set_element_pen(subgroup,4)
	end
	local benchtop = nil
	if bool_group_benchtop ~= nil then
		if specific_data.elem_handle_for_top ~= nil then
			table.insert(bool_group_benchtop[bool_group_benchtop["counter"]], specific_data.elem_handle_for_top)
		else 
			table.insert(bool_group_benchtop, {})
			bool_group_benchtop["counter"] = bool_group_benchtop["counter"] + 1
		end
	end
	if bool_group_kickboards ~= nil then
		if direction == "right" then
			if specific_data.kickboard_handle_left ~= nil then
				table.insert(bool_group_kickboards[bool_group_kickboards["counter"]], specific_data.kickboard_handle_left)
				
				if specific_data.kickboard_handle_right ~= specific_data.kickboard_handle_left then
					table.insert(bool_group_kickboards, {})
					bool_group_kickboards["counter"] = #bool_group_kickboards
					table.insert(bool_group_kickboards[bool_group_kickboards["counter"]], specific_data.kickboard_handle_right)
				end	
			else 
				table.insert(bool_group_kickboards, {})
				bool_group_kickboards["counter"] = #bool_group_kickboards
			end
		else 
			if specific_data.kickboard_handle_right ~= nil then
				table.insert(bool_group_kickboards[bool_group_kickboards["counter"]], specific_data.kickboard_handle_right)
				
				if specific_data.kickboard_handle_right ~= specific_data.kickboard_handle_left then
					table.insert(bool_group_kickboards, {})
					bool_group_kickboards["counter"] = #bool_group_kickboards
					table.insert(bool_group_kickboards[bool_group_kickboards["counter"]], specific_data.kickboard_handle_left)
				end	
			else 
				table.insert(bool_group_kickboards, {})
				bool_group_kickboards["counter"] = #bool_group_kickboards
			end
		end
		if specific_data.kickboard_handle_left ~= nil and specific_data.left_element == nil then 
			local end_kickboard = pytha.create_block(general_data.depth - general_data.kickboard_thickness - general_data.kickboard_setback, 
													general_data.kickboard_thickness, 
													general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness - general_data.kickboard_margin, 
													{specific_data.left_connection_point[1], specific_data.left_connection_point[2], specific_data.left_connection_point[3] + general_data.kickboard_margin}, 
													{u_axis={SIN(specific_data.left_direction), -COS(specific_data.left_direction), 0}, 
													v_axis={COS(specific_data.left_direction), SIN(specific_data.left_direction), 0}})
			table.insert(general_data.kickboards, end_kickboard)
			pytha.set_element_group(end_kickboard, specific_data.main_group)	--only for placement, element will be removed again and put in separate group
		end
		if specific_data.kickboard_handle_right ~= nil and specific_data.right_element == nil then 
			local end_kickboard = pytha.create_block(general_data.kickboard_thickness, 
													general_data.depth - general_data.kickboard_thickness - general_data.kickboard_setback, 
													general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness - general_data.kickboard_margin,
													{specific_data.right_connection_point[1], specific_data.right_connection_point[2], specific_data.right_connection_point[3] + general_data.kickboard_margin}, 
													{u_axis={-COS(specific_data.right_direction), -SIN(specific_data.right_direction), 0}, 
													v_axis={SIN(specific_data.right_direction), -COS(specific_data.right_direction), 0}})
			table.insert(general_data.kickboards, end_kickboard)
			pytha.set_element_group(end_kickboard, specific_data.main_group)	--only for placement, element will be removed again and put in separate group
		end
	end
	table.insert(general_data.cur_elements, subgroup)
	return subgroup
end


function recreate_geometry(data, finalize)

	if data.main_group ~= nil then
		pytha.delete_element(data.main_group)
	end
	data.cur_elements = {}
	data.kickboards = {}
	data.benchtop = {}
	local current_cabinet = 1
	
	local placement_angle = 0
	local bool_group_benchtop = {}
	table.insert(bool_group_benchtop, {})
	bool_group_benchtop["counter"] = 1
	local bool_group_kickboards = {}
	bool_group_kickboards["counter"] = 1
	table.insert(bool_group_kickboards, {})
	local total_origin = {data.origin[1], data.origin[2], data.origin[3]}
	
	
	total_origin[1] = total_origin[1]
	total_origin[2] = total_origin[2]
	placement_angle = ATAN(data.direction[2], data.direction[1])
	
	if general_data.orient_leftwards == true then 
		local cur_struct = data.cabinet_list[current_cabinet]
		total_origin[1] = total_origin[1] - cur_struct.left_connection_point[1]
		total_origin[2] = total_origin[2] - cur_struct.left_connection_point[2]
		total_origin[3] = total_origin[3] - cur_struct.left_connection_point[3]
		local rotated_new_coos = rotate_coos_by_angle({cur_struct.right_connection_point[1] - cur_struct.left_connection_point[1], 
														cur_struct.right_connection_point[2] - cur_struct.left_connection_point[2],
														cur_struct.right_connection_point[3] - cur_struct.left_connection_point[3]}, placement_angle)
		total_origin[1] = total_origin[1] - rotated_new_coos[1] + cur_struct.left_connection_point[1]
		total_origin[2] = total_origin[2] - rotated_new_coos[2] + cur_struct.left_connection_point[2]
		total_origin[3] = total_origin[3] - rotated_new_coos[3] + cur_struct.left_connection_point[3]
	end
	local origin = {total_origin[1], total_origin[2], total_origin[3]}
	
	
	--iteratively generate cabinets for sub_tree to right side...
	iterate_right(data, current_cabinet, origin, placement_angle, finalize, bool_group_benchtop, bool_group_kickboards, false)
	--...and to left side
	current_cabinet = data.cabinet_list[1].left_element
	if current_cabinet ~= nil then
		origin = {total_origin[1], total_origin[2], total_origin[3]} 
		placement_angle = ATAN(data.direction[2], data.direction[1])
--		origin[1] = origin[1] + data.cabinet_list[current_cabinet].left_connection_point[1]
--		origin[2] = origin[2] + data.cabinet_list[current_cabinet].left_connection_point[2]
--		origin[3] = origin[3] + data.cabinet_list[current_cabinet].left_connection_point[3]
		bool_group_kickboards["counter"] = 1
		bool_group_benchtop["counter"] = 1
		iterate_left(data, current_cabinet, origin, placement_angle, finalize, bool_group_benchtop, bool_group_kickboards, false)

	end
		
	
	for i,k in ipairs(bool_group_benchtop) do
		if #k > 1 then
			local new_benchtop = pytha.boole_part_union(k)
			table.insert(data.benchtop, new_benchtop)
		else
			table.insert(data.benchtop, k[1])
		end
	end
	for i,k in ipairs(bool_group_kickboards) do
		if #k > 1 then
			local new_element = pytha.boole_part_union(k)
			table.insert(data.kickboards, new_element)
		else
			table.insert(data.kickboards, k[1])
		end
	end
	pytha.set_element_name(data.benchtop, pyloc "Benchtop")
	pytha.set_element_group(data.benchtop, nil)
	data.benchtop_group = pytha.create_group(data.benchtop, {name = pyloc "Benchtop"})
	pytha.set_element_pen(data.benchtop_group, 0)
	table.insert(data.cur_elements, data.benchtop_group)
	pytha.set_element_name(data.kickboards, pyloc "Kickboard")
	pytha.set_element_group(data.kickboards, nil)
	data.kickboard_group = pytha.create_group(data.kickboards, {name = pyloc "Kickboard"})
	pytha.set_element_pen(data.kickboard_group, 0)
	table.insert(data.cur_elements, data.kickboard_group)
	data.main_group = pytha.create_group(data.cur_elements, {name = pyloc "Kitchen"})
	pytha.set_element_history(data.main_group, data, "wizard_history")
	
end

function rotate_coos_by_angle(coos, alpha)
	return {COS(alpha) * coos[1] - SIN(alpha) * coos[2], SIN(alpha) * coos[1] + COS(alpha) * coos[2], coos[3]}
end

function iterate_top(data, current_cabinet, origin, placement_angle, finalize)
--top cabinets dont need kickboards or benchtops so we dont add that logic for them. But they need placement
	local cur_struct = data.cabinet_list[current_cabinet]
	local top_origin = {origin[1], origin[2], origin[3]}	--call by reference only for tables
	local current_top_cabinet = nil
	local high_cab = nil
	if cur_struct.row == 0x1 then 
		current_top_cabinet = data.cabinet_list[current_cabinet].top_element
	elseif cur_struct.row == 0x3 then 
		current_top_cabinet = current_cabinet
		high_cab = 1
	end
	if current_top_cabinet ~= nil then
		iterate_right(data, current_top_cabinet, top_origin, placement_angle, finalize, nil, nil, true, high_cab)
		
		current_top_cabinet = data.cabinet_list[current_top_cabinet].left_top_element
		if current_top_cabinet ~= nil then
			top_origin[1] = origin[1]
			top_origin[2] = origin[2]
			top_origin[3] = origin[3]
			iterate_left(data, current_top_cabinet, top_origin, placement_angle, finalize, nil, nil, true)
		end
	end
end

function iterate_right(data, current_cabinet, origin, placement_angle, finalize, bool_group_benchtop, bool_group_kickboards, top_row, exists)
		
	while current_cabinet ~= nil do
		local cur_struct = data.cabinet_list[current_cabinet]
		local subgroup = nil
		if exists == nil then 
			subgroup = create_geometry_for_element(data, current_cabinet, finalize, "right", bool_group_benchtop, bool_group_kickboards)
		end			
		
		if top_row == false then
			iterate_top(data, current_cabinet, origin, placement_angle, finalize)
		end
		placement_angle = placement_angle - cur_struct.left_direction
		--here rotate and placement_angle
		origin[1] = origin[1] - cur_struct.left_connection_point[1]
		origin[2] = origin[2] - cur_struct.left_connection_point[2]
		origin[3] = origin[3] - cur_struct.left_connection_point[3]
		if subgroup ~= nil then
			pytha.rotate_element({subgroup, cur_struct.elem_handle_for_top}, cur_struct.left_connection_point, 'z', placement_angle)
			pytha.move_element({subgroup, cur_struct.elem_handle_for_top}, origin)
		end
		local rotated_new_coos = rotate_coos_by_angle({cur_struct.right_connection_point[1] - cur_struct.left_connection_point[1], 
														cur_struct.right_connection_point[2] - cur_struct.left_connection_point[2],
														cur_struct.right_connection_point[3] - cur_struct.left_connection_point[3]}, placement_angle)
		origin[1] = origin[1] +  rotated_new_coos[1] + cur_struct.left_connection_point[1]
		origin[2] = origin[2] +  rotated_new_coos[2] + cur_struct.left_connection_point[2]
		origin[3] = origin[3] +  rotated_new_coos[3] + cur_struct.left_connection_point[3]			
		placement_angle = placement_angle + data.cabinet_list[current_cabinet].right_direction
		
		if top_row == false then 
			current_cabinet = data.cabinet_list[current_cabinet].right_element
		else 
			current_cabinet = data.cabinet_list[current_cabinet].right_top_element
		end
		exists = nil
	end
end



function iterate_left(data, current_cabinet, origin, placement_angle, finalize, bool_group_benchtop, bool_group_kickboards, top_row)

	while current_cabinet ~= nil do
		local cur_struct = data.cabinet_list[current_cabinet]
		local subgroup = nil
		subgroup = create_geometry_for_element(data, current_cabinet, finalize, "left", bool_group_benchtop, bool_group_kickboards)
		
		if top_row == false then
			iterate_top(data, current_cabinet, origin, placement_angle, finalize)
		end
		
		
		placement_angle = placement_angle - cur_struct.right_direction
		--here rotate and placement_angle
		
		origin[1] = origin[1] - cur_struct.right_connection_point[1]
		origin[2] = origin[2] - cur_struct.right_connection_point[2]
		origin[3] = origin[3] - cur_struct.right_connection_point[3]
		if subgroup ~= nil then
			pytha.rotate_element({subgroup, cur_struct.elem_handle_for_top}, cur_struct.right_connection_point, 'z', placement_angle)
			pytha.move_element({subgroup, cur_struct.elem_handle_for_top}, origin)
		end
		local rotated_new_coos = rotate_coos_by_angle({cur_struct.left_connection_point[1] - cur_struct.right_connection_point[1], 
														cur_struct.left_connection_point[2] - cur_struct.right_connection_point[2],
														cur_struct.left_connection_point[3] - cur_struct.right_connection_point[3]}, placement_angle)
		origin[1] = origin[1] +  rotated_new_coos[1] + cur_struct.right_connection_point[1]
		origin[2] = origin[2] +  rotated_new_coos[2] + cur_struct.right_connection_point[2]
		origin[3] = origin[3] +  rotated_new_coos[3] + cur_struct.right_connection_point[3]
		placement_angle = placement_angle + data.cabinet_list[current_cabinet].left_direction

		if top_row == false then 
			current_cabinet = data.cabinet_list[current_cabinet].left_element
		else 
			current_cabinet = data.cabinet_list[current_cabinet].left_top_element
		end
	end
end

function finish_kickboard(general_data, specific_data)

end
