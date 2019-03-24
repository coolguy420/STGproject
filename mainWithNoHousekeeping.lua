debug = true

canShoot = true
canShootTimerMax = 0.1
canShootTimer = canShootTimerMax

createEnemyTimerMax = 10
createEnemyTimer = createEnemyTimerMax

noEnemy = true;

bulletImg = nil

bullets = {}

enemies = {}

isAlive = true
score = 0

movingLeft = false
movingRight = false

function new_single_box_enemy(initX, initY, height, width, initImg)
	-- Make a new enemy with the specified collision,
	-- a velocity pointing down, and a hitbox with the 
	-- size specified by enemy_size
	enemy = {
		position = { x= initX, y= initY },
		velocity = { x=0, y=100 }, -- Move down constantly
		boxes = {},
		img = initImg
	}
	enemy.boxes[1] = {x = initX, y = initY, h = height, w = width}
	return enemy
end

function new_bullet(initX, initY, velocityX, velocityY, type)
	if(type == 1) then
		newBullet = { 
			x = initX, 
			y = initY,
			velocity ={
				x = velocityX,
				y = velocityY
			},
			box = {
				x = initX,
				y = initY,
				h = 32,
				w = 22
			},
			img = thickBulletImg
		}
	elseif(type == 2) then
		newBullet = { 
			x = initX, 
			y = initY,
			velocity ={
				x = velocityX,
				y = velocityY
			},
			box = {
				x = initX,
				y = initY,
				h = 40,
				w = 12
			},
			img = thinBulletImg
		}
	end
		return newBullet
end

function is_colliding(boxA, boxB)
	-- Get the top left and bottom right of each the enemy's hitbox
	-- Remember the hitboxes are relative to entity's position
	boxA_minx = boxA.x 
	boxA_miny = boxA.y
	boxA_maxx = boxA_minx + boxA.w
	boxA_maxy = boxA_miny + boxA.h

	-- Get the top left and bottom right of each the enemy's hitbox
	boxB_minx = boxB.x
	boxB_miny = boxB.y
	boxB_maxx = boxB_minx + boxB.w
	boxB_maxy = boxB_miny + boxB.h

	-- Check each bound
	if boxA_minx > boxB_maxx then return false end
	if boxA_maxx < boxB_minx then return false end
	if boxA_miny > boxB_maxy then return false end
	if boxA_maxy < boxB_miny then return false end

	-- If none of the above passed then there is a collision
	return true
end

function love.load(arg)
		player = {
		x = 200, 
		y = 600, 
		speed = 350, 
		img = nil, 
		imgL = nil, 
		imgR = nil,
		box = {x = 195, y = 595, h = 10, w = 10}
	}
		player.img = love.graphics.newImage('assets/ship.png')
		player.imgL = love.graphics.newImage('assets/shipleft.png')
		player.imgR = love.graphics.newImage('assets/shipright.png')
		thickBulletImg = love.graphics.newImage('assets/bullet.png')
		thinBulletImg = love.graphics.newImage('assets/bullet2.png')
		enemyImg = love.graphics.newImage('assets/enemy1.png')
		shoot = love.audio.newSource("shoot.mp3", "static")
end -- end love.load()

function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	--createEnemyTimer = createEnemyTimer - (1 * dt)
	--if createEnemyTimer < 0 then
		if noEnemy then
			enemy = new_single_box_enemy(200, -10, 38, 40, enemyImg)
			table.insert(enemies, enemy)
			noEnemy = false
		end
	--end

	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
  		canShoot = true
	end

	if love.keyboard.isDown('z') and canShoot then
	-- Create some bullets
		bulletX = (player.x - (player.img:getWidth()) / 2) + 13
		bulletY = (player.y - (player.img:getHeight()) / 2) - 15
		bullet = new_bullet(bulletX, bulletY, 0, 900, 1)
		table.insert(bullets, bullet)
		bullet = new_bullet(bulletX + 25, bulletY, 250, 900, 2)
		table.insert(bullets, bullet)
		bullet = new_bullet(bulletX - 10, bulletY, -250, 900, 2)
		table.insert(bullets, bullet)
		canShoot = false
		canShootTimer = canShootTimerMax
		shoot:play()
	elseif love.keyboard.isDown('x') and canShoot then
		bulletX = (player.x - (player.img:getWidth()) / 2) + 13
		bulletY = (player.y - (player.img:getHeight()) / 2) - 15
		bullet = new_bullet(bulletX, bulletY, 0, 900, 1)
		table.insert(bullets, bullet)
		bullet = new_bullet(bulletX + 25, bulletY, 0, 900, 2)
		table.insert(bullets, bullet)
		bullet = new_bullet(bulletX - 15, bulletY, 0, 900, 2)
		table.insert(bullets, bullet)
		canShoot = false
		canShootTimer = canShootTimerMax
		shoot:play()
	end

	
	for i, bullet in ipairs(bullets) do
		bullet.x = bullet.x + (bullet.velocity.x * dt)
		bullet.y = bullet.y - (bullet.velocity.y * dt)
		bullet.box.x = bullet.box.x + (bullet.velocity.x * dt)
		bullet.box.y = bullet.box.y - (bullet.velocity.y * dt)

  		if bullet.y < -50 then -- remove bullets when they pass off the screen
		table.remove(bullets, i)
		end
	end


	if love.keyboard.isDown('left') then
			if love.keyboard.isDown('x') then
				player.x = player.x - ((player.speed*dt) / 2)
		   		player.box.x = player.box.x - ((player.speed*dt) / 2)
			else
				player.x = player.x - (player.speed*dt)
		   		player.box.x = player.box.x - (player.speed*dt)
			end
		    movingLeft = true
	end
	if love.keyboard.isDown('right') then
			if love.keyboard.isDown('x') then
				player.x = player.x + ((player.speed*dt) /2)
				player.box.x = player.box.x + ((player.speed*dt) /2)
			else
				player.x = player.x + (player.speed*dt) 
				player.box.x = player.box.x + (player.speed*dt)
			end
			movingRight = true
	end
	if love.keyboard.isDown('up') then
			if love.keyboard.isDown('x') then
				player.y = player.y - ((player.speed*dt) /2)
				player.box.y = player.box.y - ((player.speed*dt) /2)
			else
				player.y = player.y - (player.speed*dt)
				player.box.y = player.box.y - (player.speed*dt)
			end
			
	end
	if love.keyboard.isDown('down') then
			if love.keyboard.isDown('x') then
				player.y = player.y + ((player.speed*dt) /2)
				player.box.y = player.box.y + ((player.speed*dt) /2)
			else
				player.y = player.y + (player.speed*dt)
				player.box.y = player.box.y + (player.speed*dt)
			end
	end

	-- update the positions of enemies and their hitboxes
	for i ,enemy in ipairs(enemies) do
		enemy.position.x = enemy.position.x + enemy.velocity.x * dt
		enemy.position.y = enemy.position.y + enemy.velocity.y * dt
		for _, box in pairs(enemy.boxes) do
			box.x = box.x + enemy.velocity.x * dt
			box.y = box.y + enemy.velocity.y * dt
			if isAlive and is_colliding(box, player.box) then
				-- Do any collision response here (game over screen, or whatever)
				isAlive = false
			end
			for b, bullet in ipairs(bullets) do
				if is_colliding(bullet.box, box) then
					table.remove(bullets, b)
					table.remove(enemies, i)
				end
			end
		end
	end

	if not isAlive and love.keyboard.isDown('r') then
		bullets = {}
		canShootTimer = canShootTimerMax
		player.x = 200
		player.y = 600
		player.box.x = 195
		player.box.y = 595
		score = 0
		isAlive = true
		canShoot = true
		end
end -- End love.update()

function love.draw(dt)
	if isAlive then
		if movingLeft then
			love.graphics.draw(player.imgL, (player.x - player.imgL:getWidth() / 2) + 4, (player.y - player.imgL:getHeight() /2) + 4)
			movingLeft = false
		elseif movingRight then
			love.graphics.draw(player.imgR, (player.x - player.imgR:getWidth() / 2) - 4, (player.y - player.imgR:getHeight() /2) + 4)
			movingRight = false
		else
			love.graphics.draw(player.img, player.x - player.img:getWidth() / 2, (player.y - player.img:getHeight() /2) + 4)
		end
		love.graphics.setColor(255, 0 , 0)
		love.graphics.rectangle("line", player.box.x, player.box.y, player.box.h, player.box.w)
		love.graphics.setColor(255, 255, 255)
	else
		canShoot = false
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

	for i, bullet in ipairs(bullets) do
  		love.graphics.draw(bullet.img, bullet.x, bullet.y)
  		love.graphics.setColor(255, 0, 0)
  		love.graphics.rectangle("line", bullet.box.x, bullet.box.y, bullet.box.w, bullet.box.h)
  		love.graphics.setColor(255, 255, 255)
	end

	for _,enemy in pairs(enemies) do
		love.graphics.draw(enemy.img, enemy.position.x, enemy.position.y)
		love.graphics.setColor(255, 0, 0)
		for _, hitbox in pairs(enemy.boxes)do
			love.graphics.rectangle("line", hitbox.x, hitbox.y, hitbox.w, hitbox.h)
		end
		love.graphics.setColor(255, 255, 255)
	end

end -- End love.draw()
