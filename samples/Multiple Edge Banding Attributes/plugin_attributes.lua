function material_thickness_eval(elem)
	if elem:get_element_type() ~= "part" then
		return ""
	end
	local material = elem:get_element_attribute("material-name") or ""
	if material == "" then
		material = "none"
	end
    local thickness = elem:get_element_attribute("3005") or ""
	return material .. "_" .. thickness
end





--an attribute extension that gives the cut size of a part for an edge banding machine that doesnt mill off the thickness of the edge banding material, but simply 1mm
-- SL_ID_FLAT_UMLEIMER_D_YMINUS, 1108
-- SL_ID_FLAT_UMLEIMER_D_XPLUS, 2108
-- SL_ID_FLAT_UMLEIMER_D_YPLUS, 3108
-- SL_ID_FLAT_UMLEIMER_D_XMINUS, 4108

function edge_banding_l1_with_offset_eval(elem)
	if elem:get_element_type() ~= "part" then
		return ""
	end
	local milling_offset = 1mm
	local length = pyui.parse_length(elem:get_element_attribute("1005")) or 0
	local banding_d_left = pyui.parse_length(elem:get_element_attribute("4108") or "") or 0
	local banding_d_right = pyui.parse_length(elem:get_element_attribute("2108") or "") or 0
	if length == 0 then return "" end	--no dimension available
	if banding_d_left > 0 then 
		length = length - banding_d_left + milling_offset
	end
	if banding_d_right > 0 then 
		length = length - banding_d_right + milling_offset
	end
	return pyui.format_length(length)
end

function edge_banding_l2_with_offset_eval(elem)
	if elem:get_element_type() ~= "part" then
		return ""
	end
	local milling_offset = 1mm
	local length = pyui.parse_length(elem:get_element_attribute("2005")) or 0
	local banding_d_back = pyui.parse_length(elem:get_element_attribute("3108") or "") or 0
	local banding_d_front = pyui.parse_length(elem:get_element_attribute("1108") or "") or 0
	if length == 0 then return "" end	--no dimension available
	if banding_d_back > 0 then 
		length = length - banding_d_back + milling_offset
	end
	if banding_d_front > 0 then 
		length = length - banding_d_front + milling_offset
	end
	return pyui.format_length(length)
end


local banding_table = {
	["ABS"] = {23,34,44},
	["3D-Acryl"] = {24,34,45},
	["Dünn-ABS mit Alu"] = {24,34,45},
	["Starkfurnier"] = {24,34,45},
	["Querfurnier"] = {24,34,45},
	["Alu_sandwich"] = {24,33,45},
	["Aluminium"] = {24,33,45},
	["ExWood"] = {22,34,44},
	["Melamin"] = {22,33, 45},
	["Stegkante"] = {24,34,45},
	["Tischlerkante Ahorn"] = {45},
	["Tischlerkante Buche"] = {45},
	["Tischlerkante Eiche"] = {34,45},
	["Tischlerkante Kirschbaum"] = {24,34,45},
	["Tischlerkante Nussbaum"] = {24,34,45},
}

--SL_ID_FLAT_UMLEIMER_MAT_YMINUS, 1107
--SL_ID_FLAT_UMLEIMER_MAT_XPLUS, 2107
--SL_ID_FLAT_UMLEIMER_MAT_YPLUS, 3107
--SL_ID_FLAT_UMLEIMER_MAT_XMINUS, 4107

function find_banding_in_list(banding, board_thickness)
	if banding_table[banding] == nil then return end
	local min_banding_thickness = nil
	for i,d in ipairs(banding_table[banding]) do 
		if d > board_thickness then 
			if min_banding_thickness == nil or d < min_banding_thickness then 
				min_banding_thickness = d
			end
		end
	end
	return min_banding_thickness
end

function edge_banding_selection_from_board_thickness(elem, attr_nr)
	local banding_mat_fr = elem:get_element_attribute(attr_nr) or ""
	if banding_mat_fr == nil then 
		return "" 
	end
	local thickness = elem:get_element_attribute("3005")
	if thickness == nil then 
		return banding_mat_fr
	end
	local banding_thickness = find_banding_in_list(banding_mat_fr, thickness)
	if banding_thickness == nil then 
		return banding_mat_fr 
	end

	return banding_mat_fr .. "_" .. pyui.format_length(banding_thickness)
end

function eb_selection_l3_fr(elem)
	return edge_banding_selection_from_board_thickness(elem, "1107")
end
function eb_selection_l3_ba(elem)
	return edge_banding_selection_from_board_thickness(elem, "3107")
end
function eb_selection_l3_le(elem)
	return edge_banding_selection_from_board_thickness(elem, "4107")
end
function eb_selection_l3_ri(elem)
	return edge_banding_selection_from_board_thickness(elem, "2107")
end