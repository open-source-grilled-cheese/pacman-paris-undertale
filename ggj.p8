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
		max_strength = 0.8,
		fade_factor = 0.8
	}
}
p = {
	x = 64,
	y = 64,
	width=16,
	height=32,
	interact_rad = 35
}
npcs = {
	{
		active = false,
		battle = false,
		x = 0,
		y = 0,
		width = 16,
		height = 32,
		sprite = 68,
		lines = {
			"hey there!",
			"goodbye."
		},
		win_lines = {},
		lose_lines = {}
	},
	{
		active = false,
		battle = false,
		x = 128,
		y = 128,
		width = 16,
		height = 32,
		sprite = 66,
		lines = {
			"what's up?",
			"farewell."
		},
		win_lines = {},
		lose_lines = {}
	},
	{
		active = false,
		battle = true,
		x = 64,
		y = 16,
		width = 16,
		height = 32,
		sprite = 64,
		lines = {
			"what do you want?!"
		},
		win_lines = {
			"ah, sorry."
		},
		loss_lines = {
			"stop wasting my time!"
		}
	}
}
battle = {
	p = {
		sprite = 196,
		x = 64,
		y = 64,
		w = 8,
		h = 8,
		speed = 1.5
	},
	pickups = {
		{
			sprite = 195,
			x = 16,
			y = 16,
			w = 8,
			h = 8,
			active = true
		},
		{
			sprite = 195,
			x = 100,
			y = 100,
			w = 8,
			h = 8,
			active = true
		}
	},
	enemies = {},
	enemy_max = 35,
	enemy_speed = 1.5,
	enemy_sprite = 104,
	enemy_spawn_chance = 0.3,
	enemy_ttl = 150,
	collected = 0,
	health = 3,
	iframes = 20,
	invincibility = 0,
	win = false
}

dialog = {
	active_npc = {},
	lines = {},
	curr = 1,
	battle = false
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

function _init()
	_update = _update_title
	_draw = _draw_title
	base = 95
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

	camera(p.x-60,p.y-60)
end

function _update_dialog()
	if btnp(🅾️) then
		if dialog.curr < #dialog.lines then
			dialog.curr += 1
		elseif dialog.battle then
			-- enter battle minigame
			init_battle()
			_update = _update_battle
			_draw = _draw_battle
		else
			-- return to walking mode
			_update = _update_walk
			_draw = _draw_walk
		end
	end

	camera(p.x-60, p.y-60)
end

function init_battle()
	for pickup in all(pickups) do
		pickup.active = true
	end
	battle.enemies = {}
	battle.collected = 0
	battle.health = 3
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
		if battle.p.x >= e.x and
		   battle.p.x <= e.x+e.w and
		   battle.p.y >= e.y  and
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
		_update = _update_dialog
		_draw = _draw_dialog
		dialog.lines = dialog.active_npc.win_lines
		dialog.battle = false
		dialog.curr = 1
	end

	-- loss condition
	if battle.health <= 0 then
		_update = _update_dialog
		_draw = _draw_dialog
		dialog.lines = dialog.active_npc.loss_lines
		dialog.battle = false
		dialog.curr = 1
	end
end

function do_shake()
	animations.shake.x = 16 - rnd(32)
	animations.shake.x = 16 - rnd(32)
	animations.shake.x *= animations.shake.strength
	animations.shake.x *= animations.shake.strength

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
	_x = flr(rnd(64)) + 90*cos(_angle / 360)
	_y = flr(rnd(32))+32  + 150*sin(_angle / 360)
	_xvel = -1 * battle.enemy_speed*cos(_angle/360)
	_yvel = -1 * battle.enemy_speed*sin(_angle/360)
	add(battle.enemies, {x = _x, y = _y, v = {x = _xvel, y = _yvel}, ttl = battle.enemy_ttl, w = 8, h = 8})
end

function move_player()
	animations.p.dir = 0
	if btn(⬅️) then
		p.x -= 1
		animations.p.dir = 1
		if chk_npc_coll(0) then
			p.x += 1
		end
	elseif btn(➡️) then
		p.x += 1
		animations.p.dir = 2
				if chk_npc_coll(0) then
			p.x -= 1
		end
	end
	if btn(⬆️) then
		p.y -= 1
		animations.p.dir = 3
		if chk_npc_coll(0) then
			p.y += 1
		end
	elseif btn(⬇️) then
		p.y += 1
		animations.p.dir = 4
		if chk_npc_coll(0) then
			p.y -= 1
		end
	end
end

function chk_dialog()
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

function update_animations()
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
-->8
-- draw functions

function _draw_title()
	cls(0)
	local line1 = {70, 71, 72, 92, 73, 74, 75, 76, 72, 77, 86}
	local line2 = {87, 88, 89, 92, 90, 74, 91, 72}
	local wx = 8
	local wy = 24
	for l in all(line1) do
		spr(l, wx, wy, 1, 1)
		wx += 8
	end

	wy += 10
	wx = 26

	for l in all(line2) do
		spr(l, wx, wy, 1, 1)
		wx += 8
	end

	print("press 🅾️ to begin", 30, 64)
	print ("◆ggj 2021◆", 40, 103)
	print("joshua cepeda, erin markel,", 10, 111)
	print("luke reifenberg, tanner waltz,", 5, 117)
	print("and spencer wells ♥", 27, 123)
end



function _draw_intro()
	cls(5)
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
 map(11, 8, 64, 64, 3, 3)
 -- draw player
 draw_player()

	-- draw npcs
	draw_npcs()
end

function _draw_dialog()
	-- draw the background
	_draw_walk()

	-- draw the dialog box
	rectfill(p.x-60, p.y-60, p.x+64, p.y-32, 0)
	rect(p.x-60, p.y-60, p.x+64, p.y-32, 7)
	-- draw the text
	print(dialog.lines[dialog.curr], p.x-56, p.y-56)
end

function _draw_battle()
	-- camera(animations.shake.x, animations.shake.y)
	cls(1)

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
		spr(170, h*16-16, 110, 2, 2)
	end
end

function draw_player()
	-- draw player
	if animations.p.dir == 0 then
		spr(128, p.x, p.y, 2, 4)
	elseif animations.p.dir == 1 then
		if animations.p.active then
			spr(130, p.x, p.y, 2, 4, true, false)
		else
			spr(132, p.x, p.y, 2, 4, true, false)
		end
	elseif animations.p.dir == 2 then
		if animations.p.active then
			spr(130, p.x, p.y, 2, 4, false, false)
		else
			spr(132, p.x, p.y, 2, 4, false, false)
		end
	elseif animations.p.dir == 3 then
		if animations.p.active then
			spr(136, p.x, p.y, 2, 4, false, false)
		else
			spr(136, p.x, p.y, 2, 4, true, false)
		end
	elseif animations.p.dir == 4 then
		if animations.p.active then
			spr(134, p.x, p.y, 2, 4, true, false)
		else
			spr(134, p.x, p.y, 2, 4, false, false)
		end
	end

end

function draw_npcs()
	for npc in all(npcs) do
		spr(npc.sprite, npc.x, npc.y, 2, 4)
		if npc.y <= p.y then
		 -- redraw player if they should be in front
			draw_player()
		end
		if npc.active then
			if animations.bob.active then
				_offset = -1
			else
				_offset = 0
			end
			print("🅾️", npc.x+4, npc.y-10+_offset, 7)
		end
	end
end
-->8
-- helper functions
function dist(a_x, a_y, b_x, b_y)
	return sqrt((a_x-b_x)^2 + (a_y-b_y)^2)
end

function chk_npc_coll(rad)
	local i = 1
	for npc in all(npcs) do
	if p.x-rad <= npc.x+npc.width and
		   p.x + p.width >= npc.x-rad and
		   p.y == npc.y then
		   return i
	 end
	i+= 1
	end
	return nil
end



__gfx__
bbbbbee8888bbbbbbbbbb666666bbbbb7666666666666666bbbb4444bbbbbbbbbbbbbbbb4444bbbb7777ffffffffffff11111111111111111111111111111111
bbbee77777788bbbbb767666666666bb65b75b5bb7b57b75bbb455552bbbbbbbbbbbbbb455554bbb7fff4444444444441cccccccccccccccccccccccccccccc1
bbf77888888778bbb6bbbbbbbbbbbb6b5b5b65bbbb65b6b6bb45555512bbbbbbbbbbbb45555114bb7f444444444444441c600606006406000600600060064401
be7888888888778bb6bb66666666bb6b5b5bb5bbbb5bb5b5bb455551122bbbbbbbbbb445551114bb7444444f5f5444441c006060064460066006006600604601
be7888888888878bb66662ee222f666b5b5bb5bbbb5bb5b5bb455551112bbbbbbbbbb455551114bbf444f54f5f54f4441c060000604600600060060006006401
e78888888888887866582222222ff5665b5bb5bbbb5bb5b5bb4555111122bbbbbbbb4455511114bbf444f54f5f5444441c600606006406000600600060064401
e787777777777878b6668222222ef66b5b5bb5bbbb5bb5b5bb44551112b2bbbbbbbb4b45111142bbf444f54f5f5445441c006060064460006006000600604401
e787777777777878b75666666666565b5b5bb5bbbb5bb5b5bb4b45bbb2bb2bbbbbb4bb4bbb14b2bbf454f54f4f4445441c555555555555555555555555555551
e787777777777878b76666555555555b5b5bb5bbbb5bb5b5bbb4444551112bbbbbb4555514442bbbf454f44f5f54444411111111111111111111111111111111
8787777777777878b76566656555655b5b5bb5bbbb5bb5b5bbbb454111112bbbbbb455111412bbbbf45ff54f5f5445441cccccccccccccccccccc1ccccccccc1
8788888888888878b76565656665655b5756656bb6576565bbbb414111112bbbbbb451111412bbbbf454f54f5f5445441c06060000440000000001c006004401
b87888888888878bb76565656565555b5555555555555555bbbb4444222222bbbb4444444442bbbbf454f54f5f5445441c60000000440000000001c060004461
b87788888888872bb76565556565655b5b5bb5b55b5bb5b5bbbb4bb44bbbb2bbbb4bbbb42bb2bbbbf454f54f5f5445441c006ff60069e600000601c60009e601
bb877888888772bbb76565666565555b57b56b7bb7b57b75bbbb4b2bb4bbbb2bb4bbbb4bb2b2bbbbf454f54f5f5445441c06dfd6dd696006406401c000996401
bbb8877777722bbbb76566656565655b5b6bb6b66b6bb6b6bbb402bbbb4bbbb24bbbb4bbbb2b2bbbf454f54f5f4445441c60dd6d96940064464461c00996dd01
bbbbb888882bbbbbb76666555555555b5555555555555555bbb402bbbb4bbbb24bbbb4bbbb2b2bbbf454f54f544476441c006dd699640644644601c0996e8ed1
bbbbbb6555bbbbbbbbbbb7777666666666666666666bbbbbbbbbbbbbbbbbbbbbbbbbbb8ee8bbbbbbf454f54f545466441c06fe6900640646446221c9968999d1
bbbbbbb55bbbbbbbbb777755555555555555555555666bbbbbbbbbbbbbbbbbbbbbbbb82288ebbbbbf454f54f5f5445441c6ee6eee6996444462221c968899dd1
bbbbbbbb5bbbbbbbb7655b5b55b5b55b5b55b5b55b5555bbbbbbbbbbbbbbbbbbbbbbbe8d888bbbbbf454f54f5f5445441cf622e66f869962622621c60d998dd1
bbbbbbbb5bbbbbbbb76bb5b5bb5b5bb5b5bb5b5bb5b5b5bbbbbbb4444444f4bbbbbbbbb22bbbbbbbf454f54f5f5445441c62226822869969226f21c446dd6dd1
bbbbbbbb5bbbbbbbbb6bb555bb555bb555bb555bb555b5bbbbbbbf111111f4bbbb777772266666bbf454444f545445441c2266888888969926fff1c46dd64dd1
bbbbbbbb5bbbbbbbbb677656556565565655656556565666bbbb41711771f54b7777776666666666f454454f545445441c268886668869996fff51c6dd644641
bbbbbbbb5bbbbbbbbb6756555555555555555555555556b6bbbb41777711f54bb6666666665555bbf454454f545445441c28886828868969fff651cdd6046441
bbbbbbbb5bbbbbbbbb66b5b5bb5b5bb5b5bb5b5bb5b5b6bbbbbbf171711f454bbbbbbbbb5bbbbbbbf4544544545445441c55555555555555555551c555555551
bbbbbbbb5bbbbbbbbb665555555555555555555555b556bbbbbf11111116566bbbbbbbbb5bbbbbbbf45445445444454411111111111111111111111111111111
bbbbbbbb5bbbbbbbbb67666666666666666666666666666bbbbf177171f4654bbbbbbbbb5bbbbbbbf4544544544445441cccccccccccccc1ccccc1ccccccccc1
bbbbbbbb5bbbbbbbbb56b77777777777777777777777766bbbbf17171145554bbbbbbbbb5bbbbbbbf4544544545445441cddddddddddddc1cdddc1cdddddddc1
bbbbbbbb5bbbbbbbbb5bb6bbbbbbbbbbbbbbbbbbbb55b66bbbf111111f455554bbbbbbb55bbbbbbbf4544544545445441cd55555555555c1cd55c1cd555555c1
bbbbbbbb5bbbbbbbbb5bb6bbbbbbbbbbbbbbbbbbbbb5bb6bbb41717114555554bbbbbb5555bbbbbbf4544544545445441cd55555555555c1cd55c1cd555555c1
bbbbbbbb5bbbbbbbbb5bb6bbbbbbbbbbbbbbbbbbbbb5bb6bb4111711f4b55554bbbbb5555555bbbbf4444444444444441cd55555555555c1cd55c1cd555555c1
bbbbbbb655bbbbbbbb5bb6bbbbbbbbbbbbbbbbbbbbb5bb6bb4444444fbbbbb54b5b555bbbbb555b5f4444444444444441cccccccccccccc1ccccc1ccccccccc1
bbbbbb65555bbbbbbb55b66bbbbbbbbbbbbbbbbbbbb55b664bbbbbbfbbbbbbb4bb55bbbbbbbbb550f55555555555555511111111111111111111111111111111
bbbbbbb444bbbbbbbbbbbbbbbbbbbbbbbbbbbb4444bbbbbb00000070070000000000000000000000000000000000000000000000000000003361153333356313
bbbbbb4fff4bbbbbbbbbbbbbbbbbbbbbbbbbb4fff4bbbbbb00777700070000000000000000770000000000000000000000770000000000003333333333333313
bbbbbbfffffbbbbbbbbbbbbbbbbbbbbbbbbbb4ffff4bbbbb07007000077700000077000007770000000770000077000007007000000777006666653533666631
bbbbbbfffffbbbbbbbbbbbbbbbbbbbbbbbbbb4ffff4bbbbb00007000070070000700700000700000007707700700700007007000007000003355633336656333
bbbbbbfffffbbbbbbbbbbbbbbbbbbbbbbbbb4bffff44bbbb00007000070070000777000000700000007077000700700007007000000770003331133665656333
bbbbbbbfffbbbbbbbbbbbbbbbbbbbbbbbbb4b666ffb4bbbb00007000070070000700000007770000007007000700700000777700000007003311533655336333
bbbbbb7bfb7bbbbbbbbbbbbbbbbbbbbbbbb46b66fbb4bbbb00770000070070000077770007707770000770000700770007007000007770703311533333531363
bbbbb17fff71bbbbbbbbbbbbbbbb777bbbbbc666fcccbbbb00000000000000000000000000000000000000000000000000770000000000003311533333331163
bbbb7717f7177bbbbbbbbbbbbbb77777bbbbccfcccccbbbb00000000000000000000000000000000000000000000000000000000000000003311333366335163
bbb77717717777bbbbbbbbbbbb777ff7bbbbcffcccbfbbbb00000000007000700000000007007000070007000000000000000000000000003313133311135113
bbbff717717bffbbbbbbbbbbbb77fffbbbbbffccccbfbbbb00070000077000700077000007007000770007000770700000000000000000003333333316633113
bbffb771717bbfbbbbbbbbbbbbb7ffffbbbffcccccbfbbbb00777000007000700700700007007000070007707007070000000000000000003333333336111533
bbfbb771717bbfbbbbbbbbbbbbb77777bbbbbbcccbfbbbbb00070000007070700700700007007000077777007007070000000000000000001313133336633331
bbfbbb71717bbfbbbbbbbbbbbee77e77bbbbbbcccffbbbbb00070000007070700700700000777700070007007007070000000000000000001311333335633311
bbfbbb71717bbfbbbbbbbbbeeeeeeee7bbbbbbcccfbbbbbb00707700000707000077070007007000070007007007077000000000000000006331333333333333
bbfbbb71717bbfbbbbbbbbbeeeeeeeb7bbbbbbccbfbbbbbb00000000000000000000000000770000000000000000000000000000000000006661153333356313
bbbbbb44444bbbbbbbbbbbeeeeeeeeb7bbbbb44444bbbbbb5555555566666666444444443333333355555555555a555555575555555a55555555555555555555
bbbbbb55555bbbbbbbbbbbeeeeebeeebbbbbcccccccbbbbb55555555666666664444444433333333555555555555555555555555555555555555555555555555
bbbbbb55555bbbbbbbbbbbeeeeebbbeebbbbbccccccbbbbb5555555566666666444444443333333355555555555a55555557555555a555555555555555555555
bbbbbb55555bbbbbbbbbbbeeeeebbbbebbbbbccccccbbbbb75757575555555554444444433333333555555555555555555555555a55555555555555555555555
bbbbbb55555bbbbbbbbbbbeeeeebbbbebbbbbcccccccbbbb5555555555555555444444443333333355555555555a555555575555555555556665556655555566
bbbbb55bb55bbbbbbbbbbbeeeeebbb4fbbbbccccccccbbbb55555555666666664444444433333333555555555555555555555555555555556666666666656666
bbbbb55bb55bbbbbbbbbbee2eeebb4b4bbbbccccccccbbbb5555555566666666444444443333333355555555555a555555575555555555556666666666666655
bbbbb55bbb55bbbbbbbbe22222ebbbb4bbbccccccccccbbb55555555666666664444444433333333555555555555555555555555555555556666666556666656
bbbbb55bbb55bbbbbbbbb222222bbbb4bbccccccccccccbb66655666666666666665566633333333555555554544444444444444333333336666660655666666
bbbbb55bbb55bbbbbbbbb22b222bbbb4bcccccccccccbbbb666556666666666666555666333333d3555555554444554445544444332333336660666666566666
bbbb555bbb55bbbbbbbbb22bb22bbbb4cccbfbbbbbfbbbbb66655666666666665555566633333d3d555555554444444445444544323233336006666666666006
bbbb555bbb55bbbbbbbbb22bb22bbbb4bbbbfbbbbbfbbbbb6665566666666666555556663d333333a5a5a5a54454444444444544333333236666555666666660
bbbb555bbb55bbbbbbbbb22bb222bbb4bbbbfbbbbbfbbbbb666556666666666655556666d3d33333555555554544444444544444333332326665555666655566
bbbb555bbb55bbbbbbbb22bbb222bbb4bbbbfbbbbbfbbbbb6665566666666666666666663333d333555555555444444544454444333233335555555555555555
bbb4444bbb444bbbbbbb55bbb555bbb4bbbbfbbbbbfbbbbb666556666666666666666666333d3d33555555554444455544454455332323335555555555555555
bb44444bbb44444bbbb555bbb55555b4bbbbdbbbbbdbbbbb66655666666666666666666633333333555555554544554444444444333333335555555555555555
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbbbbbb121211bbbbbbbbbbbbb499b944b
bbbbbb00000bbbbbbbbbbb00000bbbbbbbbbbbbbbbbbbbbbbbbbbb00000bbbbbbbbbbb00000bbbbbbbbbbbbb0099900bbbbb21212112bbbb7bbbe8b8849b94bb
bbbbb0000000bbbbbbbbb0000000bbbbbbbbbb00000bbbbbbbbbb0000000bbbbbbbbb0000000bbbbbbbbbbb00999990bbbbbeeeeeee2bbbbe7b7e8b88bbabbbb
bbbbb0fffff0bbbbbbbbb000ffffbbbbbbbbb0000000bbbbbbbbb0fffff0bbbbbbbbb0000000bbbbbbbbbb0099999990bbbbbeeeee2bbbbbeebeebabb49144bb
bbbbb0fffff0bbbbbbbbb00fffffbbbbbbbbb000ffffbbbbbbbbb0fffff0bbbbbbbbb0000000bbbbbbbbb009aaaa9990bbbbbeeeee2bbbbbbbab8861c491c14b
bbbbb00fff00bbbbbbbbbb00ffffbbbbbbbbb00fffffbbbbbbbbb00fff00bbbbbbbbb0000000bbbbbbbb00aaa4449940bbbbeeeeeee2bbbbee6ee86c1c0c1cbb
bbbbbbbbfbbbbbbbbbbbbbbbfbbbbbbbbbbbbb00ffffbbbbbbbbbbbbfbbbbbbbbbbbbbbb0bbbbbbbbbb0099999999400bbb77eeeeeee2bbb2e6e2b6bcc1ccbbb
bbbbbbb8f8bbbbbbbbbbbbb8f8bbbbbbbbbbbbbbfbbbbbbbbbbbbbb8f8bbbbbbbbbbbbb888bbbbbbbb00aaaa9999400bbbe7eeeeeeee22bbeb66eb6bbba1bbbb
bbbbb888f88bbbbbbbbbbb88f8bbbbbbbbbbbbb8f8bbbbbbbbbbb888f88bbbbbbbbbb888888bbbbbb00aa444999400bbbbeeeeeeeeee22bbbbb66b66cc1ccbbb
bbbb88888888bbbbbbbbbb8888bbbbbbbbbbbb88f88bbbbbbbbb88888888bbbbbbbb88888888bbbb0099999999400bbbbbeeeeeeeee222bbbbbb6bbc1c1c1cbb
bbbbfb8888bfbbbbbbbbbb8f88bbbbbbbbbbbbf888ebbbbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb0aaaaa999400bbbbbbbeeeeeeee22bbbbbbb66b1c61bc1bb
bbbbfb8888bfbbbbbbbbbb88f8bbbbbbbbbbbf8888ebbbbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb9aa44499400bbbbbbbbeeeeeeee22bbbbbbb66b6061bbbbb
bbbbfb8888bfbbbbbbbbbb88f8bbbbbbbbbbbf8888bebbbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb9999999400bbbbbbbbbbeeeeee22bbbbbbbbb6b6061bbbbb
bbbbfb8888bfbbbbbbbbbb888fbbbbbbbbbbfb8888bebbbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb999994400bbbbbbbbbbbeeeeee22bbbbbbbbb1b6011bbbbb
bbbbfb8888bfbbbbbbbbbe888fbbbbbbbbbfbb8888bbebbbbbbbfb8888bfbbbbbbbbfb8888bfbbbb0444400bbbbbbbbbbbbbbeeee22bbbbbbbbbb1b1011bbbbb
bbbbfb8888bfbbbbbbbbeb8888fbbbbbbbbfbb8888bbbebbbbbbfb8888bfbbbbbbbbfb8888bfbbbbb00000bbbbbbbbbbbbbbb222222bbbbbbbbbb1b1011bbbbb
bbbbfb000bbfbbbbbbbbbb0000bbbbbbbbbbbb0000bbbbbbbbbbf6000bbfbbbbbbbbfb000bbfbbbbbbbbbbbbbb000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb22222bbbbbbbbbbbb2222bbbbbbbbbbbb2222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbbb000099900bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbb22222bbbbbbbbbbbb2222bbbbbbbbbbbb2222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbb0009994a9940bbbb6bbbbbbbbbbbbbbbbbb6633bbb31b
bbbbb22222bbbbbbbbbbbb2222bbbbbbbbbbbb2222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbb099a994999490bbb6bbb6bbbb3bb3bbb7e66666bb311b
bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbb09aa994499490bbb6bb16bb1b3bb3bb3ee6666333311b
bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbb09a999940000bbb663b16bb133bb3bbb666633333311b
bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbb094499990bbbbb3b663113bb133b13bbb66633333331bb
bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbb09944900bbbbbb3b63311331113b13b3666333332d1bbb
bbbbb22222bbbbbbbbbbb22222bbbbbbbbbbb222222bbbbbbbbbb22222bbbbbbbbbbb22222bbbbbbbb09a9940bbbbbbb3b63311331113113b363333333221bbb
bbbbb2222fbbbbbbbbbbb22fbebbbbbbbbbbb22bbffbbbbbbbbbb2222fbbbbbbbbbbb2222fbbbbbbbb0aa9990bbbbbbb3163311333113133bb333333333311bb
bbbbb2bbbfbbbbbbbbbbb2fbbebbbbbbbbbbb2ebbbfbbbbbbbbbb2bbbfbbbbbbbbbbb2bbbfbbbbbbbb0aa9990bbbbbbb3133313333113133bb3333333333111b
bbbbbfbbbfbbbbbbbbbbbfbbbbebbbbbbbbbbebbbbfbbbbbbbbbbfbbbfbbbbbbbbbbbfbbbfbbbbbbbb0a44440bbbbbbb3133313333113133b333d2333331111b
bbbbbfbbbfbbbbbbbbbbfbbbbbebbbbbbbbbbebbbbfbbbbbbbbbbfbbbfbbbbbbbbbbbfbbbfbbbbbbbbb0999990bbbbbb3133311333313333b1112233333111bb
bbbbbfbbbfbbbbbbbbbbfbbbbbebbbbbbbbbebbbbbbfbbbbbbbbbfbbbfbbbbbbbbbbbfbbbfbbbbbbbbbb09994400bbbb3113113333311333bbb1133333111bbb
bbbbbfbbbfbbbbbbbbb4fbbbbbbe4bbbbbb4ebbbbbbf4bbbbbbbb4bbbfbbbbbbbbbbbfbbb4bbbbbbbbbbb0444990bbbb3313133333331333bbb4444444555bbb
bbbbb4bbb4bbbbbbbbbb4bbbbbb4bbbbbbbb4bbbbbb4bbbbbbbbbbbbb4bbbbbbbbbbb4bbbbbbbbbbbbbbbb00000bbbbb3313333333333333bb444444444555bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb66666665556666665555555533333333333333d300000000000000000000000000000000
bbbbbb00000bbbbbeb33bbbbbbbbbbbeb000000bbbbbbbbbb333bbbb66666665556666665555555533d333333333333300000000000000000000000000000000
bbbbb0000000bbbbe373bbccbbbbbbe700000000bb6b3bb1333333bb666666555666666655555555333d333333333d3300000000000000000000000000000000
bbbbb0000000bbbbe33999cccb22bbee0ffffff0b66333b1333333bb6666665555666666555555a533d333d333d3d33300000000000000000000000000000000
bbbbb0000000bbbb666979c7667288860f0ff0f0663333b13333333b66666665556666665555a5553333333d3333333300000000000000000000000000000000
bbbbb0000000bbbbbbbb99cccb2b878b0ffffff0663333b13333333b666666665566666655555555333d33d33d33333300000000000000000000000000000000
bbbbbbbb0bbbbbbbbbbbbbbccbbbb8bb0ffffff063333333333333bb6666666555666666555a55553333d3333333333300000000000000000000000000000000
bbbbbbb888bbbbbbbbbbbbbbbbbbbbbb00ffff0063333333333333bb666666655666666655555555333d33333333333300000000000000000000000000000000
bbbbb888888bbbbbbbbbb33666333333333bbbbb3333bd333b33331b666666655566666655555555333333d333d3333300000000000000000000000000000000
bbbb88888888bbbbbbbb336666333333333bbbbb3333bd533b55351b66666665556666665555555533d33d33333d333300000000000000000000000000000000
bbbbfb8888bfbbbbbb33666633333333333bbbbb3333b55bb555331b6666666655666666555555553d3333d33333333300000000000000000000000000000000
bbbbfb8888bfbbbb33366663333333333333bbbbb131b155b555331b6666666555666666a555555533d33333333d333300000000000000000000000000000000
bbbbfb8888bfbbbb33666633333333333333bbbbb135bb55b511311b666666655566666655a5555533333d3333333d3300000000000000000000000000000000
bbbbfb8888bfbbbb366633333333333333333bbbbb1d515555b131bb6666666556666666555555553333d333333333d300000000000000000000000000000000
bbbbfb8888bfbbbb366333333333333333333bbbbb11d55555bb31bb6666666556666666555a555533333d333333333300000000000000000000000000000000
bbbbfb8888bfbbbb333333333333333310111bbbbbbb1d555513355b666666655666666655555555333333333333333300000000000000000000000000000000
bbbbfb000bbfbbbb33333333333333331b11bbbbbbbbb155551331bb4444544445444454555a5555666666660000000000000000000000000000000000000000
bbbbb22222bbbbbb333334333bb331b31b11bbbbbbbbbb5555133bbb444454444544445455555555666666660000000000000000000000000000000000000000
bbbbb22222bbbbbbbb3334bbbb4411b11bbbbbbbbbbbbb5555535bbb44445444454445545555a555666666660000000000000000000000000000000000000000
bbbbb22222bbbbbbb333444bbb411b11bbbbbbbbbbbbbb55555bbbbb4445544455444544555555a5666555550000000000000000000000000000000000000000
bbbbb22222bbbbbbb33b4444b4111bbbbbbbbbbbbbbbbb55551bbbbb444544445444454455555555666555550000000000000000000000000000000000000000
bbbbb22222bbbbbbbbbbfff4441bbbbbbbbbbbbbbbbbbb55551bbbbb444544445444454455555555666555550000000000000000000000000000000000000000
bbbbb22222bbbbbbbbbbbff4441bbbbbbbbbbbbbbbbbbb55551bbbbb444544445444454455555555666555660000000000000000000000000000000000000000
bbbbb22222bbbbbbbbbbbff4441bbbbbbbbbbbbbbbbbbb55551bbbbb444544445444454455555555666556660000000000000000000000000000000000000000
bbbbb22222bbbbbbbbbbbff4441bbbbbbbbbbbbbbbbbbb55551bbbbb444544445444454466655666666666660000000000000000000000000000000000000000
bbbbb2222fbbbbbbbbbbbf44441bbbbbbbbbbbbbbbbbbb55551bbbbb444544445444454466655566666666660000000000000000000000000000000000000000
bbbbb2bbbfbbbbbbbbbbbf44441bbbbbbbbbbbbbbbbbbb55551bbbbb444544445444454466655555666666660000000000000000000000000000000000000000
bbbbbfbbbfbbbbbbbbbbbf444441bbbbbbbbbbbbbbbbbb55551bbbbb444544445444454466655555555566660000000000000000000000000000000000000000
bbbbbfbbbfbbbbbbbbbbbf4444411bbbbbbbbbbbbbbbbb555511bbbb444544445444454466665555555556660000000000000000000000000000000000000000
bbbbbfbbbfbbbbbbbbbbf4444441111bbbbbbbbbbbbbb5511111bbbb444554445544455466666666555556660000000000000000000000000000000000000000
bbbbb4bbbfbbbbbbbbbf444544444111bbbbbbbbbbbb515111111bbb444454444544445466666666665556660000000000000000000000000000000000000000
bbbbbbbbb4bbbbbbb4444544454444111bbbbbbbbbb55111115111bb444454444544445466666666665556660000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000006b6b6b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000006b6b6b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000006b6b6b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
