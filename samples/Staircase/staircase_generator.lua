--Example for a simple spiral staircase

function edit_stairs(element)
	loaded_data = pytha.get_element_history(element, "stairs_history")
	if loaded_data == nil then
		pyui.alert(pyloc "No data found")
		return 
	end
	recreate_geometry(loaded_data)
	pyui.run_modal_dialog(make_dialog, loaded_data)
	pyio.save_values("default_dimensions", loaded_data)
end

function main()
	local data = {
		cur_elements = {},
		shape = 1,					--0: straight, 1: L shaped
		pedestal = false,
		total_height = 2640,		--height of the stairs
		steps = 18,					--number of steps
		step_thickness = 60,		--board thickness ot the steps
		rail_height = 900,			--height of the rail, measured to the center of the rail handle
		total_width = 1120,					
		width = 1000,	
		inner_diameter = 600,			--diameter of the stairs to the center of the handrail. There is an additional offset (see outer_radius)
		sheet_thickness = 10,			--excess of the steps at the central pole and at the vertical rail bars
		l_shape_left = false,				--rotation direction
		calculation_type = 0,		-- 0 for step number 
		slope = 17 / 29,
		step_height = 170,
		step_length = 290,
		gehlaenge = 0,
		min_inner_step_width = 100,	
		b_factor = 2^0.25,
		stringer_left = 1, 
		stringer_right = 1, 
		stringer_thickness = 60, 
		stringer_top_over = 50, 
		stringer_bottom_over = 80, 
		inner_radius = 0,
		outer_radius = 0,
		segs_per_step = 12,
		opening_length = 3000,
		second_length = nil,
		origin = {0,0,0},
		direction = {1,0,0},
		pedestal_length = 2.5,
		outer_corner = {0,0,0},
		inner_corner = {1120,0,0},
		third_point = nil,
		fourth_point = nil,
		picked_length = false,

	}
--	local loaded_data = pyio.load_values("default_dimensions")
--	if loaded_data ~= nil then data = loaded_data end
	data.steps = math.floor(data.total_height / data.step_height + 0.5)
	data.step_height = data.total_height / data.steps
	data.step_length = 630 - 2 * data.step_height
	data.gehlaenge = data.step_length * (data.steps - 1)
	pyui.run_modal_dialog(make_dialog, data)
	pyio.save_values("default_dimensions", data)
end

function make_dialog(dialog, data)
	local controls = {}

	dialog:set_window_title("Staircase Generator")
	
	controls.btn_straight = dialog:create_label({1,2}, "Define geometry of staircase")
	local button_outer_points = dialog:create_button({3,4}, "Via outer points")
	controls.fold_box_shape = dialog:create_group_box({1,4}, "Shape")
	controls.btn_straight = dialog:create_radio_button(1, "Straight")
	controls.btn_l_shaped = dialog:create_linked_radio_button(2, "L-shaped")
	controls.l_shape_left = dialog:create_check_box(3, "Turn left")
	controls.l_shape_left:set_control_checked(data.l_shape_left)
	controls.check_pedestal = dialog:create_check_box(4, "With pedestal")
	controls.check_pedestal:set_control_checked(data.pedestal)
	dialog:end_group_box()
	
	dialog:create_group_box({1,4}, "Dimensions")
	
	dialog:create_label(1, "Floor Height")
	controls.total_height = dialog:create_text_box(2, pyui.format_length(data.total_height))
	local label1 = dialog:create_label(3, "Width")
	controls.width = dialog:create_text_box(4, pyui.format_length(data.width))
	dialog:create_label(1, "Ceiling width")
	controls.ceil_opening = dialog:create_text_box(2, pyui.format_length(data.opening_length))
	
	local label4 = dialog:create_label(3, "Step number")
	controls.step_number = dialog:create_text_spin(4, pyui.format_length(data.steps))
	controls.picked_length = dialog:create_check_box({1,2}, "Length via picked points")
	controls.picked_length:set_control_checked(data.picked_length)
	controls.step_height_label = dialog:create_label(3, "Step height")
	controls.step_height = dialog:create_text_display(4, pyui.format_length(data.step_height))
	controls.step_length_label = dialog:create_label(3, "Step depth")
	controls.step_length = dialog:create_text_display(4, pyui.format_length(data.step_length))
	dialog:end_group_box()
	
	controls.fold_box_input_type = dialog:create_foldable_group_box({1,4}, "Details")
	dialog:create_label(1, "Step thickness")
	step_thickness = dialog:create_text_box(2, pyui.format_length(data.step_thickness))
	
	dialog:create_label(3, "String thickness")
	stringer_thickness = dialog:create_text_box(4, pyui.format_length(data.stringer_thickness))
	
	dialog:create_label(1, "String margin top")
	stringer_top_over = dialog:create_text_box(2, pyui.format_length(data.stringer_top_over))
	dialog:create_label(3, "String margin bottom")
	stringer_bottom_over = dialog:create_text_box(4, pyui.format_length(data.stringer_bottom_over))
	
	dialog:create_label(1, "Inner circular join")
	inner_radius = dialog:create_text_box(2, pyui.format_length(data.inner_radius))
	
	
	dialog:end_group_box()
	
--	local button_top_point = dialog:create_button(1, "Pick top point")
--	local button_corner_point = dialog:create_button(2, "Pick corner")
--	local button_bottom_point = dialog:create_button(3, "Pick bottom")
	
	local align1 = dialog:create_align({1,4}) 
	

	local align1 = dialog:create_align({1,4}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(3)
	local cancel = dialog:create_cancel_button(4)
	
	dialog:equalize_column_widths({2,4})
	controls.fold_box_input_type:set_control_checked(true)
	controls.fold_box_input_type:set_control_checked(false)
-----------------------------------------------------


	
	button_outer_points:set_on_click_handler(function()
		-- Pick in graphics
		button_outer_points:disable_control()
		if data.main_group ~= nil then
			pytha.delete_element(pytha.get_group_members(data.main_group))
		end
		data.cur_elements = {}
		data.main_group = nil
	
		local ret_wert = pyux.select_coordinate(false, pyloc "Pick outer top corner")
		if ret_wert ~= nil then
			data.outer_corner = ret_wert
			pyux.highlight_coordinate(ret_wert)
		else 
			button_outer_points:enable_control()
			pyux.clear_highlights()
			return
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
			data.total_width = dir_length
		else 
			button_outer_points:enable_control()
			pyux.clear_highlights()
			return
		end
		local text = pyloc "Pick pedestal corner"
		if data.shape == 0 then 
			text = pyloc "Pick bottom corner"
		end
		ret_wert = pyux.select_coordinate(false, text)
		local sign = 1
		if ret_wert ~= nil then
			data.third_point = ret_wert
			pyux.highlight_coordinate(ret_wert)
			local vector = {ret_wert[1] - data.outer_corner[1], ret_wert[2] - data.outer_corner[2]}
			local perp_dir = {-data.direction[2], data.direction[1]}
			data.opening_length = vector[1] * perp_dir[1] + vector[2] * perp_dir[2]
			if data.shape == 0 then 
				data.total_height = data.outer_corner[3] - data.third_point[3]
			end
			
			sign = 1
			if data.opening_length > 0 then 
				sign = -1 
				if data.shape == 0 then 
					local aux_p = {data.outer_corner[1], data.outer_corner[2], data.outer_corner[3]}
					data.outer_corner = {data.inner_corner[1], data.inner_corner[2], data.inner_corner[3]}
					data.inner_corner = {aux_p[1], aux_p[2], aux_p[3]}
					data.direction = {-data.direction[1], -data.direction[2], -data.direction[3]}
				end
			end
			data.opening_length = math.abs(data.opening_length)
			
			
		else 
			button_outer_points:enable_control()
			pyux.clear_highlights()
			return
		end
		if data.shape ~= 0 then 
			ret_wert = pyux.select_coordinate(false, pyloc "Pick outer bottom corner")
			if ret_wert ~= nil then
				data.fourth_point = ret_wert
				pyux.highlight_coordinate(ret_wert)
				
				data.second_length = (ret_wert[1] - data.outer_corner[1]) * data.direction[1] + (ret_wert[2] - data.outer_corner[2]) * data.direction[2]
				
					
				if data.second_length < 0 then 
					local aux_p = {data.outer_corner[1], data.outer_corner[2], data.outer_corner[3]}
					data.outer_corner = {data.inner_corner[1], data.inner_corner[2], data.inner_corner[3]}
					data.inner_corner = {aux_p[1], aux_p[2], aux_p[3]}
					data.direction = {-data.direction[1], -data.direction[2], -data.direction[3]}
					data.second_length = data.second_length - data.total_width
				end
				if sign * data.second_length < 0 then
					data.l_shape_left = true
				else 
					data.l_shape_left = false
				end
				data.second_length = math.abs(data.second_length)
				
				data.total_height = data.outer_corner[3] - data.fourth_point[3]

			else 
				data.second_length = nil
				button_outer_points:enable_control()
				pyux.clear_highlights()
				return
			end
		end
		data.steps = math.floor(data.total_height / data.step_height + 0.5)
		data.step_height = data.total_height / data.steps
		
		
		pyux.clear_highlights()
		button_outer_points:enable_control()
		recreate_all(data, controls)
		controls.total_height:set_control_text(pyui.format_length(data.total_height))
		controls.ceil_opening:set_control_text(pyui.format_length(data.opening_length))
		controls.width:set_control_text(pyui.format_length(data.width))
		controls.l_shape_left:set_control_checked(data.l_shape_left)
	end)


	controls.btn_straight:set_on_click_handler(function()
		data.shape = 0
		recreate_all(data, controls)
	end)
	controls.btn_l_shaped:set_on_click_handler(function()
		data.shape = 1
		recreate_all(data, controls)
	end)
	
	controls.l_shape_left:set_on_click_handler(function(state)
		data.l_shape_left = state
		
		local aux_p = {data.outer_corner[1], data.outer_corner[2], data.outer_corner[3]}
		data.outer_corner = {data.inner_corner[1], data.inner_corner[2], data.inner_corner[3]}
		data.inner_corner = {aux_p[1], aux_p[2], aux_p[3]}
		data.direction = {-data.direction[1], -data.direction[2], -data.direction[3]}
					
		recreate_all(data, controls)
	end)
	
	
	controls.picked_length:set_on_click_handler(function(state)
		data.picked_length = state
		recreate_all(data, controls)
	end)
	
	controls.check_pedestal:set_on_click_handler(function(state)
		data.pedestal = state
		recreate_all(data, controls)
	end)
	
	controls.total_height:set_on_change_handler(function(text)
		data.total_height = math.max(pyui.parse_length(text), 500)
		data.steps = math.floor(data.total_height / data.step_height + 0.5)
		data.step_height = data.total_height / data.steps
		recreate_all(data, controls)
	end)
	
	controls.step_number:set_on_change_handler(function(text)
		data.steps = math.max(math.floor(pyui.parse_length(text)), 1)
		data.step_height = data.total_height / data.steps
		recreate_all(data, controls)
	end)
	
	controls.ceil_opening:set_on_change_handler(function(text)
		data.opening_length = math.max(pyui.parse_length(text), 0)
		recreate_all(data, controls)
	end)
	
	step_thickness:set_on_change_handler(function(text)
		data.step_thickness = math.max(pyui.parse_length(text), 0)
		recreate_all(data, controls)
	end)
	
	stringer_thickness:set_on_change_handler(function(text)
		data.stringer_thickness = math.max(pyui.parse_length(text), 0)
		recreate_all(data, controls)
	end)
	
	stringer_top_over:set_on_change_handler(function(text)
		data.stringer_top_over = math.max(pyui.parse_length(text), 0)
		recreate_all(data, controls)
	end)
	
	stringer_bottom_over:set_on_change_handler(function(text)
		data.stringer_bottom_over = math.max(pyui.parse_length(text), 0)
		recreate_all(data, controls)
	end)
	
	inner_radius:set_on_change_handler(function(text)
		data.inner_radius = math.max(pyui.parse_length(text), 0)
		recreate_all(data, controls)
	end)
	
	controls.width:set_on_change_handler(function(text)
		data.width = math.max(pyui.parse_length(text), 0)
		recreate_all(data, controls)
	end)
	recreate_all(data, controls)
	
end
function calculate_gehlaenge(data)
	data.radius = data.width / 2
	
	if data.shape == 0 then
		if data.picked_length == true then 
			data.step_length = data.opening_length / (data.steps - 1)
			data.gehlaenge = data.opening_length
		else
			data.step_length = 630 - 2 * data.step_height
			data.gehlaenge = data.step_length * (data.steps - 1)
		end
	else
		--pedestal calculates the number of steps from the height and fits in the pedestal size depending on the number of steps
		if data.pedestal == false then 
			if data.picked_length == true and data.second_length ~= nil then 
				data.outer_arm_length_out = data.opening_length - data.stringer_thickness
				
				data.outer_arm_length_in = data.second_length - data.stringer_thickness
				data.inner_arm_length_out = data.outer_arm_length_out - data.width
				data.inner_arm_length_in = data.outer_arm_length_in - data.width
				data.gehlaenge = data.inner_arm_length_out + data.inner_arm_length_in  + data.radius * math.pi / 2
				data.step_length = data.gehlaenge / (data.steps - 1)
			else 
				data.step_length = 630 - 2 * data.step_height
				data.gehlaenge = data.step_length * (data.steps - 1)
				data.outer_arm_length_out = math.min(data.opening_length - data.stringer_thickness, data.gehlaenge)
				data.inner_arm_length_out = data.outer_arm_length_out - data.width
				data.inner_arm_length_in = data.gehlaenge - data.radius * math.pi / 2 - data.inner_arm_length_out
				data.outer_arm_length_in = data.inner_arm_length_in + data.width
			end
		end
	end
end


function recreate_all(data, controls)

	recreate_geometry(data)
	update_ui(data, controls)

end
function update_ui(data, controls)
	

	if data.shape == 0 then 
		controls.btn_straight:set_control_checked(true)
--		controls.check_pedestal:disable_control()
	else 
		controls.btn_l_shaped:set_control_checked(true)
	end
	if data.second_length ~= nil or data.shape == 0 then
		controls.picked_length:enable_control()
	else 
		controls.picked_length:disable_control()
	end
	controls.step_height:set_control_text(pyui.format_length(data.step_height))
	controls.step_length:set_control_text(pyui.format_length(data.step_length))
	controls.step_number:set_control_text(pyui.format_length(data.steps))

end



function recreate_geometry(data)

	if data.main_group ~= nil then
		pytha.delete_element(pytha.get_group_members(data.main_group))
	end
	data.cur_elements = {}
	data.main_group = nil
	if data.outer_corner ~= nil then 
		data.origin = {data.outer_corner[1], data.outer_corner[2], data.outer_corner[3]}
	end
	data.width = data.total_width - 2 * data.stringer_thickness
	calculate_gehlaenge(data)
	if data.shape == 0 then
		straight_stairs(data)
	else  
		if data.pedestal == true then 
			pedestal_angled_stairs(data, data.l_shape_left)
		else
			angled_stairs(data, data.l_shape_left)
		end
	end
	
	data.main_group = pytha.create_group(data.cur_elements)
	pytha.set_element_history(data.main_group, data, "stairs_history")

	local placement_angle = calculate_angle(data.direction[1], data.direction[2])
	if data.l_shape_left == true then 
		pytha.rotate_element(data.main_group, {0,0,0}, 'z', 180 + placement_angle)
	else
		pytha.rotate_element(data.main_group, {0,0,0}, 'z', placement_angle)
	end
	pytha.move_element(data.main_group, {data.origin[1], data.origin[2], data.origin[3] - data.total_height})
end

function straight_stairs(data)
	local p_aussenwange = {}
	table.insert(p_aussenwange, {0, -data.stringer_thickness, (- data.stringer_thickness / data.step_length + 1) * data.step_height + data.stringer_top_over})
	for i = 1,data.steps - 1,1 do
		local z = i * data.step_height - data.step_thickness
		local aussen = {{0,(i-1) * data.step_length, z}, {data.width,(i-1) * data.step_length, z},{data.width, i * data.step_length, z},{0, i * data.step_length, z}}
		local fla_handle = pytha.create_polygon(aussen)
		local profile = pytha.create_profile(fla_handle, data.step_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		table.insert(data.cur_elements, profile)
	end	
	
	table.insert(p_aussenwange, {0, (data.steps - 1) * data.step_length + data.stringer_thickness, (data.steps + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
	
	fla_table = {}
	for i, k in pairs(p_aussenwange) do
		table.insert(fla_table, p_aussenwange[i])
	end
	for i = #p_aussenwange,1,-1 do
		table.insert(fla_table, {p_aussenwange[i][1], p_aussenwange[i][2], p_aussenwange[i][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness})
	end
	if data.stringer_thickness > 0 then
		local fla_handle = pytha.create_polygon(fla_table)
		local profile = pytha.create_profile(fla_handle, data.stringer_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		profile = pytha.cut_element(profile, {0,0,0}, {0,0,1}, {type = "keep_front"})[1]
		table.insert(data.cur_elements, profile)
		profile = pytha.copy_element(profile, {data.width + data.stringer_thickness, 0, 0})[1]
		table.insert(data.cur_elements, profile)
	end	

	pytha.move_element(data.cur_elements, {data.stringer_thickness, -(data.steps - 1) * data.step_length, 0})


end

function angled_stairs(data, left_handed)

	local mid_step = (data.inner_arm_length_in + data.radius * math.pi / 4) / data.step_length
	local erste_verzogene_stufe = math.max(math.ceil((data.inner_arm_length_in - 3.5 * data.step_length) / data.step_length) + 1, 1)
	local letzte_verzogene_stufe = math.min(math.floor((data.inner_arm_length_in + data.radius * math.pi / 2 + 3.5 * data.step_length) / data.step_length) + 1, data.steps + 1)
	
--erster Schenkel
	local upper_i = math.ceil(mid_step) + 1	-- +1 da Vorderkante bei i=0 beginnt
	local lower_i = upper_i - 1
	
	local lower_j = math.floor(mid_step) + 1
	local upper_j = lower_j + 1	--fuer zweiten Schenkel
	
	local gl_punkte = {}
	
	for i = 0,data.steps,1 do
		table.insert(gl_punkte, get_gehlinien_punkt(data, i))
	end
	local proj_x_wert = gl_punkte[letzte_verzogene_stufe][1]
	local proj_y_wert = gl_punkte[erste_verzogene_stufe][2]
	local aux_inner_midpoint_radius = data.radius * data.min_inner_step_width / (data.step_length - data.min_inner_step_width) 
	local aux_inner_midpoint = {data.width + aux_inner_midpoint_radius * math.sqrt(2) / 2, data.inner_arm_length_in - aux_inner_midpoint_radius * math.sqrt(2) / 2}
	
	local rel_len_in = (data.width - gl_punkte[lower_i][1]) / (aux_inner_midpoint[1] - gl_punkte[lower_i][1])
	local P1_in = {data.width, gl_punkte[lower_i][2] + rel_len_in * (aux_inner_midpoint[2] - gl_punkte[lower_i][2])}
	rel_len_in = (data.inner_arm_length_in - gl_punkte[upper_i][2]) / (aux_inner_midpoint[2] - gl_punkte[upper_i][2])
	local P2_in = {gl_punkte[upper_i][1] + rel_len_in * (aux_inner_midpoint[1] - gl_punkte[upper_i][1]), data.inner_arm_length_in}
	
	rel_len_in = (proj_y_wert - gl_punkte[lower_i][2]) / (P1_in[2] - gl_punkte[lower_i][2])
	local P1_in_proj = {gl_punkte[lower_i][1] + rel_len_in * (P1_in[1] - gl_punkte[lower_i][1]), proj_y_wert}
	rel_len_in = (proj_y_wert - gl_punkte[upper_i][2]) / (P2_in[2] - gl_punkte[upper_i][2])
	local P2_in_proj = {gl_punkte[upper_i][1] + rel_len_in * (P2_in[1] - gl_punkte[upper_i][1]), proj_y_wert}
	local beta_in = P1_in_proj[1] - P2_in_proj[1]
	
	
	local rel_len_out = (data.inner_arm_length_in - gl_punkte[upper_j][2]) / (aux_inner_midpoint[2] - gl_punkte[upper_j][2])
	local P1_out = {gl_punkte[upper_j][1] + rel_len_out * (aux_inner_midpoint[1] - gl_punkte[upper_j][1]), data.inner_arm_length_in}
	rel_len_out = (data.width - gl_punkte[lower_j][1]) / (aux_inner_midpoint[1] - gl_punkte[lower_j][1])
	local P2_out = {data.width, gl_punkte[lower_j][2] + rel_len_out * (aux_inner_midpoint[2] - gl_punkte[lower_j][2])}
	
	rel_len_out = (proj_x_wert - gl_punkte[upper_j][1]) / (P1_out[1] - gl_punkte[upper_j][1])
	local P1_out_proj = {proj_x_wert, gl_punkte[upper_j][2] + rel_len_out * (P1_out[2] - gl_punkte[upper_j][2])}
	rel_len_out = (proj_x_wert - gl_punkte[lower_j][1]) / (P2_out[1] - gl_punkte[lower_j][1])
	P2_out_proj = {proj_x_wert, gl_punkte[lower_j][2] + rel_len_out * (P2_out[2] - gl_punkte[lower_j][2])}
	local beta_out = P1_out_proj[2] - P2_out_proj[2]
	
	local slope = 0
	local p_innen = {}
	local p_aussen = {}
	local i_counter = 0
	for i = 0,mid_step,1 do
		local verziehungs_i = lower_i - i - 1
		local P_proj = {P1_in_proj[1] + verziehungs_i * beta_in, proj_y_wert}		--hier den b_factor mit berücksichtigen
		slope = (P_proj[2] - gl_punkte[i + 1][2]) / (P_proj[1] - gl_punkte[i + 1][1])
		slope = math.min(0, slope)	-- damit werden die Fälle bei step < erste_verzogene stufe berücksichtigt
		if gl_punkte[i + 1][2] + slope * (data.width - gl_punkte[i + 1][1]) <= data.inner_arm_length_in - data.inner_radius  or data.inner_radius <= data.stringer_thickness then	
			table.insert(p_innen, {data.width, gl_punkte[i + 1][2] + slope * (data.width - gl_punkte[i + 1][1])})	-- in der Krümmung ist with - gl_punkte nicht mehr nur radius
		else --falls inner radius == 0 wird der Fall hier nie erreicht...
			table.insert(p_innen, {data.width + data.inner_radius, gl_punkte[i + 1][2] + slope * (data.width + data.inner_radius - gl_punkte[i + 1][1])})
		end
		table.insert(p_aussen, {0, gl_punkte[i + 1][2] - slope * gl_punkte[i + 1][1]})
		i_counter = i
	end 
	for i = i_counter + 1,data.steps,1 do
		local verziehungs_i = i - upper_j + 1
		local P_proj = {proj_x_wert, P1_out_proj[2] + verziehungs_i * beta_out}		--hier den b_factor mit berücksichtigen
		slope = (P_proj[1] - gl_punkte[i + 1][1]) / (P_proj[2] - gl_punkte[i + 1][2])		-- slope ist hier dx/dy, um senkrechte kanten zu vermeiden.
		slope = math.min(0, slope)	-- damit werden die Fälle bei step < erste_verzogene stufe berücksichtigt
		if gl_punkte[i + 1][1] + slope * (data.inner_arm_length_in - gl_punkte[i + 1][2]) >= data.width + data.inner_radius then	
			table.insert(p_innen, {gl_punkte[i + 1][1] + slope * (data.inner_arm_length_in - gl_punkte[i + 1][2]), data.inner_arm_length_in})	-- in der Krümmung ist with - gl_punkte nicht mehr nur radius
		else --falls inner radius == 0 wird der Fall hier nie erreicht...
			table.insert(p_innen, {gl_punkte[i + 1][1] + slope * (data.inner_arm_length_in - data.inner_radius - gl_punkte[i + 1][2]), data.inner_arm_length_in - data.inner_radius})
		end
		table.insert(p_aussen, {gl_punkte[i + 1][1] + slope * (data.outer_arm_length_in - gl_punkte[i + 1][2]), data.outer_arm_length_in})	
	end 
	
	local p_aussenwange = {}
	local z = 0
	local test_p = {}
	local bool_profile = nil
	if data.stringer_left == 1 then
		table.insert(p_aussenwange, {0, -data.stringer_thickness, (- data.stringer_thickness / data.step_length + 1) * data.step_height + data.stringer_top_over})
		for i = 0,mid_step + 1 / data.segs_per_step,1 / data.segs_per_step do
			i = math.min(mid_step, i)
			local delta_x_off = 0
			z = (i + 1) * data.step_height + data.stringer_top_over
			local verziehungs_i = lower_i - i - 1
			local P_proj = {P1_in_proj[1] + verziehungs_i * beta_in, proj_y_wert}		--hier den b_factor mit berücksichtigen
			slope = (P_proj[2] - get_gehlinien_punkt(data, i)[2]) / (P_proj[1] - get_gehlinien_punkt(data, i)[1])
			slope = math.min(0, slope)	-- damit werden die Fälle bei step < erste_verzogene stufe berücksichtigt
			if i > math.floor(mid_step) then --garantiert dass mid_step - floor(mid_step) > 0
				local slope_out = -1	--hier korrigieren wenn Treppenbreiten unterschiedlich sind, vorerst ein Hack...
				local P_proj_final = {P1_in_proj[1] + (lower_i - mid_step - 1) * beta_in, proj_y_wert}		--hier den b_factor mit berücksichtigen
				local slope_in = (P_proj_final[2] - get_gehlinien_punkt(data, mid_step)[2]) / (P_proj_final[1] - get_gehlinien_punkt(data, mid_step)[1])
				local delta_x = (slope_in - slope_out) * get_gehlinien_punkt(data, mid_step)[1]
				local x = (i - math.floor(mid_step)) / ((mid_step - math.floor(mid_step)))
				delta_x_off = delta_x * x^2--x^2 ist eine gute Taylorentwicklung erster Ordnung für eine Krümmung...
			end 
			table.insert(p_aussenwange, {0, get_gehlinien_punkt(data, i)[2] - slope * get_gehlinien_punkt(data, i)[1] + delta_x_off, z})
		end 
		table.insert(p_aussenwange, {0, data.outer_arm_length_in, (mid_step + 1) * data.step_height + data.stringer_top_over})
		
	
--		local rail_edges = pytha.create_polyline("open", p_aussenwange)	--create the polyline
--		local cross_sec = pytha.create_rectangle(data.stringer_thickness, data.step_height + data.stringer_top_over + data.stringer_bottom_over + data.step_thickness,
--							{p_aussenwange[1][1], p_aussenwange[1][2], p_aussenwange[1][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness}, {w_axis = {0,-1,0}})
--		local sweep_options = {keep_vertical = 1}

--		local rail = pytha.create_sweep(rail_edges, cross_sec, sweep_options)[1]		--create the sweep

		local fla_table = {}
		for i, k in pairs(p_aussenwange) do
			table.insert(fla_table, p_aussenwange[i])
		end
		for i = #p_aussenwange,1,-1 do
			table.insert(fla_table, {p_aussenwange[i][1], p_aussenwange[i][2], p_aussenwange[i][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness})
		end	
					
		local fla_handle = pytha.create_polygon(fla_table)
		local profile = pytha.create_profile(fla_handle, data.stringer_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		profile = pytha.cut_element(profile, {0,0,0}, {0,0,1}, {type = "keep_front"})[1]
		table.insert(data.cur_elements, profile)
		
		p_aussenwange = {}
	
		table.insert(p_aussenwange, {- data.stringer_thickness, data.outer_arm_length_in, (mid_step + 1) * data.step_height + data.stringer_top_over})
		for i = mid_step,data.steps - 1,1 / data.segs_per_step do
			local delta_x_off = 0
			z = (i + 1) * data.step_height + data.stringer_top_over
			local verziehungs_i = i - upper_j + 1
			local P_proj = {proj_x_wert, P1_out_proj[2] + verziehungs_i * beta_out}		--hier den b_factor mit berücksichtigen
			slope = (P_proj[1] - get_gehlinien_punkt(data, i)[1]) / (P_proj[2] - get_gehlinien_punkt(data, i)[2])		-- slope ist hier dx/dy, um senkrechte kanten zu vermeiden.
			slope = math.min(0, slope)	-- damit werden die Fälle bei step < erste_verzogene stufe berücksichtigt
			if i < math.ceil(mid_step) then		--garantiert dass ceil(mid_step) - mid_step > 0
				local slope_in = -1	--hier korrigieren wenn Treppenbreiten unterschiedlich sind, vorerst ein Hack...
				local P_proj_final = {proj_x_wert, P1_out_proj[2] + (mid_step - upper_j + 1) * beta_out}		--hier den b_factor mit berücksichtigen
				local slope_out = (P_proj_final[1] - get_gehlinien_punkt(data, mid_step)[1]) / (P_proj_final[2] - get_gehlinien_punkt(data, mid_step)[2])
				local delta_x = (slope_in - slope_out) * (data.outer_arm_length_in - get_gehlinien_punkt(data, mid_step)[2])
				local x = (math.ceil(mid_step) - i) / (math.ceil(mid_step) - mid_step)
				delta_x_off = delta_x * x^2	
			end 
			table.insert(p_aussenwange, {get_gehlinien_punkt(data, i)[1] + slope * (data.outer_arm_length_in - get_gehlinien_punkt(data, i)[2]) + delta_x_off, data.outer_arm_length_in, z})	

		end 
		table.insert(p_aussenwange, {data.outer_arm_length_out, data.outer_arm_length_in, (data.steps) * data.step_height + data.stringer_top_over})
		table.insert(p_aussenwange, {data.outer_arm_length_out + data.stringer_thickness, data.outer_arm_length_in, (data.steps + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
		
		
		local fla_table = {}
		for i, k in pairs(p_aussenwange) do
			table.insert(fla_table, p_aussenwange[i])
		end
		for i = #p_aussenwange,1,-1 do
			table.insert(fla_table, {p_aussenwange[i][1], p_aussenwange[i][2], p_aussenwange[i][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness})
		end
		
		local fla_handle = pytha.create_polygon(fla_table)
		profile = pytha.create_profile(fla_handle, data.stringer_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		table.insert(data.cur_elements, profile)
	end

	p_aussenwange = {}
	local bool_profile_base = {}
	local first_z_adaption = 0
	local last_z_adaption = 0
	if data.stringer_right == 1 then
		table.insert(p_aussenwange, {data.width, -data.stringer_thickness, (- data.stringer_thickness / data.step_length + 1) * data.step_height + data.stringer_top_over})
		for i = 0,mid_step + 1 / data.segs_per_step,1 / data.segs_per_step do	--we want to guarantee that the end point is hit, therefore +1 iteration with min statement
			i = math.min(mid_step, i)
			local delta_x_off = 0
			z = (i + 1) * data.step_height + data.stringer_top_over
			local verziehungs_i = lower_i - i - 1
			local P_proj = {P1_in_proj[1] + verziehungs_i * beta_in, proj_y_wert}		--hier den b_factor mit berücksichtigen
			slope = (P_proj[2] - get_gehlinien_punkt(data, i)[2]) / (P_proj[1] - get_gehlinien_punkt(data, i)[1])			
			slope = math.min(0, slope)	-- damit werden die Fälle bei step < erste_verzogene stufe berücksichtigt
			local P_proj_final = {P1_in_proj[1] + (lower_i - mid_step - 1) * beta_in, proj_y_wert}		--hier den b_factor mit berücksichtigen
			local slope_in = (P_proj_final[2] - get_gehlinien_punkt(data, mid_step)[2]) / (P_proj_final[1] - get_gehlinien_punkt(data, mid_step)[1])
			if i > math.floor(mid_step) and data.inner_radius <= data.stringer_thickness then --garantiert dass mid_step - floor(mid_step) > 0
				local slope_out = -1	--hier korrigieren wenn Treppenbreiten unterschiedlich sind, vorerst ein Hack...
				local slope_in = (P_proj_final[2] - get_gehlinien_punkt(data, mid_step)[2]) / (P_proj_final[1] - get_gehlinien_punkt(data, mid_step)[1])
				local delta_x = (slope_in - slope_out) * (data.width - get_gehlinien_punkt(data, mid_step)[1])
				local x = (i - math.floor(mid_step)) / ((mid_step - math.floor(mid_step)))
				delta_x_off = delta_x * x^2
			end 
			if data.inner_radius <= data.stringer_thickness or get_gehlinien_punkt(data, i)[2] + slope * (data.width - get_gehlinien_punkt(data, i)[1]) - delta_x_off <= data.inner_arm_length_in - data.inner_radius then
				table.insert(p_aussenwange, {data.width, get_gehlinien_punkt(data, i)[2] + slope * (data.width - get_gehlinien_punkt(data, i)[1]) - delta_x_off, z})
			else 
				if first_z_adaption == 0 then first_z_adaption = #p_aussenwange + 1 end
				local intersection_P = inters_line_circ(slope, get_gehlinien_punkt(data, i), {data.width + data.inner_radius, data.inner_arm_length_in - data.inner_radius}, data.inner_radius)
				local angle = math.atan(intersection_P[2] - data.inner_arm_length_in + data.inner_radius, intersection_P[1] - data.width - data.inner_radius)
				local intersection_mid_P = inters_line_circ(slope_in, get_gehlinien_punkt(data, mid_step), {data.width + data.inner_radius, data.inner_arm_length_in - data.inner_radius}, data.inner_radius)
				local intersection_angle = math.atan(intersection_mid_P[2] - data.inner_arm_length_in + data.inner_radius, intersection_mid_P[1] - data.width - data.inner_radius)
				local angle_final = .75 * math.pi		--hier den b_factor mit berücksichtigen
				local delta_alpha = angle_final - intersection_angle
				local x = (math.pi - angle) / (math.pi - intersection_angle)
				delta_alpha_off = delta_alpha * x^2
				
				table.insert(p_aussenwange, {data.width + data.inner_radius * (1 + math.cos(angle + delta_alpha_off)), data.inner_arm_length_in + data.inner_radius * (-1 + math.sin(angle + delta_alpha_off)), z})
			
			end
		end 
		
		if data.inner_radius > data.stringer_thickness then
			for i,k in pairs(p_aussenwange) do 
				table.insert(bool_profile_base, {k[1], k[2], 0})	--bottom over to avoid fringe cases
			end
		end
		
		local fla_table = {}
		for i, k in pairs(p_aussenwange) do
			table.insert(fla_table, {p_aussenwange[i][1], p_aussenwange[i][2], p_aussenwange[i][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness})
		end
		for i = #p_aussenwange,1,-1 do
			table.insert(fla_table, p_aussenwange[i])
		end	
			
		if data.inner_radius <= data.stringer_thickness then		
			local fla_handle = pytha.create_polygon(fla_table)
			local profile = pytha.create_profile(fla_handle, data.stringer_thickness, {type = "straight"})[1]
			profile = pytha.cut_element(profile, {0,0,0}, {0,0,1}, {type = "keep_front"})[1]
			if data.inner_radius > data.stringer_thickness then
				profile = pytha.cut_element(profile, {0,data.inner_arm_length_in - data.inner_radius,0}, {0,1,0}, {type = "keep_back"})[1]
			end
			pytha.delete_element(fla_handle)
			table.insert(data.cur_elements, profile)

			p_aussenwange = {}
		end
		for i = mid_step,data.steps - 1,1 / data.segs_per_step do
			z = (i + 1) * data.step_height + data.stringer_top_over
			local delta_x_off = 0
			local verziehungs_i = i - upper_j + 1
			local P_proj = {proj_x_wert, P1_out_proj[2] + verziehungs_i * beta_out}		--hier den b_factor mit berücksichtigen
			slope = (P_proj[1] - get_gehlinien_punkt(data, i)[1]) / (P_proj[2] - get_gehlinien_punkt(data, i)[2])		-- slope ist hier dx/dy, um senkrechte kanten zu vermeiden.
			slope = math.min(0, slope)	-- damit werden die Fälle bei step < erste_verzogene stufe berücksichtigt
			local P_proj_final = {proj_x_wert, P1_out_proj[2] + (mid_step - upper_j + 1) * beta_out}		--hier den b_factor mit berücksichtigen
			local slope_out = (P_proj_final[1] - get_gehlinien_punkt(data, mid_step)[1]) / (P_proj_final[2] - get_gehlinien_punkt(data, mid_step)[2])
			if i < math.ceil(mid_step) then		--garantiert dass ceil(mid_step) - mid_step > 0
				local slope_in = -1	--hier korrigieren wenn Treppenbreiten unterschiedlich sind, vorerst ein Hack...
				local delta_x = (slope_in - slope_out) * (data.inner_arm_length_in - get_gehlinien_punkt(data, mid_step)[2])
				local x = (math.ceil(mid_step) - i) / (math.ceil(mid_step) - mid_step)
				delta_x_off = delta_x * x^2
			end 
			if data.inner_radius <= data.stringer_thickness or get_gehlinien_punkt(data, i)[1] + slope * (data.inner_arm_length_in - get_gehlinien_punkt(data, i)[2]) + delta_x_off >= data.width + data.inner_radius then
				table.insert(p_aussenwange, {get_gehlinien_punkt(data, i)[1] + slope * (data.inner_arm_length_in - get_gehlinien_punkt(data, i)[2]) + delta_x_off, data.inner_arm_length_in, z})	
			else 
				last_z_adaption = #p_aussenwange + 1
				if  i ~= mid_step then
					local intersection_P = inters_line_circ(1 / slope, get_gehlinien_punkt(data, i), {data.width + data.inner_radius, data.inner_arm_length_in - data.inner_radius}, data.inner_radius)
					local angle = math.atan(intersection_P[2] - data.inner_arm_length_in + data.inner_radius, intersection_P[1] - data.width - data.inner_radius)
					local intersection_mid_P = inters_line_circ(1 / slope_out, get_gehlinien_punkt(data, mid_step), {data.width + data.inner_radius, data.inner_arm_length_in - data.inner_radius}, data.inner_radius)
					local intersection_angle = math.atan(intersection_mid_P[2] - data.inner_arm_length_in + data.inner_radius, intersection_mid_P[1] - data.width - data.inner_radius)
					local angle_final = .75 * math.pi		--hier den b_factor mit berücksichtigen
					local delta_alpha = intersection_angle - angle_final
					local x = (angle - math.pi / 2) / (intersection_angle - math.pi / 2)
					delta_alpha_off = delta_alpha * x^2
					
					table.insert(p_aussenwange, {data.width + data.inner_radius * (1 + math.cos(angle - delta_alpha_off)), data.inner_arm_length_in + data.inner_radius * (-1 + math.sin(angle - delta_alpha_off)), z})
				end
			end
			
		end 
		table.insert(p_aussenwange, {data.outer_arm_length_out, data.inner_arm_length_in, (data.steps) * data.step_height + data.stringer_top_over})
		table.insert(p_aussenwange, {data.outer_arm_length_out + data.stringer_thickness, data.inner_arm_length_in, (data.steps + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
		
		if first_z_adaption > 0 and last_z_adaption > 0 then
			for i = first_z_adaption, last_z_adaption, 1 do
				local initial_slope = p_aussenwange[first_z_adaption + 1][3] - p_aussenwange[first_z_adaption][3]
				local end_slope = p_aussenwange[last_z_adaption][3] - p_aussenwange[last_z_adaption - 1][3]
				local initial_angle = math.atan(p_aussenwange[first_z_adaption][2] - data.inner_arm_length_in + data.inner_radius, p_aussenwange[first_z_adaption][1] - data.width - data.inner_radius)
				local end_angle = math.atan(p_aussenwange[last_z_adaption][2] - data.inner_arm_length_in + data.inner_radius, p_aussenwange[last_z_adaption][1] - data.width - data.inner_radius)
				
				local dist = last_z_adaption - first_z_adaption + 1
				local angle = math.atan(p_aussenwange[i][2] - data.inner_arm_length_in + data.inner_radius, p_aussenwange[i][1] - data.width - data.inner_radius)
				local x = (angle - initial_angle) / (end_angle - initial_angle)--(i - first_z_adaption) / dist
				local smootherstep = x * x * x * (x * (x * 6 - 15) + 10)
				local z_new = (1 - smootherstep) * (p_aussenwange[first_z_adaption][3] + initial_slope * (i - first_z_adaption)) + smootherstep * (p_aussenwange[last_z_adaption][3] + end_slope * (i - last_z_adaption))
				p_aussenwange[i][3] = z_new
			end
		end
		
		
		
		if data.inner_radius > data.stringer_thickness then
			local rail_edges = pytha.create_polyline("open", p_aussenwange)	--create the polyline
			local rect = pytha.create_rectangle(data.stringer_thickness, data.step_height + data.stringer_top_over + data.stringer_bottom_over + data.step_thickness, 
												{p_aussenwange[1][1], p_aussenwange[1][2], p_aussenwange[1][3] - data.step_height - data.stringer_bottom_over - data.step_thickness}, {w_axis = "-y"})
			local sweep_options = {keep_vertical = 1}

			local rail = pytha.create_sweep(rail_edges, rect, sweep_options)[1]		--create the sweep
			pytha.delete_element(rail_edges)	--delete the line
			pytha.delete_element(rect)	--delete the line
			rail = pytha.cut_element(rail, {0,0,0}, {0,0,1}, {type = "keep_front"})[1]
			kruemmling, rail = pytha.cut_element(rail, {0, data.inner_arm_length_in - data.inner_radius, 0}, {0,1,0}, {type = "keep_both"})
			table.insert(data.cur_elements, rail[1])
			rail, kruemmling = pytha.cut_element(kruemmling[1], {data.width + data.inner_radius, 0, 0}, {1,0,0}, {type = "keep_both"})
			table.insert(data.cur_elements, rail[1])
			table.insert(data.cur_elements, kruemmling[1])
		end
	
		
		
		
		
		if data.inner_radius > data.stringer_thickness then
			local offset = #bool_profile_base
			for i,k in pairs(p_aussenwange) do 
				table.insert(bool_profile_base, {k[1], k[2], 0})	--bottom over to avoid fringe cases
			end
			local fla_handle = pytha.create_polygon(bool_profile_base)
			bool_profile = pytha.create_profile(fla_handle, -data.total_height, {type = "straight"})[1]
			pytha.delete_element(fla_handle)
		else 
		
			fla_table = {}
			for i, k in pairs(p_aussenwange) do
				table.insert(fla_table, {p_aussenwange[i][1], p_aussenwange[i][2], p_aussenwange[i][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness})
			end
			for i = #p_aussenwange,1,-1 do
				table.insert(fla_table, p_aussenwange[i])
			end
			
			local fla_handle = pytha.create_polygon(fla_table)
			local profile = pytha.create_profile(fla_handle, data.stringer_thickness, {type = "straight"})[1]
			pytha.delete_element(fla_handle)
			table.insert(data.cur_elements, profile)		
		end
	end

	
	for i = 1,data.steps - 1,1 do
		local z = i * data.step_height - data.step_thickness
		local kontur = {}
		if i <= mid_step + 1 and i + 1 > mid_step + 1 then 
			if data.inner_radius <= data.stringer_thickness then
				kontur = {{p_aussen[i][1], p_aussen[i][2], z}, {p_innen[i][1], p_innen[i][2], z}, 
							{data.width, data.inner_arm_length_in, z},
							{p_innen[i + 1][1], p_innen[i + 1][2], z}, {p_aussen[i + 1][1], p_aussen[i + 1][2], z},
							{0, data.inner_arm_length_in + data.width, z}}
			else 
				kontur = {{p_aussen[i][1], p_aussen[i][2], z}, {p_innen[i][1], p_innen[i][2], z}, 
							{p_innen[i + 1][1], p_innen[i + 1][2], z}, {p_aussen[i + 1][1], p_aussen[i + 1][2], z},
							{0, data.inner_arm_length_in + data.width, z}}
			end
		else 
			kontur = {{p_aussen[i][1], p_aussen[i][2], z}, {p_innen[i][1], p_innen[i][2], z}, 
						{p_innen[i + 1][1], p_innen[i + 1][2], z}, {p_aussen[i + 1][1], p_aussen[i + 1][2], z}}
		end
		local fla_handle = pytha.create_polygon(kontur)
		local profile = pytha.create_profile(fla_handle, data.step_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		if bool_profile ~= nil then
		local subtract = pytha.copy_element(bool_profile, {0,0,0}, 1)
			profile = pytha.boole_part_difference(profile, subtract)
		end
		
		table.insert(data.cur_elements, profile)
	end	
	if bool_profile ~= nil then
			pytha.delete_element(bool_profile)
		end

		
	pytha.move_element(data.cur_elements, {-data.outer_arm_length_out, -data.outer_arm_length_in - data.stringer_thickness, 0})
	pytha.rotate_element(data.cur_elements, {0,0,0}, "z", 90)
	if left_handed == true then
		local dir = "x"
		pytha.mirror_element(data.cur_elements, {0,0,0}, dir) --data.width / 2 + data.stringer_thickness
	end
	

end

function get_gehlinien_punkt(data, i)
	local ret_P = {}
	if data.step_length * i <=  data.inner_arm_length_in then
			ret_P = {data.radius, data.step_length * i}
		elseif data.step_length * i <=  data.inner_arm_length_in + data.radius * math.pi / 2 then
			ret_P = {data.width - data.radius * math.cos((data.step_length * i - data.inner_arm_length_in) / data.radius), data.inner_arm_length_in + data.radius * math.sin((data.step_length * i - data.inner_arm_length_in) / data.radius)}
		else
			ret_P = {data.width + data.step_length * i - data.inner_arm_length_in - data.radius * math.pi / 2, data.inner_arm_length_in + data.radius}
		end
	return ret_P 
end

function get_innenwangen_punkte(data, i)
	local ret_P = {}
	if data.step_length * i <=  data.inner_arm_length_in then
			ret_P = {data.radius, data.step_length * i}
	elseif data.step_length * i <=  data.inner_arm_length_in + data.radius * math.pi / 2 then
		ret_P = {data.width - data.radius * math.cos((data.step_length * i - data.inner_arm_length_in) / data.radius), data.inner_arm_length_in + data.radius * math.sin((data.step_length * i - data.inner_arm_length_in) / data.radius)}
	else
		ret_P = {data.width + data.step_length * i - data.inner_arm_length_in - data.radius * math.pi / 2, data.inner_arm_length_in + data.radius}
	end
	return ret_P 
end

function pedestal_angled_stairs(data, left_handed)
	local pedestal_number = 0
	data.step_length = 630 - 2 * data.step_height
	data.gehlaenge = data.step_length * (data.steps - 1 + (data.pedestal_length - 1))	--the pedestal is already included in the normal steps as one step height, thus also already as one step length
	data.outer_arm_length_out = data.opening_length - data.stringer_thickness - data.width	--this corresponds to the section after the pedestal
	data.outer_arm_length_out = math.floor(data.outer_arm_length_out / data.step_length) * data.step_length
	pedestal_number = data.steps - math.floor(data.outer_arm_length_out / data.step_length) - 1
	local pedestal_over_out = data.opening_length - data.stringer_thickness - data.width - data.outer_arm_length_out
	
	if data.picked_length == true and data.second_length ~= nil then 
		data.length_on_pedestal = math.max(data.pedestal_length * data.step_length, data.radius * math.pi / 2 + data.opening_length - data.stringer_thickness - data.width - data.outer_arm_length_out)
		--this is absolute minimum length with correct step height
		if data.second_length - data.stringer_thickness - data.width + data.length_on_pedestal + data.outer_arm_length_out < data.gehlaenge then
			data.gehlaenge = data.second_length + data.opening_length - 2 * data.width + data.radius * math.pi / 2
			data.step_length = data.gehlaenge / (data.steps - 1 + (data.pedestal_length - 1))
		end
		data.outer_arm_length_in = data.second_length - data.stringer_thickness - data.width
		
	else
		
		data.length_on_pedestal = math.max(data.pedestal_length * data.step_length, data.radius * math.pi / 2 + data.opening_length - data.stringer_thickness - data.width - data.outer_arm_length_out)
		data.outer_arm_length_in = data.gehlaenge - data.outer_arm_length_out - data.length_on_pedestal
		
	end
	local pedestal_over_in = data.opening_length - data.stringer_thickness - data.width - data.outer_arm_length_out - pedestal_over_out
	
	for i = 1, pedestal_number - 1,1 do
		local z = i * data.step_height - data.step_thickness
		local aussen = {{data.width + pedestal_over_in + (pedestal_number - i) * data.step_length, data.stringer_thickness, z}, 
						{data.width + pedestal_over_in + (pedestal_number - i) * data.step_length, data.stringer_thickness + data.width, z},
						{data.width + pedestal_over_in + (pedestal_number - i - 1) * data.step_length, data.stringer_thickness + data.width, z},
						{data.width + pedestal_over_in + (pedestal_number - i - 1) * data.step_length, data.stringer_thickness, z}}
		local fla_handle = pytha.create_polygon(aussen)
		local profile = pytha.create_profile(fla_handle, data.step_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		table.insert(data.cur_elements, profile)
	end	
	
	local p_pedestal = {}
	local z_ped = pedestal_number * data.step_height - data.step_thickness
	table.insert(p_pedestal, {0, data.stringer_thickness, z_ped})
	table.insert(p_pedestal, {data.width + pedestal_over_in, data.stringer_thickness, z_ped}) 
	if pedestal_over_in > 0 then
		table.insert(p_pedestal, {data.width + pedestal_over_in, data.stringer_thickness + data.width, z_ped})
	end
	if pedestal_over_in > 0  and pedestal_over_out > 0 or pedestal_over_in == 0  and pedestal_over_out == 0 then
		table.insert(p_pedestal, {data.width, data.stringer_thickness + data.width, z_ped})
		end
	if pedestal_over_out > 0 then
		table.insert(p_pedestal, {data.width, data.stringer_thickness + data.width + pedestal_over_out, z_ped})
	end
	table.insert(p_pedestal, {0, data.stringer_thickness + data.width + pedestal_over_out, z_ped})
	local ped_handle = pytha.create_polygon(p_pedestal)
	local pedestal = pytha.create_profile(ped_handle, data.step_thickness, {type = "straight"})[1]
	pytha.delete_element(ped_handle)
	table.insert(data.cur_elements, pedestal)
	
	
	
	
	for i = pedestal_number + 1, data.steps - 1, 1 do
		local z = i * data.step_height - data.step_thickness
		local aussen = {{0,data.opening_length + (i - data.steps) * data.step_length, z}, 
						{data.width,data.opening_length + (i - data.steps) * data.step_length, z},
						{data.width, data.opening_length + (i + 1 - data.steps) * data.step_length, z},
						{0, data.opening_length + (i + 1 - data.steps) * data.step_length, z}}
		local fla_handle = pytha.create_polygon(aussen)
		local profile = pytha.create_profile(fla_handle, data.step_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		table.insert(data.cur_elements, profile)
	end	
	
	
	--outer stringer in
	local p_aussenwange = {}
	table.insert(p_aussenwange, {data.width + pedestal_over_in + (pedestal_number - 1) * data.step_length, data.stringer_thickness, (- data.stringer_thickness / data.step_length + 1) * data.step_height + data.stringer_top_over})
	table.insert(p_aussenwange, {data.width + pedestal_over_in, data.stringer_thickness, (pedestal_number + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
	table.insert(p_aussenwange, {0, data.stringer_thickness, (pedestal_number + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
	
	fla_table = {}
	for i, k in pairs(p_aussenwange) do
		table.insert(fla_table, p_aussenwange[i])
	end
	for i = #p_aussenwange,1,-1 do
		table.insert(fla_table, {p_aussenwange[i][1], p_aussenwange[i][2], p_aussenwange[i][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness})
	end
	if data.stringer_thickness > 0 then
		local fla_handle = pytha.create_polygon(fla_table)
		local profile = pytha.create_profile(fla_handle, data.stringer_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		profile = pytha.cut_element(profile, {0,0,0}, {0,0,1}, {type = "keep_front"})[1]
		table.insert(data.cur_elements, profile)
	end	
	--inner stringer in
	local p_aussenwange = {}
	table.insert(p_aussenwange, {data.width + pedestal_over_in + (pedestal_number - 1) * data.step_length, data.stringer_thickness + data.width + data.stringer_thickness, (- data.stringer_thickness / data.step_length + 1) * data.step_height + data.stringer_top_over})
	table.insert(p_aussenwange, {data.width + pedestal_over_in, data.stringer_thickness + data.width + data.stringer_thickness, (pedestal_number + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
	
	fla_table = {}
	for i, k in pairs(p_aussenwange) do
		table.insert(fla_table, p_aussenwange[i])
	end
	for i = #p_aussenwange,1,-1 do
		table.insert(fla_table, {p_aussenwange[i][1], p_aussenwange[i][2], p_aussenwange[i][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness})
	end
	if data.stringer_thickness > 0 then
		local fla_handle = pytha.create_polygon(fla_table)
		local profile = pytha.create_profile(fla_handle, data.stringer_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		profile = pytha.cut_element(profile, {0,0,0}, {0,0,1}, {type = "keep_front"})[1]
		table.insert(data.cur_elements, profile)
	end	
	
	--outer stringer out
	p_aussenwange = {}
	table.insert(p_aussenwange, {0, 0, (pedestal_number + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
	table.insert(p_aussenwange, {0, data.opening_length + (pedestal_number - data.steps) * data.step_length, (pedestal_number + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
	table.insert(p_aussenwange, {0, data.opening_length + data.stringer_thickness, (data.steps + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
	
	fla_table = {}
	for i, k in pairs(p_aussenwange) do
		table.insert(fla_table, p_aussenwange[i])
	end
	for i = #p_aussenwange,1,-1 do
		table.insert(fla_table, {p_aussenwange[i][1], p_aussenwange[i][2], p_aussenwange[i][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness})
	end
	if data.stringer_thickness > 0 then
		local fla_handle = pytha.create_polygon(fla_table)
		local profile = pytha.create_profile(fla_handle, data.stringer_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		table.insert(data.cur_elements, profile)
	end	
	
	--inner stringer out
	
	p_aussenwange = {}
	table.insert(p_aussenwange, {data.width + data.stringer_thickness, math.max(data.opening_length + (pedestal_number - data.steps) * data.step_length, data.width + data.stringer_thickness), (math.max((pedestal_number - data.steps / data.step_length), (data.width + data.stringer_thickness - data.opening_length) / data.step_length)) * data.step_height + data.stringer_top_over})
	table.insert(p_aussenwange, {data.width + data.stringer_thickness, data.opening_length + data.stringer_thickness, (data.steps + data.stringer_thickness / data.step_length) * data.step_height + data.stringer_top_over})
	
	fla_table = {}
	for i, k in pairs(p_aussenwange) do
		table.insert(fla_table, p_aussenwange[i])
	end
	for i = #p_aussenwange,1,-1 do
		table.insert(fla_table, {p_aussenwange[i][1], p_aussenwange[i][2], p_aussenwange[i][3] - data.step_height - data.stringer_top_over - data.stringer_bottom_over - data.step_thickness})
	end
	if data.stringer_thickness > 0 then
		local fla_handle = pytha.create_polygon(fla_table)
		local profile = pytha.create_profile(fla_handle, data.stringer_thickness, {type = "straight"})[1]
		pytha.delete_element(fla_handle)
		table.insert(data.cur_elements, profile)
	end	
	

	pytha.move_element(data.cur_elements, {data.stringer_thickness, -data.opening_length, 0})
	
	
	
	if left_handed == true then
		local dir = "x"
		pytha.mirror_element(data.cur_elements, {data.width / 2 + data.stringer_thickness / 2,0,0}, dir) --data.width / 2 + data.stringer_thickness
	end
	

end


function inters_line_circ(slope, P_line, P_circ, r)

	local x0 = P_line[1] - P_circ[1]
	local y0 = P_line[2] - P_circ[2]
	local c = y0 - slope * x0
	local ma = 1 + slope * slope
	local mb = 2 * slope * c
	local mc = c * c - r * r
	local x_inter_1 = (-mb + math.sqrt(mb * mb - 4 * ma * mc)) / (2 * ma)
	local x_inter_2 = (-mb - math.sqrt(mb * mb - 4 * ma * mc)) / (2 * ma)
	local y_inter_1 = slope * x_inter_1 + c
	local y_inter_2 = slope * x_inter_2 + c
	if x_inter_1 <= 0 and y_inter_1 >= 0 then
		return {x_inter_1 + P_circ[1], y_inter_1 + P_circ[2]}
	else 
		return {x_inter_2 + P_circ[1], y_inter_2 + P_circ[2]}
	end

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
