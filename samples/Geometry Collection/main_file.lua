--Example for different possible geometries and features

function main()
	
--	local aussen = {{0,0,0},{600,0,0},{800,1000,0},{0,1000,0}}
--	local innen = {{200,200,0},{200,500,0},{300,500,0},{400,400,0},{400,200,0}}
--	local fla_handle = pytha.create_polygon(aussen)
--	local profile = pytha.create_profile(fla_handle, 50, {type = "rounded", bottom_radius = 10, top_radius = 5, top_segments = 1})[1]
--	pytha.delete_element(fla_handle)
	
	local circle_inf = {height_segments = 2}
	local cylinder = pytha.create_cylinder(200, 50, {0,0,0}, circle_inf);
	pytha.extend_element(cylinder, {50,20,0}, {pivot = {"mid","mid","mid"}, u_divisions={-30,0,20}})
	local circle_inf = {v_axis = {0,1,1}, segments = 17, height_segments = 11, top_radius = 0}


--	local cone = pytha.create_cylinder(200, 30, {1500,0,0}, circle_inf);
	for i=1,11,1 do
--		cone = pytha.copy_element(cone, {0,0,0})
--		pytha.rotate_element(cone, {1300,0,0}, 'z', 30)
--		pytha.set_element_pen(cone, i + 1)
	end
	local radius = 300
	local radius2 = 200
	local points = {}
	for i=1,72,1 do
		local x = math.cos(2 * math.pi * i / 72.0)
		local y = math.sin(i* 2 * math.pi /72.0)
		local z = math.cos(3* i*2 * math.pi/72)
		table.insert(points, {1500 + radius * x, 1000 + radius2 * y, 50 * z})
	end
--	pytha.create_polyline("closed", points)

end