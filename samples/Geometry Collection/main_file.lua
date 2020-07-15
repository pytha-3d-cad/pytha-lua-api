--Example for different possible geometries and features

function main()
	
	local points = {{0,0,0},{600,0,0},{800,1000,0},{0,1000,0}}
	local fla_handle = pytha.create_polygon(points)
	local profile = pytha.create_profile(fla_handle, 50)
	pytha.delete_element(fla_handle)
	pytha.create_element_ref_point(profile, {0,0,0})
	pytha.create_element_ref_point(profile, {600,0,0})
	pytha.create_element_ref_point(profile, {0,1000,0})
	
	-----------------------------------------------
	
	local cylinder_info = {v_axis = {0,1,1}, segments = 17, height_segments = 11, top_radius = 0}
	local cone = pytha.create_cylinder(200, 30, {1500,0,0}, cylinder_info);
	for i=1,11,1 do
		cone = pytha.copy_element(cone, {0,0,0})
		pytha.rotate_element(cone, {1300,0,0}, 'z', 30)
		pytha.set_element_pen(cone, i + 1)
	end
	
	-----------------------------------------------

	local radius = 300
	local radius2 = 200
	points = {}
	for i=1,72,1 do
		local x = math.cos(2 * math.pi * i / 72.0)
		local y = math.sin(i* 2 * math.pi /72.0)
		local z = math.cos(3* i*2 * math.pi/72)
		table.insert(points, {1500 + radius * x, 1000 + radius2 * y, 50 * z})
	end
	pytha.create_polyline("closed", points)
	
	

end