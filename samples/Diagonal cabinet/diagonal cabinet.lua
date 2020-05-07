--Beispiel eines einfachen Schrankkorpus mit variabler Anzahl an Fachboeden
controls = {door_side = nil,

}
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
		width2 = 1000,
		height = 838,
		depth = 550,
		setback_shelves = 5,
		shelve_count = 2,
		width_rail = 126,
		origin = {0,0,150},
		gap = 3,
		top_gap = 7,
		max_door_width = 700,
		drawer_height = 125,
		door_rh = false,
		right_element = nil,
		left_element = nil, 
		right_connection_point = {0,0},
		left_connection_point = {0,0},
		right_direction = -90,
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
	dialog:set_window_title("Diagonal Cabinet")
	
	local label_benchtop = dialog:create_label(1, "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(data.benchtop_height))
	local label_bt_thick = dialog:create_label(1, "Benchtop thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(data.benchtop_thickness))
	local label1 = dialog:create_label(1, "Left Width")
	local width = dialog:create_text_box(2, pyui.format_length(data.width))
	local label7 = dialog:create_label(1, "Right Width")
	local width2 = dialog:create_text_box(2, pyui.format_length(data.width2))
	local label2 = dialog:create_label(1, "Height")
	local height = dialog:create_text_box(2, pyui.format_length(data.height))
	local label3 = dialog:create_label(1, "Depth")
	local depth = dialog:create_text_box(2, pyui.format_length(data.depth))
	local label4 = dialog:create_label(1, "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(data.thickness))
	local label5 = dialog:create_label(1, "Drawer height")
	local drawer_height = dialog:create_text_box(2, pyui.format_length(data.drawer_height))
	local label6 = dialog:create_label(1, "Number of shelves")
	local shelve_count = dialog:create_text_box(2, pyui.format_length(data.shelve_count))
	
	controls.door_side = dialog:create_check_box({1, 2}, "Door right side")

	local align1 = dialog:create_align({1,2}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
	dialog:equalize_column_widths({1,2,4})
	
	bt_height:set_on_change_handler(function(text)
		data.benchtop_height = pyui.parse_length(text)
		recreate_all(data)
	end)
	bt_thick:set_on_change_handler(function(text)
		data.benchtop_thickness = pyui.parse_length(text)
		recreate_all(data)
	end)
	
	width:set_on_change_handler(function(text)
		data.width = pyui.parse_length(text)
		recreate_all(data)
	end)
	
	width2:set_on_change_handler(function(text)
		data.width2 = pyui.parse_length(text)
		recreate_all(data)
	end)
	
	height:set_on_change_handler(function(text)
		data.height = pyui.parse_length(text)
		recreate_all(data)
	end)
	
	depth:set_on_change_handler(function(text)
		data.depth = pyui.parse_length(text)
		recreate_all(data)
	end)
	
	
	thickness:set_on_change_handler(function(text)
		data.thickness = pyui.parse_length(text)
		recreate_all(data)
	end)
	
	drawer_height:set_on_change_handler(function(text)
		data.drawer_height = pyui.parse_length(text)
		recreate_all(data)
	end)
	
	shelve_count:set_on_change_handler(function(text)
		data.shelve_count = pyui.parse_length(text)
		recreate_all(data)
	end)
	
	controls.door_side:set_on_click_handler(function(state)
		data.door_rh = state
		recreate_all(data)
	end)
	
	update_ui(data)
end

function recreate_all(data)
	update_ui(data)
	recreate_geometry(data)
end

function update_ui(data)
	if get_diag_door_length(data) - 2 * data.gap > 0 then
		if get_diag_door_length(data)  > data.max_door_width then
			controls.door_side:disable_control()
		else
			controls.door_side:enable_control()
		end
	else 
		controls.door_side:disable_control()
	end
end

function recreate_geometry(data)
	if data.main_group ~= nil then
		pytha.delete_element(pytha.get_group_members(data.main_group))
	end
	data.cur_elements = {}
	local base_height = data.benchtop_height - data.height - data.benchtop_thickness

	local loc_origin= {}
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local door_height = data.height - data.top_gap - data.drawer_height
	if data.drawer_height > 0 then
		door_height = door_height - data.gap
	end

	loc_origin[1] = data.origin[1]
	loc_origin[2] = data.origin[2]
	loc_origin[3] = base_height
	
	local slope = (data.width2 - data.depth)/(data.width - data.depth)
	local groove_dist_back_off = data.groove_dist + data.thickness_back
		
	local door_diag_offset_y1 = -data.gap * slope + data.thickness * (1 - PYTHAGORAS(slope, 1))	--distance that door is standing out further than a normal door. We shift by that value to bring all doors to the same height
	local door_diag_offset_x2 = -data.gap / slope + data.thickness * (1 - PYTHAGORAS(1 / slope, 1))	--distance that door is standing out further than a normal door. We shift by that value to bring all doors to the same height

	--Left side
	local poly_array = {{0, -door_diag_offset_y1,0}, 
						{data.thickness, -door_diag_offset_y1 - data.thickness * slope, 0}, 
						{data.thickness, data.depth, 0}, 
						{0, data.depth, 0}}
	local fla_handle = pytha.create_polygon(poly_array)
	local profile = pytha.create_profile(fla_handle, data.height)[1]
	pytha.delete_element(fla_handle)
	pytha.rotate_element(profile, {0,0,0}, 'z', data.own_direction)
	pytha.move_element(profile, loc_origin)
	table.insert(data.cur_elements, profile)
	
	--Right side
	poly_array = {{data.width, data.depth - data.width2 + data.thickness, 0}, 
					{data.width - data.depth - data.thickness / slope - door_diag_offset_x2, data.depth - data.width2 + data.thickness, 0}, 
					{data.width - data.depth - door_diag_offset_x2, data.depth - data.width2, 0}, 
					{data.width, data.depth - data.width2, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	profile = pytha.create_profile(fla_handle, data.height)[1]
	pytha.delete_element(fla_handle)
	pytha.rotate_element(profile, {0,0,0}, 'z', data.own_direction)
	pytha.move_element(profile, loc_origin)
	table.insert(data.cur_elements, profile)
	
	
	--Bottom
	poly_array = {{data.thickness, -data.thickness * slope - door_diag_offset_y1, 0}, 
					{data.width - data.depth - data.thickness / slope - door_diag_offset_x2, data.depth - data.width2 + data.thickness, 0}, 
					{data.width - groove_dist_back_off, data.depth - data.width2 + data.thickness, 0}, 
					{data.width - groove_dist_back_off, data.depth - groove_dist_back_off, 0},
					{data.thickness, data.depth - groove_dist_back_off, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	profile = pytha.create_profile(fla_handle, data.thickness)[1]
	pytha.rotate_element(profile, {0,0,0}, 'z', data.own_direction)
	pytha.move_element(profile, loc_origin)
	table.insert(data.cur_elements, profile)
	
	--We reuse the fla handle for the top and the shelves
	loc_origin[3] = base_height + data.height - data.thickness
	profile = pytha.create_profile(fla_handle, data.thickness)[1]
	pytha.delete_element(fla_handle)
	pytha.rotate_element(profile, {0,0,0}, 'z', data.own_direction)
	pytha.move_element(profile, loc_origin)
	table.insert(data.cur_elements, profile)
	
	--shelf setback needs pythagoras 
	--Shelves
	poly_array = {{data.thickness, - data.thickness * slope - door_diag_offset_y1 + data.setback_shelves * PYTHAGORAS(slope, 1), 0}, 
					{data.width - data.depth - data.thickness / slope - door_diag_offset_x2 + data.setback_shelves * PYTHAGORAS(1 / slope, 1), data.depth - data.width2 + data.thickness, 0}, 
					{data.width - groove_dist_back_off, data.depth - data.width2 + data.thickness, 0}, 
					{data.width - groove_dist_back_off, data.depth - groove_dist_back_off, 0},
					{data.thickness, data.depth - groove_dist_back_off, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	for i=1,data.shelve_count,1 do
		loc_origin[3] = base_height + i * door_height / (data.shelve_count + 1)

		profile = pytha.create_profile(fla_handle, data.thickness)[1]
		pytha.rotate_element(profile, {0,0,0}, 'z', data.own_direction)
		pytha.move_element(profile, loc_origin)
		table.insert(data.cur_elements, profile)
	end
	pytha.delete_element(fla_handle)
	--Back
	loc_origin[1] = data.thickness - data.groove_depth
	loc_origin[2] = data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(data.width - data.thickness + data.groove_depth - groove_dist_back_off, data.thickness_back, data.height, loc_origin)
	table.insert(data.cur_elements, new_elem)
	loc_origin[1] = data.width - groove_dist_back_off
	loc_origin[2] = data.depth - data.width2 +  data.thickness - data.groove_depth
	loc_origin[3] = base_height 
	new_elem = pytha.create_block(data.thickness_back, data.width2 - data.thickness + data.groove_depth - groove_dist_back_off + data.thickness_back, data.height, loc_origin)
	table.insert(data.cur_elements, new_elem)
	

	--here we need to introduce arotated coordinate system for the door
	local main_dir = {data.width - data.depth, data.depth - data.width2, 0}
	local diag_length = PYTHAGORAS(main_dir[1], main_dir[2], main_dir[3])
	main_dir[1] = main_dir[1] / diag_length
	main_dir[2] = main_dir[2] / diag_length
	main_dir[3] = main_dir[3] / diag_length
	
	local third_dir =  {-main_dir[2], main_dir[1], 0}
	
	local diag_coos = {main_dir, third_dir, {0,0,1}}
	--this point gives a 3mm gap of the door to the side
	loc_origin[1] = data.gap
	loc_origin[2] = -data.thickness
	loc_origin[3] = base_height
	local door_length = get_diag_door_length(data)
	
	--Door
	if door_length > 0 then
		
		if door_length > data.max_door_width then	--create two doors
			local door_width = door_length / 2 - data.gap
		--left handed door
			create_door(data, door_width, door_height, loc_origin, false, diag_coos)
		--right handed door
			loc_origin[1] = loc_origin[1] + (door_width + 2 * data.gap) * main_dir[1]
			loc_origin[2] = loc_origin[2] + (door_width + 2 * data.gap) * main_dir[2]
			create_door(data, door_width, door_height, loc_origin, true, diag_coos)
		else
		--only one door 
			create_door(data, door_length, door_height, loc_origin, data.door_rh, diag_coos)
		end
		
		--Drawer
		if data.drawer_height > 0 then
			loc_origin[1] = data.gap
			loc_origin[2] = -data.thickness
			loc_origin[3] = base_height + data.height - data.top_gap - data.drawer_height
			local axes = {u_axis = diag_coos[1], v_axis = diag_coos[2], w_axis = diag_coos[3]}

			new_elem = pytha.create_block(door_length, data.thickness, data.drawer_height, loc_origin, axes)
			table.insert(data.cur_elements, new_elem)
			create_handle(data, loc_origin, door_length, data.drawer_height, false, diag_coos, 'center', 'center')
		end
	end
	data.right_connection_point = {data.width,0}
	data.main_group = pytha.group_elements(data.cur_elements)
end

function get_diag_door_length(data)
	local p2 = {data.width - data.depth - data.thickness, data.depth - data.width2 + data.gap, 0}
	local door_length = PYTHAGORAS(p2[1] - data.gap, p2[2] + data.thickness, 0)
	return door_length
end

