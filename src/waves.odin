package main

set_route :: proc(route: ^Path_Route, points: ..Vec2) {
	route.point_count = min(len(points), MAX_PATH_POINTS)
	for i := 0; i < route.point_count; i += 1 { route.points[i] = points[i] }
}

init_levels :: proc(g: ^Game) {
	g.level_count = 3

	grass := &g.levels[0]
	grass.name = "Grasslands"
	grass.starting_gold, grass.starting_lives = START_GOLD, START_LIVES
	grass.route_count = 1
	set_route(&grass.routes[0],vec2(20,300),vec2(180,300),vec2(180,100),vec2(420,100),vec2(420,500),vec2(700,500),vec2(700,220),vec2(940,220))
	grass.waves[0] = Wave_Def{.Grunt,10,0.65,1.0,1.0}
	grass.waves[1] = Wave_Def{.Grunt,15,0.55,1.1,1.0}
	grass.waves[2] = Wave_Def{.Runner,10,0.45,1.0,1.0}
	grass.waves[3] = Wave_Def{.Grunt,22,0.45,1.25,1.0}
	grass.waves[4] = Wave_Def{.Brute,6,0.95,1.0,1.0}
	grass.waves[5] = Wave_Def{.Runner,18,0.38,1.15,1.0}
	grass.waves[6] = Wave_Def{.Grunt,28,0.35,1.45,1.0}
	grass.waves[7] = Wave_Def{.Brute,10,0.75,1.3,1.0}
	grass.waves[8] = Wave_Def{.Runner,24,0.32,1.45,1.0}
	grass.waves[9] = Wave_Def{.Boss,1,1.0,1.0,1.0}
	grass.waves[10] = Wave_Def{.Armored,7,0.90,1.0,1.0}
	grass.waves[11] = Wave_Def{.Grunt,34,0.28,1.65,1.0}
	grass.waves[12] = Wave_Def{.Runner,28,0.27,1.65,1.05}
	grass.waves[13] = Wave_Def{.Armored,13,0.72,1.35,1.0}
	grass.waves[14] = Wave_Def{.Boss,1,1.0,2.25,1.08}
	grass.wave_count = 15

	forest := &g.levels[1]
	forest.name = "Forest Pass"
	forest.starting_gold, forest.starting_lives = 220, START_LIVES
	forest.route_count = 2
	set_route(&forest.routes[0],vec2(20,140),vec2(220,140),vec2(220,300),vec2(500,300),vec2(500,100),vec2(740,100),vec2(740,340),vec2(940,340))
	set_route(&forest.routes[1],vec2(20,580),vec2(220,580),vec2(220,420),vec2(500,420),vec2(500,620),vec2(740,620),vec2(740,460),vec2(940,460))
	forest.waves[0] = Wave_Def{.Grunt,14,0.62,1.0,1.0}
	forest.waves[1] = Wave_Def{.Runner,12,0.52,1.0,1.0}
	forest.waves[2] = Wave_Def{.Grunt,20,0.48,1.15,1.0}
	forest.waves[3] = Wave_Def{.Brute,8,0.90,1.0,1.0}
	forest.waves[4] = Wave_Def{.Runner,22,0.38,1.15,1.0}
	forest.waves[5] = Wave_Def{.Armored,7,0.86,1.0,1.0}
	forest.waves[6] = Wave_Def{.Grunt,30,0.34,1.4,1.0}
	forest.waves[7] = Wave_Def{.Brute,12,0.70,1.2,1.0}
	forest.waves[8] = Wave_Def{.Runner,30,0.30,1.35,1.05}
	forest.waves[9] = Wave_Def{.Boss,1,1.0,1.3,1.0}
	forest.waves[10] = Wave_Def{.Armored,12,0.70,1.2,1.0}
	forest.waves[11] = Wave_Def{.Grunt,38,0.27,1.65,1.0}
	forest.waves[12] = Wave_Def{.Runner,36,0.25,1.55,1.08}
	forest.waves[13] = Wave_Def{.Brute,18,0.58,1.45,1.0}
	forest.waves[14] = Wave_Def{.Armored,17,0.60,1.45,1.0}
	forest.waves[15] = Wave_Def{.Grunt,46,0.23,1.95,1.05}
	forest.waves[16] = Wave_Def{.Runner,44,0.22,1.85,1.12}
	forest.waves[17] = Wave_Def{.Brute,22,0.52,1.75,1.0}
	forest.waves[18] = Wave_Def{.Armored,22,0.52,1.75,1.02}
	forest.waves[19] = Wave_Def{.Boss,2,1.20,2.3,1.08}
	forest.wave_count = 20

	frozen := &g.levels[2]
	frozen.name = "Frozen Road"
	frozen.starting_gold, frozen.starting_lives = 230, START_LIVES
	frozen.route_count = 1
	set_route(&frozen.routes[0],vec2(20,660),vec2(140,660),vec2(140,420),vec2(340,420),vec2(340,180),vec2(580,180),vec2(580,540),vec2(820,540),vec2(820,260),vec2(940,260))
	frozen.waves[0] = Wave_Def{.Runner,14,0.48,1.0,1.08}
	frozen.waves[1] = Wave_Def{.Grunt,18,0.48,1.1,1.08}
	frozen.waves[2] = Wave_Def{.Runner,22,0.34,1.15,1.12}
	frozen.waves[3] = Wave_Def{.Brute,8,0.82,1.0,1.08}
	frozen.waves[4] = Wave_Def{.Runner,30,0.28,1.3,1.15}
	frozen.waves[5] = Wave_Def{.Armored,8,0.78,1.0,1.08}
	frozen.waves[6] = Wave_Def{.Grunt,34,0.29,1.5,1.12}
	frozen.waves[7] = Wave_Def{.Runner,38,0.24,1.5,1.18}
	frozen.waves[8] = Wave_Def{.Brute,14,0.62,1.3,1.10}
	frozen.waves[9] = Wave_Def{.Boss,1,1.0,1.5,1.12}
	frozen.waves[10] = Wave_Def{.Runner,46,0.21,1.7,1.20}
	frozen.waves[11] = Wave_Def{.Armored,14,0.61,1.3,1.10}
	frozen.waves[12] = Wave_Def{.Grunt,44,0.24,1.85,1.15}
	frozen.waves[13] = Wave_Def{.Runner,52,0.19,1.9,1.23}
	frozen.waves[14] = Wave_Def{.Brute,20,0.52,1.65,1.12}
	frozen.waves[15] = Wave_Def{.Armored,20,0.50,1.6,1.12}
	frozen.waves[16] = Wave_Def{.Runner,60,0.17,2.15,1.25}
	frozen.waves[17] = Wave_Def{.Grunt,56,0.20,2.2,1.18}
	frozen.waves[18] = Wave_Def{.Brute,26,0.44,2.0,1.15}
	frozen.waves[19] = Wave_Def{.Boss,2,1.10,2.7,1.18}
	frozen.wave_count = 20
}

load_level :: proc(g: ^Game, level_index: int) {
	level := &g.levels[level_index]
	g.mode = .Playing
	g.restart_confirmation = false
	g.gold, g.lives = level.starting_gold, level.starting_lives
	g.enemies_defeated, g.enemies_leaked = 0, 0
	g.selected_tower_type, g.selected_tower_index = .None, -1
	g.enemies = {}
	g.enemy_count = 0
	g.towers = {}
	g.tower_count = 0
	g.projectiles = {}
	g.effects = {}
	g.waves = level.waves
	g.wave_count = level.wave_count
	g.current_wave = 0
	g.wave_state = .Waiting
	g.wave_spawned_count = 0
	g.wave_spawn_timer = 0
	g.game_speed = 1
	init_map(g)
}

try_start_wave :: proc(g: ^Game) {
	if g.wave_state != .Waiting || g.current_wave >= g.wave_count { return }
	g.wave_state = .Spawning
	g.wave_spawned_count = 0
	g.wave_spawn_timer = 0
}

update_wave :: proc(g: ^Game, dt: f32) {
	if g.wave_state == .Spawning {
		wave := g.waves[g.current_wave]
		g.wave_spawn_timer -= dt
		if g.wave_spawn_timer <= 0 && g.wave_spawned_count < wave.count {
			spawn_enemy(g,wave)
			g.wave_spawned_count += 1
			g.wave_spawn_timer = wave.spawn_interval
		}
		if g.wave_spawned_count >= wave.count { g.wave_state = .Clearing }
	}
	if g.wave_state == .Clearing && g.enemy_count == 0 {
		g.current_wave += 1
		if g.current_wave >= g.wave_count { g.wave_state = .Finished
		} else { g.wave_state = .Waiting; g.gold += 20 }
	}
}

spawn_enemy :: proc(g: ^Game, wave: Wave_Def) {
	if g.enemy_count >= MAX_ENEMIES { return }
	level := &g.levels[g.current_level]
	route_index := g.wave_spawned_count % level.route_count
	route := &level.routes[route_index]
	def := get_enemy_def(wave.enemy_type)
	e := Enemy{}
	e.kind = wave.enemy_type
	e.route_index = route_index
	e.pos = route.points[0]
	e.path_index = 1
	e.max_hp = def.max_hp*wave.hp_mult
	e.hp = e.max_hp
	e.speed = def.speed*wave.speed_mult
	e.gold_reward, e.lives_damage = def.gold_reward, def.lives_damage
	e.alive = true
	g.enemies[g.enemy_count] = e
	g.enemy_count += 1
}
