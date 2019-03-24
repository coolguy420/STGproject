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

function love.load(arg)
	-- Initiate the player's starting position, speed, images and hitbox
		player = {
		x = 200, 
		y = 600, 
		speed = 350, 
		img = nil, 
		imgL = nil, 
		imgR = nil,
		box = {x = 195, y = 595, h = 10, w = 10}
	}
	-- Load images for player/enemies/bullets
		player.img = love.graphics.newImage('assets/ship.png')
		player.imgL = love.graphics.newImage('assets/shipleft.png')
		player.imgR = love.graphics.newImage('assets/shipright.png')
		thickBulletImg = love.graphics.newImage('assets/bullet.png')
		thinBulletImg = love.graphics.newImage('assets/bullet2.png')
		enemyImg = love.graphics.newImage('assets/enemy1.png')
		shoot = love.audio.newSource("shoot.mp3", "static")
end -- end love.load()

function love.update(dt)
	
	-- for testing purposes until waves are implemented, spawn one enemy
	-- then spawn nothing else

	--createEnemyTimer = createEnemyTimer - (1 * dt)
	--if createEnemyTimer < 0 then
		if noEnemy then
			enemy = new_single_box_enemy(200, -10, 38, 40, enemyImg)
			table.insert(enemies, enemy)
			noEnemy = false
		end
	--end

	-- is this creating the shooting bug?
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
  		canShoot = true
	end

	handleInput(dt)

	updateEnemies(dt)

	updateBullets(dt)

	-- Pause the game, delete bullets, (should also delete enemies)
	-- TODO - temporary invincibility after pressing R, lose a life,
	-- if no lives are left, "CONTINUE?" countdown until credit added or game over
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
		drawPlayer()
	else
		canShoot = false
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

	drawBullets()

	drawEnemies()

end -- End love.draw()

function new_single_box_enemy(initX, initY, height, width, initImg)
	-- Currently this function makes an enemy with only one hitbox variable in size
	enemy = {
		position = { x= initX, y= initY },
		velocity = { x=0, y=100 }, -- Move down constantly
		boxes = {},
		img = initImg
	}
	enemy.boxes[1] = {x = initX, y = initY, h = height, w = width}
	return enemy
end

-- TODO - make function with variable hitboxes OR make specific functions
-- for enemy types OR modify new_single_box_enemy to take an enemy type
-- which creates specific enemy and returns it. I like the last idea

function is_colliding(boxA, boxB)
	-- Takes two boxes top left / top right values and checks for collision
	boxA_minx = boxA.x
	boxA_miny = boxA.y
	boxA_maxx = boxA_minx + boxA.w
	boxA_maxy = boxA_miny + boxA.h

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

function new_bullet(initX, initY, velocityX, velocityY, type)
	-- type 1 is a thicker bullet that has a wider but shorter hitbox
	-- type 2 is a thinner bullet that has a longer but less wide hitbox
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

function handleInput(Dt)
	-- TODO - change this to pause game at some point
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	-- Pressing Z creates a spread shot of bullets
	-- Pressing X creates a focused straight shot of bullets
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
		-- Play shooting sound effect
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
		-- Play shooting sound effect
		shoot:play()
	end

	-- Checks if focus fire is being used (X), then halves speed - common shmup mechanic
	if love.keyboard.isDown('left') then
			if love.keyboard.isDown('x') then
				player.x = player.x - ((player.speed*Dt) / 2)
		   		player.box.x = player.box.x - ((player.speed*Dt) / 2)
			else
				player.x = player.x - (player.speed*Dt)
		   		player.box.x = player.box.x - (player.speed*Dt)
			end
		    movingLeft = true
	end
	if love.keyboard.isDown('right') then
			if love.keyboard.isDown('x') then
				player.x = player.x + ((player.speed*Dt) /2)
				player.box.x = player.box.x + ((player.speed*Dt) /2)
			else
				player.x = player.x + (player.speed*Dt) 
				player.box.x = player.box.x + (player.speed*Dt)
			end
			movingRight = true
	end
	if love.keyboard.isDown('up') then
			if love.keyboard.isDown('x') then
				player.y = player.y - ((player.speed*Dt) /2)
				player.box.y = player.box.y - ((player.speed*Dt) /2)
			else
				player.y = player.y - (player.speed*Dt)
				player.box.y = player.box.y - (player.speed*Dt)
			end
			
	end
	if love.keyboard.isDown('down') then
			if love.keyboard.isDown('x') then
				player.y = player.y + ((player.speed*Dt) /2)
				player.box.y = player.box.y + ((player.speed*Dt) /2)
			else
				player.y = player.y + (player.speed*Dt)
				player.box.y = player.box.y + (player.speed*Dt)
			end
	end
end -- end handleInput


function updateEnemies(Dt)
	-- Iterate over table of enemies, update their position and hitboxes
	-- For each enemy, iterate over their hitboxes and check collision against player
	-- Then check collision against player's bullets - remove both bullet/enemy on collision
	for i ,enemy in ipairs(enemies) do
		enemy.position.x = enemy.position.x + enemy.velocity.x * Dt
		enemy.position.y = enemy.position.y + enemy.velocity.y * Dt
		for _, box in pairs(enemy.boxes) do
			box.x = box.x + enemy.velocity.x * Dt
			box.y = box.y + enemy.velocity.y * Dt
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
end -- end updateEnemies

function updateBullets(Dt)
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

function drawPlayer()
	-- Draws ship image and player's collision box (smaller rectangle inside the ship)
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
end -- end drawPlayer

function drawBullets()
	for i, bullet in ipairs(bullets) do
  		love.graphics.draw(bullet.img, bullet.x, bullet.y)
  		love.graphics.setColor(255, 0, 0)
  		love.graphics.rectangle("line", bullet.box.x, bullet.box.y, bullet.box.w, bullet.box.h)
  		love.graphics.setColor(255, 255, 255)
	end
end -- end drawBullets

function drawEnemies()
	for _,enemy in pairs(enemies) do
		love.graphics.draw(enemy.img, enemy.position.x, enemy.position.y)
		love.graphics.setColor(255, 0, 0)
		for _, hitbox in pairs(enemy.boxes)do
			love.graphics.rectangle("line", hitbox.x, hitbox.y, hitbox.w, hitbox.h)
		end
		love.graphics.setColor(255, 255, 255)
	end
end -- end drawEnemies