function new_bullet(init_x, init_y, velocity_x, velocity_y, type)
	-- type 1 is a thicker bullet that has a wider but shorter hitbox
	-- type 2 is a thinner bullet that has a longer but less wide hitbox
	if type == "thick_bullet" then
		box = { x = init_x, y = init_y, h = 32, w = 22 }
		img = thick_bullet_img
	elseif type == "thin_bullet" then
		box = { x = init_x, y = init_y, h = 40, w = 12 }
		img = thin_bullet_img
	elseif type == "enemy_bullet" then
		box = { x = init_x, y = init_y, h = 26, w = 26 }
		img = enemy_bullet
	end

	bullet = { 
		x = init_x, 
		y = init_y,
		velocity = {
		x = velocity_x,
		y = velocity_y
		},
		box = box,
		img = img
	}
	
	return bullet
end

function new_bullet(init_x, init_y, velocity_x, velocity_y, type)
	-- type 1 is a thicker bullet that has a wider but shorter hitbox
	-- type 2 is a thinner bullet that has a longer but less wide hitbox
	if type == "thick_bullet" then
		box = { x = init_x, y = init_y, h = 32, w = 22 }
		img = thick_bullet_img
	elseif type == "thin_bullet" then
		box = { x = init_x, y = init_y, h = 40, w = 12 }
		img = thin_bullet_img
	elseif type == "enemy_bullet" then
		box = { x = init_x, y = init_y, h = 26, w = 26 }
		img = enemy_bullet
	end

	bullet = { 
		x = init_x, 
		y = init_y,
		velocity = {
		x = velocity_x,
		y = velocity_y
		},
		box = box,
		img = img
	}
	
	return bullet
end

function new_rotating_bullet(init_x, init_y, speed, rotation, type)
	-- type 1 is a thicker bullet that has a wider but shorter hitbox
	-- type 2 is a thinner bullet that has a longer but less wide hitbox
	if type == "thick_bullet" then
		box = { x = init_x, y = init_y, h = 32, w = 22 }
		img = thick_bullet_img
	elseif type == "thin_bullet" then
		box = { x = init_x, y = init_y, h = 40, w = 12 }
		img = thin_bullet_img
	elseif type == "enemy_bullet" then
		box = { x = init_x, y = init_y, h = 26, w = 26 }
		img = enemy_bullet
	end

	rotating_bullet = { 
		x = init_x, 
		y = init_y,
		rotation = rotation,
		speed = speed,
		box = box,
		img = img
	}
	
	return rotating_bullet
end



function fire_straight_bullet(x, y, target_x, target_y, speed, type, destination_table)
	Dx = target_x - x
	Dy = target_y - y
	D = math.sqrt((Dx * Dx) + (Dy * Dy))
	bullet = new_bullet(x, y, (Dx / D) * speed, ((Dy / D) * speed) * -1, type)
	if destination_table == 1 then
		table.insert(enemy_bullets, bullet)
	elseif destination_table == 2 then
		table.insert(player_bullets, bullet)
	end
end

function fire_rotating_bullet(x, y, speed, type, rotation, destination_table)
	bullet = new_rotating_bullet(x, y, speed, rotation, type)
	if destination_table == 1 then
		table.insert(rotating_enemy_bullets, bullet)
	elseif destination_table == 2 then
		table.insert(rotating_player_bullets, bullet)
	end
end

-- fire_bullet(x, y, target_x, target_y)
--	x_tweak = x + 100
--	y_tweak = y + 130
--	Dx = target_x - x_tweak 
--	Dy = target_y - y_tweak
--
--	D = math.sqrt((Dx * Dx) + (Dy * Dy))
--
--	bullet = new_bullet(x + 100, y + 130, (Dx / D) * 450, ((Dy / D) * 450) * -1, 1)
--	table.insert(bullets, bullet)
--end

function update_player_bullets(Dt)
	for i, bullet in ipairs(player_bullets) do
		bullet.x = bullet.x + (bullet.velocity.x * Dt)
		bullet.y = bullet.y - (bullet.velocity.y * Dt)
		bullet.box.x = bullet.box.x + (bullet.velocity.x * Dt)
		bullet.box.y = bullet.box.y - (bullet.velocity.y * Dt)

  		if bullet.y < -5 then -- remove bullets when they pass off the screen
		table.remove(player_bullets, i)
		end
	end
end -- updateBullets

function update_enemy_bullets(Dt)
	for i, bullet in ipairs(enemy_bullets) do
		bullet.x = bullet.x + (bullet.velocity.x * Dt)
		bullet.y = bullet.y - (bullet.velocity.y * Dt)
		bullet.box.x = bullet.box.x + (bullet.velocity.x * Dt)
		bullet.box.y = bullet.box.y - (bullet.velocity.y * Dt)

		if is_colliding(bullet.box, player.box) then
				die()
		end

  		if bullet.y > 650 or bullet.x > 480 or bullet.x < -10 then -- remove bullets when they pass off the screen
			table.remove(enemy_bullets, i)
		end
	end
end -- updateBullets

function update_rotating_bullets(Dt)
	for i, bullet in ipairs(rotating_enemy_bullets) do
		bullet.rotation = bullet.rotation + 45 * Dt
		rotation_rads = bullet.rotation * math.pi / 180
		direction_x = math.cos(rotation_rads)
		direction_y = -math.sin(rotation_rads)
		velocity_x = direction_x * bullet.speed
		velocity_y = -direction_y * bullet.speed
		bullet.x = bullet.x + (velocity_x * Dt)
		bullet.y = bullet.y - (velocity_y * Dt)
		bullet.box.x = bullet.box.x + (velocity_x * Dt)
		bullet.box.y = bullet.box.y - (velocity_y * Dt)

		if is_colliding(bullet.box, player.box) then
			die()
		end

  		if bullet.y > 640 or bullet.x > 480 or bullet.x < 0 then -- remove bullets when they pass off the screen
			table.remove(rotating_enemy_bullets, i)
		end
	end
end