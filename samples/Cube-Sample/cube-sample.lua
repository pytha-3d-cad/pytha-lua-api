--Beispiel eines einfachen Schrankkorpus mit variabler Anzahl an Fachboeden

function main()
	local data = {size = 200., name = "Box"}
	
	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then data = loaded_data end
	recreate_geometry(data)
	
	pyui.run_modal_dialog(cube_dialog, data)
	
	pyio.save_values("default_dimensions", data)
end

function cube_dialog(dialog, data)
	dialog:set_window_title("My Cube")
	
	local label1 = dialog:create_label_left(1, "Size")
	local size = dialog:create_text_box(2, pyui.format_length(data.size))
	local btn = dialog:create_button({3,4}, "Material")
	local label2 = dialog:create_label_top({1,2}, "Name")
	local name = dialog:create_text_box({3,4}, data.name)
	
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
	
    btn:set_on_click_handler(function()
        data.mat_handle = pyio.select_material(data.mat_handle)
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
    if data.current_element2 ~= nil then
        pytha.delete_element(data.current_element2)
    end
	
	data.current_element = pytha.create_block(data.size, data.size, data.size, {0, 0, 0})
	data.current_element2 = pytha.create_block(data.size, data.size, data.size, {300, 0, 0}, {u_axis = {1,1,1}, v_axis = {-1,1,1}, price=50, name="asdf"})
	pytha.set_element_attributes(data.current_element, {name = data.name})
	data.new_group = pytha.group_elements({data.current_element, data.current_element2})
	if data.mat_handle ~= nil then 
		pytha.set_element_material(data.new_group, data.mat_handle)
	end
	pytha.dissolve_group(data.new_group)
end
