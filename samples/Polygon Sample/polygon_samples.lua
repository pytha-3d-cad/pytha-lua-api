--Example for different polygons and polylines

function main()
	local length = 1000
	local width = 1000
	local bul = 600
	local hole_diameter = 15
	local frame_distance = 50
	local number_x = 20
	local number_y = 20
	local points = {{0,0,0},{length,0,0},{length,length,0},{0,length,0}}
	local points2 = {{300,100,0},{300,300,0},{400,300,0},{500,100,0}}
	local segments = {{radius = bul, orientation = "ccw", select_arc = "large"},{radius = bul, orientation = "cw", select_arc = "small"},{radius = bul*2, orientation = "ccw", select_arc = "small"},{radius = bul*2, orientation = "cw", select_arc = "small"}}
	local segments2 = {{bulge = 50},{},{bulge = 20},{}}

	pytha.create_polygon_ex({{points, segments}})
	pytha.create_polygon_ex({{points, {}}, {points2, segments2}}, {2000,0,0})
	
	
	local hole_distance_x = (length - 2 * frame_distance - number_x * hole_diameter) / (number_x - 1)
	local hole_distance_y = (width - 2 * frame_distance - number_y * hole_diameter) / (number_y - 1)
	local outer_frame = {{0,0,0}, {length,0,0},{length,width,0},{0,width,0}}
	local loops = {}
	local circ_seg = {angle=-180, segments = -24}
	table.insert(loops, {outer_frame, {{},{},{},{}}})
	for i=0,number_x-1,1 do
		for j=0,number_y-1,1 do
			table.insert(loops, {{{i*(hole_distance_x + hole_diameter) + frame_distance, hole_diameter / 2 + j * (hole_distance_y + hole_diameter) + frame_distance,0},
									{i * (hole_distance_x + hole_diameter) + frame_distance + hole_diameter, hole_diameter / 2 + j * (hole_distance_y + hole_diameter) + frame_distance,0}}, {circ_seg,circ_seg}})
		end
	end


	local fla_handle = pytha.create_polygon_ex(loops, {4000,0,0})

end