--------------------------------------------------------------------------
-- Conway's Game of Life in PYTHA (in memoriam John H. Conway 1937 - 2020)
--------------------------------------------------------------------------

-- Configuration
-------------------------
-- start_config - possible options include:
--  + nil: random start configuration (see start_rows, start_cols)
--  + Gosper: a "cannon" shooting gliders to infinity
local start_config = "Gosper"
-- start_rows, start_cols: for a random start configuration, the number of rows/columns to fill initially
local start_cols = 50
local start_rows = 50
-------------------------

function main()
	local field = {}
	
	init_life(field)
  
	run_life(field)
end

function init_life(field)
	local config = _G[start_config]
	if config ~= nil then 
		for y, row in pairs(config) do
			for x, value in pairs(row) do
				if value == 1 then
					local xy = encode_xy(x, y)
					field[xy] = bear(x, y)
				end
			end
		end
	else 
		for x = 1, start_cols do
			for y = 1, start_rows do
				if math.random(0, 1) > 0.5 then 
					local xy = encode_xy(x, y)
					field[xy] = bear(x, y)
				end
			end
		end	
	end
end

function bear(x, y)
	return pytha.create_block(8, 8, 8, {x*10+1, y*10+1, 0})
end

function kill(elem)
	pytha.delete_element(elem)
end

function encode_xy(x, y)
	return (((x + 0x80000000) & 0xFFFFFFFF) << 32) | ((y + 0x80000000) & 0xFFFFFFFF)
end

function decode_xy(xy)
	return ((xy >> 32) & 0xFFFFFFFF) - 0x80000000, (xy & 0xFFFFFFFF) - 0x80000000
end

function increment_all_neighbors(x, y, neighbors)
	for i = -1, 1 do
		for j = -1, 1 do
			if i ~= 0 or j ~= 0 then 
				local xy2 = encode_xy(x + i, y + j)
				neighbors[xy2] = (neighbors[xy2] or 0) + 1
			end
		end
	end
end

function run_life(field)
	while true do
	
		local neighbors = {}
		-- count the neighbors
		for xy in pairs(field) do
			local x, y = decode_xy(xy)
			increment_all_neighbors(x, y, neighbors)
		end
		-- kill fields
		for xy, elem in pairs(field) do
			local cur_neighbors = neighbors[xy] or 0
			if cur_neighbors < 2 or cur_neighbors > 3 then
				kill(elem)
				field[xy] = nil
			end
		end
		-- bear fields
		for xy, cur_neighbors in pairs(neighbors) do
			if cur_neighbors == 3 and field[xy] == nil then
				local x, y = decode_xy(xy)
				field[xy] = bear(x, y)
			end
		end
		
		pyui.wait(0.05)
	end
end