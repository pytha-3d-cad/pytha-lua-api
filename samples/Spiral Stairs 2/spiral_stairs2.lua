--Example for a simple spiral staircase

function main()
	local data = {
		cur_elements = {},
		total_height = 2640,		--height of the stairs
		steps = 20,					--number of steps
		step_thickness = 40,		--board thickness ot the steps
		total_angle = 290,			--how much will the stairs wind? 360 is one full turn
		rail_height = 900,			--height of the rail, measured to the center of the rail handle
		diameter = 2400,			--diameter of the stairs to the center of the handrail. There is an additional offset (see outer_radius)
		inner_diameter = 800,			--diameter of the stairs to the center of the handrail. There is an additional offset (see outer_radius)
		sheet_thickness = 10,			--excess of the steps at the central pole and at the vertical rail bars
		clockwise = false,				--rotation direction

	}
	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then data = loaded_data end
	recreate_geometry(data)
	
	pyui.run_modal_dialog(test_dialog, data)
	pyio.save_values("default_dimensions", data)
end

function test_dialog(dialog, data)
	dialog:set_window_title("Spiral Staircase")
	if data.material_steps == nil then 
		btn_steps = dialog:create_button({1,2}, "Material Steps")
	end
	if data.material_glas == nil then 
		btn_glass = dialog:create_button({3,4}, "Material Glass")
	end
	if data.material_frame == nil then 
		btn_frame = dialog:create_button({1,2}, "Material Frame")
	end
	local align1 = dialog:create_align({1,4}) -- So that OK and Cancel will be in the same row
	
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

	local align1 = dialog:create_align({3,4}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(3)
	local cancel = dialog:create_cancel_button(4)
	
	dialog:equalize_column_widths({3,4})
	
	diameter:set_on_change_handler(function(text)
		data.diameter = pyui.parse_length(text)
		recreate_geometry(data)
	end)
	
	
	if data.material_steps == nil then 
		btn_steps:set_on_click_handler(function()
			data.material_steps = pyio.select_material(data.material_steps)
			if data.material_steps then
				btn_steps:set_control_text(data.material_steps:get_name())
			end
			recreate_geometry(data)
		end)
	end
	
	if data.material_glas == nil then 
		btn_glass:set_on_click_handler(function()
			data.material_glas = pyio.select_material(data.material_glas)
			if data.material_glas then
				btn_glass:set_control_text(data.material_glas:get_name())
			end
			recreate_geometry(data)
		end)
		end
	if data.material_frame == nil then 
		btn_frame:set_on_click_handler(function()
			data.material_frame = pyio.select_material(data.material_frame)
			if data.material_frame then
				btn_frame:set_control_text(data.material_frame:get_name())
			end
			recreate_geometry(data)
		end)
	end
	
	
	
	
	
	
	
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
	
	
end


function create_step(outer_radius, inner_radius, height, angle, base_height)
	local cross_sec = {}
	local x = 0
	local y = 0
	local z = base_height
	local segs = 12
	local phi = angle / segs	--the angular steps for the outside curvature
--here we create the points on the outside
	for i=0,segs,1 do
		x = outer_radius * COS(- angle / 2 + i * phi)
		y = outer_radius * SIN(- angle / 2 + i * phi)
		table.insert(cross_sec, {x, y,z})
	end
--here we create the points on the inside
	for i=segs,0,-1 do
		x = inner_radius * COS(- angle / 2 + i * phi)
		y = inner_radius * SIN(- angle / 2 + i * phi)
		table.insert(cross_sec, {x, y,z})
	end
--first we create a face, then a profile from the face and then we delete the original face
	local face_handle = pytha.create_polygon(cross_sec)
	local profile = pytha.create_profile(face_handle, height)[1]
	pytha.delete_element(face_handle)
	pytha.create_element_ref_point(profile, {inner_radius, 0, base_height + height})
	pytha.create_element_ref_point(profile, {outer_radius, 0, base_height + height})
--give back the handle of the profile.
	return profile
end


function create_step_base(outer_radius, inner_radius, height, angle, base_height)
	local cross_sec = {}
	local x = 0
	local y = 0
	local z = base_height
	local segs = 12
	local length = outer_radius - inner_radius
	local inner_angle = angle - (5 + height) /inner_radius * 180 / math.pi
	local outer_angle = angle - (5 + height) /outer_radius * 180 / math.pi
	local inner_phi = inner_angle / segs
	local outer_phi = outer_angle / segs

--here we create the points on the outside
	for i=0,segs,1 do
		x = outer_radius * COS(- angle / 2 + height /outer_radius * 180 / math.pi + i * outer_phi)
		y = outer_radius * SIN(- angle / 2 + height /outer_radius * 180 / math.pi + i * outer_phi)
		table.insert(cross_sec, {x, y,z})
	end
--here we create the points on the inside
	for i=segs,0,-1 do
		x = inner_radius * COS(- angle / 2 + height /inner_radius * 180 / math.pi + i * inner_phi)
		y = inner_radius * SIN(- angle / 2 + height /inner_radius * 180 / math.pi + i * inner_phi)
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
	local outer_radius = data.diameter / 2	--this is the actual radius of the individual steps
	if data.cur_elements ~= nil then
		pytha.delete_element(data.cur_elements)
	end
	data.cur_elements = {}

	local step_angle = data.total_angle / data.steps

	local step = create_step(outer_radius - 35, data.inner_diameter / 2 + 10, data.step_thickness, step_angle, pole_section_height)
	if data.material_steps ~= nil then pytha.set_element_material(step, data.material_steps) end
	table.insert(data.cur_elements, step)
	
	local step_base = create_step_base(outer_radius, data.inner_diameter / 2, data.step_thickness, step_angle, pole_section_height - data.step_thickness)
	if data.material_frame ~= nil then pytha.set_element_material(step_base, data.material_frame) end
	table.insert(data.cur_elements, step_base)
	
	
--the rail bar at the front of a step is higher than the one in the center.

	local parts_collection = {}	--collection of all the individual parts except for the front rail bar 
	table.insert(parts_collection, step)
	table.insert(parts_collection, step_base)
--creation of the remaining steps.
	for i=1,data.steps - 1,1 do
		parts_collection = pytha.copy_element(parts_collection, {0,0,step_height})	--the return value contains the handles of the new parts. Therefore, the next iteration will copy those parts
			for k,v in pairs(parts_collection) do table.insert(data.cur_elements, v) end	--bring all new elements into the cur_elements. Copy always returns a table, even if it contains only one element.
			
		pytha.rotate_element(parts_collection, {0,0,0}, 'z', data.total_angle / data.steps)			
	end
--now we create the sweep line for the handrail
	local points = {}	--list of all point coordinates for the hand rail 
	local points2 = {}	--list of all point coordinates for the glass railing
	local points3 = {}	--list of all point coordinates for the glass railing
	local inner_points = {}	--list of all point coordinates for the hand rail 
	local segs = data.steps * 12	--total number of segments of the polyline, 12 per step, 6 inbetween each vertical bar
	local phi_off = 0.5 * data.total_angle / data.steps	--The line starts at the front of the first step, not in the center

--for the excess of the handrail we simply create 2 additional segments at the beginning and at the end of the polyline. This corressponds to 1/6 of the angle of a step
	for i=-2,segs+2,1 do		
		local x = data.diameter / 2 * COS(data.total_angle * i / segs - phi_off)
		local y = data.diameter / 2 * SIN(data.total_angle * i / segs - phi_off)
		local z = data.rail_height + step_height  + i * data.total_height / (segs)
		table.insert(points, {x, y, z})
		z = i * data.total_height / (segs)	--this is the negative position of the outer steel construction
		table.insert(points2, {x, y, z})
	end
	local rail_edges = pytha.create_polyline("open", points)	--create the polyline
	local rail_edges2 = pytha.create_polyline("open", points2)	--create the polyline

	local sweep_cross_section = {type = "rectangle", length = 60, width = 40} --data for the cross section of the handrail
	local sweep_options = {keep_vertical = 0}

	local rail = pytha.create_sweep(rail_edges, sweep_cross_section, sweep_options)[1]		--create the sweep
	if data.material_steps ~= nil then pytha.set_element_material(rail, data.material_steps) end
	pytha.delete_element(rail_edges)	--delete the line
	table.insert(data.cur_elements, rail)
	
	sweep_cross_section = {type = "rectangle", length = 60, width = 400} --data for the cross section of the handrail
	sweep_options = {keep_vertical = 1}

	local rail2 = pytha.create_sweep(rail_edges2, sweep_cross_section, sweep_options)[1]		--create the sweep
	if data.material_frame ~= nil then pytha.set_element_material(rail2, data.material_frame) end
	pytha.delete_element(rail_edges2)	--delete the line
	local front_parts = pytha.cut_element(rail2, {0,0,0}, "z", {type = "keep_front"})
			for k,v in pairs(front_parts) do table.insert(data.cur_elements, v) end
	pytha.delete_element(rail2)



	for i=-1,segs + 1,1 do		
		local x = data.inner_diameter / 2 * COS(data.total_angle * i / segs - phi_off)
		local y = data.inner_diameter / 2 * SIN(data.total_angle * i / segs - phi_off)
		local z = data.rail_height / 2 - 200 + step_height + i * data.total_height / (segs)	--this is the negative position of the outer steel construction
		table.insert(inner_points, {x, y, z})
		
		x = data.diameter / 2 * COS(data.total_angle * i / segs - phi_off)
		y = data.diameter / 2 * SIN(data.total_angle * i / segs - phi_off)
		z = (data.rail_height + step_height - 20 + 200) / 2 + i * data.total_height / (segs)	--this is the negative position of the outer steel construction
		table.insert(points3, {x, y, z})
	end
	local inner_rail_edges = pytha.create_polyline("open", inner_points)	--create the polyline

	sweep_cross_section = {type = "rectangle", length = 10, width = data.rail_height + 400 + step_height} --data for the inner cross section
	sweep_options = {keep_vertical = 1}

	rail = pytha.create_sweep(inner_rail_edges, sweep_cross_section, sweep_options)[1]		--create the sweep
	if data.material_frame ~= nil then pytha.set_element_material(rail, data.material_frame) end
	pytha.delete_element(inner_rail_edges)	--delete the line
	
	front_parts = pytha.cut_element(rail, {0,0,0}, "z", {type = "keep_front"})
			for k,v in pairs(front_parts) do table.insert(data.cur_elements, v) end
	pytha.delete_element(rail)



	rail_edges = pytha.create_polyline("open", points3)	--create the polyline

	sweep_cross_section = {type = "rectangle", length = 10, width = data.rail_height + step_height - 20 - 200} --data for the inner cross section
	sweep_options = {keep_vertical = 1}
	rail = pytha.create_sweep(rail_edges, sweep_cross_section, sweep_options)[1]		--create the sweep
	if data.material_glas ~= nil then pytha.set_element_material(rail, data.material_glas) end
	pytha.delete_element(rail_edges)	--delete the line
	table.insert(data.cur_elements, rail)
	
	

	if data.clockwise == true then
		local dir = "y"
		pytha.mirror_element(data.cur_elements, {0,0,0}, dir)
	end
	pytha.group_elements(data.cur_elements)
end

