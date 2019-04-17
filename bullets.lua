function new_bullet(init_x, init_y, velocity_x, velocity_y, type)
	-- type 1 is a thicker bullet that has a wider but shorter hitbox
	-- type 2 is a thinner bullet that has a longer but less wide hitbox
	if(type == 1) then
		newBullet = { 
			x = init_x, 
			y = init_y,
			velocity ={
				x = velocity_x,
				y = velocity_y
			},
			box = {
				x = init_x,
				y = init_y,
				h = 32,
				w = 22
			},
			img = thick_bullet_img,
			type = 1
		}
	elseif(type == 2) then
		newBullet = { 
			x = init_x, 
			y = init_y,
			velocity ={
				x = velocity_x,
				y = velocity_y
			},
			box = {
				x = init_x,
				y = init_y,
				h = 40,
				w = 12
			},
			img = thin_bullet_img,
			type = 2
		}
	elseif(type == 3) then
		newBullet = { 
			x = init_x, 
			y = init_y,
			velocity ={
				x = velocity_x,
				y = velocity_y
			},
			box = {
				x = init_x,
				y = init_y,
				h = 26,
				w = 26
			},
			img = enemy_bullet,
			type = 3
		}
	end
	return newBullet
end

function fire(x, y, target_x, target_y, speed, type)
	Dx = target_x - x
	Dy = target_y - y
	D = math.sqrt((Dx * Dx) + (Dy * Dy))
	bullet = new_bullet(x, y, (Dx / D) * speed, ((Dy / D) * speed) * -1, type)
	if type == 3 then
		table.insert(enemy_bullets, bullet)
	elseif type == 2 or type == 1 then
		table.insert(player_bullets, bullet)
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

  		if bullet.y < -50 then -- remove bullets when they pass off the screen
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
			if is_alive == true then
				is_alive = false
				animation = new_animation(love.graphics.newImage("assets/exp5.png"), 50, 50, 1, player.x - 100, player.y -100, 32)
				table.insert(animations, animation)
				player_die:play()
			end
			-- TODO make a "die" function that takes care of death like a real shmup game
		end

  		if bullet.y > 650 then -- remove bullets when they pass off the screen
		table.remove(enemy_bullets, i)
		end
	end
end -- updateBullets