function main()
	local data = {width=500,
				  height=500,
				  thickness=15,
				  diameter=10,
				  margin=100/3,
				  x_number=9,
				  y_number=9,
				  x_spacing=0,		--functionality later
				  y_spacing=0,		--functionality later
				  diagonal=false,	--functionality later
				  name="Pegboard"
				  }
	
	recreate_geometry(data)
	
	pyui.run_modal_dialog(pegboard_dialog, data)
end

function pegboard_dialog(dialog, data)
	dialog:set_window_title("Pegboard")
	
	local label_width = dialog:create_label(1, pyloc "Board width")
	local width = dialog:create_text_box(2, pyui.format_length(data.width))
	local label_height = dialog:create_label(3, pyloc "Board height")
	local height = dialog:create_text_box(4, pyui.format_length(data.height))
	local label_thickness = dialog:create_label(1, pyloc "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(data.thickness))
	dialog:create_align({1,4})
	local label_diameter = dialog:create_label(1, pyloc "Peg diameter")
	local diameter = dialog:create_text_box(2, pyui.format_length(data.diameter))
	local label_margin = dialog:create_label(3, pyloc "Border margin")
	local margin = dialog:create_text_box(4, pyui.format_length(data.margin))
	local label_x_number = dialog:create_label(1, pyloc "Horizontal number")
	local x_number = dialog:create_text_box(2, pyui.format_length(data.x_number))
	local label_y_number = dialog:create_label(3, pyloc "Vertical number")
	local y_number = dialog:create_text_box(4, pyui.format_length(data.y_number))
--	local label_x_spacing = dialog:create_label(1, pyloc "Horizontal spacing")
	--[[local x_spacing = dialog:create_text_box(2, pyui.format_length(data.x_spacing))
	local label_y_spacing = dialog:create_label(3, pyloc "Vertical spacing")
	local y_spacing = dialog:create_text_box(4, pyui.format_length(data.y_spacing))
	local diagonal = dialog:create_check_box({1,2}, "Diagonal peg holes?")--]]
	dialog:create_align({1,4})
	local ok = dialog:create_ok_button(3)
    local cancel = dialog:create_cancel_button(4)
	dialog:equalize_column_widths({3,4})
	
	width:set_on_change_handler(function(text)
        data.width = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	
	height:set_on_change_handler(function(text)
        data.height = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	
	thickness:set_on_change_handler(function(text)
        data.thickness = pyui.parse_length(text)
        recreate_geometry(data)
    end)
		
	diameter:set_on_change_handler(function(text)
        data.diameter = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	
	margin:set_on_change_handler(function(text)
        data.margin = pyui.parse_length(text)
        recreate_geometry(data)
    end)
		
	x_number:set_on_change_handler(function(text)
        data.x_number = pyui.parse_number(text)
        recreate_geometry(data)
    end)
		
	y_number:set_on_change_handler(function(text)
        data.y_number = pyui.parse_number(text)
        recreate_geometry(data)
    end)
			
	--x_spacing:set_on_change_handler(function(text)
    --    data.x_spacing = pyui.parse_length(text)
    --    recreate_geometry(data)
    --end)
		
	--y_spacing:set_on_change_handler(function(text)
    --    data.y_spacing = pyui.parse_length(text)
    --    recreate_geometry(data)
    --end)
	
	--diagonal:set_on_click_handler(function(state)
	--	data.diagonal = state
	--	recreate_geometry(data)
	--end)
	
end

function recreate_geometry(data)
	if data.cur_elem ~= nil then
        pytha.delete_element(data.cur_elem)
    end
		
    data.cur_elem = {}
	local y_spacing = 0
	local x_spacing = 0
	--board without holes
	local new_elem = pytha.create_block(data.width, data.thickness, data.height, {0, 0, 0})
	table.insert(data.cur_elem, new_elem)
	local hole_origin = {}
	
	--determining first hole location and spacing
	hole_origin[2] = 0
	if data.x_number == 1 then
		hole_origin[1] = data.width / 2
	else
		hole_origin[1] = data.margin + data.diameter / 2
		x_spacing = (data.width - data.margin * 2 - data.diameter * 2) / (data.x_number - 1) 
	end
	if data.y_number == 1 then
		hole_origin[3] = data.height / 2
	else	
		hole_origin[3] = data.margin + data.diameter / 2
		y_spacing = (data.height - data.margin * 2 - data.diameter * 2) / (data.y_number - 1)
	end
	
	--creating holes
	i, j = 1, 1
	while i <= data.x_number do
		while j<= data.y_number do
			new_elem = pytha.create_circle(data.diameter/2, hole_origin, {w_axis = "-y"})
			table.insert(data.cur_elem, new_elem)
			hole_origin[3] = hole_origin[3] + y_spacing
			j = j + 1
		end
		j = 1
		hole_origin[3] = data.margin + data.diameter / 2
		hole_origin[1] = hole_origin[1] + x_spacing
		i = i + 1
	end	
		
end