function main()
	local data = {cur_elements = {},
				  hole_elements = {},
				  main_group = nil,
				  origin={0,0,0},
				  width=600,
				  height=600,
				  thickness=15,
				  diameter=10,
				  margin=100,
				  x_panels=1,
				  y_panels=1,
				  x_spacing=55,		
				  y_spacing=55,		
				  diagonal=1,
				  centered=true,
				  name=pyloc "Pegboard"
				  }
	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then data = loaded_data end
	recreate_geometry(data)
	pyui.run_modal_dialog(pegboard_dialog, data)
	pyio.save_values("default_dimensions", data)
end

function pegboard_dialog(dialog, data)
	dialog:set_window_title(pyloc "Pegboard")
	
	local button_ori = dialog:create_button(1, pyloc "Pick origin")
	local label_diagonal = dialog:create_label(3, pyloc "Hole pattern")
	local diagonal = dialog:create_drop_list(4)
	diagonal:insert_control_item(pyloc "Rectangular")
	diagonal:insert_control_item(pyloc "Diagonal")
	diagonal:insert_control_item(pyloc "Honeycomb")
	diagonal:set_control_selection(data.diagonal)
	dialog:create_align({1,4})
	local label_width = dialog:create_label(1, pyloc "Board width")
	local width = dialog:create_text_box(2, pyui.format_length(data.width))
	local label_height = dialog:create_label(3, pyloc "Board height")
	local height = dialog:create_text_box(4, pyui.format_length(data.height))
	local label_thickness = dialog:create_label(1, pyloc "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(data.thickness))
	local check_center = dialog:create_check_box({3,4}, pyloc "Center holes on board")
	check_center:set_control_checked(data.centered)
	dialog:create_align({1,4})
	local label_x_panels = dialog:create_label(1, pyloc "Number of x panels")
	local x_panels = dialog:create_text_box(2, pyui.format_length(data.x_panels))
	local label_y_panels = dialog:create_label(3, pyloc "Number of y panels")
	local y_panels = dialog:create_text_box(4, pyui.format_length(data.y_panels))
	dialog:create_align({1,4})
	local label_diameter = dialog:create_label(1, pyloc "Peg diameter")
	local diameter = dialog:create_text_box(2, pyui.format_length(data.diameter))
	local label_margin = dialog:create_label(3, pyloc "Border margin")
	local margin = dialog:create_text_box(4, pyui.format_length(data.margin))
	
	local label_x_spacing = dialog:create_label(1, pyloc "Horizontal spacing")
	local x_spacing = dialog:create_text_box(2, pyui.format_length(data.x_spacing))
	local label_y_spacing = dialog:create_label(3, pyloc "Vertical spacing")
	local y_spacing = dialog:create_text_box(4, pyui.format_length(data.y_spacing))
	dialog:create_align({1,4})
	local ok = dialog:create_ok_button(3)
    local cancel = dialog:create_cancel_button(4)
	
	if data.diagonal == 3 then
		label_y_spacing:disable_control()
		y_spacing:disable_control()
	else
		label_y_spacing:enable_control()
		y_spacing:enable_control()
	end	

	button_ori:set_on_click_handler(function()
		-- Pick in graphics
		button_ori:disable_control()
		local ret_wert = pyux.select_coordinate()
		if ret_wert ~= nil then
			data.origin = ret_wert
		end
		button_ori:enable_control()
		recreate_geometry(data)
	end)

	check_center:set_on_click_handler(function(state)
		-- Pick in graphics
		data.centered = state
		recreate_geometry(data)
	end)
	
	width:set_on_change_handler(function(text)
        data.width = pyui.parse_length(text)
        if data.width == nil then
            data.width = 0
        end
		if data.width > 0 then
			recreate_geometry(data)
		end
    end)
	
	height:set_on_change_handler(function(text)
        data.height = pyui.parse_length(text)
        if data.height == nil then
            data.height = 0
        end
		if data.height > 0 then
			recreate_geometry(data)
		end
    end)
	
	thickness:set_on_change_handler(function(text)
        data.thickness = pyui.parse_length(text)
        if data.thickness == nil then
            data.thickness = 0
        end
        recreate_geometry(data)
    end)
		
	x_panels:set_on_change_handler(function(text)
        data.x_panels = math.max(1, pyui.parse_length(text))
        recreate_geometry(data)
    end)

	y_panels:set_on_change_handler(function(text)
        data.y_panels = math.max(1, pyui.parse_length(text))
        recreate_geometry(data)
    end)
		
	diameter:set_on_change_handler(function(text)
        data.diameter = pyui.parse_length(text)
        if data.diameter == nil then
            data.diameter = 1
        end
		if data.height > 0 then
			recreate_geometry(data)
		end
    end)
	
	margin:set_on_change_handler(function(text)
        data.margin = pyui.parse_length(text)
        if data.margin == nil then
            data.margin = 0
        end
        recreate_geometry(data)
    end)

	x_spacing:set_on_change_handler(function(text)
        data.x_spacing = pyui.parse_length(text)
        if data.x_spacing == nil then
            data.x_spacing = data.diameter
        end
        recreate_geometry(data)
   	end)
		
	y_spacing:set_on_change_handler(function(text)
        data.y_spacing = pyui.parse_length(text)
        if data.y_spacing == nil then
            data.y_spacing = data.diameter
        end
        recreate_geometry(data)
    end)
	
	diagonal:set_on_change_handler(function(text, new_index)
		data.diagonal = new_index
		if data.diagonal == 3 then
			label_y_spacing:disable_control()
			y_spacing:disable_control()
		else
			label_y_spacing:enable_control()
			y_spacing:enable_control()
		end	
		recreate_geometry(data)
	end)
end


function recreate_geometry(data)
	if data.main_group ~= nil then
		pytha.delete_element(pytha.get_group_members(data.main_group))
	end
	data.cur_elements = {}
    local panel_width = data.width / data.x_panels
    local panel_height = data.height / data.y_panels
    local loc_origin = {data.origin[1],data.origin[2],data.origin[3]}
	local max_width = 0
	local max_height = 0
	local x_off = 0
	local y_off = 0
	local x_spacing = data.x_spacing
	local x_fac = 1
	local y_spacing = data.y_spacing
	local circ_seg = {angle=-180, segments = -24}
	local x_diameter = data.diameter
	local y_diameter = data.diameter
	local x_hole_dist = x_diameter + x_spacing
	local y_hole_dist = y_diameter + y_spacing
	if data.diagonal == 3 then
		x_fac = 0.5 * math.sqrt(3)
		x_diameter = x_fac * data.diameter
		x_hole_dist = x_diameter + x_spacing
		y_hole_dist = x_fac * x_hole_dist
		circ_seg = {angle=-180, segments = -6}
	end
	local center_margin_x = data.margin + x_diameter / 2
	local center_margin_y = data.margin + y_diameter / 2
	if data.centered == true then
		max_width = math.floor((data.width - 2 * data.margin - x_diameter) / x_hole_dist) * x_hole_dist + x_diameter
		max_height = math.floor((data.height - 2 * data.margin - y_diameter) / y_hole_dist) * y_hole_dist + y_diameter
		if data.diagonal == 2 or data.diagonal == 3 then 
			if (data.height - 2 * data.margin - y_diameter) / y_hole_dist >= 2 then 
				max_width = math.floor((data.width - 2 * data.margin - x_diameter - 0.5 * x_hole_dist) / x_hole_dist) * x_hole_dist + x_diameter + 0.5 * x_hole_dist
			end
		end
		x_off = (data.width - 2 * data.margin - max_width) / 2
		y_off = (data.height - 2 * data.margin - max_height) / 2
	end
	
    for i = 1, data.x_panels do
		for g = 1, data.y_panels do
			local outer_frame = {loc_origin, {loc_origin[1] + panel_width, loc_origin[2], loc_origin[3]},{loc_origin[1] + panel_width, loc_origin[2], loc_origin[3] + panel_height}, {loc_origin[1], loc_origin[2], loc_origin[3] + panel_height}}
			local loops = {}
			table.insert(loops, {outer_frame, {{},{},{},{}}})
			for j = data.origin[1] + x_off + center_margin_x, data.origin[1] + data.width - center_margin_x, x_hole_dist  do
				local k_count = 0				
				for k = data.origin[3] + y_off + center_margin_y, data.origin[3] + data.height - center_margin_y, y_hole_dist  do
					local j_offset = j + 0.5 * (k_count % 2) * x_hole_dist 
					if j_offset >= outer_frame[1][1] - x_diameter / 2 and j_offset <= outer_frame[3][1] + x_diameter / 2 then 	
						if k >= outer_frame[1][3] - y_diameter / 2 and k <= outer_frame[3][3] + y_diameter / 2 then 					
							table.insert(loops, {{{j_offset, data.origin[2], k - y_diameter / 2}, {j_offset, data.origin[2], k + y_diameter / 2}}, {circ_seg,circ_seg}})
						end
					end
					if data.diagonal ~= 1 then
						k_count = k_count + 1
					end
				end
			end
			
			local face = pytha.create_polygon_ex(loops, {0,0,0})
			if data.thickness > 0 then
				local profile = pytha.create_profile(face, -data.thickness)
				for i, k in pairs(profile) do
					pytha.set_element_name(k, "Panel")
					table.insert(data.cur_elements, k)
				end
				pytha.delete_element(face)
			else 
				pytha.set_element_name(face, "Panel")
				table.insert(data.cur_elements, face)

			end
			
			loc_origin[3] = loc_origin[3] + panel_height		
		end
		loc_origin[3] = data.origin[3]
		loc_origin[1] = loc_origin[1] + panel_width
    end
    data.main_group = pytha.create_group(data.cur_elements)
    pytha.set_element_name(data.main_group, data.name)
end