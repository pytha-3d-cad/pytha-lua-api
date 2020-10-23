--Sink cabinet 

local function sink_geometry(general_data, specific_data)
--here the sink is loaded and placed. This function returns the loaded parts as a handle
	local loaded_parts = pytha.import_pyo(specific_data.sink_file)
	
	if loaded_parts ~= nil then 
		if specific_data.sink_flipped == 1 then 
			pytha.mirror_element(loaded_parts, {0,0,0}, "x")
		end
		for i = #loaded_parts, 1, -1 do 
			local ref_point_coos = pytha.get_element_ref_point_coordinates(loaded_parts[i])
			if #ref_point_coos > 0 then 
				local left_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
				local center_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
				local right_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
				if #ref_point_coos > 1 then
					center_point = {(ref_point_coos[1][1] + ref_point_coos[2][1]) / 2, 
									(ref_point_coos[1][2] + ref_point_coos[2][2]) / 2, 
									(ref_point_coos[1][3] + ref_point_coos[2][3]) / 2}
					right_point = {ref_point_coos[2][1], ref_point_coos[2][2], ref_point_coos[2][3]}
				end
				if specific_data.sink_flipped == 1 then 
					if specific_data.sink_position == 1 then 
						pytha.move_element(loaded_parts, {-right_point[1], -right_point[2], -right_point[3]}) 
					elseif specific_data.sink_position == 2 then 
						pytha.move_element(loaded_parts, {-center_point[1], -center_point[2], -center_point[3]}) 
					else
						pytha.move_element(loaded_parts, {-left_point[1], -left_point[2], -left_point[3]}) 
					end
				else 
					if specific_data.sink_position == 3 then 
						pytha.move_element(loaded_parts, {-right_point[1], -right_point[2], -right_point[3]}) 
					elseif specific_data.sink_position == 2 then 
						pytha.move_element(loaded_parts, {-center_point[1], -center_point[2], -center_point[3]}) 
					else
						pytha.move_element(loaded_parts, {-left_point[1], -left_point[2], -left_point[3]}) 
					end
				end
				break 
			end
		end
	end
	return loaded_parts
end
local function sinks_to_front_styles(general_data, specific_data, file_handle, show_dialog)

	local result_path = pyux.list_pyos(file_handle, show_dialog)
	
	if result_path ~= nil then 
		if show_dialog == true and #result_path > 0 then		--only write the default folder when dialog is really being displayed. Otherwise list might get polluted the first time kitchen wizard is being run
			general_data.default_folders.sink_folder = result_path[1]
		end
		specific_data.sink_list = {}
		table.insert(specific_data.sink_list, {name = pyloc "No sink",
														ui_function = nil, 
														file_handle = nil})
		for i,k in pairs(result_path) do
			local sink_name = k:get_name()
			sink_name = string.sub(sink_name, 1, -5)	--remove the last four characters (".pyo").
			
			table.insert(specific_data.sink_list, {name = sink_name,			--inserted with numeric key into general list of front styles. Values of old folders are not deleted...
														ui_function = nil, 
														file_handle = k})	--no problem to add the ffile handle to the table here...
		end
		table.insert(specific_data.sink_list, {name = pyloc "--Browse--",
														ui_function = update_sink_browse, 
														file_handle = nil})
	end
	controls.appliance_model:reset_content()
	local selected_i = 1
	for i,k in pairs(specific_data.sink_list) do 
		controls.appliance_model:insert_control_item(k.name)
		if specific_data.sink_file and specific_data.sink_file == k.file_handle then 
			selected_i = i
		end
	end
	if selected_i == 1 then 
		specific_data.sink_file = nil 
	end
	return selected_i
end

function update_sink_browse(general_data, specific_data)
	local updated_index = sinks_to_front_styles(general_data, specific_data, specific_data.sink_file, true)
	
	if  #specific_data.sink_list > 2 and updated_index == 1 then 
		specific_data.sink_file = specific_data.sink_list[2].file_handle
		controls.appliance_model:set_control_selection(2)
		updated_index = 2
	else 
		specific_data.sink_file = specific_data.sink_list[1].file_handle
		controls.appliance_model:set_control_selection(1)
		updated_index = 1
	end
	return updated_index
end

local function recreate_sink(general_data, specific_data)
	local cur_elements = {}
	
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin = {0, 0, base_height}
	local groove_dist_back_off = general_data.depth - general_data.thickness - general_data.groove_dist
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End LH"})
	table.insert(cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End RH"})
	table.insert(cur_elements, new_elem)
	--Bottom
	loc_origin[1] = general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth - general_data.groove_dist, general_data.thickness, loc_origin, {name = pyloc "Bottom"})
	table.insert(cur_elements, new_elem)
	--Front rail
	loc_origin[3] = base_height + specific_data.height - general_data.width_rail
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.thickness, general_data.width_rail, loc_origin, {name = pyloc "CR Front"})
	table.insert(cur_elements, new_elem)
	--Back rail
	loc_origin[2] = groove_dist_back_off
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.thickness, general_data.width_rail, loc_origin, {name = pyloc "CR Back"})
	table.insert(cur_elements, new_elem)

	
	local shelf_depth = general_data.depth - general_data.setback_shelves - groove_dist_back_off
	local front_style_info = nil
	if specific_data.front_style then 
		loc_origin[1] = 0
		loc_origin[2] = 0
		loc_origin[3] = base_height
		front_style_info = organization_style_list[specific_data.front_style]
		if front_style_info then
			front_style_info.geometry_function(general_data, specific_data, specific_data.width, specific_data.height, shelf_depth, general_data.top_gap, loc_origin, coordinate_system, cur_elements)
		end		
	end	
	
--------------------
	if specific_data.sink_file then 
		loc_origin[1] = 0
		loc_origin[2] = 0
		loc_origin[3] = base_height
		local loaded_parts = sink_geometry(general_data, specific_data) 
		if loaded_parts ~= nil then 
			for i,k in pairs(loaded_parts) do
				table.insert(cur_elements, k)
				local name = pytha.get_element_attribute(k, "name")
				if string.find(string.lower(name), "template") ~= nil then
					table.insert(general_data.benchtop_templates, k)
				end
			end
			
			pytha.move_element(loaded_parts, {0.5 * specific_data.width * (specific_data.sink_position - 1), 0, general_data.benchtop_height})
		end
	end
--------------------	

	--Kickboard
	specific_data.kickboard_handle_left = pytha.create_block(specific_data.width, general_data.kickboard_thickness, base_height - general_data.kickboard_margin, {0, general_data.kickboard_setback, general_data.kickboard_margin}, {name = pyloc "Kickboard"})
	table.insert(cur_elements, specific_data.kickboard_handle_left)
	specific_data.kickboard_handle_right = specific_data.kickboard_handle_left
	
	if specific_data.individual_call == nil then
		local benchtop = pytha.create_rectangle(specific_data.width, general_data.top_over + general_data.depth, {0, -general_data.top_over, general_data.benchtop_height - general_data.benchtop_thickness})
		specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness, {name = pyloc "Benchtop"})[1]
		pytha.delete_element(benchtop)
	end
	
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end

local function placement_sink(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, general_data.depth,0}
	specific_data.left_connection_point = {0, general_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end

local function ui_update_sink(general_data, soft_update)
	ui_update_straight_intelli_doors(general_data, soft_update)	--by default we add the doors. Can of course be modified
	if soft_update == true then return end

	

--for e.g. stovetop this handler can be 
	controls.appliance_model:set_on_change_handler(function(text, new_index)
		local specific_data = general_data.cabinet_list[general_data.current_cabinet]
		if specific_data.sink_list[new_index].ui_function then 
			new_index = specific_data.sink_list[new_index].ui_function(general_data, specific_data)
		end
		specific_data.sink_file = specific_data.sink_list[new_index].file_handle
		recreate_all(general_data, true)
	end)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	controls.label6:hide_control()
	controls.shelf_count:hide_control()
	controls.label_width:show_control()
	controls.width:show_control()
	controls.height_label:show_control()
	controls.height:show_control()
	controls.sink_orientation_label:show_control()
	controls.sink_orientation:show_control()
	controls.appliance_model_label:show_control()
	controls.appliance_model:show_control()
	
	controls.sink_orientation:reset_content()
	controls.sink_orientation:insert_control_item(pyloc "left")
	controls.sink_orientation:insert_control_item(pyloc "centered")
	controls.sink_orientation:insert_control_item(pyloc "right")
	controls.sink_orientation:insert_control_item(pyloc "flipped, left")
	controls.sink_orientation:insert_control_item(pyloc "flipped, centered")
	controls.sink_orientation:insert_control_item(pyloc "flipped, right")
	controls.sink_orientation:set_control_selection(3 * specific_data.sink_flipped + specific_data.sink_position)
	
	controls.subtypecombo_label:set_control_text(pyloc "Sink model")

	sinks_to_front_styles(general_data, specific_data, specific_data.sink_file, false)


end



--here we register the cabinet to the typelist 
--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			--might still be undefined here
	cabinet_typelist = {}
end
cabinet_typelist.sink = 			
{									
	name = pyloc "Sink cabinet",		
	row = 0x1,							
	default_data = {width = 600, shelf_count = 0, sink_flipped = 0, sink_position = 1, sink_list = {}}, --1: left, 2: center, 3: right			
	geometry_function = recreate_sink,	 	
	placement_function = placement_sink, 	
	ui_update_function = ui_update_sink, 	
	organization_styles = {"straight_intelli_doors"},		--here add the front styles for the sink cabinet
}
