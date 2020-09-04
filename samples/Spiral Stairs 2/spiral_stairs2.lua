--Example for a simple spiral staircase

function main()
	local data = {
		cur_elements = {},
		total_height = 4000,		--height of the stairs
		steps = 20,					--number of steps
		step_thickness = 40,		--board thickness ot the steps
		total_angle = 290,			--how much will the stairs wind? 360 is one full turn
		rail_height = 900,			--height of the rail, measured to the center of the rail handle
		diameter = 5000,			--diameter of the stairs to the center of the handrail. There is an additional offset (see outer_radius)
		width = 1200,
		sheet_thickness = 20,			--excess of the steps at the central pole and at the vertical rail bars
		clockwise = false,				--rotation direction
		outer_corner = nil,
		inner_corner = nil,
		third_point = nil,
		origin = {-5000,0,0},
		end_with_step = false
	}
--	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then data = loaded_data end
	recreate_geometry(data)
	
	pyui.run_modal_dialog(test_dialog, data)
	pyio.save_values("default_dimensions", data)
end

function test_dialog(dialog, data)
	dialog:set_window_title("Spiral Staircase")
	
	local label2 = dialog:create_label({1,3}, "Pick 3 points to calculate the staircase dimensions!")
	local button_ori = dialog:create_button(4, pyloc "Pick dimensions")
	local button_dir = nil --dialog:create_button(2, pyloc "Pick direction")
	local align1 = dialog:create_align({1,4})
	
	local label2 = dialog:create_label(1, "Total Height")
	local total_height = dialog:create_text_box(2, pyui.format_length(data.total_height))
	local label1 = dialog:create_label(1, "Diameter")
	local diameter = dialog:create_text_box(2, pyui.format_length(data.diameter))
	local label5 = dialog:create_label(3, "Width")
	local width = dialog:create_text_box(4, pyui.format_length(data.width))
	local label5 = dialog:create_label(3, "Angle")
	local total_angle = dialog:create_text_display(4, pyui.format_length(data.total_angle))
	
	dialog:create_label(1, "Step thickness")
	local step_thickness = dialog:create_text_box(2, pyui.format_length(data.step_thickness))
	
	local end_with_step = dialog:create_check_box({1,2}, "Step on final height")
	end_with_step:set_control_checked(data.end_with_step)
	
	dialog:create_label(3, "String thickness")
	local sheet_thickness = dialog:create_text_box(4, pyui.format_length(data.sheet_thickness))
	
	
	
--	local clockwise = dialog:create_check_box({3,4}, "Clockwise")

	local btn_frame = dialog:create_button({1,2}, "Material Frame")
	if data.material_glas == nil then 
		btn_glass = dialog:create_button({3,4}, "Material Glass")
	end
	local btn_steps = dialog:create_button({3,4}, "Material Steps")
	if data.material_steps then
		btn_steps:set_control_text(data.material_steps:get_name())
	else 
		btn_steps:set_control_text("Material Steps")
	end
	if data.material_frame then
		btn_frame:set_control_text(data.material_frame:get_name())
	else 
		btn_frame:set_control_text("Material Frame")
	end
	

	local align1 = dialog:create_align({1,4}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(3)
	local cancel = dialog:create_cancel_button(4)
	
	dialog:equalize_column_widths({3,4})
	
	
	
	button_ori:set_on_click_handler(function()
		-- Pick in graphics
		button_ori:disable_control()
		if data.cur_elements ~= nil then
			pytha.delete_element(data.cur_elements)
		end
		data.cur_elements = {}
	
		local ret_wert = pyux.select_coordinate(false, pyloc "Pick outer top corner")
		if ret_wert ~= nil then
			data.outer_corner = ret_wert
			pyux.highlight_coordinate(ret_wert)
		end
		ret_wert = pyux.select_coordinate(false, pyloc "Pick inner top corner")
		if ret_wert ~= nil then
			data.inner_corner = ret_wert
			pyux.highlight_coordinate(ret_wert)
			
			data.direction = {ret_wert[1] - data.outer_corner[1], ret_wert[2] - data.outer_corner[2], ret_wert[3] - data.outer_corner[3]}
			local dir_length = PYTHAGORAS(data.direction[1], data.direction[2], data.direction[3])
			data.direction[1] = data.direction[1] / dir_length
			data.direction[2] = data.direction[2] / dir_length
			data.direction[3] = data.direction[3] / dir_length
			data.width = dir_length
		else 
		end
		ret_wert = pyux.select_coordinate(false, pyloc "Pick outer bottom corner")
		if ret_wert ~= nil then
			data.third_point = ret_wert
			pyux.highlight_coordinate(ret_wert)
			data.total_height = data.outer_corner[3] - data.third_point[3]
			calc_center(data) 
			data.diameter = 2 * PYTHAGORAS(data.outer_corner[1] - data.origin[1], data.outer_corner[2] - data.origin[2])
		else 
		end
		
		total_height:set_control_text(pyui.format_length(data.total_height))
		diameter:set_control_text(pyui.format_length(data.diameter))
		width:set_control_text(pyui.format_length(data.width))
		pyux.clear_highlights()
		button_ori:enable_control()
		recreate_geometry(data, true)
		total_angle:set_control_text(pyui.format_length(data.total_angle))	--is calculated during geometry input, therefore refreshing afterwards
	end)
	
--	button_dir:set_on_click_handler(function()
--		-- Pick in graphics
--		button_dir:disable_control()
--		local ret_wert = pyux.select_coordinate()
--		if ret_wert ~= nil then
--			data.direction = {ret_wert[1] - data.origin[1], ret_wert[2] - data.origin[2], ret_wert[3] - data.origin[3]}
--			local dir_length = PYTHAGORAS(data.direction[1], data.direction[2], data.direction[3])
--			data.direction[1] = data.direction[1] / dir_length
--			data.direction[2] = data.direction[2] / dir_length
--			data.direction[3] = data.direction[3] / dir_length
--		end
--		button_dir:enable_control()
--		recreate_all(data, true)
--	end)
	
	
	
	sheet_thickness:set_on_change_handler(function(text)
		data.sheet_thickness = math.max(pyui.parse_length(text), 0)
		recreate_geometry(data)
	end)
	
	
	diameter:set_on_change_handler(function(text)
		data.diameter = math.max(pyui.parse_length(text), 1500)
		recreate_geometry(data)
	end)
	
	total_angle:set_on_change_handler(function(text)
		data.total_angle = pyui.parse_length(text) or data.total_angle 
		recreate_geometry(data)
	end)
	
	width:set_on_change_handler(function(text)
		data.width = math.max(pyui.parse_length(text), 100)
		recreate_geometry(data)
	end)
	
	btn_steps:set_on_click_handler(function()
		data.material_steps = pyux.select_material(data.material_steps)
		if data.material_steps then
			btn_steps:set_control_text(data.material_steps:get_name())
		else 
			btn_steps:set_control_text("Material Steps")
		end
		recreate_geometry(data)
	end)
	
	if data.material_glas == nil then 
		btn_glass:set_on_click_handler(function()
			data.material_glas = pyux.select_material(data.material_glas)
			if data.material_glas then
				btn_glass:set_control_text(data.material_glas:get_name())
			else 
				btn_glass:set_control_text("Material Glass")
			end
			recreate_geometry(data)
		end)
	end
	btn_frame:set_on_click_handler(function()
		data.material_frame = pyux.select_material(data.material_frame)
		if data.material_frame then
			btn_frame:set_control_text(data.material_frame:get_name())
		else 
			btn_frame:set_control_text("Material Frame")
		end
		recreate_geometry(data)
	end)
	
	
	total_height:set_on_change_handler(function(text)
		data.total_height = math.max(pyui.parse_length(text), 500)
		recreate_geometry(data)
	end)
	
	step_thickness:set_on_change_handler(function(text)
		data.step_thickness = math.max(pyui.parse_length(text), 0)
		recreate_geometry(data)
	end)
	end_with_step:set_on_click_handler(function(state)
		data.end_with_step = state
		recreate_geometry(data)
	end)
	
--	clockwise:set_on_click_handler(function(state)
--		data.clockwise = state
--		recreate_geometry(data)
--	end)
	
	
end


function create_step_base(outer_radius, inner_radius, height, angle, base_height)
	local cross_sec = {}
	local x = 0
	local y = 0
	local z = base_height
	local segs = 12
	local length = outer_radius - inner_radius
	local inner_angle = angle - (35) /inner_radius * 180 / math.pi
	local outer_angle = angle - (35) /outer_radius * 180 / math.pi
	local inner_phi = inner_angle / segs
	local outer_phi = outer_angle / segs

--here we create the points on the outside
	for i=0,segs,1 do
		x = outer_radius * COS(30 /outer_radius * 180 / math.pi + i * outer_phi)
		y = outer_radius * SIN(30 /outer_radius * 180 / math.pi + i * outer_phi)
		table.insert(cross_sec, {x, y,z})
	end
--here we create the points on the inside
	for i=segs,0,-1 do
		x = inner_radius * COS(30 /inner_radius * 180 / math.pi + i * inner_phi)
		y = inner_radius * SIN(30 /inner_radius * 180 / math.pi + i * inner_phi)
		table.insert(cross_sec, {x, y,z})
	end
	
--first we create a face, then a profile from the face and then we delete the original face
	local face_handle = pytha.create_polygon(cross_sec)
	local profile = pytha.create_profile(face_handle, height)[1]
	pytha.delete_element(face_handle)
--give back the handle of the profile.
	return profile
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
		x = outer_radius * COS(i * phi)
		y = outer_radius * SIN(i * phi)
		table.insert(cross_sec, {x, y,z})
	end
--here we create the points on the inside
	for i=segs,0,-1 do
		x = inner_radius * COS(i * phi)
		y = inner_radius * SIN(i * phi)
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

function recreate_geometry(data)
	local outer_radius = data.diameter / 2	--this is the actual radius of the individual steps
	local inner_radius = outer_radius - data.width	
	
	local clockwise = data.clockwise
	local additional_step = 0
	if data.end_with_step == false then
		additional_step = 1
	end
	
	--firstly calculate number of steps, depending on the total height
	data.steps = math.floor(data.total_height / 180 + 0.5)	--round to next integer
	local step_height = data.total_height / (data.steps + additional_step) 	--as close as possible to 180mm
	
	local radius_of_walking = (outer_radius - inner_radius) * 2 / 3		--at 2/3 of the stair width
	local step_length = 630 - 2 * step_height
	local approximate_angle = ATAN(step_length / radius_of_walking)
	--now we can get this angle to giving a full number of steps on 360 deg
	local step_angle = 360 / math.floor(360 / approximate_angle + 0.5) 
	data.total_angle = data.steps * step_angle
	
	if data.outer_corner ~= nil and data.inner_corner ~= nil and data.third_point ~= nil then
		local dir_cross = {-data.direction[2], data.direction[1]}
		local u_dist = (data.third_point[1] - data.origin[1]) * data.direction[1] + (data.third_point[2] - data.origin[2]) * data.direction[2]	--scalar product
		local v_dist = (data.third_point[1] - data.origin[1]) * dir_cross[1] + (data.third_point[2] - data.origin[2]) * dir_cross[2]	--scalar product
		local total_angle1 = calculate_angle(u_dist, v_dist)
		total_angle1 = 180 - total_angle1
		if total_angle1 < 0 then total_angle1 = total_angle1 + 360 end
		
		local total_angle2 = 360 - total_angle1
		
		local step_angle1 = total_angle1 / data.steps
		local step_angle2 = total_angle2 / data.steps
		
		if math.abs(total_angle1 - data.total_angle) < math.abs(total_angle2 - data.total_angle) then 
			data.total_angle = total_angle1
			clockwise = false
		else 
			data.total_angle = total_angle2
			clockwise = true
		end
		step_angle = data.total_angle / data.steps
	end




	local pole_section_height = step_height - data.step_thickness	--height of the central pole pieces
	if data.cur_elements ~= nil then
		pytha.delete_element(data.cur_elements)
	end
	data.cur_elements = {}


	local step = create_step(outer_radius - 65, inner_radius + data.sheet_thickness/2 + 5, data.step_thickness, step_angle, pole_section_height)
	if data.material_steps ~= nil then pytha.set_element_material(step, data.material_steps) end
	table.insert(data.cur_elements, step)
	
	local step_base = create_step_base(outer_radius - 30, inner_radius + data.sheet_thickness/2, data.step_thickness, step_angle, pole_section_height - data.step_thickness)
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
	local height_increment = step_height / 12
	local phi_off = 0 --0.5 * data.total_angle / data.steps	--The line starts at the front of the first step, not in the center

--for the excess of the handrail we simply create 2 additional segments at the beginning and at the end of the polyline. This corressponds to 1/6 of the angle of a step
	for i=0,segs,1 do		
		local x = (outer_radius - 30) * COS(data.total_angle * i / segs - phi_off)
		local y = (outer_radius - 30) * SIN(data.total_angle * i / segs - phi_off)
		local z = data.rail_height + step_height + i * height_increment
		table.insert(points, {x, y, z})
		z = 50 + i * height_increment	--this is the negative position of the outer steel construction
		table.insert(points2, {x, y, z})
	end
	local rail_edges = pytha.create_polyline("open", points)	--create the polyline
	local rail_edges2 = pytha.create_polyline("open", points2)	--create the polyline

	local sweep_cross_section = {type = "rectangle", length = 60, width = 40} --data for the cross section of the handrail
	local sweep_options = {keep_vertical = 1}

	local rail = pytha.create_sweep(rail_edges, sweep_cross_section, sweep_options)[1]		--create the sweep
	if data.material_steps ~= nil then pytha.set_element_material(rail, data.material_steps) end
	pytha.delete_element(rail_edges)	--delete the line
	table.insert(data.cur_elements, rail)
	
	sweep_cross_section = {type = "rectangle", length = 60, width = 400} --data for the cross section of the handrail
	sweep_options = {keep_vertical = 1}

--	local rail2 = pytha.create_sweep(rail_edges2, sweep_cross_section, sweep_options)[1]		--create the sweep
--	if data.material_frame ~= nil then pytha.set_element_material(rail2, data.material_frame) end
	pytha.delete_element(rail_edges2)	--delete the line
--	local front_parts = pytha.cut_element(rail2, {0,0,0}, "z", {type = "keep_front"})
--			for k,v in pairs(front_parts) do table.insert(data.cur_elements, v) end
--	pytha.delete_element(rail2)


	for i=0,segs,1 do		
		local x = inner_radius * COS(data.total_angle * i / segs - phi_off)
		local y = inner_radius * SIN(data.total_angle * i / segs - phi_off)
		local z = data.rail_height / 2 - 200 + step_height + i * height_increment	--this is the negative position of the outer steel construction
		table.insert(inner_points, {x, y, z})

	end

	for i=1,segs-1,1 do		
		
		x = (outer_radius - 30) * COS(data.total_angle * i / segs - phi_off)
		y = (outer_radius - 30) * SIN(data.total_angle * i / segs - phi_off)
		z = (data.rail_height + step_height - 20 -100) / 2 + i * height_increment	--this is the negative position of the outer steel construction
		table.insert(points3, {x, y, z})
	end
	local inner_rail_edges = pytha.create_polyline("open", inner_points)	--create the polyline

	sweep_cross_section = {type = "rectangle", length = data.sheet_thickness, width = data.rail_height + 400 + step_height} --data for the inner cross section
	sweep_options = {keep_vertical = 1}

	rail = pytha.create_sweep(inner_rail_edges, sweep_cross_section, sweep_options)[1]		--create the sweep
	if data.material_frame ~= nil then pytha.set_element_material(rail, data.material_frame) end
	pytha.delete_element(inner_rail_edges)	--delete the line
	
	front_parts = pytha.cut_element(rail, {0,0,0}, "z", {type = "keep_front"})
			for k,v in pairs(front_parts) do table.insert(data.cur_elements, v) end
	pytha.delete_element(rail)


	rail_edges = pytha.create_polyline("open", points3)	--create the polyline

	sweep_cross_section = {type = "rectangle", length = 10, width = data.rail_height + step_height - 20 + 100} 
	sweep_options = {keep_vertical = 1}
	rail = pytha.create_sweep(rail_edges, sweep_cross_section, sweep_options)[1]		--create the sweep
	if data.material_glas ~= nil then pytha.set_element_material(rail, data.material_glas) end
	pytha.delete_element(rail_edges)	--delete the line
	table.insert(data.cur_elements, rail)
	

	if clockwise == true then
		local dir = "y"
		pytha.mirror_element(data.cur_elements, {0,0,0}, dir)
	end
	local group = pytha.create_group(data.cur_elements, {name = "Spiral staircase"})
	group:rotate_element({0,0,0}, 'z', -data.total_angle)
	group:move_element(data.origin)
end

function calc_center(data)

	local i = 0
	local u0 = data.outer_corner[1] - data.third_point[1]
	local v0 = data.outer_corner[2] - data.third_point[2]
	
	i = (-u0 * u0 - v0 * v0) / 2 /  (data.direction[1] * u0 + data.direction[2] * v0)
	
	data.origin = {data.outer_corner[1] + i * data.direction[1], data.outer_corner[2] + i * data.direction[2], data.third_point[3]}

end

function calculate_angle(dx, dy)
	local Phi
	if math.abs(dx) < 1e-8 and math.abs(dy) < 1e-8 then 
		return 0
	end
	if math.abs(dx) < 1e-8 then 
		if dy > 0 then
			Phi = 90.0
		else 
			Phi = 270.0
		end
	else
		if math.abs(dy) < 1e-8 then 
			if dx > 0.0 then
				Phi = 0.0
			else
				Phi = 180.0
			end
		else
			Phi = ATAN(dy / dx)
			if dx < 0 then 
				Phi = Phi + 180.0
			end
			Phi = math.fmod((Phi + 360.0), 360.0)
		end
	end
	return Phi
end


