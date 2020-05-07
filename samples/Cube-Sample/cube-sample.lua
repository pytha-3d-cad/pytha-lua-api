--Beispiel eines einfachen Schrankkorpus mit variabler Anzahl an Fachboeden

function main()
	local data = {size = 200., name = "Box", number = 4}
	
	recreate_geometry(data)
	
	pyui.run_modal_dialog(cube_dialog, data)
end

function cube_dialog(dialog, data)
	dialog:set_window_title("My Cube")
	
	local label1 = dialog:create_label_left(1, "Size")
	local size = dialog:create_text_box(2, pyui.format_length(data.size))
	local label3 = dialog:create_label_left(3, "Test label")
	local count = dialog:create_text_box(4, pyui.format_length(data.number))
	local label2 = dialog:create_label_top({1,2}, "Name")
	local name = dialog:create_text_box({1,2}, data.name)
	dialog:create_align({1,4})
	local ok = dialog:create_ok_button(3)
	local cancel = dialog:create_cancel_button(4)
	
	 size:set_on_change_handler(function(text)
        data.size = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	
    name:set_on_change_handler(function(text)
        data.name = text
        recreate_geometry(data)
    end)
	
    count:set_on_change_handler(function(text)
        data.number = text
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
    if data.new_elems ~= nil then
        pytha.delete_element(data.new_elems)
    end
	data.current_element = pytha.create_block(data.size, data.size, data.size, {0, 0, 0})
	data.current_element2 = pytha.create_block(data.size, data.size, data.size, {300, 0, 0})
	pytha.set_element_attribute(data.current_element, "name", data.name)
	data.new_group = pytha.group_elements({data.current_element, data.current_element2})
	data.new_elems = pytha.copy_element(data.new_group, {1000,0,0}, data.number)
	pytha.dissolve_group(data.new_group)
end
