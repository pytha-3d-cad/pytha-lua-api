--Example of a Kitchen wizard generator

function edit_wizard(element)
	local general_data = pytha.get_element_history(element, "wizard_history")
	if general_data == nil then
		pyui.alert(pyloc "No data found")
		return 
	end
	init_typecombolist()
	pyui.run_modal_dialog(wizard_dialog, general_data)
	recreate_geometry(general_data, true)
end

function main()
	local general_data = _G["general_default_data"]
--	local loaded_data = pyio.load_values("default_dimensions")
--	if loaded_data ~= nil then general_data = loaded_data end
	init_typecombolist()
	general_data.current_cabinet = initialize_cabinet_values(general_data, typecombolist[0x1][1])
	
	general_data.own_direction = 0
	
	pyui.run_modal_dialog(wizard_dialog, general_data)
	recreate_geometry(general_data, true)
	
--	pyio.save_values("default_dimensions", general_data)
end

--here we could use metatables to distinguish the geometry functions. The same is true for the user interface. 
function create_geometry_for_element(general_data, element, finalize, direction, bool_group_benchtop, bool_group_kickboards)
	local specific_data = general_data.cabinet_list[element]
	local spec_type_info = cabinet_typelist[specific_data.this_type]
	local subgroup = nil
	
	subgroup = spec_type_info.geometry_function(general_data, specific_data)
	
	if subgroup == nil then
		pyui.alert("Problem in geometry of cabinet type \"" .. spec_type_info.name .. "\"")
	end
	
	pytha.set_element_name(subgroup, spec_type_info.name)
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

local function recalc_placement_angle(data)
	local placement_angle = calculate_angle(data.direction[1], data.direction[2])
	local ini_struct = data.cabinet_list[1]
	if data.orient_leftwards == true then 
		placement_angle = placement_angle + 180
		placement_angle = placement_angle - ini_struct.left_direction
	else
		placement_angle = placement_angle - ini_struct.right_direction
	end
	return placement_angle
end
function recreate_geometry(data, finalize)

	if data.main_group ~= nil then
		pytha.delete_element(data.main_group)
	end
	data.main_group = nil 
	data.cur_elements = {}
	data.kickboards = {}
	data.benchtop = {}
	local current_cabinet = 1
	
	local bool_group_benchtop = {}
	table.insert(bool_group_benchtop, {})
	bool_group_benchtop["counter"] = 1
	local bool_group_kickboards = {}
	bool_group_kickboards["counter"] = 1
	table.insert(bool_group_kickboards, {})
	local total_origin = {data.origin[1], data.origin[2], data.origin[3]}
	local ini_struct = data.cabinet_list[current_cabinet]
	
	for i, k in pairs(data.cabinet_list) do
		local spec_type_info = cabinet_typelist[k.this_type]
		k.origin_point = nil	--has to be set to nil to avoid a fix origin when switching left and right orientation
		spec_type_info.placement_function(data, k)--needs to be calculated before geometry creation
	end	
	
	local placement_angle = recalc_placement_angle(data)
	total_origin[1] = total_origin[1]
	total_origin[2] = total_origin[2]
	
	if data.orient_leftwards == true then 
		local rotated_new_coos = rotate_coos_by_angle({ini_struct.right_connection_point[1] - ini_struct.left_connection_point[1], 
														ini_struct.right_connection_point[2] - ini_struct.left_connection_point[2],
														ini_struct.right_connection_point[3] - ini_struct.left_connection_point[3]}, placement_angle)
		total_origin[1] = total_origin[1] - rotated_new_coos[1]
		total_origin[2] = total_origin[2] - rotated_new_coos[2]
		total_origin[3] = total_origin[3] - rotated_new_coos[3]
		
		if data.cabinet_list[current_cabinet].origin_point ~= nil then 
			rotated_new_coos = rotate_coos_by_angle({ini_struct.right_connection_point[1] - ini_struct.origin_point[1], 
															ini_struct.right_connection_point[2] - ini_struct.origin_point[2],
															ini_struct.right_connection_point[3] - ini_struct.origin_point[3]}, placement_angle)
			total_origin[1] = total_origin[1] + rotated_new_coos[1]
			total_origin[2] = total_origin[2] + rotated_new_coos[2]
			total_origin[3] = total_origin[3] + rotated_new_coos[3]
		end
	else 
		if data.cabinet_list[current_cabinet].origin_point ~= nil then 
			local rotated_new_coos = rotate_coos_by_angle({ini_struct.left_connection_point[1] - ini_struct.origin_point[1], 
															ini_struct.left_connection_point[2] - ini_struct.origin_point[2],
															ini_struct.left_connection_point[3] - ini_struct.origin_point[3]}, placement_angle)
			total_origin[1] = total_origin[1] + rotated_new_coos[1]
			total_origin[2] = total_origin[2] + rotated_new_coos[2]
			total_origin[3] = total_origin[3] + rotated_new_coos[3]
		end
	end
	local origin = {total_origin[1], total_origin[2], total_origin[3]}
	
	
	--iteratively generate cabinets for sub_tree to right side...
	
	--to compensate for rotation inside function
	placement_angle = placement_angle + ini_struct.left_direction
	iterate_right(data, current_cabinet, origin, placement_angle, finalize, bool_group_benchtop, bool_group_kickboards, false)
	--...and to left side
	placement_angle = recalc_placement_angle(data)
	placement_angle = placement_angle + ini_struct.left_direction
	current_cabinet = data.cabinet_list[1].left_element
	if current_cabinet ~= nil then
		origin = {total_origin[1], total_origin[2], total_origin[3]} 
		bool_group_kickboards["counter"] = 1
		bool_group_benchtop["counter"] = 1
		
		--to compensate for rotation inside function
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
		---ori placement plus
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
		
		placement_angle = placement_angle + cur_struct.right_direction
		
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
		placement_angle = placement_angle - cur_struct.right_direction
		local rotated_new_coos = rotate_coos_by_angle({cur_struct.left_connection_point[1] - cur_struct.right_connection_point[1], 
														cur_struct.left_connection_point[2] - cur_struct.right_connection_point[2],
														cur_struct.left_connection_point[3] - cur_struct.right_connection_point[3]}, placement_angle)
		if top_row == false then
			local loc_origin = {origin[1], origin[2], origin[3]}
			loc_origin[1] = loc_origin[1] + rotated_new_coos[1] 
			loc_origin[2] = loc_origin[2] + rotated_new_coos[2]
			loc_origin[3] = loc_origin[3] + rotated_new_coos[3]
			iterate_top(data, current_cabinet, loc_origin, placement_angle, finalize)
		end
		
		--here rotate and placement_angle
		origin[1] = origin[1] - cur_struct.right_connection_point[1]
		origin[2] = origin[2] - cur_struct.right_connection_point[2]
		origin[3] = origin[3] - cur_struct.right_connection_point[3]
		
		if subgroup ~= nil then
			pytha.rotate_element({subgroup, cur_struct.elem_handle_for_top}, cur_struct.right_connection_point, 'z', placement_angle)
			pytha.move_element({subgroup, cur_struct.elem_handle_for_top}, origin)
		end
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


function calculate_angle(dx, dy)
	local Phi
	if math.abs(dx) < 1e-8 and math.abs(dy) < 1e-8 then 
		return 0
	end
	if math.abs(dx) < 1e-8 then 
		if dy > 0 then
			Phi = 90.0
		else 
			Phi = 270.0
		end
	else
		if math.abs(dy) < 1e-6 then 
			if dx > 0.0 then
				Phi = 0.0
			else
				Phi = 180.0
			end
		else
			Phi = ATAN(dy / dx)
			if dx < 0 then 
				Phi = Phi + 180.0
			end
			Phi = math.fmod((Phi + 360.0), 360.0)
		end
	end
	return Phi
end