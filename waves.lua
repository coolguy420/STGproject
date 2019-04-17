function new_wave(max)
	new_wave = {
		enemy_list ={},
		time = 0,
		max_enemies = max
	}
	return new_wave
end

function add_enemy(x, y, type, time)
	if(type == 1) then
		table.insert(wave.enemy_list, {x = x, y = y, img = enemy1, type = type, time = time})
	elseif (type == 2) then
		table.insert(wave.enemy_list, {x = x, y = y, img = enemy2, type = type, time = time})
	end
end