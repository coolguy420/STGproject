require "enemy"
require "player"
require "bullets"
require "waves"

debug = true

can_shoot = true
can_shoot_timer_max = 0.1
can_shoot_timer = can_shoot_timer_max

no_enemy = true;



function love.load(arg)
	-- Initialize the player's starting position, speed, images and hitbox
		player = {
		x = 200, 
		y = 600, 
		velocity = {x = 0, y = 0}, 
		img = nil, 
		img_l = nil, 
		img_r = nil,
		box = {x = 195, y = 595, h = 10, w = 10}
	}
	current_wave = 1
	player_bullets = {}
	enemy_bullets = {}
	enemies = {}
	animations = {}
	waves = {}
	num_enemies = 0
	all_enemies_spawned = 0
	is_alive = true
	score = 0
	lives = 3
	respawn_timer = 0
	-- Load media for player/enemies/player_bullets
	load_media()

	wave_1 = create_wave(1)
	add_enemy(200, 10, 1, 100, wave_1)
	table.insert(waves, wave_1)
	wave_2 = create_wave(1)
	add_enemy(50, -50, 2, 50, wave_2)
	table.insert(waves, wave_2)

end -- end love.load()

function love.update(dt)
	-- for testing purposes until waves are implemented, spawn one enemy
	-- then spawn nothing else
	if not is_alive then
		can_shoot = false
	else
		if all_enemies_spawned == 1 then
			if next(enemies) == nil then
				current_wave = current_wave + 1
				all_enemies_spawned = 0
				num_enemies = 0
			end
		else
			waves[current_wave].time = waves[current_wave].time + 1
			for _, enemy in pairs(waves[current_wave].enemy_list) do
				if (enemy.time == waves[current_wave].time) then
					enemy = new_enemy(enemy.x, enemy.y, enemy.type)
					table.insert(enemies, enemy)
					num_enemies = num_enemies + 1
					if num_enemies == waves[current_wave].max_enemies then
						all_enemies_spawned = 1
					end
				end
			end
		end

		-- is this creating the shooting bug?
		can_shoot_timer = can_shoot_timer - (1 * dt)
		if can_shoot_timer < 0 then
	  		can_shoot = true
		end

		handle_input(dt)
		update_enemies(dt)
		update_player_bullets(dt)
		update_enemy_bullets(dt)

	end -- end game updates

	-- Pause the game, delete player_bullets, (should also delete enemies)
	-- TODO - temporary invincibility after pressing R, lose a life,
	-- if no lives are left, "CONTINUE?" countdown until credit added or game over
	if not is_alive and love.keyboard.isDown('r') then
		player_bullets = {}
		can_shoot_timer = can_shoot_timer_max
		player.x = 200
		player.y = 600
		player.box.x = 195
		player.box.y = 595
		score = 0
		is_alive = true
		can_shoot = true
	end

	for _, animation in pairs(animations) do
		animation.current_time = animation.current_time + dt
		if animation.current_time >= animation.duration then
		    animation.current_time = animation.current_time - animation.duration
		end
	end	
end -- End love.update()

function love.draw(dt)
	if is_alive then
		draw_player()
	else
		can_shoot = false
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end

	draw_player_bullets()
	draw_enemy_bullets()
	draw_enemies()
	draw_values() 

	for i, animation in ipairs(animations) do
		local sprite_num = math.floor(animation.current_time / animation.duration * #animation.quads) + 1
   		love.graphics.draw(animation.sprite_sheet, animation.quads[sprite_num], animation.x, animation.y, 0, 4)
    	if (sprite_num == animation.maxSprites) then
    		table.remove(animations, i)
    	end
	end
	
end -- End love.draw()	

-- TODO - make function with variable hitboxes OR make specific functions
-- for enemy types OR modify new_single_box_enemy to take an enemy type
-- which creates specific enemy and returns it. I like the last idea

function is_colliding(box_a, boxB)
	-- Takes two boxes top left / top right values and checks for collision
	box_a_min_x = box_a.x
	box_a_min_y = box_a.y
	box_a_max_x = box_a_min_x + box_a.w
	box_a_max_y = box_a_min_y + box_a.h

	boxB_min_x = boxB.x
	boxB_min_y = boxB.y
	boxB_max_x = boxB_min_x + boxB.w
	boxB_max_y = boxB_min_y + boxB.h

	-- Check each bound
	if box_a_min_x > boxB_max_x then return false end
	if box_a_max_x < boxB_min_x then return false end
	if box_a_min_y > boxB_max_y then return false end
	if box_a_max_y < boxB_min_y then return false end

	-- If none of the above passed then there is a collision
	return true
end

function draw_player()
	-- Draws ship image and player's collision box (smaller rectangle inside the ship)
	if player.velocity.x < 0 then
		love.graphics.draw(player.img_l, (player.x - player.img_l:getWidth() / 2) + 4, (player.y - player.img_l:getHeight() /2) + 4)
	elseif player.velocity.x > 0 then
		love.graphics.draw(player.img_r, (player.x - player.img_r:getWidth() / 2) - 4, (player.y - player.img_r:getHeight() /2) + 4)
	else
		love.graphics.draw(player.img, player.x - player.img:getWidth() / 2, (player.y - player.img:getHeight() /2) + 4)
	end
	love.graphics.setColor(255, 0 , 0)
	love.graphics.rectangle("line", player.box.x, player.box.y, player.box.h, player.box.w)
	love.graphics.setColor(255, 255, 255)
end -- end draw_player

function draw_player_bullets()
	for _, bullet in pairs(player_bullets) do
  		love.graphics.draw(bullet.img, bullet.x, bullet.y)
  		love.graphics.setColor(255, 0, 0)
  		love.graphics.rectangle("line", bullet.box.x, bullet.box.y, bullet.box.w, bullet.box.h)
  		love.graphics.setColor(255, 255, 255)
	end
end -- end draw_player_bullets

function draw_enemies()
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
end -- end draw_enemies

function draw_enemy_bullets()
	for i, bullet in ipairs(enemy_bullets) do
  		love.graphics.draw(bullet.img, bullet.x, bullet.y)
  		love.graphics.setColor(255, 0, 0)
  		love.graphics.rectangle("line", bullet.box.x, bullet.box.y, bullet.box.w, bullet.box.h)
  		love.graphics.setColor(255, 255, 255)
	end
end

function draw_values()
	y_pos = 200
	for i, wave in ipairs(waves) do
		love.graphics.setColor(0, 0, 255)
		love.graphics.print("Wave " .. i .. " time: " .. wave.time, 50, y_pos)
		y_pos = y_pos + 15
	end
		
	y_pos = 260
	for i, enemy in ipairs(enemies) do
		love.graphics.print("Enemy  " .. i .. " vals: x:" .. math.floor(enemy.x) .. " y:" .. math.floor(enemy.y) .. " hp:" .. enemy.hp, 50, y_pos)
		y_pos = y_pos + 15
	end		

	love.graphics.print("all_enemies_spawned: " .. all_enemies_spawned, 50, 50)

	love.graphics.setColor(255, 255, 255)
end

function new_animation(image, width, height, duration, x, y, sprite_num)
    local animation = {}
    animation.sprite_sheet = image;
    animation.quads = {};
    animation.x = x
    animation.y = y
    animation.maxSprites = sprite_num
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
 
    animation.duration = duration or 1
    animation.current_time = 0
 
    return animation
end

function load_media()
	-- images and spritesheets
	player.img = love.graphics.newImage('assets/ship.png')
	player.img_l = love.graphics.newImage('assets/shipleft.png')
	player.img_r = love.graphics.newImage('assets/shipright.png')
	thick_bullet_img = love.graphics.newImage('assets/bullet.png')
	thin_bullet_img = love.graphics.newImage('assets/bullet2.png')
	enemy1 = love.graphics.newImage('assets/enemy1.png')
	enemy2 = love.graphics.newImage('assets/enemy2.png')
	small_explosion = love.graphics.newImage("assets/exp4.png")
	player_explode = love.graphics.newImage("assets/exp5.png")
	enemy_bullet = love.graphics.newImage("assets/bullet3.png")

	-- audio
	shoot = love.audio.newSource("shoot.mp3", "static")
	player_die = love.audio.newSource("die3.wav", "static")
end