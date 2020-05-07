--Example of a Menger Sponge
function main()
	local data = {
		origin = {0, 0, 0},
		size = 500., 
		depth = 2,
	}
	
	recreate_geometry(data)
	
	pyui.run_modal_dialog(cube_dialog, data)
end

function cube_dialog(dialog, data)
	dialog:set_window_title("My Cube")
	
	local label1 = dialog:create_label_left(1, "Size")
	local size = dialog:create_text_box(2, pyui.format_length(data.size))
	local label2 = dialog:create_label_left(1, "Depth")
	local depth = dialog:create_text_box(2, pyui.format_number(data.depth))
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
	
	dialog:equalize_column_widths({1,2});
	
	size:set_on_change_handler(function(text)
        data.size = pyui.parse_length(text)
        recreate_geometry(data)
    end)
	
    depth:set_on_change_handler(function(text)
        data.depth = math.floor(pyui.parse_number(text))
		data.depth = math.min(data.depth, 5)
        recreate_geometry(data)
    end)
	
end

function my_copy(base_element, dr, all_elements)
	local copy_element = pytha.copy_element(base_element, dr)
	table.insert(all_elements, copy_element[1])
end

function recreate_geometry(data)
    if data.current_element ~= nil then
        pytha.delete_element(data.current_element)
		data.current_element = nil
    end
	
	if data.size < 0.00001 or data.size == nil then
		return
	end
	
	if data.depth < 1 or data.depth == nil then
		data.depth = 1
	end
	
	local l = data.size / (3 ^ (data.depth - 1))
	
	local base_elem = pytha.create_block(l, l, l, data.origin)
	
	for i = 2, data.depth do
		
		-- Base level
		local bottom_elements = {}
		my_copy(base_elem, {0, 0, 0}, bottom_elements)
		my_copy(base_elem, {l, 0, 0}, bottom_elements)
		my_copy(base_elem, {2 * l, 0, 0}, bottom_elements)
		my_copy(base_elem, {2 * l, l, 0}, bottom_elements)
		my_copy(base_elem, {2 * l, 2 * l, 0}, bottom_elements)
		my_copy(base_elem, {l, 2 * l, 0}, bottom_elements)
		my_copy(base_elem, {0, 2 * l, 0}, bottom_elements)
		my_copy(base_elem, {0, l, 0}, bottom_elements)
		
		local bottom = pytha.boole_part_union(bottom_elements)
		
		-- Middle level
		local middle_elements = {}
		my_copy(base_elem, {0, 0, l}, middle_elements)
		my_copy(base_elem, {2 * l, 0, l}, middle_elements)
		my_copy(base_elem, {2 * l, 2 * l, l}, middle_elements)
		my_copy(base_elem, {0, 2 * l, l}, middle_elements)
		
		local middle = pytha.boole_part_union(middle_elements)
		
		-- Top level
		local top_elements = {}
		my_copy(base_elem, {0, 0, 2 * l}, top_elements)
		my_copy(base_elem, {l, 0, 2 * l}, top_elements)
		my_copy(base_elem, {2 * l, 0, 2 * l}, top_elements)
		my_copy(base_elem, {2 * l, l, 2 * l}, top_elements)
		my_copy(base_elem, {2 * l, 2 * l, 2 * l}, top_elements)
		my_copy(base_elem, {l, 2 * l, 2 * l}, top_elements)
		my_copy(base_elem, {0, 2 * l, 2 * l}, top_elements)
		my_copy(base_elem, {0, l, 2 * l}, top_elements)
		
		local top = pytha.boole_part_union(top_elements)
		
		pytha.delete_element(base_elem);

		base_elem = pytha.boole_part_union({bottom, middle, top})
		l = 3 * l
	end
	
	data.current_element = base_elem
end