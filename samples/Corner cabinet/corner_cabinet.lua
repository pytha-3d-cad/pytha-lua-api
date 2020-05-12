--Beispiel eines einfachen Schrankkorpus mit variabler Anzahl an Fachboeden

function main()
	local data = {
		cur_elements = {},
		main_group = nil,
		benchtop_height = 950,
		benchtop_thickness = 38,
		thickness = 19,
		thickness_back = 5,
		groove_dist = 35,
		groove_depth = 5,
		width = 1000,
		height = 838,
		depth = 550,
		setback_shelves = 5,
		shelve_count = 2,
		width_rail = 126,
		origin = {0,0,150},
		gap = 3,
		top_gap = 7,
		door_width = 500,
		drawer_height = 125,
		door_rh = false,
		right_element = nil,
		left_element = nil, 
		right_connection_point = {0,0},
		left_connection_point = {0,0},
		right_direction = 0,
		left_direction = 0,
		own_direction = 0,
		handle_length = 128,
	}
	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then data = loaded_data end
	
	data.own_direction = 0
	recreate_geometry(data)
	
	pyui.run_modal_dialog(test_dialog, data)
	pyio.save_values("default_dimensions", data)
end

function test_dialog(dialog, data)
	dialog:set_window_title("Corner Cabinet")
	
	local label_benchtop = dialog:create_label(1, "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(data.benchtop_height))
	local label_bt_thick = dialog:create_label(1, "Benchtop thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(data.benchtop_thickness))
	local label1 = dialog:create_label(1, "Width")
	local width = dialog:create_text_box(2, pyui.format_length(data.width))
	local label2 = dialog:create_label(1, "Height")
	local height = dialog:create_text_box(2, pyui.format_length(data.height))
	local label3 = dialog:create_label(1, "Depth")
	local depth = dialog:create_text_box(2, pyui.format_length(data.depth))
	local label6 = dialog:create_label(1, "Door width")
	local door_width = dialog:create_text_box(2, pyui.format_length(data.door_width))
	local label4 = dialog:create_label(1, "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(data.thickness))
	local label5 = dialog:create_label(1, "Drawer height")
	local drawer_height = dialog:create_text_box(2, pyui.format_length(data.drawer_height))
	local label6 = dialog:create_label(1, "Number of shelves")
	local shelve_count = dialog:create_text_box(2, pyui.format_length(data.shelve_count))
	
	local check = dialog:create_check_box({1, 2}, "Door on right side")

	local align1 = dialog:create_align({1,2}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
	dialog:equalize_column_widths({1,2,4})
	bt_height:set_on_change_handler(function(text)
		data.benchtop_height = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	bt_thick:set_on_change_handler(function(text)
		data.benchtop_thickness = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	width:set_on_change_handler(function(text)
		data.width = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	height:set_on_change_handler(function(text)
		data.height = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	depth:set_on_change_handler(function(text)
		data.depth = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	door_width:set_on_change_handler(function(text)
		data.door_width = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	thickness:set_on_change_handler(function(text)
		data.thickness = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	drawer_height:set_on_change_handler(function(text)
		data.drawer_height = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	shelve_count:set_on_change_handler(function(text)
		data.shelve_count = pyui.parse_length(text)
		recreate_all(data)
	end)
	
	check:set_on_click_handler(function(state)
		data.door_rh = state
		recreate_geometry(data)
	end)
	
end

function recreate_geometry(data)
	if data.main_group ~= nil then
		pytha.delete_element(pytha.get_group_members(data.main_group))
	end
	data.cur_elements = {}
	local base_height = data.benchtop_height - data.height - data.benchtop_thickness
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local door_height = data.height - data.top_gap - data.drawer_height
	if data.drawer_height > 0 then
		door_height = door_height - data.gap
	end
	
	local loc_origin= {}
	loc_origin[1] = data.origin[1]
	loc_origin[2] = data.origin[2]
	loc_origin[3] = base_height
	local groove_dist_back_off = data.groove_dist + data.thickness_back
	--Left side
	local new_elem = pytha.create_block(data.thickness, data.depth, data.height, loc_origin)
	table.insert(data.cur_elements, new_elem)
	--Right side
	loc_origin[1] = data.width - data.thickness
	new_elem = pytha.create_block(data.thickness, data.depth, data.height, loc_origin)
	table.insert(data.cur_elements, new_elem)
	--Bottom
	loc_origin[1] = data.thickness
	new_elem = pytha.create_block(data.width - 2 * data.thickness, data.depth - groove_dist_back_off, data.thickness, loc_origin)
	table.insert(data.cur_elements, new_elem)
	--Front rail
	loc_origin[3] = base_height + data.height - data.thickness
	new_elem = pytha.create_block(data.width - 2 * data.thickness, data.width_rail, data.thickness, loc_origin)
	table.insert(data.cur_elements, new_elem)
	--Back rail
	loc_origin[2] = data.depth - data.width_rail - groove_dist_back_off
	new_elem = pytha.create_block(data.width - 2 * data.thickness, data.width_rail, data.thickness, loc_origin)
	table.insert(data.cur_elements, new_elem)
	--Shelves
	for i=1,data.shelve_count,1 do
		loc_origin[2] = data.setback_shelves
		loc_origin[3] = base_height + i * (data.height - data.thickness) / (data.shelve_count + 1)
		local shelf_depth = data.depth - data.setback_shelves - groove_dist_back_off
		new_elem = pytha.create_block(data.width - 2 * data.thickness, shelf_depth, data.thickness, loc_origin)
		table.insert(data.cur_elements, new_elem)
	end
	--Back
	loc_origin[1] = data.thickness - data.groove_depth
	loc_origin[2] = data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(data.width - 2 * (data.thickness - data.groove_depth), data.thickness_back, data.height, loc_origin)
	table.insert(data.cur_elements, new_elem)
	
	
	--This section is influenced by "door right"
	
	--Corner angle

	if data.door_rh == true then
		local p_array = {{0, 0, 0}, 
						{0, -100 + data.gap, 0},
						{data.thickness, -100 + data.gap, 0}, 
						{data.thickness, -data.thickness, 0}, 
						{100 - data.gap, -data.thickness, 0}, 
						{100 - data.gap, 0, 0}}
		local corner_face = pytha.create_polygon(p_array)
		local corner_angle =  pytha.create_profile(corner_face, data.height - data.top_gap)[1]
		table.insert(data.cur_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = data.width - data.door_width - 100
		loc_origin[2] = 0
		loc_origin[3] = base_height 
		pytha.move_element(corner_angle, loc_origin)
	else
		local p_array = {{0, 0, 0}, 
						{0, -data.thickness, 0}, 
						{100 - data.gap - data.thickness, -data.thickness, 0}, 
						{100 - data.gap - data.thickness, -100 + data.gap, 0},
						{100 - data.gap, -100 + data.gap, 0},
						{100 - data.gap, 0, 0}}
		local corner_face = pytha.create_polygon(p_array)
		local corner_angle =  pytha.create_profile(corner_face, data.height - data.top_gap)[1]
		table.insert(data.cur_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = data.door_width + data.gap
		loc_origin[2] = 0
		loc_origin[3] = base_height
		pytha.move_element(corner_angle, loc_origin)
	end
	if data.door_rh == true then
		loc_origin[1] = data.width - data.door_width - 100 - data.thickness
	else
		loc_origin[1] = data.door_width + 100
	end
	loc_origin[2] = loc_origin[2] - 100
	new_elem = pytha.create_block(data.thickness, 100, data.height, loc_origin)
	table.insert(data.cur_elements, new_elem)
	
	
	--Door
	if data.door_width - 2 * data.gap > 0 then
		if data.door_rh == true then
			loc_origin[1] = data.width - data.door_width + data.gap
		else
			loc_origin[1] = data.gap
		end
		loc_origin[2] = -data.thickness
		loc_origin[3] = base_height
		
		create_door(data, data.door_width - 2 * data.gap, door_height, loc_origin, not data.door_rh, coordinate_system)
			
		
		--Drawer
		if data.drawer_height > 0 then
			loc_origin[3] = base_height + data.height - data.top_gap - data.drawer_height
			new_elem = pytha.create_block(data.door_width - 2 * data.gap, data.thickness, data.drawer_height, loc_origin)
			table.insert(data.cur_elements, new_elem)
			create_handle(data, loc_origin, data.door_width - 2 * data.gap, data.drawer_height, false, coordinate_system, 'center', 'center')
		end
	end
	
	pytha.group_elements(data.cur_elements)
	data.main_group = pytha.group_elements(data.cur_elements)
end

