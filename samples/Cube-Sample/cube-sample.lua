--Beispiel eines einfachen Schrankkorpus mit variabler Anzahl an Fachboeden

function main()
	local data = {size = 500., name = "Box"}
	
	recreate_geometry(data)
	
	pyui.run_modal_dialog(cube_dialog, data)
end

function cube_dialog(dialog, data)
	dialog:set_window_title("My Cube")
	
	local label1 = dialog:create_label_left(1, "Size")
	local size = dialog:create_text_box(2, pyui.format_length(data.size))
	local label2 = dialog:create_label_top({1,2}, "Name")
	local name = dialog:create_text_box({1,2}, data.name)
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
	
	 size:set_on_change_handler(function(text)
        data.size = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	
    name:set_on_change_handler(function(text)
        data.name = text
        recreate_geometry(data)
    end)
	
end

function recreate_geometry(data)
    if data.current_element ~= nil then
        pytha.delete_element(data.current_element)
    end
	data.current_element = pytha.create_block(data.size, data.size, data.size, {0, 0, 0})
	pytha.set_element_attributes(data.current_element, "name", data.name)
end
