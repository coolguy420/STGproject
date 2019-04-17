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
			img = thick_bullet_img
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
			img = thin_bullet_img
		}
	end
		return newBullet
end

function fire_lazer(x, y, target_x, target_y)
	x_tweak = x + 100
	y_tweak = y + 130
	Dx = target_x - x_tweak 
	Dy = target_y - y_tweak

	D = math.sqrt((Dx * Dx) + (Dy * Dy))

	bullet = new_bullet(x + 100, y + 130, (Dx / D) * 800, ((Dy / D) * 800) * -1, 1)
	table.insert(bullets, bullet)
	

end

function fire_bullet(x, y, target_x, target_y)
	x_tweak = x + 100
	y_tweak = y + 130
	Dx = target_x - x_tweak 
	Dy = target_y - y_tweak

	D = math.sqrt((Dx * Dx) + (Dy * Dy))

	bullet = new_bullet(x + 100, y + 130, (Dx / D) * 450, ((Dy / D) * 450) * -1, 1)
	table.insert(bullets, bullet)
end

function update_bullets(Dt)
	for i, bullet in ipairs(bullets) do
		bullet.x = bullet.x + (bullet.velocity.x * Dt)
		bullet.y = bullet.y - (bullet.velocity.y * Dt)
		bullet.box.x = bullet.box.x + (bullet.velocity.x * Dt)
		bullet.box.y = bullet.box.y - (bullet.velocity.y * Dt)

  		if bullet.y < -50 then -- remove bullets when they pass off the screen
		table.remove(bullets, i)
		end
	end
end -- updateBullets