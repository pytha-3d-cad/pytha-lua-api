function add_parts_by_material_thickness(selection, spec)
	local match_count = 0
	for part in pytha.enumerate_parts() do
		local material_name = nil
		if spec.material_name then
			material_name = part:get_element_attribute("material-name")
		end
		if material_name == spec.material_name then
		
			local thickness_string = part:get_element_attribute("3005")
			local thickness = tonumber(thickness_string)
			if math.abs(thickness - spec.thickness) < 0.001mm then
			
				table.insert(selection, part)
				match_count = match_count + 1
			end
			
		end
		
	end
	return match_count
end

function get_list_of_materials()
	local name_keys = {}
	for part in pytha.enumerate_parts() do
		local material_name = part:get_element_attribute("material-name") or ""
		if material_name ~= "" then
			name_keys[material_name] = true
		end
	end
	local names = {}
	for material_name in pairs(name_keys) do
		table.insert(names, material_name)
	end
	table.sort(names)
	return names
end

function get_list_of_thickness(spec)
	local thicknesses = {}
	for part in pytha.enumerate_parts() do
		local material_name = nil
		if spec.material_name then
			material_name = part:get_element_attribute("material-name")
		end
		if material_name == spec.material_name then
			
			local thickness = tonumber(part:get_element_attribute("3005"))
			if thickness and thickness > 0.001mm then
				table.insert(thicknesses, thickness)
			end
		
		end
	end
	
	table.sort(thicknesses)
	
	local thickness_strings = {}
	
	local prev_thickness = 0.
	for index, thickness in pairs(thicknesses) do
		if thickness > prev_thickness + 0.001mm then
			local thickness_string = pyui.format_length(thickness)
			table.insert(thickness_strings, thickness_string)
			prev_thickness = thickness
		end
	end

	return thickness_strings
end

function repopulate_materials(material_box)
	material_box:reset_content()
	material_box:insert_control_item(pyloc "Any")
	local material_names = get_list_of_materials()
	for index, material_name in pairs(material_names) do
		material_box:insert_control_item(material_name)
	end
end

function repopulate_thicknesses(thickness_box, spec)
	local thicknesses = get_list_of_thickness(spec)
	thickness_box:reset_content()
	for k, thickness_string in pairs(thicknesses) do
		thickness_box:insert_control_item(thickness_string)
	end
end

-- Dialog to specify material and thickness 
function selection_dialog(dialog, spec)
	dialog:set_window_title(pyloc "Select by...")
	
	dialog:create_label(1, pyloc "Material")
	local material_box = dialog:create_drop_list(2, spec.material_name)
	
	dialog:create_label(1, pyloc "Thickness")
	local thickness_box = dialog:create_combo_box(2, spec.thickness)
	
	dialog:create_ok_button(1)
	dialog:create_cancel_button(2)
	
	repopulate_materials(material_box)
	repopulate_thicknesses(thickness_box, spec)
	
	material_box:set_on_change_handler(function(text, new_index)
		if new_index == 1 then
			spec.material_name = nil
		else 
			spec.material_name = text
		end
		
		repopulate_thicknesses(thickness_box, spec)
	end)
	
	thickness_box:set_on_change_handler(function(text)
        spec.thickness = pyui.parse_length(text)
    end)
end

function select_parts_by_material_thickness(selection)
	local spec = {material_name = nil, thickness = 19mm}
	pyui.run_modal_dialog(selection_dialog, spec)
	local match_count = add_parts_by_material_thickness(selection, spec)
	if match_count == 0 then 
		pyui.alert(pyloc "No parts match the specification")
	end
end