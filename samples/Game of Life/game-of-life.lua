--------------------------------------------------------------------------
-- Conway's Game of Life in PYTHA (in memoriam John H. Conway 1937 - 2020)
--------------------------------------------------------------------------

-- Configuration
-------------------------
-- start_config - possible options include:
--  + nil: random start configuration (see start_rows, start_cols)
--  + Gosper: a "cannon" shooting gliders to infinity

-- start_rows, start_cols: for a random start configuration, the number of rows/columns to fill initially
local start_cols = 30
local start_rows = 30
local field_size = 10
local random_density = 0.3
-------------------------




function main()
	local field = {}
	local loaded_data = pyio.load_values("lua_config")
	if loaded_data ~= nil then field = loaded_data end
	
	for xy, state in pairs(field) do 
		local x, y = decode_xy(xy)
		field[xy] = bear(x, y)
	end
	
	local state_field = {}
	pyui.run_modal_dialog(life_dialog, field)
	for xy, state in pairs(field) do
		state_field[xy] = 1
	end
	pyio.save_values("lua_config", state_field)
	run_life(field)
end

function life_dialog(dialog, field)
	dialog:set_window_title(pyloc "Game of Life")
	
	local button_clear = dialog:create_button(1, pyloc "Clear")
	local button_gosper = dialog:create_button(2, pyloc "Gosper")
	local button_lwss = dialog:create_button(1, pyloc "Light Spaceship")
	local button_blse = dialog:create_button(2, pyloc "Switch Engine")
	local button_blpuff = dialog:create_button(1, pyloc "Blinker Puffer")
	local button_centinal = dialog:create_button(2, pyloc "Centinal")
	
	dialog:create_align({1,2})
	local label_width = dialog:create_label(1, pyloc "X Size")
	local x_size = dialog:create_text_box(2, pyui.format_number(start_cols))
	local label_height = dialog:create_label(1, pyloc "Y Size")
	local y_size = dialog:create_text_box(2, pyui.format_number(start_rows))
	local label_density = dialog:create_label(1, pyloc "Density")
	local density = dialog:create_text_box(2, pyui.format_number(random_density))
	local button_random = dialog:create_button(1, pyloc "Random seeds")
	local button_pick = dialog:create_button(2, pyloc "Manual")
	dialog:create_align({1,2})
--	local button_run = dialog:create_button(1)
--	dialog:create_align({1,2})
	local ok = dialog:create_ok_button(1)
    local cancel = dialog:create_cancel_button(2)

--	button_run:set_on_click_handler(function()
--		if pcall(run_life(field)) then
--		else
--			pyui.alert("cancel")
--		end
--		
--	end)

	button_clear:set_on_click_handler(function()
		for xy, elem in pairs(field) do
			if elem ~= nil then
				kill(elem)
				field[xy] = nil
			end
		end
	end)
	
	button_pick:set_on_click_handler(function()
		button_pick:disable_control()
		while true do
			local ret_wert = pyux.select_coordinate()
			if ret_wert ~= nil then
				local x = math.floor(ret_wert[1]/10)
				local y = math.floor(ret_wert[2]/10)
				local xy = encode_xy(x, y)
				if field[xy] == nil then
					field[xy] = bear(x, y)
				else 
					kill(field[xy])
					field[xy] = nil
				end
			else
				break
			end
		end
		button_pick:enable_control()
	end)
	
	button_gosper:set_on_click_handler(function()
		button_pick:disable_control()
		local ret_wert = pyux.select_coordinate()
		if ret_wert ~= nil then
			local x = math.floor(ret_wert[1]/10)
			local y = math.floor(ret_wert[2]/10)
			load_standard(field, x, y, "Gosper")
		end
		button_pick:enable_control()
	end)
	
	button_lwss:set_on_click_handler(function()
		button_pick:disable_control()
		local ret_wert = pyux.select_coordinate()
		if ret_wert ~= nil then
			local x = math.floor(ret_wert[1]/10)
			local y = math.floor(ret_wert[2]/10)
			load_standard(field, x, y, "LWSS")
		end
		button_pick:enable_control()
	end)
	
	button_blse:set_on_click_handler(function()
		button_pick:disable_control()
		local ret_wert = pyux.select_coordinate()
		if ret_wert ~= nil then
			local x = math.floor(ret_wert[1]/10)
			local y = math.floor(ret_wert[2]/10)
			load_standard(field, x, y, "BLSE")
		end
		button_pick:enable_control()
	end)
	
	button_blpuff:set_on_click_handler(function()
		button_pick:disable_control()
		local ret_wert = pyux.select_coordinate()
		if ret_wert ~= nil then
			local x = math.floor(ret_wert[1]/10)
			local y = math.floor(ret_wert[2]/10)
			load_standard(field, x, y, "Bl_Puff")
		end
		button_pick:enable_control()
	end)
	
	button_centinal:set_on_click_handler(function()
		button_pick:disable_control()
		local ret_wert = pyux.select_coordinate()
		if ret_wert ~= nil then
			local x = math.floor(ret_wert[1]/10)
			local y = math.floor(ret_wert[2]/10)
			load_standard(field, x, y, "Centinal")
		end
		button_pick:enable_control()
	end)
	
	button_random:set_on_click_handler(function()
		button_pick:disable_control()
		local ret_wert = pyux.select_coordinate()
		if ret_wert ~= nil then
			local x = math.floor(ret_wert[1]/10)
			local y = math.floor(ret_wert[2]/10)
			random_field(field, x, y)
		end
		button_pick:enable_control()
	end)
	
	x_size:set_on_change_handler(function(text)
        start_cols = pyui.parse_length(text)
    end)
	y_size:set_on_change_handler(function(text)
        start_rows = pyui.parse_length(text)
    end)
	density:set_on_change_handler(function(text)
        random_density = pyui.parse_length(text)
    end)
end

function load_standard(field, off_x, off_y, name)
	local config = _G[name]
	if config ~= nil then 
		for y, row in pairs(config) do
			for x, value in pairs(row) do
				if value == 1 then
					local xy = encode_xy(x + off_x, y + off_y)
					if field[xy] == nil then
						field[xy] = bear(x + off_x, y + off_y)
					end
				end
			end
		end
	end
end


function random_field(field, off_x, off_y)
	for x = 1, start_cols do
		for y = 1, start_rows do
			if math.random() < random_density then 
				local xy = encode_xy(x + off_x, y + off_y)
				if field[xy] == nil then
					field[xy] = bear(x + off_x, y + off_y)
				else 
					kill(field[xy])
					field[xy] = nil
				end
			end
		end
	end	
end

function bear(x, y)
	return pytha.create_block(8, 8, 8, {x*field_size+1, y*field_size+1, 0})
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