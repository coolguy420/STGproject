function handle_input(Dt)
	-- TODO - change this to pause game at some point
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	-- Pressing Z creates a spread shot of player_bullets
	-- Pressing X creates a focused straight shot of player_bullets
	if love.keyboard.isDown('z') and can_shoot then
	-- Create some player_bullets
	-- TODO - possibly turn these into seperate functions
		bullet_x = (player.x - (player.img:getWidth()) / 2) + 13
		bullet_y = (player.y - (player.img:getHeight()) / 2) - 15
		bullet = new_bullet(bullet_x, bullet_y, 0, 900, "thick_bullet")
		table.insert(player_bullets, bullet)
		bullet = new_bullet(bullet_x + 25, bullet_y, 250, 900, "thin_bullet")
		table.insert(player_bullets, bullet)
		bullet = new_bullet(bullet_x - 10, bullet_y, -250, 900, "thin_bullet")
		table.insert(player_bullets, bullet)
		can_shoot = false
		can_shoot_timer = can_shoot_timer_max
		-- Play shooting sound effect
		shoot:play()
	elseif love.keyboard.isDown('x') and can_shoot then
		bullet_x = (player.x - (player.img:getWidth()) / 2) + 13
		bullet_y = (player.y - (player.img:getHeight()) / 2) - 15
		bullet = new_bullet(bullet_x, bullet_y, 0, 900, "thick_bullet")
		table.insert(player_bullets, bullet)
		bullet = new_bullet(bullet_x + 25, bullet_y, 0, 900, "thin_bullet")
		table.insert(player_bullets, bullet)
		bullet = new_bullet(bullet_x - 15, bullet_y, 0, 900, "thin_bullet")
		table.insert(player_bullets, bullet)
		can_shoot = false
		can_shoot_timer = can_shoot_timer_max
		-- Play shooting sound effect
		shoot:play()
	end

	player.velocity = {x = 0, y = 0}

	-- Checks if focus fire is being used (X), then halves speed - common shmup mechanic
	if is_alive then
		if love.keyboard.isDown('left') then
			player.velocity.x = -350
		end
		if love.keyboard.isDown('right') then
			player.velocity.x = 350
		end
		if love.keyboard.isDown('up') then
			player.velocity.y = -350
		end
		if love.keyboard.isDown('down') then
			player.velocity.y = 350
		end
	end
	
	if player.velocity.x ~= 0 and player.velocity.y ~= 0 then
        player.velocity.x = player.velocity.x / math.sqrt(2)
        player.velocity.y = player.velocity.y / math.sqrt(2)
    end

	if love.keyboard.isDown('x') then
		player.x = player.x + (player.velocity.x*Dt) / 2
		player.y = player.y + (player.velocity.y*Dt) / 2
		player.box.x = player.box.x + (player.velocity.x*Dt) / 2
		player.box.y = player.box.y + (player.velocity.y*Dt) / 2
	else
		player.x = player.x + (player.velocity.x*Dt)
		player.y = player.y + (player.velocity.y*Dt)
		player.box.x = player.box.x + (player.velocity.x*Dt)
		player.box.y = player.box.y + (player.velocity.y*Dt)
	end
	
end -- end handleInput

function die()
	if is_alive and not invincible then
		lives = lives - 1
		is_alive = false
		player_hit:play()	
		respawning = true
	end
end