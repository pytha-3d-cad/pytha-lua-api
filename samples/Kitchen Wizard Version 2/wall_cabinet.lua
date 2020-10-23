--wall cabinet with two doors

local function recreate_wall(general_data, specific_data)
	local cur_elements = {}
	
	local base_height = general_data.wall_to_base_spacing + general_data.benchtop_height
	local height = specific_data.height_top - base_height
	
	local loc_origin= {}
	
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	

	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth_wall, height, loc_origin, {name = pyloc "End LH"})
	table.insert(cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth_wall, height, loc_origin, {name = pyloc "End RH"})
	table.insert(cur_elements, new_elem)
	--Bottom
	loc_origin[1] = general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth_wall - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Bottom"})
	table.insert(cur_elements, new_elem)
	--Top
	loc_origin[3] = base_height + height - general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth_wall - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Top"})
	table.insert(cur_elements, new_elem)
	
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth_wall - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, height, loc_origin, {name = pyloc "Back"})
	table.insert(cur_elements, new_elem)
		
	
	local shelf_depth = general_data.depth_wall - general_data.setback_shelves - groove_dist_back_off
	local front_style_info = nil
	if specific_data.front_style then 
		loc_origin[1] = 0
		loc_origin[2] = 0
		loc_origin[3] = base_height
		front_style_info = organization_style_list[specific_data.front_style]
		front_style_info.geometry_function(general_data, specific_data, specific_data.width, height, shelf_depth, 0, loc_origin, coordinate_system, cur_elements) 
	end	
		
	--Downlight
	--we need to flip the face light source uside down, so we simply use the -z direction. 
	new_elem = pytha.create_rectangle(50, 50, {specific_data.width / 2 + 25, math.max(general_data.depth_wall - 150, general_data.depth_wall / 2) - 25, base_height - 10}, {w_axis = "-z", name = "light_375"})
	table.insert(cur_elements, new_elem)
	
	specific_data.main_group = pytha.create_group(cur_elements)
	
	return specific_data.main_group
end

local function placement_wall(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, general_data.depth_wall,0}
	specific_data.left_connection_point = {0, general_data.depth_wall,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end


local function ui_update_wall(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if specific_data.width - 2 * general_data.gap > 0 then
		if specific_data.width  <= specific_data.door_width then
			controls.door_side:show_control()
		end
	else 
		controls.door_side:show_control()
	end
	
	if soft_update == true then return end

	controls.label_width:show_control()
	controls.width:show_control()
	controls.height_top_label:show_control()
	controls.height_top:show_control()
	controls.label6:show_control()
	controls.shelf_count:show_control()
	controls.door_width:show_control()
	controls.label_door_width:show_control()
	
end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.wall = 				
{									
	name = pyloc "Wall cabinet",
	row = 0x2,
	default_data = {width = 600,},
	geometry_function = recreate_wall,
	placement_function = placement_wall, 
	ui_update_function = ui_update_wall,
	organization_styles = {"straight_intelli_doors",  
							"straight_no_front",},
}



