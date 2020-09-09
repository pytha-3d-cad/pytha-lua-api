--Blind End Side

local function recreate_blind(general_data, specific_data)
	local cur_elements = {}
	
	local loc_origin= {}

	loc_origin[1] = 0
	loc_origin[2] = 0 - general_data.thickness
	loc_origin[3] = 0
	local height = general_data.benchtop_height - general_data.benchtop_thickness 
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth + general_data.thickness, height, loc_origin)
	table.insert(cur_elements, new_elem)

	specific_data.kickboard_handle_right = nil
	specific_data.kickboard_handle_left = nil
	specific_data.main_group = pytha.create_group(cur_elements)
	
	local benchtop = pytha.create_rectangle(general_data.thickness, general_data.top_over + general_data.depth, {0, -general_data.top_over, general_data.benchtop_height - general_data.benchtop_thickness})
	specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness, {name = pyloc "Benchtop"})[1]
	pytha.delete_element(benchtop)
	
	return specific_data.main_group
end

local function placement_blind(general_data, specific_data)
	specific_data.right_connection_point = {general_data.thickness, general_data.depth,0}
	specific_data.left_connection_point = {0, general_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end

function ui_update_blind(general_data, soft_update)
	
	controls.door_side:disable_control()

end	
	

--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.blind_end = 				
{									
	name = "Blind End",
	row = 0x1,
	default_data = {},
	geometry_function = recreate_blind,
	placement_function = placement_blind, 	
	ui_update_function = ui_update_blind,
	organization_styles = {},
}


