
general_data = {
		cur_elements = {},
		main_group = nil,
		orient_leftwards = false,
		benchtop_height = 950,
		benchtop_thickness = 38,
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
		handle_length = 128,
		cabinet_list = {},
		current_cabinet = nil,
		benchtop = {},
		kickboards = {}}


function initialize_cabinet_values(data)
	table.insert(data.cabinet_list, {this_type = "straight",
				row = 0x1,
				width = 600,
				corner_width = 1000,
				corner_width_top = 650,
				width2 = 1000,
				width2_top = 650,
				height = 838,
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
				individual_call = nil})

	return #data.cabinet_list
end

function merge_data(merge_from, merge_to)  	--explicitely for individual cabinets, not the wizard
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




