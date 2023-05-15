--Randomly rotate objects around their individual centers
function main()

	local parts = pyux.select_part(true, "Select parts to be randomly rotated")
	if parts == nil then return end

	for i,k in ipairs(parts) do
		local bbox = pytha.get_element_bounding_box(k)
		local center = {(bbox[1][1] + bbox[2][1]) / 2, (bbox[1][2] + bbox[2][2]) / 2, (bbox[1][3] + bbox[2][3]) / 2}
		local angle = math.random() * 360
		local axis = {-1 + 2 * math.random(), -1 + 2 * math.random(), -1 + 2 * math.random()}
		local len = PYTHAGORAS(axis[1], axis[2], axis[3])
		axis = {axis[1]/len, axis[2]/len, axis[3]/len}
		pytha.rotate_element(k, center, axis, angle)
	end

end
