--Example for a simple spiral staircase

function main()
	local data = {
		cur_elements = {},
		total_height = 2640,		--height of the stairs
		steps = 12,					--number of steps
		step_thickness = 40,		--board thickness ot the steps
		pole_radius = 75,			--radius of the central pole
		total_angle = 360,			--how much will the stairs wind? 360 is one full turn
		rail_height = 900,			--height of the rail, measured to the center of the rail handle
		vertical_bar_radius = 4,	--radius of the vertical railing bars 
		diameter = 1600,			--diameter of the stairs to the center of the handrail. There is an additional offset (see outer_radius)
		step_excess = 10,			--excess of the steps at the central pole and at the vertical rail bars
		clockwise = false,				--rotation direction
		handrail_type = 0,			--cross section of handrail: line, round, square
	}
	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then data = loaded_data end
	recreate_geometry(data)
	
	pyui.run_modal_dialog(test_dialog, data)
	pyio.save_values("default_dimensions", data)
end

function test_dialog(dialog, data)
	dialog:set_window_title("Spiral Staircase")
	
	local label2 = dialog:create_label(1, "Total Height")
	local total_height = dialog:create_text_box(2, pyui.format_length(data.total_height))
	local label1 = dialog:create_label(1, "Diameter")
	local diameter = dialog:create_text_box(2, pyui.format_length(data.diameter))
	local label3 = dialog:create_label(1, "No. of steps")
	local steps = dialog:create_text_box(2, pyui.format_length(data.steps))
	local label4 = dialog:create_label(3, "Step Thickness")
	local step_thickness = dialog:create_text_box(4, pyui.format_length(data.step_thickness))
	local label5 = dialog:create_label(3, "Total Angle")
	local total_angle = dialog:create_text_box(4, pyui.format_length(data.total_angle))
	
	local clockwise = dialog:create_check_box({3,4}, "Clockwise")
	local align1 = dialog:create_align({1, 2, 3, 4}) 
	local label2 = dialog:create_label(1, "Handrail type")
	local radio1 = dialog:create_radio_button(2, "Round")
	local radio2 = dialog:create_linked_radio_button(3, "Square")
	local radio3 = dialog:create_linked_radio_button(4, "Line")

	local align1 = dialog:create_align({3,4}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(3)
	local cancel = dialog:create_cancel_button(4)
	
	dialog:equalize_column_widths({3,4})
	
	diameter:set_on_change_handler(function(text)
		data.diameter = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	total_height:set_on_change_handler(function(text)
		data.total_height = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	steps:set_on_change_handler(function(text)
		data.steps = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	step_thickness:set_on_change_handler(function(text)
		data.step_thickness = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	total_angle:set_on_change_handler(function(text)
		data.total_angle = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	clockwise:set_on_click_handler(function(state)
		data.clockwise = state
		recreate_geometry(data)
	end)
	
	radio1:set_on_click_handler(function(state)
		data.handrail_type = 0
		recreate_geometry(data)
	end)
	radio2:set_on_click_handler(function(state)
		data.handrail_type = 1
		recreate_geometry(data)
	end)
	radio3:set_on_click_handler(function(state)
		data.handrail_type = 2
		recreate_geometry(data)
	end)
	
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
	local delta_phi = ASIN(inner_radius / outer_radius) 
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
	local step_height = data.total_height / data.steps	
	local pole_section_height = step_height - data.step_thickness	--height of the central pole pieces
	local outer_radius = data.diameter / 2 + data.step_excess + data.vertical_bar_radius	--this is the actual radius of the individual steps
	pytha.delete_element(data.cur_elements)
	data.cur_elements = {}

--we use a small angle approximation when calculating the opening angle of the individual steps to account for the vertical bar radius and the excess of the step at that position
	local step_angle = data.total_angle / data.steps + (180 / math.pi) * 2 * (data.step_excess + data.vertical_bar_radius) / outer_radius	

	local step = create_step(outer_radius, data.pole_radius + data.step_excess, data.step_thickness, step_angle, pole_section_height)
	table.insert(data.cur_elements, step)
	local pole_segment = pytha.create_cylinder(pole_section_height, data.pole_radius, {0,0,0})
	table.insert(data.cur_elements, pole_segment)
	
--the rail bar at the front of a step is higher than the one in the center.
	local front_rail_bar = pytha.create_cylinder(data.rail_height + step_height, data.vertical_bar_radius, {data.diameter / 2,0,0})
	table.insert(data.cur_elements, front_rail_bar)
	pytha.rotate_element(front_rail_bar, {0,0,0}, 'z', -0.5 * data.total_angle / data.steps)	--rotate the bar into its position

	local rail_bar = pytha.create_cylinder(data.rail_height + step_height / 2, data.vertical_bar_radius, {data.diameter / 2,0,step_height})	--the central rail bar
	table.insert(data.cur_elements, rail_bar)

	local parts_collection = {}	--collection of all the individual parts except for the front rail bar 
	table.insert(parts_collection, step)
	table.insert(parts_collection, pole_segment)
	table.insert(parts_collection, rail_bar)
--creation of the remaining steps.
	for i=1,data.steps - 1,1 do
		parts_collection = pytha.copy_element(parts_collection, {0,0,step_height})	--the return value contains the handles of the new parts. Therefore, the next iteration will copy those parts
			for k,v in pairs(parts_collection) do table.insert(data.cur_elements, v) end	--bring all new elements into the cur_elements. Copy always returns a table, even if it contains only one element.
			
		pytha.rotate_element(parts_collection, {0,0,0}, 'z', data.total_angle / data.steps)	
--the front rail bar is treated separately, as this part needs to be copied one more time on the final step, so we want to keep the handle for this part
		front_rail_bar = pytha.copy_element(front_rail_bar, {0,0,step_height})
			for k,v in pairs(front_rail_bar) do table.insert(data.cur_elements, v) end
		pytha.rotate_element(front_rail_bar, {0,0,0}, 'z', data.total_angle / data.steps)
		
	end
--here we do the final copy and rotation of the front rail bar on the last step.
	front_rail_bar = pytha.copy_element(front_rail_bar, {0,0,step_height})
			for k,v in pairs(front_rail_bar) do table.insert(data.cur_elements, v) end
	pytha.rotate_element(front_rail_bar, {0,0,0}, 'z', data.total_angle / data.steps)
--now we create the sweep line for the handrail
	local points = {}	--list of all point coordinates
	local segs = data.steps * 12	--total number of segments of the polyline, 12 per step, 6 inbetween each vertical bar
	local phi_off = 0.5 * data.total_angle / data.steps	--The line starts at the front of the first step, not in the center

--for the excess of the handrail we simply create 2 additional segments at the beginning and at the end of the polyline. This corressponds to 1/6 of the angle of a step
	for i=-2,segs+2,1 do		
		local x = data.diameter / 2 * COS(data.total_angle * i / segs - phi_off)
		local y = data.diameter / 2 * SIN(data.total_angle * i / segs - phi_off)
		local z = data.rail_height + step_height  + i * data.total_height / (segs)
		table.insert(points, {x, y, z})
	end
	local rail_edges = pytha.create_polyline("open", points)	--create the polyline
	if data.handrail_type < 2 then
		local sweep_cross_section = {}
		local sweep_options = {keep_vertical = 1}
		if data.handrail_type == 0 then
			sweep_cross_section = { type = "circle", radius = 21.2, segments = 18}	--data for the cross section of the handrail
		else 
			sweep_cross_section = { type = "rectangle", length = 60, width = 40}	--data for the cross section of the handrail
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
	pytha.create_group(data.cur_elements)
end

