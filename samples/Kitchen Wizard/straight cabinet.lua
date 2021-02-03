--Straight cabinet with a variable number of shelves

local function recreate_straight(general_data, specific_data)
	local cur_elements = {}
	
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin = {0, 0, base_height}
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End LH"})
	table.insert(cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End RH"})
	table.insert(cur_elements, new_elem)
	--Bottom
	loc_origin[1] = general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth- groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Bottom"})
	table.insert(cur_elements, new_elem)
	--Front rail
	loc_origin[3] = base_height + specific_data.height - general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin, {name = pyloc "CR Front"})
	table.insert(cur_elements, new_elem)
	--Back rail
	loc_origin[2] = general_data.depth - general_data.width_rail - groove_dist_back_off
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin, {name = pyloc "CR Back"})
	table.insert(cur_elements, new_elem)
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, specific_data.height, loc_origin, {name = pyloc "Back"})
	table.insert(cur_elements, new_elem)
	
	local shelf_depth = general_data.depth - general_data.setback_shelves - groove_dist_back_off
	local front_style_info = nil
	if specific_data.front_style then 
		loc_origin[1] = 0
		loc_origin[2] = 0
		loc_origin[3] = base_height
		front_style_info = organization_style_list[specific_data.front_style]
		front_style_info.geometry_function(general_data, specific_data, specific_data.width, specific_data.height, shelf_depth, general_data.top_gap, loc_origin, coordinate_system, cur_elements) 
	end	

	--Kickboard
	specific_data.kickboard_handle_left = pytha.create_block(specific_data.width, general_data.kickboard_thickness, base_height - general_data.kickboard_margin, {0, general_data.kickboard_setback, general_data.kickboard_margin}, {name = pyloc "Kickboard"})
	table.insert(cur_elements, specific_data.kickboard_handle_left)
	specific_data.kickboard_handle_right = specific_data.kickboard_handle_left
	
	
	if specific_data.individual_call == nil then
		local benchtop = pytha.create_rectangle(specific_data.width, general_data.top_over + general_data.depth, {0, -general_data.top_over, general_data.benchtop_height - general_data.benchtop_thickness})
		specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness, {name = pyloc "Benchtop"})[1]
		pytha.delete_element(benchtop)
	end
	
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end

local function placement_straight(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, general_data.depth,0}
	specific_data.left_connection_point = {0, general_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end

local function ui_update_straight(general_data, soft_update)

	if soft_update == true then return end

	controls.label_width:show_control()
	controls.width:show_control()
	controls.height_label:show_control()
	controls.height:show_control()
	
		
end

--here we register the cabinet to the typelist 
--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			--might still be undefined here
	cabinet_typelist = {}
end
cabinet_typelist.straight = 					--used to reference the cabinet in the list
{									
	name = pyloc "Straight cabinet",			--displayed in drop List and used as group name
	row = 0x1,									--0x1 base, 0x2 wall, 0x3 high (high covers both rows)
	default_data = {width = 600,}, 				--default data that is set to individual values			
	geometry_function = recreate_straight,	 	--function to create geometry
	placement_function = placement_straight, 	--function to calculate the placement points
	ui_update_function = ui_update_straight, 	--function to set values and update UI
	organization_styles = {"straight_intelli_doors_and_drawer", 	--Front partition styles that are allowed for this cabinet type				
							"straight_intelli_doors", 
							"straight_intelli_doors_and_intelli_drawers",
							"straight_drawers",
							"straight_intelli_drawers",},		
}
