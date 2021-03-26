--Example for a simple spiral staircase

default_data = {
		cur_elements = {},
		total_height = 2640,		--height of the stairs
		steps = 12,					--number of steps
		step_thickness = 40,		--board thickness ot the steps
		pole_radius = 75,			--radius of the central pole
		total_angle = 360,			--how much will the stairs wind? 360 is one full turn
		rail_height = 900,			--height of the rail, measured to the top of the rail handle
		vertical_bar_radius = 4,	--radius of the vertical railing bars 
		diameter = 1600,			--diameter of the stairs to the center of the handrail. There is an additional offset (see outer_radius)
		step_excess = 10,			--excess of the steps at the central pole and at the vertical rail bars
		clockwise = false,				--rotation direction
		handrail_type = 1,			--cross section of handrail: line, round, square
		handrail_upright = false,	--false: tilted, true: upright
		handrail_thickness = 40,
		handrail_width = 60,
		autocalc = false		
	}

--this function allows adding new variables to the default data and to still edit old stairs without that element being nil
function merge_data(merge_from, merge_to)
	for i,k in pairs(merge_from) do
		merge_to[i] = k
	end
end

function edit_stairs(element)
	local data = default_data
	local loaded_data = pytha.get_element_history(element, "spiral_stairs_history")
	if loaded_data == nil then
		pyui.alert(pyloc "No data found")
		return 
	end
	merge_data(loaded_data, data)
	recreate_geometry(data)
	pyui.run_modal_dialog(stairs_dialog, data)
	recreate_geometry(data)
end

function main()
	local data = default_data
	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then merge_data(loaded_data, data) end
	recreate_geometry(data)
	
	pyui.run_modal_dialog(stairs_dialog, data)
	pyio.save_values("default_dimensions", data)
end

function stairs_dialog(dialog, data)
	dialog:set_window_title(pyloc "Spiral Staircase")
	controls = {}
	dialog:create_label(1, pyloc "Total Height")
	local total_height = dialog:create_text_box(2, pyui.format_length(data.total_height))
	dialog:create_label(1, pyloc "Diameter")
	local diameter = dialog:create_text_box(2, pyui.format_length(data.diameter))
	dialog:create_label(1, pyloc "No. of steps")
	controls.steps = dialog:create_text_spin(2, pyui.format_number(data.steps))
	dialog:create_label(1, pyloc "Pole diameter")
	controls.pole_dia = dialog:create_text_box(2, pyui.format_length(data.pole_radius * 2))
	local clockwise = dialog:create_check_box(3, pyloc "Clockwise")
	clockwise:set_control_checked(data.clockwise)
	local autocalc = dialog:create_check_box(4, pyloc "Auto Calc")
	autocalc:set_control_checked(data.autocalc)
	dialog:create_label(3, pyloc "Step Thickness")
	local step_thickness = dialog:create_text_box(4, pyui.format_length(data.step_thickness))
	dialog:create_label(3, pyloc "Total Angle")
	controls.total_angle = dialog:create_text_box(4, pyui.format_number(data.total_angle))

	dialog:create_group_box({3,4}, pyloc "Calculated values")
	dialog:create_label(3, pyloc "Riser")
	controls.riser = dialog:create_text_display(4, "")
	dialog:create_label(3, pyloc "Tread (min/avg/max)")
	controls.tread = dialog:create_text_display(4, "")
	dialog:create_label(3, pyloc "2*R + T")
	controls.measure = dialog:create_text_display(4, "")
	dialog:create_label(3, pyloc "Headroom")
	controls.headroom = dialog:create_text_display(4, "")
	dialog:end_group_box()
	
	local align1 = dialog:create_align({1, 2, 3, 4}) 
	dialog:create_group_box({1,2}, pyloc "Handrail")
	local label2 = dialog:create_label(1, pyloc "Shape")
	local hr_type = dialog:create_drop_list(2)
	hr_type:insert_control_item(pyloc "Round")
	hr_type:insert_control_item(pyloc "Square")
	hr_type:insert_control_item(pyloc "Line")
	hr_type:set_control_selection(data.handrail_type + 1)
	
	controls.hr_text = dialog:create_label(1, pyloc "lx, lz")
	controls.hr_dim = dialog:create_text_box(2, data.handrail_type == 0 and pyui.format_length(data.handrail_thickness) or pyui.format_length(data.handrail_width) .. "," .. pyui.format_length(data.handrail_thickness))
	controls.handrail_orientation = dialog:create_check_box({1,2}, pyloc "Upright")
	controls.handrail_orientation:set_control_checked(data.handrail_upright)
	
	dialog:end_group_box()

	local align1 = dialog:create_align({1,4}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(3)
	local cancel = dialog:create_cancel_button(4)
	
	dialog:equalize_column_widths({2,3,4})
	
	diameter:set_on_change_handler(function(text)
		data.diameter = math.max(pyui.parse_length(text) or data.diameter, 0)
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	controls.pole_dia:set_on_change_handler(function(text)
		data.pole_radius = math.max(pyui.parse_length(text) or data.pole_radius * 2, 0) / 2
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	
	total_height:set_on_change_handler(function(text)
		data.total_height = math.max(pyui.parse_length(text) or data.total_height, 500)
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	
	controls.steps:set_on_change_handler(function(text)
		data.steps = math.max(pyui.parse_number(text) or data.steps, 1)
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	
	step_thickness:set_on_change_handler(function(text)
		data.step_thickness = math.max(pyui.parse_length(text) or data.step_thickness, 0)
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	
	controls.total_angle:set_on_change_handler(function(text)
		data.total_angle = pyui.parse_number(text) or data.total_angle
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	
	controls.hr_dim:set_on_change_handler(function(text)
		local dims = {}
		dims = {pyui.parse_length(text)} or {data.handrail_width, data.handrail_thickness}
		if dims[2] == nil then 
			dims[2] = dims[1]
		end
		data.handrail_width = dims[1]
		data.handrail_thickness = dims[2]
		recreate_geometry(data)
	end)
	
	clockwise:set_on_click_handler(function(state)
		data.clockwise = state
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	
	autocalc:set_on_click_handler(function(state)
		data.autocalc = state
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	
	controls.handrail_orientation:set_on_click_handler(function(state)
		data.handrail_upright = state
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	
	hr_type:set_on_change_handler(function(text, new_index)
		data.handrail_type = new_index - 1
		controls.hr_dim:set_control_text(data.handrail_type == 0 and pyui.format_length(data.handrail_thickness) or pyui.format_length(data.handrail_width) .. "," .. pyui.format_length(data.handrail_thickness))
		recreate_geometry(data)
		update_ui(data, controls)
		
	end)
	update_ui(data, controls)
end

function update_ui(data, controls)
	controls.steps:enable_control(not data.autocalc)
	controls.total_angle:enable_control(not data.autocalc)
	if data.autocalc == true then 
		controls.steps:set_control_text(pyui.format_number(data.steps))
		controls.total_angle:set_control_text(pyui.format_number(data.total_angle))
	end
	
	controls.hr_dim:enable_control(data.handrail_type ~= 2)
	controls.hr_text:enable_control(data.handrail_type ~= 2)
	controls.handrail_orientation:enable_control(data.handrail_type ~= 2)
	controls.hr_text:set_control_text(data.handrail_type == 0 and pyloc "Diameter" or pyloc "lx, lz")
	controls.headroom:set_control_text(pyui.format_length(data.headroom))
	controls.measure:set_control_text(pyui.format_number(data.measure, 1))
	controls.riser:set_control_text(pyui.format_length(data.riser))
	controls.tread:set_control_text(pyui.format_length(data.tread[1]) .. "/" .. pyui.format_length(data.tread[2]) .. "/" .. pyui.format_length(data.tread[3]) .. "/")	--we do not want to display 3 decimals
end

function create_step(outer_radius, inner_radius, height, angle, base_height)
	local cross_sec = {}
	local x = 0
	local y = 0
	local z = base_height
	local segs = 12
	local phi = angle / segs	--the angular steps for the outside curvature
	local inner_segs = 36		
--the opening angle of a step is given from the center of the pole. However, the step has to be tangential to the cylinder
--this offset in angle is calculated here. delta phi is the angular difference
	local delta_phi = ASIN(math.min(inner_radius / outer_radius, 1)) 
	local inner_angle = 180 - angle + 2 * delta_phi	
	local phi2 = inner_angle / inner_segs	--the angular steps for the inside curvature

--here we create the points on the outside
	for i=0,segs,1 do
		x = outer_radius * COS(- angle / 2 + i * phi)
		y = outer_radius * SIN(- angle / 2 + i * phi)
		table.insert(cross_sec, {x, y,z})
	end
--here we create the points on the inside
	for i=0,inner_segs,1 do
		x = inner_radius * COS(90 + angle / 2 - delta_phi + i * phi2)
		y = inner_radius * SIN(90 + angle / 2 - delta_phi + i * phi2)
		table.insert(cross_sec, {x, y,z})
	end
--first we create a face, then a profile from the face and then we delete the original face
	local face_handle = pytha.create_polygon(cross_sec)
	local profile = pytha.create_profile(face_handle, height)[1]
	pytha.delete_element(face_handle)
--give back the handle of the profile.
	return profile
end

function recreate_geometry(data)
	local radius = data.diameter/2
	if data.autocalc == true then 
		--ideal values would be 170 riser and 290 tread
		local ideal_riser = 170
		local ideal_tread = 290
		local steprule = 630
		local ideal_step_number = data.total_height / ideal_riser
		local ideal_step_angle = 2 * ASIN(math.min(ideal_tread / (2 * (6/10 * (radius - data.pole_radius) + data.pole_radius)), 1))
		local rounded_step_angle = 360 / math.floor(360 / ideal_step_angle + 0.5)
		local real_tread = 2 * 6/10 * (radius - data.pole_radius) * SIN(rounded_step_angle / 2)
		local high_riser = data.total_height / math.floor(ideal_step_number)
		local low_riser = data.total_height / math.ceil(ideal_step_number)
		data.steps = math.abs(2*high_riser + real_tread - 630) < math.abs(2*low_riser + real_tread - 630) and math.floor(ideal_step_number) or math.ceil(ideal_step_number)
		data.total_angle = rounded_step_angle * data.steps
	end
	local step_height = data.total_height / data.steps	
	local pole_section_height = step_height - data.step_thickness	--height of the central pole pieces
	local outer_radius = radius + data.step_excess + data.vertical_bar_radius	--this is the actual radius of the individual steps
	local parts_collection = {}	--collection of all the individual parts except for the front rail bar 
	local handrail_offset = (data.handrail_type == 2 and 0 or data.handrail_thickness / 2)	-- the polyline is created at the handrail height, for the sweep it needs to be offset
	
	pytha.delete_element(data.cur_elements)
	data.cur_elements = {}

--we use a small angle approximation when calculating the opening angle of the individual steps to account for the vertical bar radius and the excess of the step at that position
	local pure_angle = data.total_angle / data.steps
	local step_angle = pure_angle + (180 / math.pi) * 2 * (data.step_excess + data.vertical_bar_radius) / outer_radius	
	data.headroom = step_height * (math.ceil(360 / pure_angle) - 1) - data.step_thickness
	
	local inner_line = 2 * (5/10 * (radius - data.pole_radius) + data.pole_radius) * SIN(pure_angle / 2) 
	local step_line = 2 * (6/10 * (radius - data.pole_radius) + data.pole_radius) * SIN(pure_angle / 2) 
	local outer_line = 2 * (7/10 * (radius - data.pole_radius) + data.pole_radius) * SIN(pure_angle / 2) 
	local unit, length_factor = pytha.get_length_unit() 

	data.measure = (2 * step_height + step_line) * length_factor * 100
	data.riser = step_height
	inner_line = math.floor(inner_line * length_factor * 1000 + 0.5) / length_factor / 1000	--round to mm precision for all units
	step_line = math.floor(step_line * length_factor * 1000 + 0.5) / length_factor / 1000		--round to mm precision for all units
	outer_line = math.floor(outer_line * length_factor * 1000 + 0.5) / length_factor / 1000	--round to mm precision for all units
	data.tread = {inner_line, step_line, outer_line}

	local step = create_step(outer_radius, data.pole_radius + data.step_excess, data.step_thickness, step_angle, pole_section_height)
	table.insert(data.cur_elements, step)


	local pole_segment = pytha.create_cylinder(pole_section_height, data.pole_radius, {0,0,0})
	table.insert(data.cur_elements, pole_segment)
	
--the rail bar at the front of a step is higher than the one in the center.
	local front_rail_bar = pytha.create_cylinder(data.rail_height - handrail_offset + step_height, data.vertical_bar_radius, {radius,0,0})
	table.insert(data.cur_elements, front_rail_bar)
	pytha.rotate_element(front_rail_bar, {0,0,0}, 'z', -0.5 * pure_angle)	--rotate the bar into its position

	--we calculate the necessary number of rail bars to have a maximum distance of 12cm inbetween each other.
	local intermediate_rail_number = math.ceil((pure_angle/2) / ASIN(math.min((120 + 2 * data.vertical_bar_radius) / (2* radius), 1)))
	for i = 1, intermediate_rail_number - 1 do 
		local rail_bar = pytha.create_cylinder(data.rail_height - handrail_offset + i / intermediate_rail_number * step_height, data.vertical_bar_radius, {radius,0,step_height})	--the central rail bar
		table.insert(data.cur_elements, rail_bar)
		table.insert(parts_collection, rail_bar)
		pytha.rotate_element(rail_bar, {0,0,0}, 'z', -0.5 * pure_angle + i * pure_angle / intermediate_rail_number)	--rotate the bar into its position
	end

	table.insert(parts_collection, step)
	table.insert(parts_collection, pole_segment)
--creation of the remaining steps.
	for i=1,data.steps - 1,1 do
		parts_collection = pytha.copy_element(parts_collection, {0,0,step_height})	--the return value contains the handles of the new parts. Therefore, the next iteration will copy those parts
			for k,v in pairs(parts_collection) do table.insert(data.cur_elements, v) end	--bring all new elements into the cur_elements. Copy always returns a table, even if it contains only one element.
			
		pytha.rotate_element(parts_collection, {0,0,0}, 'z', pure_angle)	
--the front rail bar is treated separately, as this part needs to be copied one more time on the final step, so we want to keep the handle for this part
		front_rail_bar = pytha.copy_element(front_rail_bar, {0,0,step_height})
			for k,v in pairs(front_rail_bar) do table.insert(data.cur_elements, v) end
		pytha.rotate_element(front_rail_bar, {0,0,0}, 'z', pure_angle)
		
	end
--here we do the final copy and rotation of the front rail bar on the last step.
	front_rail_bar = pytha.copy_element(front_rail_bar, {0,0,step_height})
	for k,v in pairs(front_rail_bar) do table.insert(data.cur_elements, v) end
	pytha.rotate_element(front_rail_bar, {0,0,0}, 'z', pure_angle)
--now we create the sweep line for the handrail
	local points = {}	--list of all point coordinates
	local segs = data.steps * 12	--total number of segments of the polyline, 12 per step, 6 inbetween each vertical bar
	local phi_off = 0.5 * pure_angle	--The line starts at the front of the first step, not in the center

--for the excess of the handrail we simply create 2 additional segments at the beginning and at the end of the polyline. This corressponds to 1/6 of the angle of a step
	for i=-2,segs+2,1 do		
		local x = radius * COS(data.total_angle * i / segs - phi_off)
		local y = radius * SIN(data.total_angle * i / segs - phi_off)
		local z = data.rail_height - handrail_offset + step_height  + i * data.total_height / (segs)
		table.insert(points, {x, y, z})
	end
	local rail_edges = pytha.create_polyline("open", points)	--create the polyline
	if data.handrail_type < 2 then
		local sweep_cross_section = {}
		local sweep_options = {keep_vertical = data.handrail_upright and 1 or 0}
		if data.handrail_type == 0 then
			sweep_cross_section = { type = "circle", radius = data.handrail_thickness / 2, segments = 18}	--data for the cross section of the handrail
		else 
			sweep_cross_section = { type = "rectangle", length = data.handrail_width, width = data.handrail_thickness}	--data for the cross section of the handrail
		end
		local rail = pytha.create_sweep(rail_edges, sweep_cross_section, sweep_options)[1]		--create the sweep
		table.insert(data.cur_elements, rail)
		pytha.delete_element(rail_edges)	--delete the line
	else 
		table.insert(data.cur_elements, rail_edges)
	end

	if data.clockwise == true then
		local dir = "y"
		pytha.mirror_element(data.cur_elements, {0,0,0}, dir)
	end
	local group = pytha.create_group(data.cur_elements)
	pytha.set_element_history(group, data, "spiral_stairs_history")
end

