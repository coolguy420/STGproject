function create_wave(max)
	new_wave = {
		enemy_list ={},
		time = 0,
		max_enemies = max
	}
	return new_wave
end

function add_enemy(x, y, type, time, wave)
	if type == 1 then
		table.insert(wave.enemy_list, {x = x, y = y, type = 1, time = time})
	elseif type == 2 then
		table.insert(wave.enemy_list, {x = x, y = y, type = 2, time = time})
	end
end