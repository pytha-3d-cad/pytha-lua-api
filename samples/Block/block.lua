--Simple block example with history


function edit_block(element)
	loaded_data = pytha.get_element_history(element, "block_history")
	if loaded_data == nil then
		pyui.alert(pyloc "No data found")
		return 
	end
	recreate_geometry(loaded_data)
	pyui.run_modal_dialog(cube_dialog, loaded_data)
	pyio.save_values("default_dimensions", loaded_data)
end

function main()
	local data = {size = {200, 200, 200}, angle = 0, 
				  origin={0,0,0}, name = pyloc "Block", centered = false}
	
	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then 
		for k,v in pairs(loaded_data) do data[k] = v end	--merges the loaded table into the default table
	end
	recreate_geometry(data)
	
	pyui.run_modal_dialog(cube_dialog, data)
	
	pyio.save_values("default_dimensions", data)
end

function cube_dialog(dialog, data)
	
	dialog:set_window_title(pyloc "My Block")
	
	dialog:create_label(1, pyloc "Name")
	local name = dialog:create_text_box({2,3}, data.name)
	local button_mat = dialog:create_button({4,5}, pyloc "Material")
	
	dialog:create_label(1, pyloc "Origin")
	local ori_text = pyui.format_length(data.origin[1]) .. "," .. pyui.format_length(data.origin[2]).. "," .. pyui.format_length(data.origin[3])
	local ori = dialog:create_text_box({2,3}, ori_text)
	local button_ori = dialog:create_button(4, pyloc "Pick")
	local check_ori_center = dialog:create_check_box(5, pyloc "Centered")
	dialog:create_align({1,5})
	dialog:create_label(1, pyloc "lx, ly, lz")
	local dimensions_text = pyui.format_length(data.size[1]) .. "," .. pyui.format_length(data.size[2]).. "," .. pyui.format_length(data.size[3])
	local length = dialog:create_text_box({2,3}, dimensions_text)
--	dialog:create_label(3, pyloc "Width")
--	local width = dialog:create_text_box(4, pyui.format_length(data.size[2]))
--	dialog:create_label(5, pyloc "Height")
--	local height = dialog:create_text_box(5, pyui.format_length(data.size[3]))
	dialog:create_label(4, pyloc "Angle")
	local angle = dialog:create_text_box(5, pyui.format_length(data.angle))

	
	dialog:create_align({1,4})
	local ok = dialog:create_ok_button(4)
	local cancel = dialog:create_cancel_button(5)
	dialog:equalize_column_widths({2, 3, 4, 5})
	

	
	if data.mat_handle then
		button_mat:set_control_text(data.mat_handle:get_name())
	end
	check_ori_center:set_control_checked(data.centered)
	
	length:set_on_change_handler(function(text)
        data.size = {pyui.parse_length(text)} or data.size
		if data.size[2] == nil then 
			data.size[2] = data.size[1]
		end
		if data.size[3] == nil then 
			data.size[3] = data.size[2]
		end
        recreate_geometry(data)
    end)
	-- width:set_on_change_handler(function(text)
        -- data.size[2] = pyui.parse_length(text) or data.size[2]
        -- recreate_geometry(data)
    -- end)
	-- height:set_on_change_handler(function(text)
        -- data.size[3] = pyui.parse_length(text) or data.size[3]
        -- recreate_geometry(data)
    -- end)
	angle:set_on_change_handler(function(text)
        data.angle = pyui.parse_length(text) or data.angle
        recreate_geometry(data)
    end)
	
	ori:set_on_change_handler(function(text)
        data.origin = {pyui.parse_length(text)} or data.origin
        recreate_geometry(data)
    end)
	
    name:set_on_change_handler(function(text)
        data.name = text
        recreate_geometry(data)
    end)
	
    button_mat:set_on_click_handler(function()
        data.mat_handle = pyux.select_material(data.mat_handle)
		if data.mat_handle then
			button_mat:set_control_text(data.mat_handle:get_name())
		end
        recreate_geometry(data)
    end)
	
	button_ori:set_on_click_handler(function()
		-- Pick in graphics
		button_ori:disable_control()
		local ret_wert = pyux.select_coordinate()
		if ret_wert ~= nil then
			data.origin = ret_wert
			ori_text = pyui.format_length(data.origin[1]) .. "," .. pyui.format_length(data.origin[2]).. "," .. pyui.format_length(data.origin[3])
			ori:set_control_text(ori_text)
		end
		button_ori:enable_control()
		recreate_geometry(data)
	end)
	
	check_ori_center:set_on_click_handler(function(state)
		-- Pick in graphics
		data.centered = state
		recreate_geometry(data)
	end)
	
end

function recreate_geometry(data)
    if data.current_element ~= nil then
        pytha.delete_element(data.current_element)
    end
	local origin = {data.origin[1], data.origin[2], data.origin[3]}
	local axis1 = {COS(data.angle), SIN(data.angle), 0}
	local axis2 = {-SIN(data.angle), COS(data.angle), 0}
	if data.centered == true then 
		origin[1] = origin[1] - 0.5 * (data.size[1] * axis1[1] + data.size[2] * axis2[1])
		origin[2] = origin[2] - 0.5 * (data.size[1] * axis1[2] + data.size[2] * axis2[2])
		origin[3] = origin[3]
	end
	data.current_element = pytha.create_block(data.size[1], data.size[2], data.size[3], origin, {name = data.name, u_axis = axis1})
	if data.mat_handle then
		pytha.set_element_material(data.current_element, data.mat_handle) 
	end
	pytha.set_element_history(data.current_element, data, "block_history")
end
