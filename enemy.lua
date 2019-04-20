
function new_enemy(init_x, init_y, type)
	-- Currently this function makes an enemy with only one hitbox variable in size
	if type == 1 then
		enemy = {
			x= init_x, 
			y= init_y,
			velocity = { x= 0, y= 100 },
			boxes = {},
			img = enemy1,
			hp = 2,
			hit = 0,
			angle = 0,
			type = 1
		}
		enemy.boxes[1] = {x = init_x, y = init_y, h = 38, w = 40}
	elseif type == 2 then
		enemy = {
			x= init_x, 
			y= init_y,
			velocity = { x = 0 , y = 0 }, 
			boxes = {},
			img = enemy2,
			hp = 2,
			hit = 0,
			angle = 0,
			type = 2,
			timer = 0,
			lock_on = {x = 0, y = 0},
			in_position = 0,
			flipflop = 1
		}
		enemy.boxes[1] = {x = init_x, y = init_y + 24, h = 65, w = 45}
		enemy.boxes[2] = {x = init_x + 52, y = init_y , h = 125, w = 115}
		enemy.boxes[3] = {x = init_x + 175, y = init_y + 24, h = 65, w = 45}
	elseif type == 3 then
		enemy = {
			x= init_x, 
			y= init_y,
			velocity = { x = 0 , y = 0 },
			boxes = {},
			img = enemy2,
			hp = 2,
			hit = 0,
			angle = 0,
			type = 3,
			timer = 0,
			lock_on = {x = 0, y = 0},
			in_position = 0
		}
		enemy.boxes[1] = {x = init_x, y = init_y + 24, h = 65, w = 45}
		enemy.boxes[2] = {x = init_x + 52, y = init_y , h = 125, w = 115}
		enemy.boxes[3] = {x = init_x + 175, y = init_y + 24, h = 65, w = 45}
	end

	return enemy
end

function update_enemies(Dt)
	-- Iterate over table of enemies, update their position and hitboxes
	-- For each enemy, iterate over their hitboxes and check collision against player
	-- Then check collision against player's bullets - remove both bullet/enemy on collision
	for i ,enemy in ipairs(enemies) do
		if enemy.type == 1 then
			--velocity_squared = math.sqrt((enemy.velocity.x * enemy.velocity.x) + (enemy.velocity.y * enemy.velocity.y))
			--unit_vector_x = enemy.velocity.x / velocity_squared
			--unit_vector_y = enemy.velocity.y / velocity_squared
			-- actually never gets used...
			execute_type_1_ai(enemy)
		elseif enemy.type == 2 then
			execute_type_2_ai(enemy)
		elseif enemy.type == 3 then
			execute_type_3_ai(enemy)
		end

		enemy.x = enemy.x + enemy.velocity.x * Dt
 		enemy.y = enemy.y + enemy.velocity.y * Dt

 		if enemy.x > 490 or enemy.x < -10 or enemy.y > 650 then
 			table.remove(enemies, i)
 		end

		for _, box in pairs(enemy.boxes) do
			box.x = box.x + enemy.velocity.x * Dt
			box.y = box.y + enemy.velocity.y * Dt
			if is_alive and is_colliding(box, player.box) then
					die()
			end
			for b, bullet in ipairs(player_bullets) do
				if is_colliding(bullet.box, box) then
					table.remove(player_bullets, b)
					enemy.hp = enemy.hp - 1
					enemy.hit = 1
				end
				-- this way of creating explosions is not scalable to enemies with multiple hitboxes or with a different size
				-- TODO make it scalable
				if(enemy.hp < 0) then
					animation = new_animation(love.graphics.newImage("assets/exp4.png"), 24, 24, 1, enemy.x -20, enemy.y -20, 16)
					table.remove(player_bullets, b)
					table.remove(enemies, i)
					table.insert(animations, animation)
				end
			end
		end
	end		
end -- end updateEnemies

function execute_type_1_ai(enemy)
	Dx = player.x - enemy.x 
	Dy = player.y - enemy.y

	D = math.sqrt((Dx * Dx) + (Dy * Dy))

	if(enemy.y > player.y) then
		enemy.velocity.x = (Dx / D) * 500
		enemy.velocity.y = 100
	else
		enemy.velocity.x = (Dx / D) * 500
		enemy.velocity.y = (Dy / D) * 500
	end
	
end

function execute_type_2_ai(enemy)
	enemy.velocity.y = 0
	enemy.velocity.x = 0

	if enemy.y > 50 then
		enemy.in_position = 1
	end

	if enemy.in_position == 0 then
		enemy.velocity.y = 100
	end

	if enemy.timer == 0 then
		charge_lazer:play()
		enemy.lock_on.x = player.x
		enemy.lock_on.y = player.y
	end

	if enemy.timer > 100 and enemy.timer <= 200 then
		enemy.velocity.x = 150 * enemy.flipflop
	end

	if enemy.timer > 50 and enemy.timer <= 100 then
		lazer_fire:play()
		fire(enemy.x + 100, enemy.y + 130, enemy.lock_on.x, enemy.lock_on.y, 800, "enemy_bullet", 1)
		fire(enemy.x + 100, enemy.y + 130, enemy.lock_on.x + 25, enemy.lock_on.y + 25, 800, "enemy_bullet", 1)
		fire(enemy.x + 100, enemy.y + 130, enemy.lock_on.x - 25, enemy.lock_on.y - 25, 800, "enemy_bullet", 1)
	end

	enemy.timer = enemy.timer + 1

	if enemy.timer > 200 then
		enemy.flipflop = enemy.flipflop * -1
		enemy.timer = 0
	end
end

function execute_type_3_ai(enemy)
	enemy.velocity.y = 0
	enemy.velocity.x = 0

	if enemy.y > 50 then
		enemy.in_position = 1
	end

	if enemy.in_position == 0 then
		enemy.velocity.y = 100
	end

	if enemy.timer == 50 then
		fire(enemy.x + 100, enemy.y + 130, 240, 640, 200, "spiral", 1)
		enemy.timer = 0
	end

	enemy.timer = enemy.timer + 1

end