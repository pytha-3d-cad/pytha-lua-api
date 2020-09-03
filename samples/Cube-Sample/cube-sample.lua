--Simple block example with history

function eval(element)
	local attribute = pytha.get_element_attribute(element, "block_special_attribute")
	local name = pytha.get_element_attribute(element, "name")
	local dimensions = pytha.get_element_bounding_box(element)
	local length = pytha.get_length_unit() 
	return attribute .. " " .. name .. "! Your length is " .. pyui.format_length(dimensions[2][1] - dimensions[1][1]) .. length
end

function edit_block(element)
	loaded_data = pytha.get_element_history(element, "block_history_demo")
	if loaded_data == nil then
		pyui.alert(pyloc "No data found")
		return 
	end
	recreate_geometry(loaded_data)
	pyui.run_modal_dialog(cube_dialog, loaded_data)
	pyio.save_values("default_dimensions", loaded_data)
end

function main()
	local data = {size = 200., name = "Box", pre_text = "Hello"}
	
--	local loaded_data = pyio.load_values("default_dimensions")
--	if loaded_data ~= nil then data = loaded_data end
	recreate_geometry(data)
	
	pyui.run_modal_dialog(cube_dialog, data)
	
	pyio.save_values("default_dimensions", data)
end

function cube_dialog(dialog, data)
	dialog:set_window_title("My Cube")
	
	local label1 = dialog:create_label(1, "Size")
	local size = dialog:create_text_box(2, pyui.format_length(data.size))
	local btn = dialog:create_button({3,4}, "Material")
	local label2 = dialog:create_label({1,2}, "Name")
	local name = dialog:create_text_box({3,4}, data.name)
	local label3 = dialog:create_label({1,2}, "Special Cube Greeting")
	local spec_attribute = dialog:create_text_box({3,4}, data.pre_text)
	
	dialog:create_align({1,4})
	local ok = dialog:create_ok_button({1,2})
	local cancel = dialog:create_cancel_button({3,4})
	dialog:equalize_column_widths({1,2,3,4})
	
	if data.mat_handle then
		btn:set_control_text(data.mat_handle:get_name())
	end
	
	 size:set_on_change_handler(function(text)
        data.size = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	
    name:set_on_change_handler(function(text)
        data.name = text
        recreate_geometry(data)
    end)
	
    spec_attribute:set_on_change_handler(function(text)
        data.pre_text = text
        recreate_geometry(data)
    end)
	
    btn:set_on_click_handler(function()
        data.mat_handle = pyux.select_material(data.mat_handle)
		if data.mat_handle then
			btn:set_control_text(data.mat_handle:get_name())
		end
        recreate_geometry(data)
    end)
	
	
end

function recreate_geometry(data)
    if data.current_element ~= nil then
        pytha.delete_element(data.current_element)
    end

	
	data.current_element = pytha.create_block(data.size, data.size, data.size, {0,0,0}, {name = data.name})
	
	data.current_element:set_element_attributes({block_special_attribute = data.pre_text})
	if data.mat_handle then
		pytha.set_element_material(data.current_element, data.mat_handle) 
	end
	pytha.set_element_history(data.current_element, data, "block_history_demo")
end
