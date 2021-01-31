pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- init data
animations = {
	bob = {
		curr = 0,
		final = 30,
		active = false
	},
	p = {
		curr = 0,
		final = 15,
		dir = 0,
		-- 0 is neutral
		-- 1 is left
		-- 2 is right
		-- 3 is up
		-- 4 is down
		active = false
	},
	shake = {
		x = 0,
		y = 0,
		strength = 0,
		max_strength = 0.4,
		fade_factor = 0.7
	},
	transition = {
		final = 440,
		curr = 0,
		draw_step = 0.14,
		step = 6,
		r = 160
	},
	transition_end = {
		final = 128,
		curr = -30,
		step = 3
	}
}
p = {
	x = 975,
	y = 30,
	speed = 2,
	width=16,
	height=32,
	interact_rad = 300,
	exp = 0,
	prompt_final = false
}
npcs = {
	{ -- woman
		active = false,
		battle = true,
		x = 473,
		y = 32,
		width = 16,
		height = 32,
		sprite = 69,
		v_offset = 5,
		lines = {
			{"* you politely greet the", "beautiful lady. *"},
			{"please join me for tea!"}
		},
		win_lines = {
			{"do i know a", "dominique bretodeau?"}, {"c'est moi!"}, {"* you politely thank her", "and leave *"}
		},
		lose_lines = {
			{"* you are wooed by the woman."}, {"you forgot to ask her your", "question. *"}
		}
	},
	{ -- dominique
		active = false,
		battle = true,
		x = 0,
		y = 500,
		width = 16,
		height = 32,
		sprite = 65,
		v_offset = 5,
		lines = {
			{"* you know in your heart", "that this is dominique. *"}
		},
		win_lines = {
			{"* you approach the old man *"}
		},
		lose_lines = {
			{"* you are too nervous", "to approach. *"}
		}
	},
	{ -- young man
		active = false,
		battle = true,
		x = 602,
		y = 68,
		width = 16,
		height = 32,
		sprite = 77,
		v_offset = 5,
		lines = {
			{"* you politely greet the", "young man. *"},
			{"what do you need?"}
		},
		win_lines = {
			{"you are looking for a", "dominique bretodeau?"},
			{"c'est moi!"},
			{"* you know he is too young", "to be the person you are", "looking for *"},
			{"* you thank him anyways *"}
		},
		lose_lines = {
			{"sorry, i'm not interested."}
		}
	},
	{ -- neighbor
		active = false,
		battle = false,
		x = 0, -- to be 911
		y = 500, -- to be 190
		width = 16,
		height = 32,
		sprite = 67,
		v_offset = 5,
		lines = {
			{"i heard you were looking", "for the boy who used to live", "in your house."},
			{"his name is not dominique", "bredoteau!"},
			{"instead, his name is", "dominique bretodeau!"},
			{" * you are rejuvinated and", "more determined than ever. *"}
		},
		win_lines = {
			},
		lose_lines = {
		}
	},
	{ -- casket
		active = false,
		battle = true,
		x = 41,
		y = 73,
		width = 16,
		height = 32,
		sprite = 1,
		v_offset = 5,
		lines = {
			{"* you slowly approach the", "casket. *"},
			{"* a feeling of dread", "overwhelms you. *"}
		},
		win_lines = {
			{"* you inspect the casket", "more closely. *"},
			{"\"dominique bredoteau.\""},
			{"* you bow your head and", "step back. *"}
		},
		lose_lines = {
			{"* you cannot bring yourself", "to look at the casket. *"}
		}
	}
}
battle = {
	p = {
		sprite = 252,
		x = 64,
		y = 64,
		w = 8,
		h = 8,
		speed = 2.5
	},
	pickups = {
		--[[
		{
			sprite = 220,
			x = 16,
			y = 16,
			w = 8,
			h = 8,
			active = true
		},
		{
			sprite = 220,
			x = 100,
			y = 100,
			w = 8,
			h = 8,
			active = true
		}--]]
	},
	enemies = {},
	enemy_max = 50,
	enemy_min_speed = 2,
	enemy_speed_range = 3,
	enemy_sprite = 237,
	enemy_spawn_chance = 0.4,
	enemy_ttl = 150,
	collected = 0,
	health = 3,
	iframes = 20,
	invincibility = 0,
	win = false
}

cam = {
	x = 0,
	y = 0
}

dialog = {
	active_npc = {},
	lines = {},
	curr = 1,
	battle = false
}

return_prompt = {
	{"you have given up on your", "journey to return the box"},
	{"as none of the dominique", "bredoteaus you have found are", "the one you seek."},
	{"maybe your neighbor", "can console you..."}
}

intro_text = {
		{ 12, "bonjour, amelie!", 30},
		{ 6, "it is the morning of august 31, 1997", 3},
		{ 6, "you are shocked to see on tv", 3},
		{ 12, "that lady di has died.", 3},
		{ 6, "in your shock, you drop your", 3},
		{ 6, "purfume bottle, knocking a", 3},
		{ 12, "baseboard off of the wall.", 3},
		{ 6, "after further inspection, you", 3},
		{ 12, "find an old memento box!", 3},
		{ 12, "dominique bredoteau?", 3},
		{ 6, "you shall find him and return", 3},
		{ 6, "his box!", 3}
	}
	
	ending_text = {
		{ 6, "you successfully returned", 3},
		{ 12, "the box to dominique bretodeau!", 3},
		{ 12, "the box has found its way home.", 3},
		{ 6, "your life's passion is now", 3},
		{ 24, "to do good for others.", 3},
		{ 6, "the end", 3}
	}

function _update_empty()
	_x = 0
end

function _init()
	_update = _update_title
	_draw = _draw_title
	base = 110
	base2 = 110
	palt(0, false)
	palt(11, true)
end

-->8
-- update functions
function _update_title()
	if btnp(🅾️) then
		_update = _update_intro
		_draw = _draw_intro
	end

	camera(0,0)
end

function _update_intro()
		if base > 5 then
		base -= 0.5
	 end

	 if btnp(🅾️) then
		_update = _update_walk
		_draw = _draw_walk
		end
end


function _update_walk()

	move_player()
	chk_dialog()
	

	update_npcs()
	update_animations()
	
	update_camera()
end

function update_camera() -- used to keep camera in bounds
	local ox = 56
	local oy = 48
	
	if p.x>56 and p.x<952 then
		ox = p.x - 56
	elseif p.x<= 56 then
		ox = 0
	elseif p.x>=952 then
		ox = 896
	end
	
	if p.y>48 and p.y<176 then
	 oy = p.y - 48
	elseif p.y<= 48 then
		oy = 0
	elseif p.y >= 176 then
		oy = 128
	end

	cam.x = ox
	cam.y = oy
	
	camera(ox, oy)
end

function _update_dialog()
	if btnp(🅾️) then
		if dialog.curr < #dialog.lines then
			dialog.curr += 1
		elseif dialog.battle then
			-- enter battle minigame
			init_battle()
		else
			-- return to walking mode
			
			-- add exp if talk to neighbor
			if dialog.active_npc.sprite == 67 and p.exp == 3 then 
				p.exp += 1
				spawn_dom()
			end
			_update = _update_walk
			_draw = _draw_walk
		end
	end

	update_bob_anim()
	update_camera()

	-- camera(p.x-60, p.y-60)
end

function init_battle()
	-- spawn pickups
	battle.pickups = {}
	add(battle.pickups, {
		sprite = 221,
		x = flr(rnd(64)),
		y = flr(rnd(64)),
		w = 8,
		h = 8,
		active = true
	})
	add(battle.pickups, {
		sprite = 221,
		x = flr(rnd(64)),
		y = 58+flr(rnd(64)),
		w = 8,
		h = 8,
		active = true
	})
	add(battle.pickups, {
		sprite = 221,
		x = 58+flr(rnd(64)),
		y = flr(rnd(64)),
		w = 8,
		h = 8,
		active = true
	})
	add(battle.pickups, {
		sprite = 221,
		x = 58+flr(rnd(64)),
		y = 58+flr(rnd(64)),
		w = 8,
		h = 8,
		active = true
	})
	battle.p.x = 64
	battle.p.y = 64
	battle.enemies = {}
	battle.collected = 0
	battle.health = 4
	take_dmg()
	_update = _update_start_battle
	_draw = _draw_start_battle
end

function _update_start_battle()
	animations.transition.curr += animations.transition.step

	if animations.transition.curr >= animations.transition.final then
		_update = _update_battle
		_draw = _draw_battle
		animations.transition.curr = 1
	end
end

function _update_end_battle()
	if animations.transition_end.curr >= animations.transition_end.final then
		animations.transition_end.curr = 0
		_update = _update_dialog
		_draw = _draw_dialog
	else
		animations.transition_end.curr += animations.transition_end.step
	end
end

function _update_battle()
	-- player movement
	if btn(⬅️) and battle.p.x > 0 then
		battle.p.x -= battle.p.speed
	elseif btn(➡️) and battle.p.x < 127 then
		battle.p.x += battle.p.speed
	end
	if btn(⬆️) and battle.p.y > 0 then
		battle.p.y -= battle.p.speed
	elseif btn(⬇️) and battle.p.y < 127 then
		battle.p.y += battle.p.speed
	end

	-- deplete iframes
	if battle.invincibility > 0 then
		battle.invincibility -= 1
	end

	-- pickup logic
	for pickup in all(battle.pickups) do
		if pickup.active then
			if battle.p.x > pickup.x and
			   battle.p.x < pickup.x+pickup.w and
			   battle.p.y > pickup.y and
			   battle.p.y < pickup.y+pickup.h then
				pickup.active = false
				battle.collected += 1
			end
		end
	end

	-- enemy spawning
	if #battle.enemies < battle.enemy_max and rnd() < battle.enemy_spawn_chance then
		spawn_enemy()
	end


	for e in all(battle.enemies) do
		-- enemy collision check
		if battle.p.x+battle.p.w >= e.x and
		   battle.p.x <= e.x+e.w and
		   battle.p.y+battle.p.h >= e.y  and
		   battle.p.y <= e.y+e.h and
		   battle.invincibility == 0 then
			take_dmg()
		end
		-- enemy movement
		e.x += e.v.x
		e.y += e.v.y
		e.ttl -= 1
		if e.ttl < 0 then
			del(battle.enemies, e)
		end
	end

	-- win condition
	if battle.collected == #battle.pickups then
		dialog.lines = dialog.active_npc.win_lines
		dialog.active_npc.battle = false
		dialog.battle = false
		dialog.curr = 1
		p.exp += 1
		
		if p.exp == 3 then -- see all 3 fakes
			spawn_neighbor()
		end

		battle_end()
	end

	-- loss condition
	if battle.health <= 0 then
		dialog.lines = dialog.active_npc.lose_lines
		dialog.battle = false
		dialog.curr = 1
		battle_end()
	end

end

function battle_end()
	_update_dialog()
	_update = _update_end_battle
	_draw = _draw_end_battle
end

function do_shake()
	animations.shake.x = 16 - rnd(32)
	animations.shake.y = 16 - rnd(32)
	animations.shake.x *= animations.shake.strength
	animations.shake.y *= animations.shake.strength

	camera(animations.shake.x, animations.shake.y)

	animations.shake.strength = animations.shake.strength*animations.shake.fade_factor
	if animations.shake.strength < 0.05 then
		animations.shake.strength = 0
	end
end

function take_dmg()
	battle.health -= 1
	battle.invincibility = battle.iframes
	animations.shake.strength = animations.shake.max_strength
end

function spawn_enemy()
	-- spawn enemy
	_angle = flr(rnd(360))+1
	_x = 64 + flr(rnd(127))-64 + 180*cos(_angle / 360)
	_y = 64 + flr(rnd(127))-64 + 180*sin(_angle / 360)
	_speed = rnd(battle.enemy_speed_range) + battle.enemy_min_speed
	_xvel = -1 * _speed*cos(_angle/360)
	_yvel = -1 * _speed*sin(_angle/360)
	add(battle.enemies, {x = _x, y = _y, v = {x = _xvel, y = _yvel}, ttl = battle.enemy_ttl, w = 8, h = 8})
end

function move_player()
	animations.p.dir = 0
	if btn(⬅️) then
		p.x -= p.speed
		animations.p.dir = 1
		if chk_npc_coll(0) or chk_map_coll(1) then
			p.x += p.speed
		end
	elseif btn(➡️) then
		p.x += p.speed
		animations.p.dir = 2
		if chk_npc_coll(0) or chk_map_coll(2) then
			p.x -= p.speed
		end
	end
	if btn(⬆️) then
		p.y -= p.speed
		animations.p.dir = 3
		if chk_npc_coll(0) or chk_map_coll(3) or p.y <= -24 then
			p.y += p.speed
		end
	elseif btn(⬇️) then
		p.y += p.speed
		animations.p.dir = 4
		if chk_npc_coll(0) or chk_map_coll(4) or p.y >= 224  then
			p.y -= p.speed
		end
	end
end

function chk_dialog()
	-- prompt return to home
	if p.exp == 3 and not p.prompt_final then
		_update = _update_dialog
		_draw = _draw_dialog
		dialog.lines = return_prompt
		dialog.curr = 1
		p.prompt_final = true
	end

	-- end game
	if p.exp == 5 then
	_draw = _draw_ending
	_update = _update_ending
	end

	-- check whether to enter dialog mode
	if btnp(🅾️) then
		for npc in all(npcs) do
			if npc.active then
				-- enter dialog mode
				_update = _update_dialog
				_draw = _draw_dialog
				dialog.active_npc = npc
				dialog.lines = npc.lines
				dialog.battle = npc.battle
				dialog.curr = 1
			end
		end
	end
end

function update_npcs()
	for npc in all(npcs) do
		if dist(p.x, p.y, npc.x, npc.y) < p.interact_rad then
			npc.active = true
		else
			npc.active = false
		end
	end
end

function spawn_neighbor()
	npcs[4].x = 911
	npcs[4].y = 190
end

function spawn_dom()
	npcs[2].x = 435
	npcs[2].y = 185
end

function update_animations()
	update_bob_anim()

	if animations.p.curr == animations.p.final then
		animations.p.curr = 0
	else
		animations.p.curr += 1
	end
	if animations.p.curr < animations.p.final/2 then
		animations.p.active = true
	else
		animations.p.active = false
	end
end

function update_bob_anim()
	if animations.bob.curr == animations.bob.final then
		animations.bob.curr = 0
	else
		animations.bob.curr += 1
	end
	if animations.bob.curr < animations.bob.final/2 then
		animations.bob.active = true
	else
		animations.bob.active = false
	end
end

function _update_ending()
	camera(0,0)
	
	if base2 > 5 then
		base2 -= 0.5
	end
end
-->8
-- draw functions

function _draw_title()
	cls(1)
	local line1 = {71, 72, 73, 122, 74, 75, 76, 108, 73, 124, 87}
	local line2 = {88, 89, 90, 122, 91, 75, 92, 73}
	local wx = 8
	local wy = 24
	for l in all(line1) do
		spr(l, wx, wy, 1, 1)
		wx += 7
	end

	wy += 10
	wx = 50

	for l in all(line2) do
		spr(l, wx, wy, 1, 1)
		wx += 7
	end

	print("press 🅾️ to begin", 30, 64, 7)
	print ("◆ggj 2021◆", 40, 100, 7)
	print("joshua cepeda, erin markel,", 10, 108, 7)
	print("luke reifenberg, tanner waltz,", 5, 114, 7)
	print("and spencer wells ♥", 27, 120, 7)
end



function _draw_intro()
	cls(1)
		local _y = 5
		for l in all(intro_text) do
			if l[4] != nil then
				_c = l[4]
			else
				_c = 7
			end
			print(l[2], l[3], flr(_y+base), _c)
			_y += l[1]
		end

		if base <= 5 then
		print("press 🅾️ to continue", 28, 118)
		end
end

function _draw_walk()
 cls(1)
 -- draw map
 map(0, 0, 0, 0, 128, 32)
 -- draw player
 draw_player()

	-- draw npcs
	draw_npcs()
end

function _draw_dialog()
	-- draw the background
	_draw_walk()

	-- draw the dialog box
	rectfill(cam.x+2, cam.y+2, cam.x+125, cam.y+32, 0)
	rect(cam.x+2, cam.y+2, cam.x+125, cam.y+32, 7)
	-- rectfill(p.x-60, p.y-60, p.x+64, p.y-32, 0)
	-- rect(p.x-60, p.y-60, p.x+64, p.y-32, 7)

	-- draw the text
	local b = 0
	for l in all(dialog.lines[dialog.curr]) do
		print(l, cam.x+8, cam.y+8+b)
		b += 6
	end
	-- dialog continue arrow
	if animations.bob.active then
		_offset = 1
	else
		_offset = 0
	end
	pset(cam.x+120, cam.y+27+_offset, 7)
	rectfill(cam.x+119, cam.y+25+_offset, cam.x+121, cam.y+26+_offset, 7)
	-- rectfill(p.x+58, p.y-38+_offset, p.x+60, p.y-37+_offset, 7)
	-- pset(p.x+59, p.y-36+_offset, 7)
end

-- battle start cutscene
function _draw_start_battle()
	_draw_dialog()
	for a=1,animations.transition.curr,animations.transition.draw_step do
		line(cam.x+64, cam.y+64, cam.x+64+(animations.transition.r*cos(a/360)), cam.y+64+(animations.transition.r*sin(a/360)), 5)
	end
end

function _draw_end_battle()
	_draw_dialog()
	rectfill(cam.x, cam.y+animations.transition_end.curr, cam.x+127, cam.y+127, 5)
	-- spr(battle.p.sprite, p.x - 50 + battle.p.x, battle.p.y - 58 + battle.p.y)
end

function _draw_battle()
	-- camera(animations.shake.x, animations.shake.y)
	cls(5)

	do_shake()

	for pickup in all(battle.pickups) do
		if pickup.active then
			spr(pickup.sprite, pickup.x, pickup.y)
		end
	end

	for e in all(battle.enemies) do
		spr(battle.enemy_sprite, e.x, e.y)
	end

	spr(battle.p.sprite, battle.p.x, battle.p.y)
	if battle.invincibility > 0 then
		circ(battle.p.x + 4, battle.p.y+4, 7, 7)
	end

	for h = 1, battle.health do
		spr(171, h*16-16, 110, 2, 2)
	end
end

function draw_player()
	-- draw player
	if animations.p.dir == 0 then
		spr(129, p.x, p.y, 2, 4)
	elseif animations.p.dir == 1 then
		if animations.p.active then
			spr(131, p.x, p.y, 2, 4, true, false)
		else
			spr(133, p.x, p.y, 2, 4, true, false)
		end
	elseif animations.p.dir == 2 then
		if animations.p.active then
			spr(131, p.x, p.y, 2, 4, false, false)
		else
			spr(133, p.x, p.y, 2, 4, false, false)
		end
	elseif animations.p.dir == 3 then
		if animations.p.active then
			spr(137, p.x, p.y, 2, 4, false, false)
		else
			spr(137, p.x, p.y, 2, 4, true, false)
		end
	elseif animations.p.dir == 4 then
		if animations.p.active then
			spr(135, p.x, p.y, 2, 4, true, false)
		else
			spr(135, p.x, p.y, 2, 4, false, false)
		end
	end

end

function draw_npcs()
	for npc in all(npcs) do
		spr(npc.sprite, npc.x, npc.y, 2, 4)
		if npc.y <= p.y and abs(p.x-npc.x) < 50 then
		 -- redraw player if they should be in front
			draw_player()
		end
		_color = 7
		if npc.active then
			_color = 14
		end
			if animations.bob.active then
				_offset = -1
			else
				_offset = 0
			end
			print("🅾️", npc.x+4, npc.y-npc.v_offset+_offset, _color)
	end
end

function _draw_ending()
	cls(1)
	local _y = 5
	for l in all(ending_text) do
		if l[4] != nil then
			_c = l[4]
		else
			_c = 7
		end
		print(l[2], l[3], flr(_y+base2), _c)
		_y += l[1]
		end
end
-->8
-- helper functions
function dist(a_x, a_y, b_x, b_y)
	local dx, dy = a_x - b_x, a_y - b_y
	local sdx, sdy = shr(dx, 8), shr(dy,8)
	return shl(min(0x0.7fff, sdx*sdx + sdy*sdy),16)
	
end

function chk_npc_coll(rad)
	for npc in all(npcs) do
	if p.x-rad <= npc.x+npc.width and
		   p.x + p.width >= npc.x-rad and
		   abs(p.y-npc.y) < 2 then
		   return true
	 end
	end
	return false
end

function chk_map_coll(dir)
	-- we check map collision for the bottom half of the sprite
	if dir == 1 then -- left
		_x = p.x + 3
		_y = p.y + 32
	elseif dir == 2 then -- right
		_x = p.x + 12
		_y = p.y + 32
	elseif dir == 3 then -- up
		_x = p.x + 8
		_y = p.y + 24
	elseif dir == 4 then -- down
		_x = p.x + 8
		_y = p.y + 33
	else
		return nil
	end

	map_x = _x / 8
	map_y = _y / 8
	return fget(mget(map_x, map_y), 0)
end


__gfx__
00000000bbbbbbbbbbbbbbbb88868888000000007666666666666666666644446666666666666666444466667777ffffffffffff111111111111111111111111
00000000bbbbbbbbbbbbbbbb88868888000000006657656557567576666455552666666666666664555546667fff4444444444441cccccccccccccccccccccc1
00700700bbbbbbbbbbbbbbbb66666666000000006565665555665656664555551266666666666645555114667f444444444444441c60060600640600060060c1
00077000bbbbb1111111bbbb68886888000000006565565555655656664555511226666666666445551114667444444f5f5444441c00606006446006600600c1
00077000bbbb111111111bbb6888688800000000656556555565565666455551112666666666645555111466f444f54f5f54f4441c06000060460060006006c1
00700700bbb11111111111bb6666666600000000656556555565565666455511112266666666445551111466f444f54f5f5444441c60060600640600060060c1
00000000bbb111111111111b8886888800000000656556555565565666445511126266666666464511114266f444f54f5f5445441c00606006446000600600c1
00000000bb1111111111111b8886888800000000656556555565565666464566626626666664664666146266f454f54f4f4445441c5555555555555555555551
00000000b1111117711111112226222200000000656556555565565666644445511126666664555514442666f454f44f5f544444111111111111111111111111
00000000b1111117711111112226222200000000656556555565565666664541111126666664551114126666f45ff54f5f5445441cccccccccccccccccccccc1
0000000011111117711111116666666600000000676666655667666666664141111126666664511114126666f454f54f5f5445441c06060000440000000001c1
0000000011111117711111116222622200000000666666666666666666664444222222666644444444426666f454f54f5f5445441c60000000440000000001c1
0000000011111117711111116222622200000000656556566565565666664664466662666646666426626666f454f54f5f5445441c006ff60069e600000601c1
0000000011177777777777116666666600000000675665755756757666664626646666266466664662626666f454f54f5f5445441c06dfd6dd696006406401c1
0000000011177777777777112226222200000000656556566565565666640266664666624666646666262666f454f54f5f4445441c60dd6d96940064464461c1
0000000011111117711111112226222200000000666666666666666666640266664666624666646666262666f454f54f544476441c006dd699640644644601c1
0000000011111117711111113333377776666666666666666663333366666666666666666666668ee8666666f454f54f545466441c06fe6900640646446221c9
0000000011111117711111113377775555555555555555555566633366666666666666666666682288e66666f454f54f5f5445441c6ee6eee6996444462221c1
00000000111111177111111137655353553535535355353553555533666666666666666666666e8d88866666f454f54f5f5445441cf622e66f869962622621c1
00000000111111177111111137633535335353353533535335353533664f4444444666666666666226666666f454f54f5f5445441c62226822869969226f21c1
00000000111111177111111133633555335553355533555335553533664f111111f6666666ccccc22ccccc66f454444f545445441c2266888888969926fff1c1
00000000b11111177111111b33677656556565565655656556565666645f177117166666ccccccccccccccccf454454f545445441c268886668869996fff51c1
00000000b11111177111111b33675655555555555555555555555636645f1177771466666ccccccccc111166f454454f545445441c28886828868969fff651c1
00000000b11111177111111b336635353353533535335353353536336454f117171f66666666666656666666f4544544545445441c55555555555555555551c1
00000000b11111111111111b33665555555555555555555555355633666561111111f6666666666656666666f454454454444544111111111111111111111111
00000000b11111111111111b3367666666666666666666666666666364564f171771f6666666666656666666f4544544544445441cccccccccccccc1ccccccc1
00000000b11111111111111b33563777777777777777777777777663645554117171f6666666666656666666f4544544545445441cddddddddddddc1cdddddc1
00000000bb111111111111bb33533633333333333333333333553663455554f111111f666666666556666666f4544544545445441cd55555555555c1cd5555c1
00000000bbb1111111111bbb3353363333333333333333333335336345555541171714666666665555666666f4544544545445441cd55555555555c1cd5555c1
00000000bbbb111111111bbb335336333333333333333333333533634555564f117111466666655555556666f4444444444444441cd55555555555c1cd5555c1
00000000bbbb11111111bbbb335336333333333333333333333533634566666f444444466565556666655565f4444444444444441cccccccccccccc1ccccccc1
00000000bbbb11111111bbbb3355366333333333333333333335536646666666f66666646655666666666550f555555555555555111111111111111111111111
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4444bbbbbbbbbbbbb7bb7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33611533
00000000bbbbbbbfffbbbbbbbbbbbbbbbbbbbbbbbbbbb4fff4bbbbbbbbb7777bbb7bbbbbbbbbbbbbbbb77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb33333333
00000000bbbbbb4fff4bbbbbbbbbbbbbbbbbbbbbbbbbb4ffff4bbbbbbb7bb7bbbb777bbbb77bbbbbbb777bbbbbb77bbb7b77bbbbbbbbbbbbbbbbbbbb66666535
00000000bbbbbbfffffbbbbbbbbbbbbbbbbbbbbbbbbbb4ffff4bbbbbbbbbb7bbbb7bb7bb7bb7bbbbbbb7bbbbbb77b77bb7bb7bbbbbbbbbbbbbbbbbbb33556333
00000000bbbbbbfffffbbbbbbbbbbbbbbbbbbbbbbbbb4bffff44bbbbbbbbb7bbbb7bb7bb777bbbbbbbb7bbbbbb7b77bbb7bb7bbbbbbbbbbbbbbbbbbb33311336
00000000bbbbbbbfffbbbbbbbbbbbbbbbbbbbbbbbbb4b777ffb4bbbbbbbbb7bbbb7bb7bb7bbbbbbbbb777bbbbb7bb7bbb7bb7bbbbbbbbbbaaabbbbbb33115336
00000000bbbbbb73f37bbbbbbbbbbbbbbbbbbbbbbbb47b77fbb4bbbbbbb77bbbbb7bb7bbb7777bbbbb77b777bbb77bbbb7bb77bbbbbbbbaaabbbbbbb33115333
00000000bbbbb17fff71bbbbb777bbbbbbbbbbbbbbbbc777fcccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaafffbbbbbb33115333
00000000bbbb7717f7177bbb77777bbbbbbbbbbbbbbbccfcccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaffffbbbbbb33113333
00000000bbb77717717777bb7ff777bbbbbbbbbbbbbbcffcccbfbbbbbbbbbbbbbb7bbb7bbbbbbbbb7bb7bbbbbb7bbb7bbbbbbbbbbbbbbaffffbbbbbb33131333
00000000bbbff717717bffbb4fff77bbbbbbbbbbbbbbffccccbfbbbbb7bbbbbbb77bbb7bbb77bbbb7bb7bbbbb77bbb7bb77b7bbbbbbbbbbfbbbbbbbb33333333
00000000bbffb771717bbfbbffff7bbbbbbbbbbbbbbffcccccbfbbbb777bbbbbbb7bbb7bb7bb7bbb7bb7bbbbbb7bbb777bb7b7bbbbbbb88f8bbbbbbb33333333
00000000bbfbb771717bbfbb77777bbbbbbbbbbbbbbbbbcccbfbbbbbb7bbbbbbbb7b7b7bb7bb7bbb7bb7bbbbbb77777b7bb7b7bbbbbbb8888bbbbbbb13131333
00000000bbfbbb71717bbfbb77e77eebbbbbbbbbbbbbbbcccffbbbbbb7bbbbbbbb7b7b7bb7bb7bbbb7777bbbbb7bbb7b7bb7b7bbbbbbf8878ffbbbbb13113333
00000000bbfbbb71717bbfbb7eeeeeeeebbbbbbbbbbbbbcccfbbbbbb7b77bbbbbbb7b7bbbb77b7bb7bb7bbbbbb7bbb7b7bb7b77bbbbff8878fffbbbb63313333
00000000bbfbbb71717bbfbb74eeeeeeebbbbbbbbbbbbbcccfbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77bbbbbbbbbbbbbbbbbbbbbbbbff8878bbffbbb66611533
00000000bbbbbb44444bbbbb7eeeeeeeeebbbbbbbbbbb44444bbbbbb6666666666666666666666666666666655555555bbbbbbbbbbbfb8888bbbfbbb55555555
00000000bbbbbb55555bbbbb6eeebeeeeebbbbbbbbbbcccccccbbbbb6666666666666666666666666666666655555555bb77bbbbbbbfb8878bbbfbbb55555555
00000000bbbbbb55555bbbbbeebbbeeeeebbbbbbbbbbbccccccbbbbb6666666666666666666666666666666655555555b7bb7bbbbbbfb88888bbfbbb55555555
00000000bbbbbb55555bbbbbebbbbeeeeebbbbbbbbbbbccccccbbbbb5555555566665555555566666666666655555555b7bb7bbbbbffb88888bbfbbb55555555
00000000bbbbbb55555bbbbbebbbbeeeeebbbbbbbbbbbcccccccbbbb5555555566655555555556666666666655555555b7bb7bbbbbbbb44444bbbbbb66655566
00000000bbbbb55bb55bbbbbf5bbbeeeeebbbbbbbbbbccccccccbbbb6666666666655555555556666666666655555555bb7777bbbbbbb99999bbbbbb66666666
00000000bbbbb55bb55bbbbb5b5bbeee2eebbbbbbbbbccccccccbbbb6666666666655566665556666666666655555555b7bb7bbbbbbbb99999bbbbbb66666666
00000000bbbbb55bbb55bbbb5bbbbe22222ebbbbbbbccccccccccbbb6666666666655666665556666666666655555555bb77bbbbbbbbb999999bbbbb66666665
00000000bbbbb55bbb55bbbb5bbbb222222bbbbbbbccccccccccccbb666556666665566666655666bbbbbbbb555a5555bbbbbbbbbbbbb99bbb9bbbbb66666606
00000000bbbbb55bbb55bbbb5bbbb222b22bbbbbbcccccccccccbbbb666556666665556666555666bbbbbbbb55555555bbbbbbbbbbbbb9bbbb9bbbbb66606666
00000000bbbb555bbb55bbbb5bbbb22bb22bbbbbcccbfbbbbbfbbbbb666556666665555555555666bbbbbbbb555a5555b777bbbbbbbb99bbbb9bbbbb60066666
00000000bbbb555bbb55bbbb5bbbb22bb22bbbbbbbbbfbbbbbfbbbbb666556666665555555555666bbbbbbbb555555557bbbbbbbbbbb9bbbbb9bbbbb66665556
00000000bbbb555bbb55bbbb5bbb222bb22bbbbbbbbbfbbbbbfbbbbb666556666666555555556666bbbbbbbb555a5555b77bbbbbbbbb9bbbbb9bbbbb66655556
00000000bbbb555bbb55bbbb5bbb222bbb22bbbbbbbbfbbbbbfbbbbb666556666666666666666666bbbbbbbb55555555bbb7bbbbbbbb9bbbbb9bbbbb55555555
00000000bbb4444bbb444bbb5bbb555bbb55bbbbbbbbfbbbbbfbbbbb666556666666666666666666bbbbbbbb555a5555777b7bbbbbbb9bbbbb9bbbbb55555555
00000000bb44444bbb44444b5b55555bbb5555bbbbbbdbbbbbdbbbbb666556666666666666666666bbbbbbbb55555555bbbbbbbbbbbbaabbbbaabbbb55555555
44444444bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbb444441212114444444444444
444c4447bbbbbb00000bbbbbbbbbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbb00000bbbbbbbbbbb00000bbbbbbbbbbbbb0099900b44442121211244447444e848
444c747cbbbbb0000000bbbbbbbbb0000000bbbbbbbbbb00000bbbbbbbbbb0000000bbbbbbbbb0000000bbbbbbbbbbb00999990b4444eeeeeee24444e747e848
444cccccbbbbb0fffff0bbbbbbbbb000ffffbbbbbbbbb0000000bbbbbbbbb0fffff0bbbbbbbbb0000000bbbbbbbbbb009999999044444eeeee244444ee4ee474
4444c7c4bbbbb0fffff0bbbbbbbbb00fffffbbbbbbbbb000ffffbbbbbbbbb0fffff0bbbbbbbbb0000000bbbbbbbbb009aaaa999044444eeeee24444444748831
444cccccbbbbb00fff00bbbbbbbbbb00ffffbbbbbbbbb00fffffbbbbbbbbb00fff00bbbbbbbbb0000000bbbbbbbb00aaa44499404444eeeeeee24444ee3ee83c
4441c3c1bbbbbbbbfbbbbbbbbbbbbbbbfbbbbbbbbbbbbb00ffffbbbbbbbbbbbbfbbbbbbbbbbbbbbb0bbbbbbbbbb009999999940044477eeeeeee24442e3e2434
4442334cbbbbbbb8f8bbbbbbbbbbbbb8f8bbbbbbbbbbbbbbfbbbbbbbbbbbbbb8f8bbbbbbbbbbbbb888bbbbbbbb00aaaa9999400b44e7eeeeeeee2244e433e434
24223444bbbbb888f88bbbbbbbbbbb88f8bbbbbbbbbbbbb8f8bbbbbbbbbbb888f88bbbbbbbbbb888888bbbbbb00aa444999400bb44eeeeeeeeee224444433432
24234444bbbb88888888bbbbbbbbbb8888bbbbbbbbbbbb88f88bbbbbbbbb88888888bbbbbbbb88888888bbbb0099999999400bbb44eeeeeeeee2224444443442
47334444bbbbfb8888bfbbbbbbbbbb8f88bbbbbbbbbbbbf888ebbbbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb0aaaaa999400bbbb444eeeeeeee2244444443344
24224444bbbbfb8888bfbbbbbbbbbb88f8bbbbbbbbbbbf8888ebbbbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb9aa44499400bbbbb444eeeeeeee2244444443344
24324444bbbbfb8888bfbbbbbbbbbb88f8bbbbbbbbbbbf8888bebbbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb9999999400bbbbbb4444eeeeee22444444444342
34344444bbbbfb8888bfbbbbbbbbbb888fbbbbbbbbbbfb8888bebbbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb999994400bbbbbbb4444eeeeee22444444444344
14344444bbbbfb8888bfbbbbbbbbbe888fbbbbbbbbbfbb8888bbebbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb0444400bbbbbbbbb44444eeee224444444444343
14344444bbbbfb8888bfbbbbbbbbeb8888fbbbbbbbbfbb8888bbbebbbbbbfb8888bfbbbbbbbbfb8888bfbbbbb00000bbbbbbbbbb444442222224444444444343
00000000bbbbfb000bbfbbbbbbbbbb0000bbbbbbbbbbbb0000bbbbbbbbbbf6000bbfbbbbbbbbfb000bbfbbbbbbbbbbbbbb000bbbbbbbbbbbbbbbbbbb33333333
00000000bbbbb22222bbbbbbbbbbbb2222bbbbbbbbbbbb2222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbbb000099900bbbbbbbbbbbbbbbbb33333333
00000000bbbbb22222bbbbbbbbbbbb2222bbbbbbbbbbbb2222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbb0009994a9940bbbb6bbbbbbbbbbbb33333366
00000000bbbbb22222bbbbbbbbbbbb2222bbbbbbbbbbbb2222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbb099a994999490bbb6bbb6bbbb3bb33337e666
00000000bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbb09aa994499490bbb6bb16bb1b3bb3333ee666
00000000bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbb09a999940000bbb663b16bb133bb333366663
00000000bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbb094499990bbbbb3b663113bb133b1333366633
00000000bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbb09944900bbbbbb3b63311331113b1333666333
00000000bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb222222bbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbb09a9940bbbbbbb3b6331133111311333633333
00000000bbbbb2222fbbbbbbbbbbb22fbebbbbbbbbbbb22bbffbbbbbbbbbb2222fbbbbbbbbbbb2222fbbbbbbbb0aa9990bbbbbbb316331133311313333333333
00000000bbbbb2bbbfbbbbbbbbbbb2fbbebbbbbbbbbbb2ebbbfbbbbbbbbbb2bbbfbbbbbbbbbbb2bbbfbbbbbbbb0aa9990bbbbbbb313331333311313333333333
00000000bbbbbfbbbfbbbbbbbbbbbfbbbbebbbbbbbbbbebbbbfbbbbbbbbbbfbbbfbbbbbbbbbbbfbbbfbbbbbbbb0a44440bbbbbbb31333133331131333333d233
00000000bbbbbfbbbfbbbbbbbbbbfbbbbbebbbbbbbbbbebbbbfbbbbbbbbbbfbbbfbbbbbbbbbbbfbbbfbbbbbbbbb0999990bbbbbb313331133331333331112233
00000000bbbbbfbbbfbbbbbbbbbbfbbbbbebbbbbbbbbebbbbbbfbbbbbbbbbfbbbfbbbbbbbbbbbfbbbfbbbbbbbbbb09994400bbbb311311333331133333311333
00000000bbbbbfbbbfbbbbbbbbb4fbbbbbbe4bbbbbb4ebbbbbbf4bbbbbbbb4bbbfbbbbbbbbbbbfbbb4bbbbbbbbbbb0444990bbbb331313333333133333344444
00000000bbbbb4bbb4bbbbbbbbbb4bbbbbb4bbbbbbbb4bbbbbb4bbbbbbbbbbbbb4bbbbbbbbbbb4bbbbbbbbbbbbbbbb00000bbbbb331333333333333333444444
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333d333d33333333333334544444433113333333333333333333366666ee888866666
bbbbbb00000bbbbbeb33bbbbbbbbbbbebbbbbbbbbbbbbbbbb333bbbb33d33d33333d33333323333344445544331313313333333333333333666ee77777788666
bbbbb0000000bbbbe373bbccbbbbbbe7bbbbbbbbbb6b3bb1333333bb3d3333d333333333327233334444444433333711113333333333333366f7788888877866
bbbbb0000000bbbbe33999cccb22bbeebbbbbbbbb66333b1333333bb33d33333333d333333333323445444443333333333333313333333336e78888888887786
bbbbb0000000bbbb666979c766728886bbbbbbbb663333b13333333b33333d3333333d3333333272454444443333137313333313333333336e78888888888786
bbbbb0000000bbbbbbbb99cccb2b878bbbbbbbbb663333b13333333b3333d333333333d33332333354444445133133331311663333333333e788888888888878
bbbbbbbb0bbbbbbbbbbbbbbccbbbb8bbbbbbbbbb63333333333333bb33333d33333333333327233344444555333113136331333333333333e787777777777878
bbbbbbb888bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb63333333333333bb33333333333333333333333345445544313133136633353333333333e787777777777878
bbbbb888888bbbbbbbbbb33666333333333bbbbb3333bd333b33331b333333d3333333d33e333333444444443311331133333333bbbbbbbbe787777777777878
bbbb88888888bbbbbbbb336666333333333bbbbb3333bd533b55351b33d33d3333333333e7e333e3455444443333333133133331bbbbbbbb8787777777777878
bbbbfb8888bfbbbbbb33666633333333333bbbbb3333b55bb555331b3d3333d333333d3333333e7e454445443333333333333133baaaaaaa8788888888888878
bbbbfb8888bfbbbb33366663333333333333bbbbb131b155b555331b33d3333333d3d333333e3333444445441333331331315533a990409a6878888888888786
bbbbfb8888bfbbbb33666633333333333333bbbbb135bb55b511311b33333d333333333333e7e333445444443313631133773313a944949a6877888888888726
bbbbfb8888bfbbbb366633333333333333333bbbbb1d515555b131bb3333d3333d333333333333334445444433333733337535337aaaaaa66687788888877266
bbbbfb8888bfbbbb366333333333333333333bbbbb11d55555bb31bb33333d33333333333e3333e3444544553133331333313333767676766668877777722666
bbbbfb8888bfbbbb333333333333333310111bbbbbbb1d555513355b3333333333333333e7e33e7e444444443311333333333533767676766666688888266666
bbbbfb000bbfbbbb33333333333333331b11bbbbbbbbb155551331bb4444544445444454454444543c3333c300000000bbbbbbbbbb77777b6666666555666666
bbbbb22222bbbbbb333334333bb331b31b11bbbbbbbbbb5555133bbb444454444544445445444454c7c3cc7c00000000b7bbbb7bb77777776666666556666666
bbbbb22222bbbbbbbb3334bbbb4411b11bbbbbbbbbbbbb5555535bbb4444544445444554454445543c3c3c3c00000000bb7bb7bbb7bb7bb76666666656666666
bbbbb22222bbbbbbb333444bbb411b11bbbbbbbbbbbbbb55555bbbbb444554445544454455444544333c333300000000bbb77bbbb77777776666666656666666
bbbbb22222bbbbbbb33b4444b4111bbbbbbbbbbbbbbbbb55551bbbbb4445444454444544544445443cc7c3c300000000bbb77bbbb777b7776666666656666666
bbbbb22222bbbbbbbbbbfff4441bbbbbbbbbbbbbbbbbbb55551bbbbb444544445444454454444544c7cc3c7c00000000bb7bb7bbbb77777b6666666656666666
bbbbb22222bbbbbbbbbbbff4441bbbbbbbbbbbbbbbbbbb55551bbbbb4445444454444544544445443c3333c300000000b7bbbb7bbb7b7b7b6666666656666666
bbbbb22222bbbbbbbbbbbff4441bbbbbbbbbbbbbbbbbbb55551bbbbb444544445444454454444544c7c33c3c00000000bbbbbbbbbbbbbbbb6666666656666666
bbbbb22222bbbbbbbbbbbff4441bbbbbbbbbbbbbbbbbbb55551bbbbb4445444454444544544445440000000000000000bbbbbbbbbbbbbbbb6666666656666666
bbbbb2222fbbbbbbbbbbbf44441bbbbbbbbbbbbbbbbbbb55551bbbbb4445444454444544544445440000000000000000b000000bbbbbbbbb6666666656666666
bbbbb2bbbfbbbbbbbbbbbf44441bbbbbbbbbbbbbbbbbbb55551bbbbb4445444454444544544445440000000000000000b0ffff0bbaaaaaaa6666666656666666
bbbbbfbbbfbbbbbbbbbbbf444441bbbbbbbbbbbbbbbbbb55551bbbbb4445444454444544544445440000000000000000b888888ba990409a6666666656666666
bbbbbfbbbfbbbbbbbbbbbf4444411bbbbbbbbbbbbbbbbb555511bbbb4445444454444544544445440000000000000000b888888ba944949a6666666656666666
bbbbbfbbbfbbbbbbbbbbf4444441111bbbbbbbbbbbbbb5511111bbbb4445544455444554554445540000000000000000b888888b7aaaaaa66666666656666666
bbbbb4bbbfbbbbbbbbbf444544444111bbbbbbbbbbbb515111111bbb4444544445444454454444540000000000000000b888888b767676766666666555666666
bbbbbbbbb4bbbbbbb4444544454444111bbbbbbbbbb55111115111bb4444544445444454454444540000000000000000bbbbbbbb767676766666665555566666
__gff__
0000000100010100000000000001010100000001000101000000000000010101000000000000000000000000000101010000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1313131313131313131313136867676905060506050605060505060d0e0d0e0f0d0e0d0e0f0e0d0e0f0e0d0e0f0e0d0e0f0d0e0f686767676767676767676769cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd686767690506050605060506050506686767690303030303030303030303030303030303030303030303030303030303
13131313131313131313131377cecf7715161516151615161515161d1e1d1e1f1d1e1d1e1f1e1d1e1f1e1d1e1f1e1d1e1f1d1e1f77090a6a6a6a6a6a6a070877cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd77cecf77151615161516151615151677cecf770303030303030303030303030303030303030303030303030303030303
1313f7e8e9f8f7f8e7e8131377dedf776b6b6b6b6b7b6b6b6b6b6b2d2e2d2e2f2d2e2d2e2f2e2d2e2f2e2d2e2f2e2d2e2f2d2e2f77191a0708292a090a171877cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd77dedf776b6b6b6b6b7b6b6b6b6b6b77dedf770303e7e8e8e7e8e7e8e7e8e7e803e7e8e7e8e7e8e7e8e7e8e7e8e80303
1313e7f8f9e8e78f80f8131377eeef776b6b6b6b6b7b6b6b6b6b6b3d3e3d3e3f3d3e3d3e3f3e3d3e3f3e3d3e3f3e3d3e3f3d3e3f77292a1718393a191a292a77cdc8c8cdcdcdd9cdcdcdc8cdcdcdcdcd77eeef776b6b6b6b6b7b6b6b6b6b6b77eeef770303f7f8e7e8e7e8e7e8e7e8f803f7f8f7f8f7f8f7f8f7f8f7f8f80303
1313f78f80f8f79f90f8131377feff776b6b6b6b6b7b6b6b6b6b6b6867676767676767676767676767676767676767676767676779393a6a090a6a6a6a393a77cdc8c8c8c8c8cdcdcdcdc8cdcdcdcdcd77feff776b6b6b6b6b7b6b6b6b6b6b77feff770303e7e8f7f8f7f8f7f8f7f8f803e7e8e7e8e7e8e7e8e7e8e7e8e80303
1313e79f90e8e78d8ee81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a191a6a6a6a272877cdcdcdc8cdcdc8c8c8cd23242526cdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303f7f8e7e8e7e8e7e8e7e8e803f7f8f7f8f7f8f7f8f7f8f7f8f80303
1313f78d8ef8f79d9ef81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a373877cdcdcdd9cdcdcdcdeacd33343536cdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303e7e8f7f8f7f8f7f8f7f8f803e8e7e8e7e8e7e8e7e8e7e8e7e80303
1313e79d9ee8e7e8e7e81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a68676767676767676767676767676767676767676767676767676767676767676779cdcdcdcdcdcdcdcdcdcdcdcdcdc8cdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303f7f8e7e8e7e8e7e8e7e8e803f8f7f8f7f8f7f8f7f8f7f8f7f80303
1313f7f8f7f8f7f8f7f81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdcdcdc8cdcdcdcdcdcdcdcdcdc8cdcdcdcdcdcdcdeacdcdcdd9cdcdcdcdcdcdd9cdcdcdcdc9cdcdcdcdcdcdcdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303e7e8f7f8f7f8f7f8f7f8f803e8e7e8e7e8e7e8e7e8e7e8f7f80303
1313e7e8e7e8e7e8e7e81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdc8c8c8cdcdcdcdcdcdcdcdcdc8cdcdcdcdcdcdcdcdcdcdd9d9cdcdcdcdcdcdcdcdcdcdcdeacdcdc9cdcdeacdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303f7f8e7e8e7e8e7e8e7e8e803f8f7f8f7f8f7f8f7f8f7f8e7e80303
1313f7f8f7f8f7f8f7f81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77c8cdcdc8cdc8cdcdc8c8c8cdcdcdc8cdcdcdcdc8cdcdcdcdcdcdd9cdeacdcdcdd9cdcdcdcdcdd9eacdcdd9cdcdd9cdcdea776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303e7e8f7f8f7f8f7f8f7f8f803e8e7e8e7e8e7e8e7e8e7e8f7f80303
1313e7e8e7e8e7e8e7e81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77c8c8cdc8c8c8cdcdcdc8cdcdcdc8c8c8cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdd9cdcdcdcdcdcdcdeaeacdd9d9d9cdcdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303f7f8f7f8f7f8e7e8f7f7f8f7f8f7f8f7f8f7f8f7f8f7f8e7e80303
1313f7f8f7f8f7f8f7f81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77c8c8cdc8c8cdcdcdcdcdcdcdcdc8c8cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdeaeacdcdeacdd9d9eacdd9cdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770b0ce7e8e7e8e7e8f7f8e7e8e7e8e8f7f8f7f8f7f8f7f8e7e8f7f80303
1313e8e8e8e8e7e8e7e81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdc8c8cdcdcdcdcdcdcdcdcdcdc8cdcdcdcdcdcdd9cdcdcdcdcdcdcdcdd9d9cdcdcdcdeacdcdcdcdeacdd9d9cdd9cdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a771b1cf7f8f7f8f7f8f7f8f7f8f7f8f8f7f8e7e8e7e8e7e8f7f8f7f80303
1313f8f8f7f8f7f8e7e81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdc8c8cdcdcdcdcdcdcdcdc8cdcdcdcdcdcdcdcdcdcdcdcdd9cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdd9cdeacdcdcdeacdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a772b2ce7e8e7e8e7e8e7e8e7e8e70303e7e8f7f8f7f8e7e8e7e8e7e80303
1313e7e8e7e8e7e8f7f81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdc8c8cdcdcdcdcdcdcdcdcdc8cdcdcdcdcdcdcdcdcdcdd9cdcdcdcdcdcdcdcdcdeacdcdcdcdcdcdd9d9eaeaeacdd9cdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a773b3cf7f8f7f8f7f8f7f8f7f8f7f8f8f7f8f7f8e7e8f7f8f7f8f7f80303
1313f7f8f7f8f7f8f7f81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77c8c8cdcdcdcdcdcdc8c8c8cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdd9cdcdcdcdcdcdcdcdcdcdeaeacdeacdd9d9eaeacdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303e7e8e7e8e7e8e7e8e7e8e7e8e8e7e8e7e8f7f8e7e8e7e8e7e80303
1313e7e8e7e8e7e8e7e80b0c776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77c8c8cdcdcdcdcdcdcdc8c8c8cdcdcdcdcdcdcdcdcdcdcdcdcdcdd9cdcdcdcdcdcdcdcdcdeacdcdcdeaead9eaeacdcdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303f7f8f7f8f7f8f7f8f7f8f7f8f8f7f8f7f8f7f8f7f8f7f8f7f80303
1313f7f8f7f8f7f8f7f81b1c776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdcdc8c8cdcdcdcdcdcdcdcdcdc9cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdd9cdeacdcdcdcdcdcdcdcdeaeacdcdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303e7e8e8e8e7e8e7e8e8e7e803030303030303030303030303030303
1313e7e88f80e7e8e7e82b2c776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdcdc9c9cdcdcdcdcdcdcdcdc9cdcdcdcdcdcdcdcdcdd9d9cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdeacdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303f7f8f8f8f7f8f7f8f8f7f803e7e7e8e7e8e7e8e7e7e7e7e7e70303
1313f7f89f90f78f80f83b3c776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdc9cdcdcdcdcdcdcdcdcdc9cdcdcdcdc9cdcdcdcdcdcdcdcdcdcdd9cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdd9cdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303e7e8e7e8e8e7e8e7e8e7e803f7f7f8f7e7e8f8e7f7f8e7e7e70303
1313f7f88d8ef79f90e81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdc9cdcdc9cdcdc9cdcdcdcdc9cdcdcdcdc9eaeaeaeacdcdcdcdc9cdcdcdcdcdcdcdcdc9c9cdcdcdcdcdcdcdcdcdc9776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303f7f8f7f8f8f7f8f7f8f7f803f7f8f7e7f7f8e8e7e7e8e7e7e80303
1313e7e89d9ee78d8ef81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdeaeaeaeaead9eacdcdcdc9cdcdcdcdcdcdc9cdcdc9cdcdcdcdcdcdd9cdcdcdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303e7e8e7e8e7e8e7e8e7e8e803e7e8e7e8e7e8f8f7f7f8e7e8f80303
1313f7f8f7f8f79d9ef81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdc9cdcdcdcdcdcdcdcdcdcdeaeaeaeaeaead9cdcdcdcdcdeaeaeaeacdcdcdcdcdcdc9cdcdcdcdcdcdcdcdcdcdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303f7f8f7f8f7f8f7f8f7f8f803f7f8f7f8f7e7e8e7e8e7f7f8e80303
1313e78f80e8e7e8e7e81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdd9cdcdcdcdc9cdcdcdcdeaeaeaead9d9cdcdcdcdcdcdc9eaeaeacdcdcdc9cdcdc9c9cdcdcdcdcdcdcdcdcdcdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303e7e8e7e8e7e8e7e8e7e7e8e7e7e8e7e8e7f7f8f7f8f7f8f7f80303
1313f79f90f8f78f80f81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdcdcdd9cdcdcdcdcdcdcdcdcdeaeaeaeaead9cdcdcdcdcdcdcdeaeacdc9cdcdcdc9cdcdcdcdcdcdcdcdcdcdcdcdcdcdcd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303f7f8f7f8f7f8f7f8f7f7f8f7f7f8f7f8f7f8f7f8f7e7e8e7e80303
1313e78d8ee8e79f90e81313776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a77cdd9d9cdcdcdeacdcdcdcdcdeaeaeaeaeacdcdcdcdcdcdcdcdcdd9eacdcdcdcdcdcdcdcdcdd9cdcdcdcdcdcdcdcdcdc9cd776a6a776b6b6b6b6b7b6b6b6b6b6b776a6a770303e7e8e8e7e8e7e8e7e8e7e803e7e8e7e8e7e8e7e8e7f7f8f7f80303
1313f79d9ef8f78d8ef8131377cecf776b6b6b6b6b7b6b6b6b6b6b77cecf77cdd9cdcdcdcdeacdcdcdcdeaeaeaeaead9cdcd23242526cdcdcdeaeacdcdcdcdcdcdcdcdd9cdcdcdcdcdcdcdcdd9cdcdcd77cecf776b6b6b6b6b7b6b6b6b6b6b77cecf770303f7f8f8f7f8f7f8f7f8f7f803f7f8f7f8f7f8f7f8f7f8f7e7e80303
1313e7e8e7e8e79d9ee8131377dedf776b6b6b6b6b7b6b6b6b6b6b77dedf77cdcdcdcdcdeacdcdcdcdcdeaeaeaeaead9cdcd33343536cdcdd9d9eaeaeacdcdcdcdcdcdc9c9cdc9cdcdcdcdd9d9cdcdcd77dedf776b6b6b6b6b7b6b6b6b6b6b77dedf770303e7f7f8f7f8e7e8e7e8e7e803e7e8e7e8e7e8e7e8e7e8e7e7e80303
1313f7f8f7f8f7f8f7f8131377eeef776b6b6b6b6b7b6b6b6b6b6b77eeef77d9cdcdcdcdcdcdcdcdeaeaeacdeaeaeaeacdcdcdcdcdcdcdcdd9d9d9eaeacdcdd9cdcdcdcdcdd9d9cdcdcdcdcdcdcdc9d977eeef776b6b6b6b6b7b6b6b6b6b6b77eeef770303f7f8f7f8f8f7f8f7f8f7f803f7f8f7f8f7f8f7f8f7f8f7f7f80303
13131313131313131313131377feff77050605060506050605060677feff77cdcdcdcdd9cdcdcdcdcdcdcdeaeaead9eaeaeaeaeaeaeaeaead9d9d9d9eacdcdcdcdcdcdd9cdcdcdcdcdcdc9cdcdcdcdcd77feff77050606050605060506050677feff770303030303030303030303030303030303030303030303030303030303
13131313131313131313131378676779151615161516151615161678676779cdcdcdd9cdcdcdcdcdcdcdcdeaeaeaeaeaeaeaeaeaeaeaeaeaead9d9d9eacdcdcdcdcdd9d9cdcdcdcdcdd9cdcdcdcdcdcd786767791516161516151615161516786767790303030303030303030303030303030303030303030303030303030303
