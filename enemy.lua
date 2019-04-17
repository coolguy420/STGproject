
function new_enemy(init_x, init_y, type)
	-- Currently this function makes an enemy with only one hitbox variable in size
	if type == 1 then
		enemy = {
			x= init_x, 
			y= init_y,
			velocity = { x= 0, y=100 }, -- Move down constantly
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
			velocity = { x = 0 , y = 0 }, -- Move down constantly
			boxes = {},
			img = enemy2,
			hp = 1000,
			hit = 0,
			angle = 0,
			type = 2,
			laser_timer = 0,
			laser_firing = 0,
			lock_on = {x = 0, y = 0},
			in_position = 0,
			flipflop = 1,
			fire_timer = 0
		}
		enemy.boxes[1] = {x = init_x, y = init_y + 24, h = 65, w = 45}
		enemy.boxes[2] = {x = init_x + 52, y = init_y , h = 125, w = 115}
		enemy.boxes[3] = {x = init_x + 175, y = init_y + 24, h = 65, w = 45}
	elseif type == 3 then
		enemy = {
			x= init_x, 
			y= init_y,
			velocity = { x = 0 , y = 0 }, -- Move down constantly
			boxes = {},
			img = init_img,
			hp = 1000,
			hit = 0,
			angle = 0,
			type = 2,
			laser_timer = 0,
			laser_firing = 0,
			lock_on = {x = 0, y = 0},
			in_position = 0,
			flipflop = 1,
			fire_timer = 0
		}
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
		end
		if enemy.type == 2 then
			execute_type_2_ai(enemy)
		end
		enemy.x = enemy.x + enemy.velocity.x * Dt
 		enemy.y = enemy.y + enemy.velocity.y * Dt

		for _, box in pairs(enemy.boxes) do
			box.x = box.x + enemy.velocity.x * Dt
			box.y = box.y + enemy.velocity.y * Dt
			if is_alive and is_colliding(box, player.box) then
				is_alive = false
				animation = new_animation(love.graphics.newImage("assets/exp5.png"), 50, 50, 1, player.x - 100, player.y -100, 32)
				table.insert(animations, animation)
				player_die:play()
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

	enemy.velocity.x = (Dx / D) * 500
	enemy.velocity.y = (Dy / D) * 500
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

	if enemy.laser_timer == 0 then
		enemy.lock_on.x = player.x
		enemy.lock_on.y = player.y
	end

	if enemy.laser_timer > 100 and enemy.laser_timer <= 200 then
		enemy.velocity.x = 150 * enemy.flipflop
	end

	if enemy.laser_timer > 50 and enemy.laser_timer <= 100 then
		fire(enemy.x + 100, enemy.y + 130, enemy.lock_on.x, enemy.lock_on.y, 800, 3)
		fire(enemy.x + 100, enemy.y + 130, enemy.lock_on.x + 25, enemy.lock_on.y + 25, 800, 3)
		fire(enemy.x + 100, enemy.y + 130, enemy.lock_on.x - 25, enemy.lock_on.y - 25, 800, 3)
	end
	enemy.laser_timer = enemy.laser_timer + 1

	if enemy.laser_timer > 200 then
		enemy.flipflop = enemy.flipflop * -1
		enemy.laser_timer = 0
	end
end

function execute_type_3_ai(enemy)

end