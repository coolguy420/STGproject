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
	respawning = false
	limiter = true
	scroll_y = -4360
	-- Load media for player/enemies/player_bullets
	load_media()

	wave_1 = create_wave(1)
	add_enemy(200, 10, 1, 50, wave_1)
	table.insert(waves, wave_1)
	wave_2 = create_wave(1)
	add_enemy(200, -50, 3, 50, wave_2)
	table.insert(waves, wave_2)
	wave_3 = create_wave(1)
	add_enemy(200, -50, 1, 50, wave_3)
	table.insert(waves, wave_3)

end -- end love.load()

function love.update(dt)
	-- for testing purposes until waves are implemented, spawn one enemy
	-- then spawn nothing else
	if is_alive then
		if all_enemies_spawned == 1 then
			if next(enemies) == nil then
				current_wave = current_wave + 1
				all_enemies_spawned = 0
				num_enemies = 0
			end
		else
			waves[current_wave].time = waves[current_wave].time + 1
			scroll_y = scroll_y + 5
			if scroll_y == 0 then
				scroll_y = -4360
			end

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
	
		handle_input(dt)
		update_enemies(dt)
		update_player_bullets(dt)
		update_enemy_bullets(dt)
	end
	

	can_shoot_timer = can_shoot_timer - (1 * dt)
	if can_shoot_timer < 0 then
	  	can_shoot = true
	end

	

	-- Pause the game, delete player_bullets, (should also delete enemies)
	-- TODO - temporary invincibility after pressing R, lose a life,
	-- if no lives are left, "CONTINUE?" countdown until credit added or game over
	if respawning then
		can_shoot = false
		respawn_timer = respawn_timer + 1
		if respawn_timer == 50 then
			if lives > 0 then
				respawn:play()
			else
				respawning = false
				animation = new_animation(love.graphics.newImage("assets/exp5.png"), 50, 50, 1, player.x - 100, player.y -100, 32)
				table.insert(animations, animation)
				player_die:play()
			end
		end

		if respawn_timer < 200 and respawn_timer > 50 then
			respawn_timer = respawn_timer + 1
			is_alive = true
			invincible = true
			can_shoot = true
		end

		if respawn_timer == 200 then
			wore_off:play()
			respawning = false
			respawn_timer = 0
			invincible = false
		end
	end
	

	for _, animation in pairs(animations) do
		animation.current_time = animation.current_time + dt
		if animation.current_time >= animation.duration then
		    animation.current_time = animation.current_time - animation.duration
		end
	end	
end -- End love.update()

function love.draw(dt)
	love.graphics.draw(bg, 0, scroll_y)

	if is_alive or respawning then
		draw_player()
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
	if respawn_timer > 50 then
		love.graphics.setColor(0, 255, 0)
	else
		love.graphics.setColor(255, 255, 255)
	end

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
	love.graphics.print("respawn_timer: " .. respawn_timer, 50, 65)
	love.graphics.print("lives: " .. lives, 50, 80)
	love.graphics.print("is alive: " .. tostring(is_alive), 50, 95)
	love.graphics.print("score: " .. score, 50, 110)
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
	bg = love.graphics.newImage("assets/bg.png")

	-- audio
	shoot = love.audio.newSource("shoot.mp3", "static")
	player_hit = love.audio.newSource("die.wav", "static")
	player_die = love.audio.newSource("die3.wav", "static")
	respawn = love.audio.newSource("respawn.wav", "static")
	wore_off = love.audio.newSource("wore_off.wav", "static")
	charge_lazer = love.audio.newSource("charge.ogg", "static")
	lazer_fire = love.audio.newSource("lazer2.wav", "static")
end
