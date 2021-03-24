-- in honor of Sir Roger Penrose OM, winner of the 2020 Nobel Prize in Physics
------ Configuration --------
local data = {main_group = nil,
				subdivs = 5,
				edge_length = 100,
				length = 2000,
				width = 1000,
				cut_to_rectangle = true,
				centered = true
			}
-----------------------------
local goldenRatio = (1 + math.sqrt(5)) / 2

function main()

	local loaded_data = pyio.load_values("default_dimensions")
	if loaded_data ~= nil then data = loaded_data end
	
	data.subdivs = 4
	pyui.run_modal_dialog(init_dlg, data)
	pyio.save_values("default_dimensions", data)

end

function init_dlg(dialog, data)
	local controls = {}
	dialog:set_window_title(pyloc "Penrose Tiling")

	dialog:create_label(1, pyloc "Tile edge length")
	controls.edge_length = dialog:create_text_box(2, pyui.format_length(data.edge_length))
	controls.subdiv_label = dialog:create_label(3, pyloc "Subdivisions")
	controls.subdivs = dialog:create_text_box(4, pyui.format_length(data.subdivs))
	
	
	controls.check_rect = dialog:create_check_box({1,2}, pyloc "Cut tiling to box")
	controls.check_rect:set_control_checked(data.cut_to_rectangle)
	controls.check_center = dialog:create_check_box({3,4}, pyloc "Center on box")
	controls.check_center:set_control_checked(data.centered)
	controls.len_label = dialog:create_label(1, pyloc "Box length")
	controls.length = dialog:create_text_box(2, pyui.format_length(data.length))
	controls.wid_label = dialog:create_label(3, pyloc "Box width")
	controls.width = dialog:create_text_box(4, pyui.format_length(data.width))
	
	dialog:create_align({1,4})
	local ok = dialog:create_ok_button(3)
    local cancel = dialog:create_cancel_button(4)
	dialog:equalize_column_widths({3, 4})
	
	controls.length:set_on_change_handler(function(text)
        data.length = pyui.parse_length(text) or data.length
		if data.length > 0 then
			recreate_geometry(data)
			update_ui(data, controls)
		end
    end)
	controls.width:set_on_change_handler(function(text)
        data.width = pyui.parse_length(text) or data.width
		if data.width > 0 then
			recreate_geometry(data)
			update_ui(data, controls)
		end
    end)
	controls.edge_length:set_on_change_handler(function(text)
        data.edge_length = pyui.parse_length(text) or data.edge_length
		if data.edge_length > 0 then
			recreate_geometry(data)
			update_ui(data, controls)
		end
    end)
	controls.subdivs:set_on_change_handler(function(text)
        data.subdivs = pyui.parse_length(text) or data.subdivs
		if data.subdivs > 0 then
			recreate_geometry(data)
			update_ui(data, controls)
		end
    end)
	controls.check_rect:set_on_click_handler(function(state)
		data.cut_to_rectangle = state
		
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	controls.check_center:set_on_click_handler(function(state)
		data.centered = state
		recreate_geometry(data)
		update_ui(data, controls)
	end)
	
	
	recreate_geometry(data)
	update_ui(data, controls)
end

function update_ui(data, controls)
	controls.check_center:enable_control(data.cut_to_rectangle)
	controls.len_label:enable_control(data.cut_to_rectangle)
	controls.wid_label:enable_control(data.cut_to_rectangle)
	controls.length:enable_control(data.cut_to_rectangle)
	controls.width:enable_control(data.cut_to_rectangle)
	controls.subdiv_label:enable_control(not data.cut_to_rectangle)
	controls.subdivs:enable_control(not data.cut_to_rectangle)
	if data.cut_to_rectangle == true then 
		controls.subdivs:set_control_text(data.subdivs)
	end
end

local function subdivide(triangles)
    local result = {}
    for i, tria in pairs(triangles) do
		local P = {}
		local Q = {}
		local R = {}
		color = tria[1]
		A = {tria[2][1], tria[2][2]} 
		B = {tria[3][1], tria[3][2]} 
		C = {tria[4][1], tria[4][2]}  
        if color == 0 then
            -- Subdivide red triangle
            P[1] = A[1] + (B[1] - A[1]) / goldenRatio
            P[2] = A[2] + (B[2] - A[2]) / goldenRatio
            table.insert(result,{0, C, P, B})
            table.insert(result,{1, P, C, A})
        else
            -- Subdivide blue triangle
            Q[1] = B[1] + (A[1] - B[1]) / goldenRatio
            Q[2] = B[2] + (A[2] - B[2]) / goldenRatio
            R[1] = B[1] + (C[1] - B[1]) / goldenRatio
            R[2] = B[2] + (C[2] - B[2]) / goldenRatio
            table.insert(result,{1, R, C, A})
            table.insert(result,{1, Q, R, B})
            table.insert(result,{0, R, Q, A})
		end
	end
    return result
end


function recreate_geometry(data)
	local triangles = {}
	local offset = {0, 0}
	if data.main_group ~= nil then
		pytha.delete_element(data.main_group)
	end
	local radius = (goldenRatio ^ data.subdivs) * data.edge_length
	if data.cut_to_rectangle == true then 
		data.subdivs = 0
		if data.centered == false then
			local min_length = (math.min(data.length, data.width) + 2 * math.max(data.length, data.width) * SIN(18)) * goldenRatio + 4 * data.edge_length 	--safety cause some edge elements are omitted 
			radius = data.edge_length 
			while radius < min_length do
				data.subdivs = data.subdivs + 1
				radius = radius * goldenRatio
			end
			local offset_x = (radius * COS(18) + math.min(data.length, data.width)/2 / TAN(18)) / 2	--to center triangle on x axis
			offset[1] = -offset_x
		else
			local min_length = PYTHAGORAS(data.length, data.width) / COS(18) / 2 + 4 * data.edge_length	--safety cause some edge elements are omitted 
			radius = data.edge_length 
			while radius < min_length do
				data.subdivs = data.subdivs + 1
				radius = radius * goldenRatio
			end
		end
	end
	if data.centered == false and data.cut_to_rectangle == true then 
		B = {radius * math.cos(- math.pi / 10), radius * math.sin(- math.pi / 10)}
		C = {radius * math.cos(math.pi / 10), radius * math.sin(math.pi / 10)}
		table.insert(triangles, {0, {0,0}, B, C})
	else
		for i = 1,10,1 do
			B = {radius * math.cos((2*i - 1) * math.pi / 10), radius * math.sin((2*i - 1) * math.pi / 10)}
			C = {radius * math.cos((2*i + 1) * math.pi / 10), radius * math.sin((2*i + 1) * math.pi / 10)}
			if i % 2 == 0 then 
				table.insert(triangles, {0, {0,0}, C, B})
			else 
				table.insert(triangles, {0, {0,0}, B, C})
			end
		end
	end
	--Safety check for too many structures
	if data.subdivs > 10 or (data.cut_to_rectangle == true and data.subdivs > 12) then return end
	
	-- Perform subdivisions
	for i = 1, data.subdivs do
		triangles = subdivide(triangles)
	end
	local blues = {}
	local reds = {}
	local cut_list = {}
	local short_side = math.min(data.length, data.width)
	local long_side = math.max(data.length, data.width)
	for i, tria in pairs(triangles) do 
		if cross(tria[2], tria[3], tria[4]) == true then 
			local p1 = {tria[2][1] + offset[1], tria[2][2]}
			local p2 = {tria[3][1] + offset[1], tria[3][2]}
			local p3 = {tria[3][1] + tria[4][1] - tria[2][1] + offset[1], tria[3][2] + tria[4][2] - tria[2][2]}
			local p4 = {tria[4][1] + offset[1], tria[4][2]}
			local do_create = 1
			if data.cut_to_rectangle == true then 
				do_create = is_poly_in_rect(p1, p2, p3, p4, -long_side/2, long_side/2, -short_side/2, short_side/2)
			end
			if do_create > 0 then
				local part = pytha.create_polygon({p1, p2, p3, p4}, {}, {clean_face = "dont_clean"})
				pytha.set_element_pen(part, 2 + 4 * tria[1])
				if tria[1] == 1 then 
					pytha.set_element_name(part, pyloc "blue")
					table.insert(blues, part)
				else 
					pytha.set_element_name(part, pyloc "red")
					table.insert(reds, part)
				end
				if do_create == 2 then 
					table.insert(cut_list, part)
				end
			end
		end
	end 
	local blue_group = pytha.create_group(blues, {name = pyloc "blue"})
	local red_group = pytha.create_group(reds, {name = pyloc "red"})
	data.main_group = pytha.create_group({blue_group, red_group}, {name = pyloc "Penrose"})
	
	if data.cut_to_rectangle == true then
		local rect = pytha.create_rectangle(long_side, short_side, {-long_side/2, -short_side/2})
		
		pytha.boole_part_template(cut_list, rect, "inside")
		pytha.delete_element(rect)
	end
	if data.width > data.length then 
		pytha.rotate_element(data.main_group, {0,0,0}, "z", 90)
	end	
end

function cross(A,B,C)
	return (B[1]-A[1])*(C[2]-A[2]) - (B[2]-A[2])*(C[1]-A[1]) > 0
end

--return values: 0: outside, 1: inside, 2: questionable
--can be modifierd using ... to fit arbitrary polygons
--(...) 
-- for i = 1, select("#", ...) do
-- local arg = select(i, ...)
-- xxx
-- end
-- end
function is_poly_in_rect(p1, p2, p3, p4, x_min, x_max, y_min, y_max)

	if (p1[1] < x_min and p2[1] < x_min and p3[1] < x_min and p4[1] < x_min) or 
		(p1[1] > x_max and p2[1] > x_max and p3[1] > x_max and p4[1] > x_max) or 
		(p1[2] < y_min and p2[2] < y_min and p3[2] < y_min and p4[2] < y_min) or 
		(p1[2] > y_max and p2[2] > y_max and p3[2] > y_max and p4[2] > y_max) then 
		return 0
	end
	if p1[1] >= x_min and p1[1] <= x_max and 
		p2[1] >= x_min and p2[1] <= x_max and 
		p3[1] >= x_min and p3[1] <= x_max and 
		p4[1] >= x_min and p4[1] <= x_max and 
		p1[2] >= y_min and p1[2] <= y_max and 
		p2[2] >= y_min and p2[2] <= y_max and 
		p3[2] >= y_min and p3[2] <= y_max and 
		p4[2] >= y_min and p4[2] <= y_max then
		return 1
	end
	return 2
end






























