--Michael Test to see whats possible with Plug ins

function Main()
    local data = {
	cur_elements = {}, 
	main_group = nil, 
	Width = 500, 
	Depth = 300, 
	Height = 720, 
	Thickness = 18, 
	Abc = 60,
	name = "Box",
	}
	
	--local loaded_data = pyio.load_values("default_dimensions")
	
	
	
	recreate_geometry(data)
	
	pyui.run_modal_dialog(cube_dialog, data)
	--pyio.save_values("default_dimensions", data)
	
end

function cube_dialog(dialog, data)
    dialog:set_window_title("My Cube")
	
	local label1 = dialog:create_label(1, pyloc "Width")
    local Width = dialog:create_text_box(2, pyui.format_length(data.Width))
	local label2 = dialog:create_label(1, pyloc "Depth")
    local Depth = dialog:create_text_box(2, pyui.format_length(data.Depth))
	local label3 = dialog:create_label(1, pyloc "Height")
	local Height = dialog:create_text_box(2, pyui.format_length(data.Height))
	local label4 = dialog:create_label(1, pyloc "THK")
    local Thickness = dialog:create_text_box(2, pyui.format_length(data.Thickness))
    local label5 = dialog:create_label(1, pyloc "Name")
    local name = dialog:create_text_box(2, data.name)
	local label6 = dialog:create_label(1, pyloc "Abc")
    local Abc = dialog:create_text_box(2, pyui.format_length(data.Abc))
    local ok = dialog:create_ok_button(1)
    local cancel = dialog:create_cancel_button(2)
	
	Width:set_on_change_handler(function(text)
        data.Width = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	Depth:set_on_change_handler(function(text)
        data.Depth = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	Height:set_on_change_handler(function(text)
        data.Height = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	Thickness:set_on_change_handler(function(text)
        data.Thickness = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	
	Abc:set_on_change_handler(function(text)
        data.Abc = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	
	name:set_on_change_handler(function(text)
        data.name = text
        recreate_geometry(data)
    end)

	
	
end


function recreate_geometry(data)
	
		
	if data.main_group ~= nil then
		pytha.delete_element(pytha.get_group_members(data.main_group))
	end
	data.cur_elements = {}
	
		
	local loc_origin = {}
	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = 0
	
    --Left side
	local Left_Side_element = pytha.create_block(data.Thickness, data.Depth, data.Height, loc_origin )
	
	 --Right side
	loc_origin[1] = data.Width - data.Thickness
	local Right_Side_element = pytha.create_block(data.Thickness, data.Depth, data.Height, loc_origin )
	
	--Bottom 
	local Bottom_elements = {}
	loc_origin[1] = data.Thickness
	local Bottom_elements = pytha.create_block((data.Width - (data.Thickness*2)), data.Depth - data.Thickness, data.Thickness, loc_origin )
	table.insert(data.cur_elements, Bottom_elements)
	
	--Boolean Finger Pull Rail
	local FingerPull_elements = {}
	loc_origin[1] = 0
	loc_origin[3] = data.Height - data.Abc
	local FingerPull_elements = pytha.create_block(data.Width , data.Thickness, data.Abc, loc_origin )
	table.insert(data.cur_elements, FingerPull_elements)
	
	local copies = pytha.copy_element(FingerPull_elements, {0, 0, 0}, 2)
	--pytha.copy_element returns the handle to the copied elements in a table, so you can access the two elements with copies[1] and copies[2]. 
	
	--pytha.boole_part_difference will delete copies[1], so you do not have to delete it afterwards. 
	--pytha.boole_part_difference will also delete Right_Side_element and return a new handle instead. So you will only have to add that new handle to data.cur_elements in order to delete it upon recreate_geometry. 
	--But it wouldnt hurt if a part handle is in data.cur_elements of which the part has already been deleted. 
	Right_Side_element_booled = pytha.boole_part_difference(Right_Side_element, copies[1])
	table.insert(data.cur_elements, Right_Side_element_booled)
	
	
	Left_Side_element_booled = pytha.boole_part_difference(Left_Side_element, copies[2])
	table.insert(data.cur_elements, Left_Side_element_booled)
	
	data.main_group = pytha.create_group(data.cur_elements)
	
end
		

	



