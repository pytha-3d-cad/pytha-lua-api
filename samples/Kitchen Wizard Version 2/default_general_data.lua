

--this table can be used to sort elements in the combobox. 
--Upper cabinets of course will be displayed independently from lower cabinets
cabinet_sorting_for_combobox = {}
cabinet_sorting_for_combobox[0x1] = {
		"straight",
		"corner",
		"diagonal",
		"high", 
		"end", 
}
cabinet_sorting_for_combobox[0x2] = {
		"wall",
		"cornerwall",
		"top",
}
cabinet_sorting_for_combobox[0x3] = {
		"high", 
		"straight",
		"corner",
		"diagonal",
		"end", 
}

typecombolist = {}

function init_typecombolist()

	typecombolist = {}
	typecombolist[0x1] = {}
	typecombolist[0x2] = {}
	typecombolist[0x3] = {}
	for i, k in pairs(cabinet_typelist) do
		if k.row == 0x2 then 
			table.insert(typecombolist[0x2], i)
		else 
			table.insert(typecombolist[0x1], i)
			table.insert(typecombolist[0x3], i)
		end
	end
	--here we sort for the combobox order.
	for i, tc_row in pairs(typecombolist) do	--iterate 0x1-0x3
		for u, sort_type in pairs(cabinet_sorting_for_combobox[i]) do
			for j, cab_type in pairs(tc_row) do 	--iterate the entries
				if cab_type == sort_type then
					table.remove(tc_row, j)
					table.insert(tc_row, u, cab_type)
					goto next_term
				end
			end
			::next_term::
		end
	end
	

end



--default general values. Feel free to adapt the numeric values!
general_default_data = {
		cur_elements = {},
		main_group = nil,
		orient_leftwards = false,
		benchtop_height = 950,
		handle_length = 128,
		benchtop_thickness = 38,
		general_height_base = 838,
		general_height_top = 2200,
		wall_to_base_spacing = 562,
		thickness = 19,
		kickboard_thickness = 19,
		kickboard_setback = 40,
		kickboard_margin = 3,
		thickness_back = 5,
		groove_dist = 35,
		groove_depth = 5,
		depth = 550,
		depth_wall = 330,
		setback_shelves = 5,
		width_rail = 126,
		top_gap = 7,
		top_over = 50,
		gap = 3,
		origin = {0,0,0},
		direction = {1,0,0},
		cabinet_list = {},
		current_cabinet = nil,
		benchtop = {},
		kickboards = {}
}
--default values for individual cabinets
function initialize_cabinet_values(data, cab_type)
	table.insert(data.cabinet_list, {this_type = nil,
				row = nil,
				width = 600,
				width2 = 1000,	--right side of corner cabinets
				height = data.general_height_base,
				height_top = data.general_height_top,	
				shelf_count = 2,
				door_width = 600,
				drawer_height = 125,
				door_rh = false,
				right_element = nil,
				left_element = nil, 
				right_top_element = nil,
				left_top_element = nil, 
				top_element = nil, 
				bottom_element = nil, 
				right_connection_point = {0,0,0},
				left_connection_point = {0,0,0},
				right_direction = 0,
				left_direction = 0,
				own_direction = 0,
				cur_elements = {},
				main_group = nil,
				elem_handle_for_top = nil,
				kickboard_handle_left = nil,
				kickboard_handle_right = nil,
				front_style = nil,
				individual_call = nil})
	 if cab_type ~= nil then 
		assign_cabinet_type(data, #data.cabinet_list, cab_type)
	end
	return #data.cabinet_list
end
--sets the cabinet type 
function assign_cabinet_type(data, cabinet_nr, cab_type)

	local specific_data = data.cabinet_list[cabinet_nr]
	local spec_default_data = cabinet_typelist[cab_type].default_data
	specific_data.front_style = nil
	if #cabinet_typelist[cab_type].organization_styles > 0 then 
		specific_data.front_style = cabinet_typelist[cab_type].organization_styles[1]
	end
	specific_data.this_type = cab_type
	specific_data.row = cabinet_typelist[cab_type].row
	for i,k in pairs(spec_default_data) do
		specific_data[i] = k
	end 
	
	
end

--explicitely for individual cabinets, not the wizard
function merge_data(merge_from, merge_to)  	
	for i,k in pairs(merge_from) do
		if k ~= merge_from.cabinet_list then
			merge_to[i] = k
		end
	end
	for u,spec_from in pairs(merge_from.cabinet_list) do
		if merge_to.cabinet_list[u] == nil then
			merge_to.cabinet_list[u] = {}
		end
		local spec_to = merge_to.cabinet_list[u]
		for i,k in pairs(spec_from) do
			spec_to[i] = k
		end
	end
end




