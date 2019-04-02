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

animations = {}

waves = {}

numEnemies = 0

allEnemiesSpawned = 0

isAlive = true
score = 0

movingLeft = false
movingRight = false

function love.load(arg)
	-- Initialize the player's starting position, speed, images and hitbox
		player = {
		x = 200, 
		y = 600, 
		speed = 350, 
		img = nil, 
		imgL = nil, 
		imgR = nil,
		box = {x = 195, y = 595, h = 10, w = 10}
	}
	currentWave = 1
	
	-- Load media for player/enemies/bullets
		player.img = love.graphics.newImage('assets/ship.png')
		player.imgL = love.graphics.newImage('assets/shipleft.png')
		player.imgR = love.graphics.newImage('assets/shipright.png')
		thickBulletImg = love.graphics.newImage('assets/bullet.png')
		thinBulletImg = love.graphics.newImage('assets/bullet2.png')
		enemyImg = love.graphics.newImage('assets/enemy1.png')
		shoot = love.audio.newSource("shoot.mp3", "static")
		smallExplosion = love.graphics.newImage("assets/exp4.png")

	wave1 = {enemyList = {},
			 time = 0, maxEnemies = 12}
			
	table.insert(wave1.enemyList, {x = 200, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 50})
	table.insert(wave1.enemyList, {x = 210, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 55})
	table.insert(wave1.enemyList, {x = 220, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 60})
	table.insert(wave1.enemyList, {x = 230, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 65})
	table.insert(wave1.enemyList, {x = 240, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 70})
	table.insert(wave1.enemyList, {x = 250, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 75})
	table.insert(wave1.enemyList, {x = 260, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 80})
	table.insert(wave1.enemyList, {x = 270, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 85})
	table.insert(wave1.enemyList, {x = 280, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 90})
	table.insert(wave1.enemyList, {x = 290, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 95})
	table.insert(wave1.enemyList, {x = 300, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 100})
	table.insert(wave1.enemyList, {x = 310, y = -10, h = 38, w = 40, img = enemyImg, hp = 2, type = 1, time = 105})

	table.insert(waves, wave1)

	wave2 = {enemyList = {},
			 time = 0, maxEnemies = 4}

	table.insert(wave2.enemyList, {x = 200, y = -10, h = 38, w = 40, img = enemyImg, hp = 10, type = 1, time = 100})
	table.insert(wave2.enemyList, {x = 300, y = -10, h = 38, w = 40, img = enemyImg, hp = 10, type = 1, time = 150})
	table.insert(wave2.enemyList, {x = 400, y = -10, h = 38, w = 40, img = enemyImg, hp = 10, type = 1, time = 200})
	table.insert(wave2.enemyList, {x = 420, y = -10, h = 38, w = 40, img = enemyImg, hp = 10, type = 1, time = 250})

	table.insert(waves, wave2)
end -- end love.load()

function love.update(dt)
	-- for testing purposes until waves are implemented, spawn one enemy
	-- then spawn nothing else

	if allEnemiesSpawned == 1 then
		if next(enemies) == nil then
			currentWave = currentWave + 1
			allEnemiesSpawned = 0
		end
	else
		waves[currentWave].time = waves[currentWave].time + 1
		for _, enemy in pairs(waves[currentWave].enemyList) do
			if (enemy.time == waves[currentWave].time) then
				newEnemy = new_enemy(enemy.x, enemy.y, enemy.h, enemy.w, enemy.img, enemy.hp, enemy.type)
				table.insert(enemies, newEnemy)
				numEnemies = numEnemies + 1
				if numEnemies == waves[currentWave].maxEnemies then
					allEnemiesSpawned = 1
				end
			end
		end
	end

	-- is this creating the shooting bug?
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
  		canShoot = true
	end

	for _, animation in pairs(animations) do
		animation.currentTime = animation.currentTime + dt
    	if animation.currentTime >= animation.duration then
        	animation.currentTime = animation.currentTime - animation.duration
    	end
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

	drawValues() 

	for i, animation in ipairs(animations) do
		local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
   		love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], animation.x, animation.y, 0, 4)
    	if (spriteNum == animation.maxSprites) then
    		table.remove(animations, i)
    	end
	end
	

end -- End love.draw()	

--function new_wave(...)
--	wave = {
--		time = 0,
--		enemies = {}
--	}
--	for i, enemy in ipairs(arg) do
--		wave.enemies[i] = arg[i]
--	end
--	return wave
--end -- end new_wave

function new_enemy(initX, initY, height, width, initImg, HP, type)
	-- Currently this function makes an enemy with only one hitbox variable in size
	if type == 1 then
		enemy = {
			x= initX, 
			y= initY,
			velocity = { x= 0, y=100 }, -- Move down constantly
			boxes = {},
			img = initImg,
			hp = HP,
			hit = 0,
			angle = 0,
			type = 1
		}
	elseif type == 2 then
		enemy = {
			--stuff
		}
	elseif type == 3 then
		enemy = {
			--stuff
		}
	end
	
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
	-- TODO - possibly turn these into seperate functions
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

	velocity = {x = 0, y = 0}

	-- Checks if focus fire is being used (X), then halves speed - common shmup mechanic
	if love.keyboard.isDown('left') then
		velocity.x = -350
	end
	if love.keyboard.isDown('right') then
		velocity.x = 350
	end
	if love.keyboard.isDown('up') then
		velocity.y = -350
	end
	if love.keyboard.isDown('down') then
		velocity.y = 350
	end

	if velocity.x ~= 0 and velocity.y ~= 0 then
        velocity.x = velocity.x / math.sqrt(2)
        velocity.y = velocity.y / math.sqrt(2)
    end

	if love.keyboard.isDown('x') then
		player.x = player.x + (velocity.x*Dt) / 2
		player.y = player.y + (velocity.y*Dt) / 2
		player.box.x = player.box.x + (velocity.x*Dt) / 2
		player.box.y = player.box.y + (velocity.y*Dt) / 2
	else
		player.x = player.x + (velocity.x*Dt)
		player.y = player.y + (velocity.y*Dt)
		player.box.x = player.box.x + (velocity.x*Dt)
		player.box.y = player.box.y + (velocity.y*Dt)
	end
	
end -- end handleInput


function updateEnemies(Dt)
	-- Iterate over table of enemies, update their position and hitboxes
	-- For each enemy, iterate over their hitboxes and check collision against player
	-- Then check collision against player's bullets - remove both bullet/enemy on collision
	for i ,enemy in ipairs(enemies) do
		if enemy.type == 1 then
			velocitySquared = math.sqrt((enemy.velocity.x * enemy.velocity.x) + (enemy.velocity.y * enemy.velocity.y))

			unitVectorX = velocity.x / velocitySquared
			unitVectorY = velocity.y / velocitySquared

			Dx = player.x - enemy.x 
			Dy = player.y - enemy.y

			D = math.sqrt((Dx * Dx) + (Dy * Dy))

			enemy.velocity.x = (Dx / D) * 500
			enemy.velocity.y = (Dy / D) * 500

			enemy.x = enemy.x + enemy.velocity.x * Dt
 			enemy.y = enemy.y + enemy.velocity.y * Dt
			for _, box in pairs(enemy.boxes) do
				box.x = enemy.x
				box.y = enemy.y
				if isAlive and is_colliding(box, player.box) then
					-- Do any collision response here (game over screen, or whatever)
					isAlive = false
				end
				for b, bullet in ipairs(bullets) do
					if is_colliding(bullet.box, box) then
						-- this way of creating explosions is not scalable to enemies with multiple hitboxes or with a different size
						-- TODO make it scalable
						enemy.hit = 1
						enemy.hp = enemy.hp - 1
					if(enemy.hp < 0) then
						animation = newAnimation(love.graphics.newImage("assets/exp4.png"), 24, 24, 1, enemy.x -20, enemy.y -20, 16)
						table.remove(bullets, b)
						table.remove(enemies, i)
						table.insert(animations, animation)
					end
				end
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
		if(enemy.hit == 1) then
			love.graphics.setColor(0, 0, 50)
			enemy.hit = 0
		end
		love.graphics.draw(enemy.img, enemy.x, enemy.y)
		love.graphics.setColor(255, 0, 0)
		for _, hitbox in pairs(enemy.boxes)do
			love.graphics.rectangle("line", hitbox.x, hitbox.y, hitbox.w, hitbox.h)
		end
		love.graphics.setColor(255, 255, 255)
	end
end -- end drawEnemies

function drawValues()
	yPos = 200
	for i, wave in ipairs(waves) do
		love.graphics.setColor(0, 0, 255)
		love.graphics.print("Wave " .. i .. " time: " .. wave.time, 50, yPos)
		yPos = yPos + 15
	end
		
	yPos = 230	
	for i, enemy in ipairs(enemies) do
		love.graphics.print("Enemy  " .. i .. " vals: x:" .. math.floor(enemy.x) .. " y:" .. math.floor(enemy.y) .. " hp:" .. enemy.hp, 50, yPos)
		yPos = yPos + 15
	end		

	love.graphics.print("allEnemiesSpawned: " .. allEnemiesSpawned, 50, 50)

	love.graphics.setColor(255, 255, 255)
end

function newAnimation(image, width, height, duration, x, y, spriteNum)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
    animation.x = x
    animation.y = y
    animation.maxSprites = spriteNum
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
 
    animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end

function angle_lerp(angle1, angle2, t)
 angle1=angle1%1
 angle2=angle2%1

 if math.abs(angle1-angle2)>0.5 then
  if angle1 > angle2 then
   angle2 = angle2 + 1
  else
   angle1 = angle1 + 1
  end
 end

 return ((1-t)*angle1+t*angle2)%1
end