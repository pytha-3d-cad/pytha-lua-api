
function main()
	local data = {width=800,
                  length=600,
                  height=760,
				  thickness=28,
                  leg_distance=100,
                  leg_diameter=50
				  }

	recreate_geometry(data)

	pyui.run_modal_dialog(table_generator_ui, data)
end

function table_generator_ui(dialog, data)
	dialog:set_window_title("Table generator")

	local label_length = dialog:create_label(1, pyloc "Table length")
	local length = dialog:create_text_box(2, pyui.format_length(data.length))
	local label_width = dialog:create_label(3, pyloc "Table width")
	local width = dialog:create_text_box(4, pyui.format_length(data.width))
	local label_thickness = dialog:create_label(1, pyloc "Table thickness")
    local thickness = dialog:create_text_box(2, pyui.format_length(data.thickness))
    local label_height = dialog:create_label(3, pyloc "Table height")
    local height = dialog:create_text_box(4, pyui.format_length(data.height))
	local label_leg_distance = dialog:create_label(1, pyloc "Leg distance")
    local leg_distance = dialog:create_text_box(2, pyui.format_length(data.leg_distance))
	local label_leg_diameter = dialog:create_label(3, pyloc "Leg diameter")
    local leg_diameter = dialog:create_text_box(4, pyui.format_length(data.leg_diameter))
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

	length:set_on_change_handler(function(text)
        data.length = pyui.parse_length(text)
        recreate_geometry(data)
    end)

	leg_distance:set_on_change_handler(function(text)
        data.leg_distance = pyui.parse_length(text)
        recreate_geometry(data)
    end)

	leg_diameter:set_on_change_handler(function(text)
        data.leg_diameter = pyui.parse_length(text)
        recreate_geometry(data)
    end)

end

function recreate_geometry(data)
    if data.cur_elem ~= nil then
        pytha.delete_element(data.cur_elem)
    end

    data.cur_elem = {}

    --draw table plate
    local table_plate = pytha.create_block(data.length, data.width, -data.thickness, {0, 0, data.height})
    table.insert(data.cur_elem, table_plate)

    --determine how many legs
    local no_legs_x = math.ceil( ( data.length +1 ) / 2000.0 ) + 1
    local no_legs_y = math.ceil( ( data.width +1 ) / 2000.0 ) + 1

    --determine distance between legs
    local leg_distance_x = data.length - ( 2 * data.leg_distance ) - (2 * data.leg_diameter)
    leg_distance_x = (leg_distance_x - ( ( no_legs_x - 2 ) * data.leg_diameter) ) / (no_legs_x - 1)

    local leg_distance_y = data.width - ( 2 * data.leg_distance ) - (2 * data.leg_diameter)
    leg_distance_y = (leg_distance_y - ( ( no_legs_y - 2 ) * data.leg_diameter ) ) / (no_legs_y - 1)

    --draw table legs
    i = 0
    while i < no_legs_y do
        j = 0
		while j < no_legs_x do
			leg = pytha.create_block(data.leg_diameter, data.leg_diameter, data.height - data.thickness, {
                data.leg_distance + (leg_distance_x * j + (data.leg_diameter * j)),
                data.leg_distance + (leg_distance_y * i + (data.leg_diameter * i)),
                0})
			table.insert(data.cur_elem, leg)
			j = j + 1
		end
		i = i + 1
	end

end